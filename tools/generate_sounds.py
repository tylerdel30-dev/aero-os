#!/usr/bin/env python3
"""Generate Aero OS chill sound scheme — soft, glassy, low-intensity UI audio."""

from __future__ import annotations

import math
import struct
import wave
from pathlib import Path

SR = 44100


def clamp(x: float) -> float:
    return max(-1.0, min(1.0, x))


def env(t: float, attack: float, release: float, dur: float) -> float:
    if t < attack:
        return t / attack if attack > 0 else 1.0
    if t > dur - release:
        remain = dur - t
        return max(0.0, remain / release) if release > 0 else 0.0
    return 1.0


def tone(freq: float, t: float) -> float:
    return math.sin(2 * math.pi * freq * t)


def soft_noise(t: float, seed: float = 12.3) -> float:
    # Deterministic soft noise (no import random needed)
    x = math.sin(t * 9123.1 + seed) * 43758.5453
    return (x - math.floor(x)) * 2 - 1


def write_wav(path: Path, samples: list[float]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        frames = b"".join(struct.pack("<h", int(clamp(s) * 32767)) for s in samples)
        w.writeframes(frames)


def gen_startup(dur: float = 2.4) -> list[float]:
    """Warm rising pad — boot / welcome."""
    out = []
    freqs = [196.0, 246.94, 293.66, 392.0]  # G3-ish chill stack
    for i in range(int(SR * dur)):
        t = i / SR
        e = env(t, 0.35, 0.9, dur) ** 1.2
        s = 0.0
        for n, f in enumerate(freqs):
            s += tone(f, t) * (0.22 / (n + 1))
            s += tone(f * 2.0, t) * 0.04
        s += soft_noise(t) * 0.015 * e
        # gentle high shimmer
        s += tone(784.0, t) * 0.03 * env(t, 0.8, 1.0, dur)
        out.append(s * e * 0.55)
    return out


def gen_shutdown(dur: float = 1.8) -> list[float]:
    """Descending soft pad."""
    out = []
    freqs = [392.0, 329.63, 261.63, 196.0]
    for i in range(int(SR * dur)):
        t = i / SR
        e = env(t, 0.1, 1.1, dur)
        s = sum(tone(f, t) * (0.2 / (n + 1)) for n, f in enumerate(freqs))
        out.append(s * e * 0.5)
    return out


def gen_notification(dur: float = 0.55) -> list[float]:
    """Two soft glassy chimes."""
    out = []
    for i in range(int(SR * dur)):
        t = i / SR
        e1 = env(t, 0.01, 0.35, 0.4) if t < 0.4 else 0.0
        e2 = env(t - 0.12, 0.01, 0.35, 0.4) if t >= 0.12 else 0.0
        s = tone(659.25, t) * 0.28 * e1 + tone(830.61, t) * 0.22 * e2
        s += tone(1318.5, t) * 0.05 * e1
        out.append(s * 0.7)
    return out


def gen_click(dur: float = 0.08) -> list[float]:
    """Quiet UI tap."""
    out = []
    for i in range(int(SR * dur)):
        t = i / SR
        e = env(t, 0.001, 0.06, dur)
        s = tone(1200, t) * 0.15 + soft_noise(t, 2.0) * 0.08
        out.append(s * e * 0.45)
    return out


def gen_hover(dur: float = 0.12) -> list[float]:
    """Barely-there glass tick."""
    out = []
    for i in range(int(SR * dur)):
        t = i / SR
        e = env(t, 0.002, 0.09, dur)
        s = tone(1480, t) * 0.08 + tone(2220, t) * 0.03
        out.append(s * e * 0.35)
    return out


def gen_success(dur: float = 0.7) -> list[float]:
    """Soft major arpeggio."""
    out = []
    notes = [(0.0, 523.25), (0.12, 659.25), (0.24, 783.99)]
    for i in range(int(SR * dur)):
        t = i / SR
        s = 0.0
        for start, f in notes:
            if t >= start:
                local = t - start
                e = env(local, 0.01, 0.4, 0.5)
                s += tone(f, t) * 0.2 * e
        out.append(s * 0.65)
    return out


def gen_error(dur: float = 0.45) -> list[float]:
    """Soft low dissonance — never harsh."""
    out = []
    for i in range(int(SR * dur)):
        t = i / SR
        e = env(t, 0.02, 0.25, dur)
        s = tone(220, t) * 0.22 + tone(233, t) * 0.18
        out.append(s * e * 0.5)
    return out


def gen_lock(dur: float = 0.5) -> list[float]:
    """Descending two-tone lock."""
    out = []
    for i in range(int(SR * dur)):
        t = i / SR
        e1 = env(t, 0.01, 0.25, 0.35)
        e2 = env(max(0, t - 0.15), 0.01, 0.25, 0.35) if t > 0.15 else 0.0
        s = tone(520, t) * 0.2 * e1 + tone(390, t) * 0.2 * e2
        out.append(s * 0.6)
    return out


def gen_unlock(dur: float = 0.55) -> list[float]:
    """Ascending unlock."""
    out = []
    for i in range(int(SR * dur)):
        t = i / SR
        e1 = env(t, 0.01, 0.25, 0.35)
        e2 = env(max(0, t - 0.14), 0.01, 0.3, 0.4) if t > 0.14 else 0.0
        s = tone(390, t) * 0.2 * e1 + tone(585, t) * 0.22 * e2
        out.append(s * 0.6)
    return out


def gen_volume(dur: float = 0.18) -> list[float]:
    """Volume tick."""
    out = []
    for i in range(int(SR * dur)):
        t = i / SR
        e = env(t, 0.005, 0.12, dur)
        s = tone(880, t) * 0.18
        out.append(s * e * 0.5)
    return out


def gen_message(dur: float = 0.65) -> list[float]:
    """Softer notification variant."""
    out = []
    for i in range(int(SR * dur)):
        t = i / SR
        e = env(t, 0.02, 0.4, dur)
        s = tone(587.33, t) * 0.2 + tone(880, t) * 0.12 * env(t, 0.05, 0.35, dur)
        out.append(s * e * 0.55)
    return out


def main() -> None:
    root = Path(__file__).resolve().parents[1] / "assets" / "sounds"
    sounds = {
        "startup.wav": gen_startup(),
        "shutdown.wav": gen_shutdown(),
        "notification.wav": gen_notification(),
        "message.wav": gen_message(),
        "click.wav": gen_click(),
        "hover.wav": gen_hover(),
        "success.wav": gen_success(),
        "error.wav": gen_error(),
        "lock.wav": gen_lock(),
        "unlock.wav": gen_unlock(),
        "volume.wav": gen_volume(),
    }
    for name, samples in sounds.items():
        path = root / name
        write_wav(path, samples)
        print(f"wrote {path} ({len(samples) / SR:.2f}s)")

    scheme = root / "scheme.json"
    scheme.write_text(
        """{
  "name": "Aero Chill Glass",
  "version": "1.0.1",
  "description": "Soft glassy UI sounds — warm pads, quiet chimes, never harsh. Matches Aero's translucent desktop.",
  "events": {
    "startup": "startup.wav",
    "shutdown": "shutdown.wav",
    "notification": "notification.wav",
    "message": "message.wav",
    "click": "click.wav",
    "hover": "hover.wav",
    "success": "success.wav",
    "error": "error.wav",
    "lock": "lock.wav",
    "unlock": "unlock.wav",
    "volume": "volume.wav"
  },
  "default_volume": 0.55,
  "style": "chill"
}
""",
        encoding="utf-8",
    )
    print(f"wrote {scheme}")


if __name__ == "__main__":
    main()
