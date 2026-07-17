# Aero OS

**Aero Native Foundation 0.3** — UEFI kernel with frosted glass desktop, install, and persistence.

## Build

```powershell
.\tools\build_foundation.ps1
```

Requires WSL with Rust nightly (for the host build tools only).

## Artifacts

| File | Use |
|------|-----|
| `out/AeroOS-Foundation-0.3.0.img` | VMware hard disk (UEFI) |
| `out/AeroOS-Foundation-0.3.0.iso` | USB / optical UEFI media |

ESP size is payload-based (not a padded 64 MB stub).

## VMware

1. New VM → **Other 64-bit**
2. Firmware **UEFI**
3. Attach `AeroOS-Foundation-0.3.0.img` as the hard disk
4. Power on → bootscreen → Setup → **Install Aero** → desktop
5. Reboot: settings restore from `AERO/session.json`

See [foundation/tools/run_vmware.md](foundation/tools/run_vmware.md).

## Layout

| Path | Purpose |
|------|---------|
| `foundation/` | Aero kernel + glass desktop + installer |
| `store/` | `.aero` catalog (packed into `AERO/store`) |
| `tools/build_foundation.ps1` | Build script |
| `assets/` | Branding / sounds |
| `releases/` | Download notes |

## Updates

GitHub Releases: https://github.com/tylerdel30-dev/aero-os/releases
