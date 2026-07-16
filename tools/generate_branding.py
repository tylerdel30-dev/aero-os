#!/usr/bin/env python3
"""Generate Aero OS branding: metallic silver A logo + Light/Dark/Night wallpapers."""

from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets"
WALL = ASSETS / "wallpapers"


def lerp(a: float, b: float, t: float) -> float:
    return a + (b - a) * t


def mix(c1: tuple[int, int, int], c2: tuple[int, int, int], t: float) -> tuple[int, int, int]:
    return (
        int(lerp(c1[0], c2[0], t)),
        int(lerp(c1[1], c2[1], t)),
        int(lerp(c1[2], c2[2], t)),
    )


def vertical_gradient(size: tuple[int, int], top: tuple[int, int, int], bottom: tuple[int, int, int]) -> Image.Image:
    w, h = size
    img = Image.new("RGB", size)
    px = img.load()
    for y in range(h):
        t = y / max(1, h - 1)
        c = mix(top, bottom, t)
        for x in range(w):
            px[x, y] = c
    return img


def soft_orb(img: Image.Image, cx: float, cy: float, radius: float, color: tuple[int, int, int], alpha: int) -> Image.Image:
    base = img.convert("RGBA")
    overlay = Image.new("RGBA", img.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    r = int(radius)
    draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(*color, alpha))
    blurred = overlay.filter(ImageFilter.GaussianBlur(radius=max(8, r // 4)))
    return Image.alpha_composite(base, blurred).convert("RGB")


def draw_metallic_a(size: int, bg: tuple[int, int, int] | None = None) -> Image.Image:
    """Silver metallic A mark — glass/chrome feel, not a stock system font logo."""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0) if bg is None else (*bg, 255))
    draw = ImageDraw.Draw(img)

    # Soft silver disc behind the A
    margin = size * 0.08
    draw.ellipse(
        [margin, margin, size - margin, size - margin],
        fill=(210, 218, 228, 40 if bg is None else 255),
    )

    # Try a clean bold font; fall back to default
    font = None
    for name in (
        "C:/Windows/Fonts/seguisb.ttf",  # Segoe UI Semibold
        "C:/Windows/Fonts/segoeuib.ttf",
        "C:/Windows/Fonts/arialbd.ttf",
        "C:/Windows/Fonts/arial.ttf",
    ):
        p = Path(name)
        if p.exists():
            try:
                font = ImageFont.truetype(str(p), int(size * 0.62))
                break
            except OSError:
                pass
    if font is None:
        font = ImageFont.load_default()

    text = "A"
    # Center text
    bbox = draw.textbbox((0, 0), text, font=font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    x = (size - tw) / 2 - bbox[0]
    y = (size - th) / 2 - bbox[1] - size * 0.03

    # Layered silver strokes for metallic depth
    layers = [
        ((120, 130, 145, 255), 4),
        ((180, 190, 205, 255), 2),
        ((235, 240, 248, 255), 0),
    ]
    for color, offset in layers:
        draw.text((x - offset * 0.3, y + offset * 0.2), text, font=font, fill=color)

    # Highlight sheen
    sheen = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    sd = ImageDraw.Draw(sheen)
    sd.ellipse(
        [size * 0.18, size * 0.12, size * 0.55, size * 0.42],
        fill=(255, 255, 255, 55),
    )
    sheen = sheen.filter(ImageFilter.GaussianBlur(radius=size * 0.04))
    img = Image.alpha_composite(img, sheen)
    return img


def make_wallpaper(kind: str, size: tuple[int, int] = (2560, 1440)) -> Image.Image:
    w, h = size
    if kind == "light":
        # Soft morning silver-blue sky
        img = vertical_gradient(size, (232, 238, 246), (198, 210, 224))
        img = soft_orb(img, w * 0.72, h * 0.28, h * 0.35, (255, 255, 255), 90)
        img = soft_orb(img, w * 0.25, h * 0.7, h * 0.4, (180, 200, 220), 50)
    elif kind == "dark":
        # Sunset horizon — warm amber into deep slate (not purple)
        img = vertical_gradient(size, (45, 52, 68), (18, 20, 28))
        img = soft_orb(img, w * 0.5, h * 0.62, h * 0.28, (255, 160, 90), 70)
        img = soft_orb(img, w * 0.5, h * 0.68, h * 0.12, (255, 210, 140), 100)
        # horizon band
        band = Image.new("RGBA", size, (0, 0, 0, 0))
        bd = ImageDraw.Draw(band)
        bd.rectangle([0, int(h * 0.58), w, h], fill=(25, 28, 36, 180))
        img = Image.alpha_composite(img.convert("RGBA"), band).convert("RGB")
    else:  # night
        img = vertical_gradient(size, (12, 16, 28), (4, 6, 12))
        img = soft_orb(img, w * 0.78, h * 0.22, h * 0.08, (220, 230, 255), 40)
        # stars
        px = img.load()
        for i in range(180):
            x = int((math.sin(i * 12.9898) * 43758.5453) % 1 * w)
            y = int((math.sin(i * 78.233) * 12345.678) % 1 * h * 0.65)
            b = 180 + (i % 75)
            if 0 <= x < w and 0 <= y < h:
                px[x, y] = (b, b, min(255, b + 20))
    # subtle vignette
    vig = Image.new("RGBA", size, (0, 0, 0, 0))
    vd = ImageDraw.Draw(vig)
    for i in range(40):
        a = int(i * 1.8)
        vd.rectangle([i, i, w - 1 - i, h - 1 - i], outline=(0, 0, 0, a))
    return Image.alpha_composite(img.convert("RGBA"), vig).convert("RGB")


def main() -> None:
    ASSETS.mkdir(parents=True, exist_ok=True)
    WALL.mkdir(parents=True, exist_ok=True)

    logo = draw_metallic_a(1024)
    logo.save(ASSETS / "aero-logo.png", optimize=True)
    print(f"wrote {ASSETS / 'aero-logo.png'}")

    first = draw_metallic_a(1024)
    first.save(ASSETS / "firstboot-logo.png", optimize=True)
    print(f"wrote {ASSETS / 'firstboot-logo.png'}")

    start = draw_metallic_a(256)
    start.save(ASSETS / "start-button.png", optimize=True)
    print(f"wrote {ASSETS / 'start-button.png'}")

    for kind in ("light", "dark", "night"):
        wp = make_wallpaper(kind)
        path = WALL / f"{kind}.png"
        wp.save(path, optimize=True)
        print(f"wrote {path} ({wp.size[0]}x{wp.size[1]})")


if __name__ == "__main__":
    main()
