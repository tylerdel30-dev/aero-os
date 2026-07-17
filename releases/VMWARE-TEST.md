# VMware smoke-test — Aero Kernel 0.4

## Before boot
- [ ] `.\tools\build_foundation.ps1`
- [ ] `out/AeroOS-Foundation-0.4.0.img`
- [ ] VM: Other 64-bit, UEFI ON

## Boot
- [ ] Splash → Setup or restored session
- [ ] Transitions to kernel mode (desktop still draws)
- [ ] PS/2 keyboard works after ExitBootServices
- [ ] Start → Files lists AERO/ (if ATA/FAT readable)
- [ ] Store / About / Control Center
- [ ] Install persists session across reboot
