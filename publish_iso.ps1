#Requires -Version 5.1
<#
.SYNOPSIS
    Upload Aero OS ISO(s) from .\out\ to the GitHub release for this version.

.EXAMPLE
    .\publish_iso.ps1
    .\publish_iso.ps1 -Tag v1.0.1
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
    Write-Host "No out\ folder. Build first with: .\build_os.ps1" -ForegroundColor Red
    exit 1
}

$isos = @(Get-ChildItem -Path $OutDir -Filter "*.iso" -ErrorAction SilentlyContinue)
if ($isos.Count -eq 0) {
    Write-Host "No .iso files in out\. Run .\build_os.ps1 first." -ForegroundColor Red
    exit 1
}

# Infer tag from filename AeroOS-1.0.0-Stratus-amd64.iso or /etc style version
if ([string]::IsNullOrWhiteSpace($Tag)) {
    $match = [regex]::Match($isos[0].Name, "AeroOS-(\d+\.\d+\.\d+)")
    if ($match.Success) {
        $Tag = "v$($match.Groups[1].Value)"
    } else {
        $Tag = "v1.0.0"
    }
}

Write-Host "Publishing ISOs to ${Repo} release ${Tag}" -ForegroundColor Cyan

# Ensure release exists
$releaseView = gh release view $Tag --repo $Repo 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "==> Creating release ${Tag}" -ForegroundColor Green
    $notes = @"
## Aero OS ${Tag}

### Download
- Bootable ISO (use Rufus on Windows: GPT + UEFI, DD mode)
- Verify with the ``.sha256`` file

### Install / update
After installing, later updates come from this same repo:
``````
aero update
aero upgrade
``````
"@
    gh release create $Tag --repo $Repo --title "Aero OS $Tag" --notes $notes
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

foreach ($iso in $isos) {
    Write-Host "==> Uploading $($iso.Name) ($([math]::Round($iso.Length/1MB,1)) MB)" -ForegroundColor Green
    gh release upload $Tag $iso.FullName --repo $Repo --clobber
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    $shaFile = "$($iso.FullName).sha256"
    $shaTxt = "$($iso.FullName).sha256.txt"
    if (Test-Path $shaFile) {
        gh release upload $Tag $shaFile --repo $Repo --clobber
    } elseif (Test-Path $shaTxt) {
        gh release upload $Tag $shaTxt --repo $Repo --clobber
    } else {
        $hash = (Get-FileHash -Path $iso.FullName -Algorithm SHA256).Hash.ToLower()
        $hashPath = Join-Path $OutDir "$($iso.Name).sha256.txt"
        Set-Content -Path $hashPath -Value $hash -Encoding ascii
        gh release upload $Tag $hashPath --repo $Repo --clobber
    }
}

# Also upload update manifest if present for this tag
$manifest = Join-Path $ProjectRoot "releases\$Tag\aero-update-manifest.json"
if (Test-Path $manifest) {
    Write-Host "==> Uploading update manifest" -ForegroundColor Green
    gh release upload $Tag $manifest --repo $Repo --clobber
}

Write-Host ""
Write-Host "Done. Download page:" -ForegroundColor Green
Write-Host "  https://github.com/${Repo}/releases/tag/${Tag}" -ForegroundColor Cyan
