#Requires -Version 5.1
<#
.SYNOPSIS
    Build Aero OS ISO on Windows using Docker Desktop (FreeBSD builder container).

.DESCRIPTION
    Orchestrates a FreeBSD-based ISO build from Windows. Requires Docker Desktop
    with the Linux container backend enabled. The ISO is written to .\out\
#>
param(
    [switch]$SkipImageBuild,
    [switch]$NoCache,
    [switch]$Publish
)

$ErrorActionPreference = "Stop"
$ProjectRoot = $PSScriptRoot
$ImageName = "aero-os-builder"
$Dockerfile = Join-Path $ProjectRoot "docker\Dockerfile"

function Test-DockerAvailable {
    try {
        $null = docker version 2>&1
        return $LASTEXITCODE -eq 0
    } catch {
        return $false
    }
}

function Test-DockerRunning {
    try {
        $info = docker info 2>&1
        return $LASTEXITCODE -eq 0
    } catch {
        return $false
    }
}

Write-Host "Aero OS — Windows ISO Builder" -ForegroundColor Cyan
Write-Host "Unix foundation: FreeBSD (Darwin-class BSD lineage)" -ForegroundColor DarkGray
Write-Host ""

if (-not (Test-DockerAvailable)) {
    Write-Host "Docker was not found on PATH." -ForegroundColor Red
    Write-Host ""
    Write-Host "Install Docker Desktop for Windows:" -ForegroundColor Yellow
    Write-Host "  https://www.docker.com/products/docker-desktop/"
    Write-Host ""
    Write-Host "After installation, enable WSL 2 backend and restart Docker Desktop."
    exit 1
}

if (-not (Test-DockerRunning)) {
    Write-Host "Docker is installed but the daemon is not running." -ForegroundColor Red
    Write-Host "Start Docker Desktop, wait until it reports 'Running', then retry."
    exit 1
}

if (-not (Test-Path $Dockerfile)) {
    Write-Host "Missing Dockerfile at: $Dockerfile" -ForegroundColor Red
    exit 1
}

$ProjectMount = $ProjectRoot -replace '\\', '/'
if ($ProjectMount -match '^[A-Za-z]:') {
    $drive = $ProjectMount.Substring(0, 1).ToLower()
    $rest = $ProjectMount.Substring(2)
    $ProjectMount = "/mnt/$drive$rest"
}

if (-not $SkipImageBuild) {
    Write-Host "==> Building Aero OS builder image ($ImageName)" -ForegroundColor Green
    $buildArgs = @(
        "build",
        "-t", $ImageName,
        "-f", $Dockerfile,
        $ProjectRoot
    )
    if ($NoCache) {
        $buildArgs += "--no-cache"
    }
    & docker @buildArgs
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Docker image build failed." -ForegroundColor Red
        exit $LASTEXITCODE
    }
} else {
    Write-Host "==> Skipping image build (using existing $ImageName)" -ForegroundColor DarkGray
}

Write-Host "==> Running FreeBSD ISO build inside container" -ForegroundColor Green
Write-Host "    Project mount: ${ProjectRoot} -> /aero" -ForegroundColor DarkGray

$runArgs = @(
    "run",
    "--rm",
    "--privileged",
    "--cap-add", "SYS_ADMIN",
    "-v", "${ProjectRoot}:/aero",
    "-e", "AERO_BUILD_CONTAINER=1",
    "-e", "AERO_PROJECT_ROOT=/aero",
    "-e", "AERO_HOST_OS=Windows",
    $ImageName
)

& docker @runArgs
$exitCode = $LASTEXITCODE

if ($exitCode -eq 0) {
    Write-Host ""
    Write-Host "==> Aero OS ISO build finished successfully" -ForegroundColor Green
    $outDir = Join-Path $ProjectRoot "out"
    $isoFile = $null
    if (Test-Path $outDir) {
        Write-Host "Output directory: $outDir" -ForegroundColor Cyan
        Get-ChildItem -Path $outDir -Filter "*.iso" -ErrorAction SilentlyContinue | ForEach-Object {
            $isoFile = $_
            $sizeMb = [math]::Round($_.Length / 1MB, 1)
            Write-Host "  $($_.Name)  ($sizeMb MB)" -ForegroundColor White
        }
    }

    if ($isoFile) {
        Write-Host ""
        Write-Host "==> Verifying image (SHA-256)" -ForegroundColor Green
        $hash = (Get-FileHash -Path $isoFile.FullName -Algorithm SHA256).Hash.ToLower()
        $hash | Out-File -FilePath "$($isoFile.FullName).sha256.txt" -Encoding ascii
        Write-Host "  $hash" -ForegroundColor DarkGray

        Write-Host ""
        Write-Host "==> Write to USB with Rufus" -ForegroundColor Green
        Write-Host "  1. Download Rufus:  https://rufus.ie" -ForegroundColor White
        Write-Host "  2. Insert a USB drive (8 GB or larger — it will be ERASED)" -ForegroundColor White
        Write-Host "  3. In Rufus select your USB, click SELECT, choose:" -ForegroundColor White
        Write-Host "       $($isoFile.FullName)" -ForegroundColor Cyan
        Write-Host "  4. Partition scheme: GPT   |   Target system: UEFI (non CSM)" -ForegroundColor White
        Write-Host "  5. If asked, write in DD Image mode" -ForegroundColor White
        Write-Host "  6. Click START, then boot the target PC from USB" -ForegroundColor White
        Write-Host ""
        Write-Host "  On first boot the Aero logo appears, then the setup wizard opens." -ForegroundColor DarkGray

        if ($Publish) {
            Write-Host ""
            Write-Host "==> Publishing ISO to GitHub (tylerdel30-dev/aero-os)" -ForegroundColor Green
            & (Join-Path $ProjectRoot "publish_iso.ps1")
            if ($LASTEXITCODE -ne 0) {
                Write-Host "ISO publish failed (build still succeeded)." -ForegroundColor Yellow
            }
        } else {
            Write-Host ""
            Write-Host "Upload later with:  .\publish_iso.ps1" -ForegroundColor DarkGray
            Write-Host "Or rebuild+upload:  .\build_os.ps1 -Publish" -ForegroundColor DarkGray
        }
    }
} else {
    Write-Host ""
    Write-Host "Build failed with exit code $exitCode" -ForegroundColor Red
}

exit $exitCode
