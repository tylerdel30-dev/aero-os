#!/usr/bin/env python3
"""Inject Aero overlay into FreeBSD disc1 ISO via Rock Ridge facade (keeps boot)."""

from __future__ import annotations

import hashlib
import stat
import sys
from pathlib import Path

import pycdlib

ROOT = Path(__file__).resolve().parents[1]
FREEBSD = ROOT / ".cache" / "freebsd" / "FreeBSD-14.3-RELEASE-amd64-disc1.iso"
OVERLAY = ROOT / "build-workspace" / "full-os-overlay"
OUT = ROOT / "out" / "AeroOS-1.0.1-Stratus.iso"


def ensure_dir(fac, rr_path: str) -> None:
    rr_path = "/" + rr_path.strip("/")
    if rr_path == "/":
        return
    parts = rr_path.strip("/").split("/")
    cur = ""
    for part in parts:
        cur = f"{cur}/{part}"
        try:
            fac.get_record(cur)
        except Exception:
            fac.add_directory(cur, 0o755)


def file_mode(host: Path) -> int:
    name = host.name
    parent = host.parent.name
    if host.suffix in {
        ".wav", ".json", ".css", ".png", ".txt", ".conf", ".xml",
        ".desktop", ".swift", ".md", ".example"
    }:
        return 0o644
    if parent in {"bin", "sbin", "rc.d"} or name.endswith(".sh"):
        return 0o755
    if name.startswith("aero") and "." not in name:
        return 0o755
    if name in {"aexes", "labwc", "autostart"}:
        return 0o755
    mode = host.stat().st_mode
    if mode & stat.S_IXUSR:
        return 0o755
    return 0o644


def main() -> int:
    if not FREEBSD.is_file():
        print(f"Missing FreeBSD ISO: {FREEBSD}", file=sys.stderr)
        return 1
    if not OVERLAY.is_dir():
        print(f"Missing overlay: {OVERLAY}", file=sys.stderr)
        return 1

    print(f"Opening FreeBSD disc1 ({FREEBSD.stat().st_size / (1024 * 1024):.0f} MB)...")
    iso = pycdlib.PyCdlib()
    iso.open(str(FREEBSD))
    fac = iso.get_rock_ridge_facade()

    files = sorted(p for p in OVERLAY.rglob("*") if p.is_file())
    print(f"Injecting {len(files)} Aero files into AeroOS-1.0.1-Stratus.iso...")
    for i, host in enumerate(files, 1):
        rel = host.relative_to(OVERLAY).as_posix()
        rr = "/" + rel
        parent = "/" + "/".join(rel.split("/")[:-1]) if "/" in rel else "/"
        if parent != "/":
            ensure_dir(fac, parent)
        mode = file_mode(host)
        try:
            try:
                fac.get_record(rr)
                fac.rm_file(rr)
            except Exception:
                pass
            fac.add_file(str(host), rr, mode)
        except Exception as exc:
            print(f"  FAIL {rel}: {exc}", file=sys.stderr)
            iso.close()
            return 1
        if i % 25 == 0 or i == len(files):
            print(f"  {i}/{len(files)}")

    OUT.parent.mkdir(parents=True, exist_ok=True)
    # Remove previous same-name ISO only (do not delete arch-specific siblings)
    if OUT.exists():
        OUT.unlink()
    for side in (Path(str(OUT) + ".sha256.txt"), Path(str(OUT) + ".sha256")):
        if side.exists():
            side.unlink()
    print(f"Writing {OUT} ...")
    iso.write(str(OUT))
    iso.close()

    # pycdlib zeroes the hybrid MBR/GPT system area — restore for USB/Rufus DD boot
    sys.path.insert(0, str(Path(__file__).resolve().parent))
    from fix_hybrid_boot import patch_hybrid

    print("Restoring FreeBSD hybrid MBR/GPT for USB boot...")
    patch_hybrid(FREEBSD, OUT)

    mb = OUT.stat().st_size / (1024 * 1024)
    print(f"Done: {mb:.1f} MB -> {OUT.name}")
    if mb < 400:
        print("ERROR: ISO too small", file=sys.stderr)
        return 1

    h = hashlib.sha256()
    with open(OUT, "rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    sha = h.hexdigest()
    Path(str(OUT) + ".sha256.txt").write_text(sha + "\n", encoding="ascii")
    print(f"SHA256: {sha}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
