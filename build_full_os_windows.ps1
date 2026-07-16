#Requires -Version 5.1
<#
.SYNOPSIS
    Build FULL Aero OS bootable ISO for Intel/AMD PCs and laptops (amd64).

.DESCRIPTION
    Downloads FreeBSD RELEASE amd64 disc1 (~1.2 GB), injects the complete Aero
    desktop (sounds, tools, overlay), writes AeroOS-*-amd64.iso (~1.2 GB+).

.EXAMPLE
    .\build_full_os_windows.ps1
    .\build_full_os_windows.ps1 -Publish
#>
param(
    [switch]$Publish,
    [switch]$SkipDownload
)

$ErrorActionPreference = "Stop"
$ProjectRoot = $PSScriptRoot
$Version = "1.0.1"
$Codename = "Stratus"
$Arch = "amd64"
$FreeBSDVer = "14.3"

$CacheDir = Join-Path $ProjectRoot ".cache\freebsd"
$OutDir = Join-Path $ProjectRoot "out"
$OverlayDir = Join-Path $ProjectRoot "build-workspace\full-os-overlay"
$IsoName = "AeroOS-$Version-$Codename.iso"
$IsoPath = Join-Path $OutDir $IsoName
$FreeBsdIso = Join-Path $CacheDir "FreeBSD-$FreeBSDVer-RELEASE-amd64-disc1.iso"
$FreeBsdUrl = "https://download.freebsd.org/releases/ISO-IMAGES/$FreeBSDVer/FreeBSD-$FreeBSDVer-RELEASE-amd64-disc1.iso"

Write-Host "Aero OS - FULL amd64 ISO (entire OS for PCs/laptops)" -ForegroundColor Cyan
Write-Host "  FreeBSD $FreeBSDVer disc1 + Aero desktop + chill sounds" -ForegroundColor DarkGray
Write-Host ""

function New-Dir([string]$path) {
    New-Item -ItemType Directory -Force -Path $path | Out-Null
}

function Copy-IfExists([string]$src, [string]$dst) {
    if (-not (Test-Path $src)) { return $false }
    $parent = Split-Path $dst -Parent
    if ($parent) { New-Dir $parent }
    Copy-Item -Path $src -Destination $dst -Force -Recurse
    return $true
}

$soundsDir = Join-Path $ProjectRoot "assets\sounds"
if (@(Get-ChildItem -Path $soundsDir -Filter "*.wav" -ErrorAction SilentlyContinue).Count -lt 11) {
    Write-Host "==> Generating chill sound scheme" -ForegroundColor Green
    $gen = Join-Path $ProjectRoot "tools\generate_sounds.py"
    if (Get-Command py -ErrorAction SilentlyContinue) { & py -3 $gen } else { & python $gen }
}

New-Dir $CacheDir
New-Dir $OutDir

if (-not $SkipDownload) {
    if ((Test-Path $FreeBsdIso) -and ((Get-Item $FreeBsdIso).Length -gt 500MB)) {
        Write-Host "==> Cached FreeBSD disc1 ($([math]::Round((Get-Item $FreeBsdIso).Length/1MB)) MB)" -ForegroundColor DarkGray
    } else {
        Write-Host "==> Downloading FreeBSD $FreeBSDVer amd64 disc1 (~1.2 GB)" -ForegroundColor Green
        $partial = "$FreeBsdIso.partial"
        try {
            Start-BitsTransfer -Source $FreeBsdUrl -Destination $partial -DisplayName "FreeBSD-disc1"
        } catch {
            $wc = New-Object System.Net.WebClient
            $wc.DownloadFile($FreeBsdUrl, $partial)
        }
        if (-not (Test-Path $partial) -or ((Get-Item $partial).Length -lt 500MB)) {
            throw "FreeBSD ISO download failed."
        }
        Move-Item $partial $FreeBsdIso -Force
    }
}

Write-Host "==> Staging Aero overlay" -ForegroundColor Green
if (Test-Path $OverlayDir) { Remove-Item -Recurse -Force $OverlayDir }
New-Dir $OverlayDir
$share = Join-Path $OverlayDir "usr\local\share\aero"
New-Dir "$share\sounds"; New-Dir "$share\store"; New-Dir "$share\src"; New-Dir "$share\wallpapers"
New-Dir (Join-Path $OverlayDir "usr\local\bin")
New-Dir (Join-Path $OverlayDir "usr\local\sbin")
New-Dir (Join-Path $OverlayDir "usr\local\etc\bsdinstall\aero")
New-Dir (Join-Path $OverlayDir "etc\aero")
New-Dir (Join-Path $OverlayDir "boot")
New-Dir (Join-Path $OverlayDir "aero")

$Version | Set-Content (Join-Path $OverlayDir "etc\aero-version") -Encoding ascii
@"
Aero OS $Version $Codename
Architecture: $Arch
Foundation: FreeBSD $FreeBSDVer-RELEASE
Sounds: Aero Chill Glass
"@ | Set-Content (Join-Path $OverlayDir "etc\aero-release") -Encoding ascii

Copy-Item (Join-Path $soundsDir "*") (Join-Path $share "sounds") -Force
Copy-IfExists (Join-Path $ProjectRoot "style.css") (Join-Path $share "style.css") | Out-Null
Copy-IfExists (Join-Path $ProjectRoot "store\index.json") (Join-Path $share "store\index.json") | Out-Null
Copy-IfExists (Join-Path $ProjectRoot "config\repos.conf") (Join-Path $OverlayDir "etc\aero\repos.conf") | Out-Null
Copy-IfExists (Join-Path $ProjectRoot "releases\v1.0.1\aero-update-manifest.json") (Join-Path $OverlayDir "aero\aero-update-manifest.json") | Out-Null

foreach ($tool in @("aero", "aero-sound", "aero-notify", "aero-open", "aexes", "aero-fetch-icon")) {
    Copy-IfExists (Join-Path $ProjectRoot "tools\$tool") (Join-Path $OverlayDir "usr\local\bin\$tool") | Out-Null
}
foreach ($f in @("main.swift", "aero-settings.swift", "aero-lock.swift", "aero-firstboot.swift", "aero-store.swift", "aero-update-ui.swift")) {
    Copy-IfExists (Join-Path $ProjectRoot $f) (Join-Path $share "src\$f") | Out-Null
}
foreach ($name in @("aero-logo.png", "firstboot-logo.png", "start-button.png")) {
    Copy-IfExists (Join-Path $ProjectRoot "assets\$name") (Join-Path $share $name) | Out-Null
}
if (Test-Path (Join-Path $ProjectRoot "assets\aero-logo.png")) {
    Copy-Item (Join-Path $ProjectRoot "assets\aero-logo.png") (Join-Path $OverlayDir "boot\aero-splash.png") -Force
}
foreach ($wp in @("light.png", "dark.png", "night.png")) {
    Copy-IfExists (Join-Path $ProjectRoot "assets\wallpapers\$wp") (Join-Path $share "wallpapers\$wp") | Out-Null
}

$overlaySrc = Join-Path $ProjectRoot "overlay"
if (Test-Path $overlaySrc) {
    Get-ChildItem $overlaySrc -Recurse -File | ForEach-Object {
        $rel = $_.FullName.Substring($overlaySrc.Length).TrimStart("\", "/")
        $dest = Join-Path $OverlayDir $rel
        New-Dir (Split-Path $dest -Parent)
        Copy-Item $_.FullName $dest -Force
    }
}
Copy-IfExists (Join-Path $ProjectRoot "bsdinstall\installer.conf") (Join-Path $OverlayDir "usr\local\etc\bsdinstall\aero\installer.conf") | Out-Null
Copy-IfExists (Join-Path $ProjectRoot "bsdinstall\partition.conf") (Join-Path $OverlayDir "usr\local\etc\bsdinstall\aero\partition.conf") | Out-Null
Copy-IfExists (Join-Path $ProjectRoot "profile\packages.amd64") (Join-Path $OverlayDir "usr\local\etc\bsdinstall\aero\packages.amd64") | Out-Null
Copy-IfExists (Join-Path $ProjectRoot "overlay\usr\local\sbin\aero-install") (Join-Path $OverlayDir "usr\local\sbin\aero-install") | Out-Null

@"
Aero OS $Version $Codename - FULL amd64 install media
FreeBSD $FreeBSDVer-RELEASE + Aero desktop (chill sounds).
Rufus: GPT + UEFI + DD mode. 8 GB+ USB.
"@ | Set-Content (Join-Path $OverlayDir "AERO-README.TXT") -Encoding ascii

Write-Host "==> Ensuring pycdlib" -ForegroundColor Green
py -3 -m pip install pycdlib -q

Write-Host "==> Merging FreeBSD + Aero into bootable ISO" -ForegroundColor Green
& py -3 (Join-Path $ProjectRoot "tools\merge_freebsd_iso.py")
if ($LASTEXITCODE -ne 0) { throw "ISO merge failed" }

$sizeMb = [math]::Round((Get-Item $IsoPath).Length / 1MB, 1)
Write-Host ""
Write-Host "==> FULL Aero OS ISO ready" -ForegroundColor Green
Write-Host "  $IsoPath" -ForegroundColor Cyan
Write-Host "  Size : $sizeMb MB (was 1.1 MB overlay-only before)" -ForegroundColor White
Write-Host "  Arch : amd64 — normal Intel/AMD PCs and laptops" -ForegroundColor White
Write-Host "  Rufus: SELECT this ISO - GPT - UEFI - DD if asked" -ForegroundColor Green

if ($Publish) {
    $gh = "C:\Program Files\GitHub CLI\gh.exe"
    if (Test-Path $gh) {
        & $gh release upload "v$Version" $IsoPath "$IsoPath.sha256.txt" --repo tylerdel30-dev/aero-os --clobber
    }
}

exit 0
