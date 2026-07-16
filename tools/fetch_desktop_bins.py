#!/usr/bin/env python3
"""Download aero-desktop-amd64.tar.xz from GitHub release into out/ for ISO injection."""

from __future__ import annotations

import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "out"
URL = (
    "https://github.com/tylerdel30-dev/aero-os/releases/download/"
    "v1.0.1/aero-desktop-amd64.tar.xz"
)


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    dest = OUT / "aero-desktop-amd64.tar.xz"
    print(f"Fetching {URL}")
    try:
        urllib.request.urlretrieve(URL, dest)
    except Exception as exc:  # noqa: BLE001
        print(f"Not available yet: {exc}", file=sys.stderr)
        return 1
    size = dest.stat().st_size
    if size < 1024:
        dest.unlink(missing_ok=True)
        print("Download too small — artifact missing", file=sys.stderr)
        return 1
    print(f"Saved {dest} ({size} bytes)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
