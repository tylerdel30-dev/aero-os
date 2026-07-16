# Aero OS Downloads

**https://github.com/tylerdel30-dev/aero-os/releases**

## Current images

| Version | File | Size | Notes |
|--------|------|------|--------|
| v1.0.1 Stratus | `AeroOS-1.0.1-Stratus.iso` | **~2.6 GB** | Full amd64: FreeBSD 14.3 + Aero + **185 offline packages** (labwc/gtk4/swift/wine/firefox…) |
| v1.0.1 Stratus | `AeroOS-1.0.1-Stratus-aarch64.iso` | ~1+ GB | Full arm64 FreeBSD disc1 + Aero layer |

## Turnkey path (after install)

```
aero-bootstrap /
aero-build-desktop   # compiles aero-shell, settings, lock, store, firstboot, update-ui
reboot
```

Or enable labwc (autostart runs bootstrap/compile if binaries missing).

## Rufus

SELECT `AeroOS-1.0.1-Stratus.iso` · GPT + UEFI · DD mode · 8 GB+ USB
