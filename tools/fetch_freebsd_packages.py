#!/usr/bin/env python3
"""Download FreeBSD amd64 packages into an offline pkg repo for the Aero ISO."""

from __future__ import annotations

import json
import sys
import tarfile
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / ".cache" / "freebsd-packages" / "All"
ABI = "FreeBSD:14:amd64"
BASE = f"https://pkg.freebsd.org/{ABI}/latest"
PACKAGES_LIST = ROOT / "profile" / "packages.amd64"

# Critical desktop set (always fetch). Full list from packages.amd64 is attempted too.
CRITICAL = [
    "pkg",
    "bash",
    "curl",
    "ca_root_nss",
    "dbus",
    "labwc",
    "wayland",
    "seatd",
    "gtk4",
    "gtk4-layer-shell",
    "glib",
    "pango",
    "cairo",
    "pipewire",
    "wireplumber",
    "foot",
    "thunar",
    "mesa-dri",
    "libglvnd",
    "png",
    "freetype2",
    "fontconfig",
    "harfbuzz",
    "libepoll-shim",
    "libxkbcommon",
    "wlroots15",
    "wlroots",
    "pixman",
    "libinput",
    "evdev-proto",
    "xf86-input-libinput",
]


def download(url: str, dest: Path) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    if dest.exists() and dest.stat().st_size > 1024:
        return
    print(f"  GET {url}")
    req = urllib.request.Request(url, headers={"User-Agent": "AeroOS-builder/1.0"})
    with urllib.request.urlopen(req, timeout=120) as resp, open(dest, "wb") as out:
        while True:
            chunk = resp.read(1024 * 256)
            if not chunk:
                break
            out.write(chunk)


def load_packagesite(cache: Path) -> dict[str, dict]:
    site = cache / "packagesite.pkg"
    download(f"{BASE}/packagesite.pkg", site)
    # packagesite.pkg is tar of packagesite.yaml (sometimes zstd). Try tarfile; else 7z.
    names: dict[str, dict] = {}
    try:
        with tarfile.open(site, "r:*") as tar:
            member = None
            for m in tar.getmembers():
                if m.name.endswith("packagesite.yaml") or m.name.endswith("packagesite.json"):
                    member = m
                    break
            if member is None:
                raise RuntimeError("packagesite.yaml not in archive")
            f = tar.extractfile(member)
            assert f is not None
            text = f.read().decode("utf-8", "replace")
    except Exception:
        # Fall back: treat as single-file yaml dumped by pkg
        import subprocess

        tmp = cache / "packagesite_extract"
        if tmp.exists():
            import shutil

            shutil.rmtree(tmp)
        tmp.mkdir(parents=True)
        subprocess.run(
            [r"C:\Program Files\7-Zip\7z.exe", "x", "-y", f"-o{tmp}", str(site)],
            check=False,
            capture_output=True,
        )
        yaml_path = next(tmp.rglob("packagesite.yaml"), None)
        if yaml_path is None:
            yaml_path = next(tmp.rglob("packagesite.json"), None)
        if yaml_path is None:
            raise RuntimeError("Could not extract packagesite")
        text = yaml_path.read_text(encoding="utf-8", errors="replace")

    # packagesite.yaml is JSON-lines or YAML docs per package
    for line in text.splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        try:
            if line.startswith("{"):
                obj = json.loads(line)
            else:
                continue
        except json.JSONDecodeError:
            continue
        name = obj.get("name")
        if name:
            names[name] = obj
    return names


def wanted_names() -> list[str]:
    names = list(CRITICAL)
    if PACKAGES_LIST.exists():
        for line in PACKAGES_LIST.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            names.append(line)
    # de-dupe preserve order
    seen = set()
    out = []
    for n in names:
        if n not in seen:
            seen.add(n)
            out.append(n)
    return out


def main() -> int:
    cache = ROOT / ".cache" / "freebsd-packages"
    cache.mkdir(parents=True, exist_ok=True)
    OUT.mkdir(parents=True, exist_ok=True)

    print(f"Loading packagesite for {ABI}...")
    try:
        catalog = load_packagesite(cache)
    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1
    print(f"Catalog entries: {len(catalog)}")

    wanted = wanted_names()
    # Resolve direct packages + one level of deps by name if present in catalog
    to_fetch: set[str] = set()
    for name in wanted:
        if name in catalog:
            to_fetch.add(name)
            deps = catalog[name].get("deps") or {}
            if isinstance(deps, dict):
                to_fetch.update(deps.keys())
            elif isinstance(deps, list):
                for d in deps:
                    if isinstance(d, str):
                        to_fetch.add(d)
                    elif isinstance(d, dict) and "name" in d:
                        to_fetch.add(d["name"])
        else:
            print(f"  warn: not in catalog: {name}")

    print(f"Downloading {len(to_fetch)} packages...")
    ok = 0
    for name in sorted(to_fetch):
        meta = catalog.get(name)
        if not meta:
            continue
        reponame = meta.get("repopath") or meta.get("path")
        if not reponame:
            # construct from name-version
            ver = meta.get("version", "")
            reponame = f"All/{name}-{ver}.pkg"
        if not reponame.startswith("All/"):
            reponame = f"All/{reponame}" if "/" not in reponame else reponame
        url = f"{BASE}/{reponame}"
        dest = OUT / Path(reponame).name
        try:
            download(url, dest)
            ok += 1
        except Exception as exc:
            print(f"  FAIL {name}: {exc}")

    # Write local repo meta
    conf = cache / "Aero.conf"
    conf.write_text(
        f"""Aero: {{
  url: "file:///usr/local/share/aero/offline-packages",
  enabled: yes,
  priority: 10,
  mirror_type: "srv"
}}
""",
        encoding="utf-8",
    )
    print(f"Done: {ok} packages in {OUT}")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
