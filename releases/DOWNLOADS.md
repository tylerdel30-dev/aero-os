# Aero OS Downloads

**https://github.com/tylerdel30-dev/aero-os/releases**

## Current images

| Version | File | Notes |
|--------|------|--------|
| Foundation 0.1 | `AeroOS-Foundation-0.1.0.img` | UEFI disk image — Aero native kernel + glass Setup |
| Foundation 0.1 | `AeroOS-Foundation-0.1.0.iso` | UEFI ISO |

SHA256:

| File | Hash |
|------|------|
| `.img` | `67b08dcc35ed338edda709a067f38b6c234bfce92ec5e275f39f3a15dc4b9bda` |
| `.iso` | `da0e361408a70bd42855c2d6c1b8bcb68544dc639bb8176acf327c25bc643c85` |

Build: `.\tools\build_foundation.ps1`

VMware: Other 64-bit, UEFI, attach the `.img` as HDD.  
Guide: [foundation/tools/run_vmware.md](../foundation/tools/run_vmware.md)

## Writing USB

Prefer DD / image mode with the `.iso` or `.img`, or `.\write_usb.ps1` for the ISO.
