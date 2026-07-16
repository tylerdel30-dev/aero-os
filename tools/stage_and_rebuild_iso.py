#!/usr/bin/env python3
"""Stage full Aero overlay (including offline pkgs) and rebuild AeroOS-1.0.1-Stratus.iso"""

from __future__ import annotations

import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OVERLAY = ROOT / "build-workspace" / "full-os-overlay"
PKG_ALL = ROOT / ".cache" / "freebsd-packages" / "All"


def copy_into(src: Path, dst: Path) -> None:
    if not src.exists():
        return
    dst.parent.mkdir(parents=True, exist_ok=True)
    if src.is_dir():
        if dst.exists():
            shutil.rmtree(dst)
        shutil.copytree(src, dst)
    else:
        shutil.copy2(src, dst)


def main() -> int:
    if OVERLAY.exists():
        shutil.rmtree(OVERLAY)
    OVERLAY.mkdir(parents=True)

    # Generate assets if needed
    sounds = ROOT / "assets" / "sounds"
    if len(list(sounds.glob("*.wav"))) < 11:
        subprocess.check_call([sys.executable, str(ROOT / "tools" / "generate_sounds.py")])
    if not (ROOT / "assets" / "aero-logo.png").exists():
        subprocess.check_call([sys.executable, str(ROOT / "tools" / "generate_branding.py")])

    (OVERLAY / "etc").mkdir(parents=True)
    (OVERLAY / "etc" / "aero-version").write_text("1.0.1\n", encoding="ascii")
    (OVERLAY / "etc" / "aero-release").write_text(
        'Aero OS 1.0.1 "Stratus"\nFoundation: FreeBSD 14.3-RELEASE\nTurnkey: offline pkgs + aero-build-desktop\n',
        encoding="ascii",
    )

    share = OVERLAY / "usr" / "local" / "share" / "aero"
    for sub in ("sounds", "store", "src", "wallpapers", "examples", "docs", "tools", "offline-packages"):
        (share / sub).mkdir(parents=True, exist_ok=True)

    for p in sounds.iterdir():
        if p.is_file():
            shutil.copy2(p, share / "sounds" / p.name)

    for name in (
        "style.css",
        "store/index.json",
        "store/catalog.example.json",
        "config/repos.conf",
        "main.swift",
        "aero-settings.swift",
        "aero-lock.swift",
        "aero-firstboot.swift",
        "aero-store.swift",
        "aero-update-ui.swift",
    ):
        src = ROOT / name
        if not src.exists():
            continue
        if name.endswith(".swift"):
            copy_into(src, share / "src" / src.name)
        elif name.startswith("store/"):
            copy_into(src, share / "store" / src.name)
        elif name.startswith("config/"):
            copy_into(src, OVERLAY / "etc" / "aero" / "repos.conf")
        else:
            copy_into(src, share / src.name)

    for tool in ("aero", "aero-sound", "aero-notify", "aero-open", "aexes", "aero-fetch-icon", "aero-windows"):
        copy_into(ROOT / "tools" / tool, OVERLAY / "usr" / "local" / "bin" / tool)

    copy_into(ROOT / "config" / "oauth.conf.example", OVERLAY / "usr" / "local" / "share" / "aero" / "docs" / "oauth.conf.example")
    copy_into(ROOT / "config" / "oauth.conf.example", OVERLAY / "etc" / "aero" / "oauth.conf.example")

    for gen in ("generate_sounds.py", "generate_branding.py"):
        copy_into(ROOT / "tools" / gen, share / "tools" / gen)

    for brand in ("aero-logo.png", "firstboot-logo.png", "start-button.png"):
        copy_into(ROOT / "assets" / brand, share / brand)
    copy_into(ROOT / "assets" / "aero-logo.png", OVERLAY / "boot" / "aero-splash.png")
    for wp in ("light.png", "dark.png", "night.png"):
        copy_into(ROOT / "assets" / "wallpapers" / wp, share / "wallpapers" / wp)

    # Project overlay tree
    proj_overlay = ROOT / "overlay"
    if proj_overlay.exists():
        for f in proj_overlay.rglob("*"):
            if f.is_file():
                rel = f.relative_to(proj_overlay)
                copy_into(f, OVERLAY / rel)

    for conf in ("installer.conf", "partition.conf"):
        copy_into(ROOT / "bsdinstall" / conf, OVERLAY / "usr" / "local" / "etc" / "bsdinstall" / "aero" / conf)
    copy_into(ROOT / "profile" / "packages.amd64", OVERLAY / "usr" / "local" / "etc" / "bsdinstall" / "aero" / "packages.amd64")
    copy_into(ROOT / "profile" / "iso.conf", share / "docs" / "iso.conf")
    copy_into(ROOT / "scripts" / "aero-updater.sh", OVERLAY / "usr" / "local" / "sbin" / "aero-updater")
    copy_into(ROOT / "releases" / "v1.0.1" / "aero-update-manifest.json", OVERLAY / "aero" / "aero-update-manifest.json")
    copy_into(ROOT / "releases" / "DOWNLOADS.md", OVERLAY / "aero" / "DOWNLOADS.md")
    copy_into(ROOT / "examples" / "hello-aero", share / "examples" / "hello-aero")

    # Offline packages
    if PKG_ALL.exists() and any(PKG_ALL.glob("*.pkg")):
        dest_all = share / "offline-packages" / "All"
        dest_all.mkdir(parents=True, exist_ok=True)
        count = 0
        for pkg in PKG_ALL.glob("*.pkg"):
            shutil.copy2(pkg, dest_all / pkg.name)
            count += 1
        print(f"Staged {count} offline packages")
        # minimal meta for pkg
        (share / "offline-packages" / "meta.conf").write_text(
            'version = "2";\ndumping_period = "0";\n', encoding="ascii"
        )

    readme = OVERLAY / "AERO-README.TXT"
    readme.write_text(
        "Aero OS 1.0.1 Stratus - turnkey path: aero-bootstrap then aero-build-desktop\n"
        "Offline packages: /usr/local/share/aero/offline-packages\n"
        "Binaries compile on FreeBSD via Swift/GTK4 (GitHub Actions workflow available).\n",
        encoding="ascii",
    )
    shutil.copy2(readme, OVERLAY / "README.TXT")

    files = sum(1 for _ in OVERLAY.rglob("*") if _.is_file())
    print(f"Overlay files: {files}")
    subprocess.check_call([sys.executable, str(ROOT / "tools" / "merge_freebsd_iso.py")])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
