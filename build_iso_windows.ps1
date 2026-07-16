#Requires -Version 5.1
param(
    [ValidateSet("aarch64", "arm64", "amd64")]
    [string]$Arch = "aarch64",
    [switch]$Publish
)

$ErrorActionPreference = "Stop"
$ProjectRoot = $PSScriptRoot
$Version = "1.0.1"
$Codename = "Stratus"
if ($Arch -eq "arm64") { $Arch = "aarch64" }

$OutDir = Join-Path $ProjectRoot "out"
$StageRoot = Join-Path $ProjectRoot "build-workspace\windows-iso\$Arch"
$IsoName = "AeroOS-$Version-$Codename-$Arch.iso"
$IsoPath = Join-Path $OutDir $IsoName

Write-Host "Aero OS - Windows ISO Builder (no Docker / no VM)" -ForegroundColor Cyan
Write-Host "  Version : $Version $Codename" -ForegroundColor DarkGray
Write-Host "  Arch    : $Arch" -ForegroundColor DarkGray
Write-Host ""

$soundsDir = Join-Path $ProjectRoot "assets\sounds"
$wavs = @(Get-ChildItem -Path $soundsDir -Filter "*.wav" -ErrorAction SilentlyContinue)
if ($wavs.Count -lt 11) {
    Write-Host "==> Generating chill sound scheme" -ForegroundColor Green
    $gen = Join-Path $ProjectRoot "tools\generate_sounds.py"
    if (Get-Command py -ErrorAction SilentlyContinue) { & py -3 $gen }
    elseif (Get-Command python -ErrorAction SilentlyContinue) { & python $gen }
    else { throw "Python required to generate sounds." }
}

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

if (-not ("AeroIsoWriter" -as [type])) {
    Add-Type -TypeDefinition @"
using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Runtime.InteropServices.ComTypes;

public static class AeroIsoWriter {
    public static void WriteStreamToFile(object comStreamObj, string path, long totalBytes) {
        IStream stream = (IStream)comStreamObj;
        byte[] buffer = new byte[1024 * 1024];
        IntPtr bytesReadPtr = Marshal.AllocHGlobal(4);
        try {
            using (FileStream fs = new FileStream(path, FileMode.Create, FileAccess.Write)) {
                long copied = 0;
                while (copied < totalBytes) {
                    int toRead = (int)Math.Min(buffer.Length, totalBytes - copied);
                    stream.Read(buffer, toRead, bytesReadPtr);
                    int got = Marshal.ReadInt32(bytesReadPtr);
                    if (got <= 0) break;
                    fs.Write(buffer, 0, got);
                    copied += got;
                }
            }
        } finally {
            Marshal.FreeHGlobal(bytesReadPtr);
        }
    }
}
"@
}

function Write-IsoImapi {
    param([string]$SourceFolder, [string]$IsoPath, [string]$VolumeName)

    Write-Host "==> Packing ISO with Windows IMAPI2" -ForegroundColor Green
    if (Test-Path $IsoPath) { Remove-Item $IsoPath -Force }
    New-Dir (Split-Path $IsoPath -Parent)

    $fsi = New-Object -ComObject IMAPI2FS.MsftFileSystemImage
    $fsi.FileSystemsToCreate = 3
    $vol = ($VolumeName -replace '[^A-Z0-9_]', '_').ToUpperInvariant()
    if ($vol.Length -gt 16) { $vol = $vol.Substring(0, 16) }
    if ([string]::IsNullOrWhiteSpace($vol)) { $vol = "AERO_OS" }
    $fsi.VolumeName = $vol
    $null = $fsi.Root.AddTree($SourceFolder, $false)
    $result = $fsi.CreateResultImage()
    $total = [int64]$result.TotalBlocks * [int64]$result.BlockSize
    $mb = [math]::Round($total / 1MB, 1)
    Write-Host "  writing $mb MB..." -ForegroundColor DarkGray
    [AeroIsoWriter]::WriteStreamToFile($result.ImageStream, $IsoPath, $total)

    if (-not (Test-Path $IsoPath) -or ((Get-Item $IsoPath).Length -lt 64KB)) {
        throw "ISO packing failed or produced an empty image."
    }
}

Write-Host "==> Staging ISO tree" -ForegroundColor Green
if (Test-Path $StageRoot) { Remove-Item -Recurse -Force $StageRoot }
New-Dir $StageRoot
New-Dir (Join-Path $StageRoot "etc")
New-Dir (Join-Path $StageRoot "etc\aero")
New-Dir (Join-Path $StageRoot "boot")
New-Dir (Join-Path $StageRoot "docs")

$stamp = [DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
@(
    "Aero OS $Version `"$Codename`"",
    "Architecture: $Arch",
    "Built: $stamp",
    "Host: Windows (native ISO pack - no Docker, no VM)",
    "Sounds: Aero Chill Glass"
) | Set-Content -Path (Join-Path $StageRoot "AERO-OS.TXT") -Encoding ascii

$Version | Set-Content -Path (Join-Path $StageRoot "etc\aero-version") -Encoding ascii
@(
    "Aero OS $Version `"$Codename`"",
    "Built: $stamp",
    "Foundation: FreeBSD 14.2-RELEASE ($Arch)",
    "Media: Windows-packed install payload ISO"
) | Set-Content -Path (Join-Path $StageRoot "etc\aero-release") -Encoding ascii

$share = Join-Path $StageRoot "usr\local\share\aero"
New-Dir $share
New-Dir (Join-Path $share "sounds")
New-Dir (Join-Path $share "store")
New-Dir (Join-Path $share "wallpapers")
New-Dir (Join-Path $share "src")
New-Dir (Join-Path $StageRoot "usr\local\bin")
New-Dir (Join-Path $StageRoot "usr\local\sbin")
New-Dir (Join-Path $StageRoot "usr\local\etc\rc.d")
New-Dir (Join-Path $StageRoot "usr\local\etc\bsdinstall\aero")

Copy-IfExists (Join-Path $ProjectRoot "style.css") (Join-Path $share "style.css") | Out-Null
Copy-IfExists (Join-Path $ProjectRoot "store\index.json") (Join-Path $share "store\index.json") | Out-Null
Copy-IfExists (Join-Path $ProjectRoot "config\repos.conf") (Join-Path $StageRoot "etc\aero\repos.conf") | Out-Null
Copy-IfExists (Join-Path $ProjectRoot "releases\v1.0.1\aero-update-manifest.json") (Join-Path $StageRoot "aero-update-manifest.json") | Out-Null

Copy-Item -Path (Join-Path $soundsDir "*") -Destination (Join-Path $share "sounds") -Force
$soundCount = @(Get-ChildItem (Join-Path $share "sounds\*.wav")).Count
Write-Host "  sounds: $soundCount wav files" -ForegroundColor DarkGray

foreach ($name in @("aero-logo.png", "firstboot-logo.png", "start-button.png")) {
    Copy-IfExists (Join-Path $ProjectRoot "assets\$name") (Join-Path $share $name) | Out-Null
}
if (Test-Path (Join-Path $ProjectRoot "assets\aero-logo.png")) {
    Copy-Item (Join-Path $ProjectRoot "assets\aero-logo.png") (Join-Path $StageRoot "boot\aero-splash.png") -Force
}
foreach ($wp in @("light.png", "dark.png", "night.png")) {
    Copy-IfExists (Join-Path $ProjectRoot "assets\wallpapers\$wp") (Join-Path $share "wallpapers\$wp") | Out-Null
}

$bin = Join-Path $StageRoot "usr\local\bin"
foreach ($tool in @("aero", "aero-sound", "aero-notify", "aero-open", "aexes", "aero-fetch-icon")) {
    Copy-IfExists (Join-Path $ProjectRoot "tools\$tool") (Join-Path $bin $tool) | Out-Null
}
Copy-IfExists (Join-Path $ProjectRoot "overlay\usr\local\sbin\aero-install") (Join-Path $StageRoot "usr\local\sbin\aero-install") | Out-Null

$overlay = Join-Path $ProjectRoot "overlay"
if (Test-Path $overlay) {
    Get-ChildItem -Path $overlay -Recurse -File | ForEach-Object {
        $rel = $_.FullName.Substring($overlay.Length).TrimStart("\", "/")
        $dest = Join-Path $StageRoot $rel
        New-Dir (Split-Path $dest -Parent)
        Copy-Item $_.FullName $dest -Force
    }
}

Copy-IfExists (Join-Path $ProjectRoot "bsdinstall\installer.conf") (Join-Path $StageRoot "usr\local\etc\bsdinstall\aero\installer.conf") | Out-Null
Copy-IfExists (Join-Path $ProjectRoot "bsdinstall\partition.conf") (Join-Path $StageRoot "usr\local\etc\bsdinstall\aero\partition.conf") | Out-Null
Copy-IfExists (Join-Path $ProjectRoot "profile\packages.amd64") (Join-Path $StageRoot "usr\local\etc\bsdinstall\aero\packages.$Arch") | Out-Null

$src = Join-Path $share "src"
foreach ($f in @("main.swift", "aero-settings.swift", "aero-lock.swift", "aero-firstboot.swift", "aero-store.swift", "aero-update-ui.swift")) {
    Copy-IfExists (Join-Path $ProjectRoot $f) (Join-Path $src $f) | Out-Null
}

@(
    "Aero OS $Version ($Arch) - Windows-packed ISO",
    "=============================================",
    "",
    "This is a real ISO image (not a VM disk). It contains the Aero desktop",
    "overlay, chill glass sound scheme, App Store index, and install helpers.",
    "",
    "Architecture: $Arch",
    "",
    "On a FreeBSD $Arch system:",
    "  1. Mount this ISO",
    "  2. Copy /usr/local and /etc/aero* onto the root filesystem",
    "  3. Enable: sysrc labwc_enable=YES pipewire_enable=YES",
    "  4. Reboot into Aero shell",
    "",
    "Write with Rufus (Windows):",
    "  GPT + UEFI - DD Image mode if offered - 8 GB+ USB",
    "",
    "Sounds:",
    "  /usr/local/share/aero/sounds/",
    "  aero-sound startup"
) | Set-Content -Path (Join-Path $StageRoot "docs\README.txt") -Encoding ascii
Copy-Item (Join-Path $StageRoot "docs\README.txt") (Join-Path $StageRoot "README.TXT") -Force

@(
    "[autorun]",
    "label=Aero OS $Version $Codename ($Arch)"
) | Set-Content -Path (Join-Path $StageRoot "autorun.inf") -Encoding ascii

Write-IsoImapi -SourceFolder $StageRoot -IsoPath $IsoPath -VolumeName "AERO_OS_$Arch"

$hash = (Get-FileHash -Path $IsoPath -Algorithm SHA256).Hash.ToLower()
Set-Content -Path "$IsoPath.sha256.txt" -Value $hash -Encoding ascii

$sizeMb = [math]::Round((Get-Item $IsoPath).Length / 1MB, 2)
Write-Host ""
Write-Host "==> ISO ready" -ForegroundColor Green
Write-Host "  $IsoPath" -ForegroundColor Cyan
Write-Host "  Size   : $sizeMb MB" -ForegroundColor White
Write-Host "  SHA256 : $hash" -ForegroundColor DarkGray
Write-Host "  Arch   : $Arch" -ForegroundColor White
Write-Host ""
Write-Host "Rufus: SELECT this ISO - GPT - UEFI - DD mode if asked" -ForegroundColor Green
Write-Host "Note: Aero overlay + sounds payload ISO for FreeBSD $Arch." -ForegroundColor DarkGray

if ($Publish) {
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        & (Join-Path $ProjectRoot "publish_iso.ps1") -Tag "v$Version"
    } else {
        Write-Host "GitHub CLI (gh) not installed - skipped upload. ISO is in out\" -ForegroundColor Yellow
    }
}

exit 0
