# Aero OS

**Aero Native Foundation 0.2** — UEFI kernel with frosted glass desktop and `.aero` Store.

## Build

```powershell
.\tools\build_foundation.ps1
```

Requires WSL with Rust nightly (for the host build tools only).

## Artifacts

| File | Use |
|------|-----|
| `out/AeroOS-Foundation-0.2.0.img` | VMware hard disk (UEFI) |
| `out/AeroOS-Foundation-0.2.0.iso` | USB / optical UEFI media |

## VMware

1. New VM → **Other 64-bit**
2. Firmware **UEFI**
3. Attach `AeroOS-Foundation-0.2.0.img` as the hard disk
4. Power on → bootscreen → Setup → glass desktop

See [foundation/tools/run_vmware.md](foundation/tools/run_vmware.md).

## Layout

| Path | Purpose |
|------|---------|
| `foundation/` | Aero kernel + glass desktop |
| `store/` | App catalog and `.aero` manifests |
| `examples/hello-aero/` | Sample `.aero` app bundle |
| `catalog.json` | Public store catalog |
| `tools/build_foundation.ps1` | Build script |
| `assets/` | Branding / sounds |

## Store / `.aero`

Apps are JSON `.aero` manifests under `store/apps/` and `examples/`.  
Foundation lists them in **Start → Aero Store** (builtins open in-desktop panels).

## Updates

GitHub Releases: https://github.com/tylerdel30-dev/aero-os/releases
