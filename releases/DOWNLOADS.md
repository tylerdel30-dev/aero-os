# Aero OS Downloads

**https://github.com/tylerdel30-dev/aero-os/releases**

## Current images

| Version | File | Notes |
|--------|------|--------|
| Foundation 0.3 | `AeroOS-Foundation-0.3.0.img` | UEFI disk — install + persistent session |
| Foundation 0.3 | `AeroOS-Foundation-0.3.0.iso` | UEFI ISO (payload-sized ESP) |

SHA256:

| File | Hash |
|------|------|
| `.img` | `521359262e87f5cd7250c544d870fa057d100cd71a72c47cf64a048a89f3f478` |
| `.iso` | `b510717574269f2ba57b1a50cfff8b33bbc2c23adc046c7df07814dc93f05668` |

Build: `.\tools\build_foundation.ps1`

VMware: Other 64-bit, UEFI, attach the `.img` as HDD.  
Guide: [foundation/tools/run_vmware.md](../foundation/tools/run_vmware.md)

## Writing USB

Prefer DD / image mode with the `.iso` or `.img`, or `.\write_usb.ps1` for the ISO.
