"""Shared helpers for Aero OS Python GTK4 desktop apps."""

from __future__ import annotations

import os
import shutil
import subprocess
import sys
from pathlib import Path

APPEARANCE_MODES = ("light", "dark", "night")
_LAYER_MODE = None  # "gi", "ctypes", or None


def share_dir() -> Path:
    return Path(os.environ.get("AERO_SHARE", "/usr/local/share/aero"))


def config_dir() -> Path:
    d = Path.home() / ".config" / "aero"
    d.mkdir(parents=True, exist_ok=True)
    return d


def _repo_style() -> Path | None:
    here = Path(__file__).resolve().parent
    for rel in (here / ".." / "style.css", here / ".." / ".." / "style.css"):
        p = rel.resolve()
        if p.is_file():
            return p
    return None


def style_path() -> Path | None:
    for p in (share_dir() / "style.css", _repo_style()):
        if p and p.is_file():
            return p
    return None


def _ensure_gtk():
    try:
        import gi

        gi.require_version("Gtk", "4.0")
        from gi.repository import Gtk  # noqa: F401

        return gi
    except Exception as exc:
        ver = f"{sys.version_info.major}{sys.version_info.minor}"
        print(
            f"aero-gtk: GTK4 bindings unavailable ({exc}).\n"
            f"Install: pkg install py{ver}-pygobject gtk4",
            file=sys.stderr,
        )
        sys.exit(1)


def load_css(widget) -> None:
    gi = _ensure_gtk()
    from gi.repository import Gtk

    path = style_path()
    if not path:
        return
    provider = Gtk.CssProvider()
    provider.load_from_path(str(path))
    Gtk.StyleContext.add_provider_for_display(
        widget.get_display(),
        provider,
        Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION,
    )


def play_sound(name: str) -> None:
    exe = shutil.which("aero-sound")
    if not exe:
        return
    try:
        subprocess.Popen([exe, name], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except OSError:
        pass


def read_appearance() -> str:
    p = config_dir() / "appearance"
    if p.is_file():
        mode = p.read_text(encoding="utf-8").strip().lower()
        if mode in APPEARANCE_MODES:
            return mode
    legacy = config_dir() / "display.conf"
    if legacy.is_file():
        for line in legacy.read_text(encoding="utf-8").splitlines():
            if line.startswith("appearance="):
                mode = line.split("=", 1)[1].strip().lower()
                if mode in APPEARANCE_MODES:
                    return mode
    return "dark"


def write_appearance(mode: str) -> None:
    if mode not in APPEARANCE_MODES:
        raise ValueError(f"appearance must be one of {APPEARANCE_MODES}")
    (config_dir() / "appearance").write_text(mode + "\n", encoding="utf-8")


def read_sound_enabled() -> bool:
    p = config_dir() / "sound.conf"
    if not p.is_file():
        return True
    for line in p.read_text(encoding="utf-8").splitlines():
        if line.startswith("enabled="):
            v = line.split("=", 1)[1].strip().lower()
            return v not in ("0", "false", "no", "off")
    return True


def write_sound_enabled(enabled: bool) -> None:
    p = config_dir() / "sound.conf"
    lines: list[str] = []
    if p.is_file():
        for line in p.read_text(encoding="utf-8").splitlines():
            if not line.startswith("enabled="):
                lines.append(line)
    lines.append(f"enabled={'1' if enabled else '0'}")
    p.write_text("\n".join(lines) + "\n", encoding="utf-8")


def spawn(cmd: list[str] | str, **kwargs) -> subprocess.Popen | None:
    try:
        if isinstance(cmd, str):
            return subprocess.Popen(cmd, shell=True, **kwargs)
        return subprocess.Popen(cmd, **kwargs)
    except OSError as exc:
        print(f"aero-gtk: failed to run {cmd!r}: {exc}", file=sys.stderr)
        return None


def import_gtk():
    gi = _ensure_gtk()
    from gi.repository import Gdk, Gio, GLib, Gtk

    return gi, Gtk, Gdk, GLib, Gio


def _init_layer_gi(window, namespace: str = "aero-desktop") -> bool:
    try:
        import gi

        gi.require_version("Gtk4LayerShell", "1.0")
        from gi.repository import Gtk4LayerShell

        Gtk4LayerShell.init_for_window(window)
        Gtk4LayerShell.set_layer(window, Gtk4LayerShell.Layer.BACKGROUND)
        Gtk4LayerShell.set_namespace(window, namespace)
        for edge in (
            Gtk4LayerShell.Edge.TOP,
            Gtk4LayerShell.Edge.BOTTOM,
            Gtk4LayerShell.Edge.LEFT,
            Gtk4LayerShell.Edge.RIGHT,
        ):
            Gtk4LayerShell.set_anchor(window, edge, True)
        Gtk4LayerShell.set_exclusive_zone(window, -1)
        Gtk4LayerShell.set_keyboard_mode(window, Gtk4LayerShell.KeyboardMode.NONE)
        return True
    except Exception:
        return False


def _init_layer_ctypes(window, namespace: str = "aero-desktop") -> bool:
    import ctypes

    for libname in ("gtk4-layer-shell-0", "gtk4-layer-shell", "libgtk4-layer-shell.so.0"):
        try:
            lib = ctypes.CDLL(libname)
            break
        except OSError:
            lib = None
    if lib is None:
        return False

    c_bool = ctypes.c_bool
    c_int = ctypes.c_int
    try:
        win_p = ctypes.c_void_p(int(window.__gpointer__))  # type: ignore[attr-defined]
    except AttributeError:
        return False

    lib.gtk_layer_init_for_window(win_p)
    lib.gtk_layer_set_layer(win_p, c_int(0))
    lib.gtk_layer_set_namespace(win_p, namespace.encode())
    for edge in (0, 1, 2, 3):
        lib.gtk_layer_set_anchor(win_p, c_int(edge), c_bool(True))
    lib.gtk_layer_set_exclusive_zone(win_p, c_int(-1))
    lib.gtk_layer_set_keyboard_mode(win_p, c_int(0))
    return True


def setup_layer_shell(window, namespace: str = "aero-desktop") -> str:
    """Return mode used: 'gi', 'ctypes', or 'fallback'."""
    global _LAYER_MODE
    if _init_layer_gi(window, namespace):
        _LAYER_MODE = "gi"
        return "gi"
    if _init_layer_ctypes(window, namespace):
        _LAYER_MODE = "ctypes"
        return "ctypes"
    _LAYER_MODE = "fallback"
    return "fallback"


def apply_wallpaper_class(widget, mode: str | None = None) -> None:
    mode = mode or read_appearance()
    for m in APPEARANCE_MODES:
        widget.remove_css_class(f"wallpaper-{m}")
    widget.add_css_class(f"wallpaper-{mode}")


def add_common_import_path() -> None:
    """Allow imports when installed under /usr/local/bin."""
    lib = share_dir() / "lib"
    here = Path(__file__).resolve().parent
    for p in (lib, here):
        s = str(p)
        if s not in sys.path:
            sys.path.insert(0, s)
