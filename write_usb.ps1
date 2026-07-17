#Requires -Version 5.1
<#
.SYNOPSIS
    Write AeroOS ISO to a USB stick as GPT + UEFI bootable media.

.DESCRIPTION
    Always produces a GPT disk. Raw-writes the GPT-only ISO (protective MBR type
    0xEE + GPT + EFI System Partition, no BIOS). Do not use Rufus "ISO mode" or MBR —
    this script is the supported Windows path.

.EXAMPLE
    .\write_usb.ps1
    .\write_usb.ps1 -DiskNumber 2
    .\write_usb.ps1 -DiskNumber 2 -Force
#>
param(
    [int]$DiskNumber = -1,
    [string]$IsoPath = "",
    [switch]$Force
)

$ErrorActionPreference = "Stop"

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
        ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERROR: Run this from an elevated PowerShell (Right-click > Run as Administrator)." -ForegroundColor Red
    exit 1
}

if (-not $IsoPath) {
    $cand = @(
        (Join-Path $PSScriptRoot "out\AeroOS-Foundation-0.4.0.iso"),
        (Join-Path $PSScriptRoot "out\AeroOS-Foundation-0.4.0.img"),
        (Join-Path $PSScriptRoot "out\AeroOS-Foundation-0.3.0.iso"),
        (Join-Path $PSScriptRoot "out\AeroOS-Foundation-0.3.0.img")
    ) | Where-Object { Test-Path $_ } | Select-Object -First 1
    if ($cand) { $IsoPath = $cand }
    else { $IsoPath = Join-Path $PSScriptRoot "out\AeroOS-Foundation-0.4.0.iso" }
}
if (-not (Test-Path $IsoPath)) {
    Write-Host "ERROR: Image not found: $IsoPath" -ForegroundColor Red
    Write-Host "Build with: .\tools\build_foundation.ps1" -ForegroundColor Yellow
    exit 1
}
$isoSize = (Get-Item $IsoPath).Length

# Require hybrid GPT on the image (protective MBR 0xEE + EFI PART)
$fs = [System.IO.File]::OpenRead($IsoPath)
$head = New-Object byte[] 1024
[void]$fs.Read($head, 0, 1024)
$fs.Close()
$mbrOk = ($head[510] -eq 0x55 -and $head[511] -eq 0xAA)
$partType = $head[446 + 4]
$gptOk = ([System.Text.Encoding]::ASCII.GetString($head, 512, 8) -eq "EFI PART")
if (-not ($mbrOk -and $gptOk)) {
    Write-Host "ERROR: ISO is missing hybrid GPT. Rebuild with tools\stage_and_rebuild_iso.py" -ForegroundColor Red
    exit 1
}
if ($partType -ne 0xEE) {
    Write-Host "ERROR: ISO protective MBR is not type 0xEE (GPT). Refusing." -ForegroundColor Red
    exit 1
}
Write-Host "ISO verified: GPT-only (protective MBR 0xEE + GPT + UEFI ESP, no BIOS)" -ForegroundColor Green
Write-Host ("  {0}  ({1:N1} MB)" -f $IsoPath, ($isoSize / 1MB)) -ForegroundColor DarkGray
Write-Host ""

$usbDisks = Get-Disk | Where-Object { $_.BusType -eq "USB" }
if (-not $usbDisks) {
    Write-Host "No USB disks detected. Plug in a stick (8 GB+) and re-run." -ForegroundColor Yellow
    exit 1
}

Write-Host "USB disks (will become GPT after write):" -ForegroundColor Cyan
foreach ($d in $usbDisks) {
    Write-Host ("  Disk {0}: {1}  {2:N1} GB  (now: {3})" -f $d.Number, $d.FriendlyName, ($d.Size / 1GB), $d.PartitionStyle)
}
Write-Host ""

if ($DiskNumber -lt 0) {
    Write-Host "Re-run with -DiskNumber <n> to write GPT media. Example:" -ForegroundColor Yellow
    Write-Host ("  .\write_usb.ps1 -DiskNumber {0}" -f $usbDisks[0].Number) -ForegroundColor White
    exit 0
}

$target = $usbDisks | Where-Object { $_.Number -eq $DiskNumber }
if (-not $target) {
    Write-Host "ERROR: Disk $DiskNumber is not a USB disk. Refusing." -ForegroundColor Red
    exit 1
}
if ($target.Size -lt $isoSize) {
    Write-Host "ERROR: Disk $DiskNumber is smaller than the ISO." -ForegroundColor Red
    exit 1
}

Write-Host ("TARGET: Disk {0}  {1}  {2:N1} GB" -f $target.Number, $target.FriendlyName, ($target.Size / 1GB)) -ForegroundColor Red
Write-Host "This will ERASE the stick and write a GPT + UEFI Aero OS image." -ForegroundColor Red
if (-not $Force) {
    $ans = Read-Host "Type YES to continue"
    if ($ans -ne "YES") { Write-Host "Aborted."; exit 0 }
}

Write-Host "==> Clearing old partition tables on disk $DiskNumber"
Get-Partition -DiskNumber $DiskNumber -ErrorAction SilentlyContinue | ForEach-Object {
    if ($_.DriveLetter) {
        try { mountvol "$($_.DriveLetter):" /D } catch { }
    }
}
try { Set-Disk -Number $DiskNumber -IsOffline $false } catch { }
try { Set-Disk -Number $DiskNumber -IsReadOnly $false } catch { }
try {
    Clear-Disk -Number $DiskNumber -RemoveData -RemoveOEM -Confirm:$false -ErrorAction SilentlyContinue
} catch { }

# Force-clean with diskpart so no volumes remain mounted (main cause of write errors)
Write-Host "==> Force-cleaning disk $DiskNumber with diskpart"
$dpScript = @"
select disk $DiskNumber
attributes disk clear readonly
online disk noerr
clean
"@
$dpFile = [System.IO.Path]::GetTempFileName()
Set-Content -Path $dpFile -Value $dpScript -Encoding ascii
try { diskpart /s $dpFile | Out-Null } catch { }
Remove-Item $dpFile -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Take the disk OFFLINE so Windows won't auto-mount volumes and lock the disk
# mid-write. The raw PhysicalDrive handle stays writable while offline.
Write-Host "==> Taking disk $DiskNumber offline to prevent volume locks"
try { Set-Disk -Number $DiskNumber -IsOffline $true } catch { }
try { Set-Disk -Number $DiskNumber -IsReadOnly $false } catch { }
Start-Sleep -Seconds 1

Write-Host "==> Writing GPT hybrid ISO to \\.\PhysicalDrive$DiskNumber"
$src = $null
$dst = $null
try {
    $src = [System.IO.File]::OpenRead($IsoPath)
    # Share ReadWrite so a stray handle doesn't cause a sharing violation
    $dst = New-Object System.IO.FileStream("\\.\PhysicalDrive$DiskNumber",
        [System.IO.FileMode]::Open, [System.IO.FileAccess]::Write, [System.IO.FileShare]::ReadWrite, 1MB)
    $buf = New-Object byte[] (4MB)
    $written = 0L
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    while (($n = $src.Read($buf, 0, $buf.Length)) -gt 0) {
        if ($n % 512 -ne 0) {
            $pad = 512 - ($n % 512)
            [Array]::Clear($buf, $n, $pad)
            $n += $pad
        }
        $dst.Write($buf, 0, $n)
        $written += $n
        if (($written % 256MB) -lt 4MB) {
            $pct = [math]::Round(100 * $written / $isoSize)
            $mbs = [math]::Round(($written / 1MB) / [math]::Max($sw.Elapsed.TotalSeconds, 0.1), 1)
            Write-Host ("  {0}%  {1:N0} / {2:N0} MB  ({3} MB/s)" -f $pct, ($written / 1MB), ($isoSize / 1MB), $mbs)
        }
    }
    $dst.Flush()
    $sw.Stop()
} catch {
    Write-Host ""
    Write-Host "ERROR: USB write failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Common fixes:" -ForegroundColor Yellow
    Write-Host "  - Close Explorer windows / antivirus scanning the stick" -ForegroundColor Yellow
    Write-Host "  - Unplug and replug the USB, then re-run" -ForegroundColor Yellow
    Write-Host "  - Try a different USB port (rear/2.0) or a different stick" -ForegroundColor Yellow
    if ($dst) { $dst.Dispose() }
    if ($src) { $src.Dispose() }
    try { Set-Disk -Number $DiskNumber -IsOffline $false } catch { }
    exit 1
} finally {
    if ($dst) { $dst.Dispose() }
    if ($src) { $src.Dispose() }
}

# Bring the disk back online so we (and firmware) can read the fresh GPT
try { Set-Disk -Number $DiskNumber -IsOffline $false } catch { }
Start-Sleep -Seconds 2

# Verify GPT landed on the stick
Write-Host "==> Verifying GPT on USB"
Start-Sleep -Seconds 2
try { Update-HostStorageCache | Out-Null } catch { }
$probe = New-Object byte[] 1024
$check = New-Object System.IO.FileStream("\\.\PhysicalDrive$DiskNumber",
    [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite, 1MB)
try {
    [void]$check.Read($probe, 0, 1024)
} finally {
    $check.Dispose()
}
$usbGpt = ([System.Text.Encoding]::ASCII.GetString($probe, 512, 8) -eq "EFI PART")
$usbEe = ($probe[446 + 4] -eq 0xEE)
$usbMbr = ($probe[510] -eq 0x55 -and $probe[511] -eq 0xAA)
if (-not ($usbGpt -and $usbEe -and $usbMbr)) {
    Write-Host "ERROR: USB does not show GPT after write (MBR/GPT probe failed)." -ForegroundColor Red
    exit 1
}

$style = "Unknown"
try {
    $style = (Get-Disk -Number $DiskNumber).PartitionStyle
} catch { }

Write-Host ""
Write-Host ("==> Done: {0:N0} MB in {1:N0}s" -f ($written / 1MB), $sw.Elapsed.TotalSeconds) -ForegroundColor Green
Write-Host ("USB is GPT bootable (probe OK, Windows PartitionStyle={0})" -f $style) -ForegroundColor Green
Write-Host "Boot: UEFI boot menu -> select this USB (not legacy/CSM)." -ForegroundColor Cyan
Write-Host "If using Rufus instead: Partition scheme GPT, Target UEFI, DD Image mode only." -ForegroundColor DarkGray
