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

    for tool in (
        "aero",
        "aero-sound",
        "aero-notify",
        "aero-open",
        "aexes",
        "aero-fetch-icon",
        "aero-windows",
        "aero-shell-lite",
        "aero-settings-lite",
        "aero-lock-lite",
        "aero-store-lite",
        "aero-firstboot-lite",
        "aero-shell-gtk",
        "aero-settings-gtk",
        "aero-lock-gtk",
        "aero-store-gtk",
        "aero-firstboot-gtk",
        "aero-shell",
        "aero-settings",
        "aero-lock",
        "aero-store",
        "aero-firstboot",
    ):
        copy_into(ROOT / "tools" / tool, OVERLAY / "usr" / "local" / "bin" / tool)
        copy_into(ROOT / "tools" / tool, share / "tools" / tool)

    # Shared Python GTK helpers
    lib = share / "lib"
    lib.mkdir(parents=True, exist_ok=True)
    copy_into(ROOT / "tools" / "aero_gtk_common.py", lib / "aero_gtk_common.py")
    copy_into(ROOT / "tools" / "aero_gtk_common.py", OVERLAY / "usr" / "local" / "bin" / "aero_gtk_common.py")

    bin_dir = OVERLAY / "usr" / "local" / "bin"

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

    # Offline packages (skip huge toolchain blobs to stay under GitHub 2GB ISO limit)
    if PKG_ALL.exists() and any(PKG_ALL.glob("*.pkg")):
        dest_all = share / "offline-packages" / "All"
        dest_all.mkdir(parents=True, exist_ok=True)
        count = 0
        skipped = 0
        skip_prefixes = ("llvm", "gcc", "rust", "swift510")
        for pkg in PKG_ALL.glob("*.pkg"):
            if pkg.name.lower().startswith(skip_prefixes):
                skipped += 1
                continue
            shutil.copy2(pkg, dest_all / pkg.name)
            count += 1
        print(f"Staged {count} offline packages (skipped {skipped} toolchain pkgs)")
        (share / "offline-packages" / "meta.conf").write_text(
            'version = "2";\ndumping_period = "0";\n', encoding="ascii"
        )

    # Prebuilt FreeBSD amd64 desktop ELFs (from Actions / release download)
    bin_dir = OVERLAY / "usr" / "local" / "bin"
    bin_dir.mkdir(parents=True, exist_ok=True)
    prebuilt_candidates = [
        ROOT / "out-bin",
        ROOT / ".cache" / "aero-desktop",
        ROOT / "out" / "aero-desktop",
    ]
    tarball = ROOT / "out" / "aero-desktop-amd64.tar.xz"
    if not tarball.exists():
        tarball = ROOT / ".cache" / "aero-desktop-amd64.tar.xz"
    if tarball.exists():
        extract = ROOT / "build-workspace" / "prebuilt-bins"
        if extract.exists():
            shutil.rmtree(extract)
        extract.mkdir(parents=True)
        subprocess.check_call(["tar", "-xJf", str(tarball), "-C", str(extract)])
        prebuilt_candidates.insert(0, extract)
        print(f"Extracted prebuilt tarball: {tarball.name}")

    injected = 0
    for cand in prebuilt_candidates:
        if not cand.is_dir():
            continue
        for name in (
            "aero-shell",
            "aero-settings",
            "aero-lock",
            "aero-firstboot",
            "aero-store",
            "aero-update-ui",
        ):
            src = cand / name
            if src.is_file():
                dst = bin_dir / name
                shutil.copy2(src, dst)
                dst.chmod(0o755)
                injected += 1
        if injected:
            print(f"Injected {injected} prebuilt desktop binaries from {cand}")
            break
    if not injected:
        print("NOTE: no prebuilt aero-shell yet — ISO will bootstrap/compile on first boot")

    readme = OVERLAY / "AERO-README.TXT"
    readme.write_text(
        "Aero OS 1.0.1 Stratus - liquid glass desktop via aero-shell-gtk (Python GTK4).\n"
        "Includes Firefox, Wine, Python/PyGObject. Start menu: Super+Space.\n"
        "Dock + top bar use style.css glass theme. Optional Swift: offline zip / AERO_COMPILE=1.\n",
        encoding="ascii",
    )
    shutil.copy2(readme, OVERLAY / "README.TXT")

    files = sum(1 for _ in OVERLAY.rglob("*") if _.is_file())
    print(f"Overlay files: {files}")
    subprocess.check_call([sys.executable, str(ROOT / "tools" / "merge_freebsd_iso.py")])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
