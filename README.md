# Aero OS

**Aero Native Kernel 0.4** — ExitBootServices, glass desktop, FAT Files, install + persistence.

## Build

```powershell
.\tools\build_foundation.ps1
```

Requires WSL with Rust nightly.

## Artifacts

| File | Use |
|------|-----|
| `out/AeroOS-Foundation-0.4.0.img` | VMware hard disk (UEFI) |
| `out/AeroOS-Foundation-0.4.0.iso` | USB / optical UEFI media |

## Boot flow

1. UEFI splash + Setup / restore session
2. **ExitBootServices** → Aero kernel (GDT/IDT/PIC/PIT + PS/2)
3. Glass desktop (Start, Store, Files, Control Center)

## VMware

1. Other 64-bit, UEFI
2. Attach `AeroOS-Foundation-0.4.0.img`
3. Install in Setup, then reboot to verify persistence

GitHub: https://github.com/tylerdel30-dev/aero-os/releases
