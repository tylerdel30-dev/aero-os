# VMware smoke-test — Aero Foundation 0.3

## Before boot
- [ ] `.\tools\build_foundation.ps1`
- [ ] `out/AeroOS-Foundation-0.3.0.img`
- [ ] VM: Other 64-bit, UEFI ON
- [ ] Attach `.img` as hard disk

## Boot
- [ ] Metallic Aero bootscreen with logo overlay
- [ ] Logo shrinks into Setup card
- [ ] Setup: Hello → Name → Region → Appearance → Install
- [ ] Install writes `AERO/session.json`
- [ ] Desktop: glass taskbar, Start, Store, clock
- [ ] Reboot restores name/look (skips wizard)
- [ ] Space opens Start; 1/2/3 changes look (persists)
