#Requires -Version 5.1
<#
.SYNOPSIS
    Upload Aero Foundation images from .\out\ to a GitHub release.

.EXAMPLE
    .\publish_iso.ps1
    .\publish_iso.ps1 -Tag v0.1.0
#>
param(
    [string]$Tag = "",
    [string]$Repo = "tylerdel30-dev/aero-os"
)

$ErrorActionPreference = "Stop"
$ProjectRoot = $PSScriptRoot
$OutDir = Join-Path $ProjectRoot "out"

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "GitHub CLI (gh) is required. Install: https://cli.github.com/" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $OutDir)) {
    Write-Host "No out\ folder. Build first: .\tools\build_foundation.ps1" -ForegroundColor Red
    exit 1
}

$assets = @(Get-ChildItem -Path $OutDir -File -ErrorAction SilentlyContinue | Where-Object {
    $_.Name -match '^AeroOS-Foundation-.*\.(img|iso)(\.sha256)?$'
})
if ($assets.Count -eq 0) {
    Write-Host "No Foundation images in out\. Run .\tools\build_foundation.ps1 first." -ForegroundColor Red
    exit 1
}

if ([string]::IsNullOrWhiteSpace($Tag)) {
    $match = [regex]::Match(($assets | Select-Object -First 1).Name, "Foundation-(\d+\.\d+\.\d+)")
    if ($match.Success) {
        $Tag = "v$($match.Groups[1].Value)"
    } else {
        $Tag = "v0.1.0"
    }
}

Write-Host "Publishing Foundation assets to ${Repo} release ${Tag}" -ForegroundColor Cyan

$releaseView = gh release view $Tag --repo $Repo 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "==> Creating release ${Tag}" -ForegroundColor Green
    $notes = @"
## Aero OS ${Tag} — Foundation

### Download
- ``AeroOS-Foundation-*.img`` — attach as UEFI hard disk in VMware
- ``AeroOS-Foundation-*.iso`` — UEFI install media

### Build
``````
.\tools\build_foundation.ps1
``````
"@
    gh release create $Tag --repo $Repo --title "Aero OS $Tag" --notes $notes
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

foreach ($a in $assets) {
    Write-Host "==> Uploading $($a.Name) ($([math]::Round($a.Length/1MB,1)) MB)" -ForegroundColor Green
    gh release upload $Tag $a.FullName --repo $Repo --clobber
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

Write-Host ""
Write-Host "Done. Download page:" -ForegroundColor Green
Write-Host "  https://github.com/${Repo}/releases/tag/${Tag}" -ForegroundColor Cyan
