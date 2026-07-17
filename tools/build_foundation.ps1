#Requires -Version 5.1
<#
.SYNOPSIS
    Build Aero Native Foundation disk image via WSL (Rust nightly).
#>
$ErrorActionPreference = "Stop"
$Root = $PSScriptRoot
if ((Split-Path -Leaf $Root) -eq "tools") {
    $Root = Split-Path $Root -Parent
}
$Script = Join-Path $Root "tools\build_foundation_iso.sh"

Write-Host "Aero Native Foundation — building via WSL" -ForegroundColor Cyan
$drive = $Root.Substring(0, 1).ToLower()
$rest = $Root.Substring(2).Replace('\', '/')
$wslRoot = "/mnt/$drive$rest"

# Prefer the Ubuntu WSL distro when present (build host only).
$distro = "Ubuntu"
& wsl -d $distro -u root -- bash -lc "sed -i 's/\r$//' '$wslRoot/foundation/build-all.sh' '$wslRoot/tools/build_foundation_iso.sh'; bash '$wslRoot/foundation/build-all.sh'"
if ($LASTEXITCODE -ne 0) { throw "Foundation build failed" }

$img = Join-Path $Root "out\AeroOS-Foundation-0.4.0.img"
if (-not (Test-Path $img)) { throw "Missing $img" }
Write-Host "OK: $img" -ForegroundColor Green
$iso = Join-Path $Root "out\AeroOS-Foundation-0.4.0.iso"
if (Test-Path $iso) { Write-Host "OK: $iso" -ForegroundColor Green }
