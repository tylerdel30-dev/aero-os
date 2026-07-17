# Aero OS Downloads

**https://github.com/tylerdel30-dev/aero-os/releases**

## Current images

| Version | File | Notes |
|--------|------|--------|
| Foundation 0.2 | `AeroOS-Foundation-0.2.0.img` | UEFI disk — frosted glass desktop + Store |
| Foundation 0.2 | `AeroOS-Foundation-0.2.0.iso` | UEFI ISO |

SHA256:

| File | Hash |
|------|------|
| `.img` | `01a69e5f7fc863513ffe79f837d2a892bf03bc2d70c6d0d3340293caf431f0aa` |
| `.iso` | `e79f212c26dd86c3c70263b6b975b37eeed3e8443d0d6ca323cb259ff43eea01` |

Build: `.\tools\build_foundation.ps1`

VMware: Other 64-bit, UEFI, attach the `.img` as HDD.  
Guide: [foundation/tools/run_vmware.md](../foundation/tools/run_vmware.md)

## Writing USB

Prefer DD / image mode with the `.iso` or `.img`, or `.\write_usb.ps1` for the ISO.

## Store

- `store/index.json` — Foundation app catalog
- `store/apps/*.aero` — app manifests
- `examples/hello-aero/hello.aero` — sample bundle
- `catalog.json` — public catalog mirror
