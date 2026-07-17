# Aero OS

**Aero Native Foundation** — UEFI kernel with glass-lite Setup.

## Build

```powershell
.\tools\build_foundation.ps1
```

Requires WSL with Rust nightly (for the host build tools only).

## Artifacts

| File | Use |
|------|-----|
| `out/AeroOS-Foundation-0.1.0.img` | VMware hard disk (UEFI) |
| `out/AeroOS-Foundation-0.1.0.iso` | USB / optical UEFI media |

## VMware

1. New VM → **Other 64-bit**
2. Firmware **UEFI**
3. Attach `AeroOS-Foundation-0.1.0.img` as the hard disk
4. Power on → bootscreen → Setup → glass desktop

See [foundation/tools/run_vmware.md](foundation/tools/run_vmware.md).

## Layout

| Path | Purpose |
|------|---------|
| `foundation/` | Aero kernel + glass-lite Setup |
| `tools/build_foundation.ps1` | Build script |
| `assets/` | Branding / sounds |
| `store/` | App catalog (`.aero`) |
| `releases/` | Download notes |

## Updates

GitHub Releases: https://github.com/tylerdel30-dev/aero-os/releases
