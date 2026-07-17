# Aero Foundation — VMware / USB

## Build

```powershell
.\tools\build_foundation.ps1
```

Output: `out/AeroOS-Foundation-0.1.0.img` and `.iso`

## VMware Workstation

1. New VM → **Other** → **Other 64-bit**
2. Firmware: **UEFI**
3. Attach `AeroOS-Foundation-0.1.0.img` as hard disk
4. 512 MB+ RAM
5. Power on — bootscreen + logo shrink into Setup
6. Flow: Splash → Hello → Name → Region → Appearance → Desktop
7. Desktop: Space = Start menu · 1/2/3 = look · clock on taskbar

## USB

Raw-write the `.iso` or `.img` (DD mode).
