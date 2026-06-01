#!/usr/bin/env python3
"""Generate iDoubtIt app icons (iOS AppIcon + web favicons) from the game theme."""

from __future__ import annotations

import json
import math
import os
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
APP_ICON_DIR = ROOT / "iDoubtIt" / "Game.xcassets" / "AppIcon.appiconset"
WEB_ICON_DIR = ROOT / "assets" / "icons"

# GameTheme / index.html palette
BG_TOP = (51, 128, 219)
BG_BOTTOM = (13, 51, 102)
FELT = (26, 112, 82)
FELT_BORDER = (12, 77, 56)
GOLD = (255, 214, 89)
WHITE = (255, 255, 255)

IOS_SLOTS = [
    ("icon-40.png", "iphone", "20x20", "2x"),
    ("icon-60.png", "iphone", "20x20", "3x"),
    ("icon-58.png", "iphone", "29x29", "2x"),
    ("icon-87.png", "iphone", "29x29", "3x"),
    ("icon-80.png", "iphone", "40x40", "2x"),
    ("icon-120.png", "iphone", "40x40", "3x"),
    ("icon-120.png", "iphone", "60x60", "2x"),
    ("icon-180.png", "iphone", "60x60", "3x"),
    ("icon-20-ipad.png", "ipad", "20x20", "1x"),
    ("icon-40-ipad.png", "ipad", "20x20", "2x"),
    ("icon-29-ipad.png", "ipad", "29x29", "1x"),
    ("icon-58-ipad.png", "ipad", "29x29", "2x"),
    ("icon-40-ipad-1x.png", "ipad", "40x40", "1x"),
    ("icon-80-ipad.png", "ipad", "40x40", "2x"),
    ("icon-76.png", "ipad", "76x76", "1x"),
    ("icon-152.png", "ipad", "76x76", "2x"),
    ("icon-167.png", "ipad", "83.5x83.5", "2x"),
    ("icon-1024.png", "ios-marketing", "1024x1024", "1x"),
]

WEB_SIZES = {
    "favicon-16.png": 16,
    "favicon-32.png": 32,
    "apple-touch-icon.png": 180,
    "icon-192.png": 192,
    "icon-512.png": 512,
}


def lerp(a: int, b: int, t: float) -> int:
    return int(a + (b - a) * t)


def gradient_bg(size: int) -> Image.Image:
    img = Image.new("RGBA", (size, size))
    px = img.load()
    for y in range(size):
        t = y / max(size - 1, 1)
        r = lerp(BG_TOP[0], BG_BOTTOM[0], t)
        g = lerp(BG_TOP[1], BG_BOTTOM[1], t)
        b = lerp(BG_TOP[2], BG_BOTTOM[2], t)
        for x in range(size):
            px[x, y] = (r, g, b, 255)
    return img


def load_font(size: int) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = [
        "/System/Library/Fonts/Supplemental/Arial Unicode.ttf",
        "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/Library/Fonts/Arial Unicode.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    ]
    for path in candidates:
        if os.path.isfile(path):
            try:
                return ImageFont.truetype(path, size)
            except OSError:
                pass
    return ImageFont.load_default()


def draw_icon(size: int) -> Image.Image:
    img = gradient_bg(size)
    draw = ImageDraw.Draw(img)
    pad = size * 0.08
    cx, cy = size / 2, size / 2
    compact = size < 48

    # Felt table ellipse
    rx = size * (0.40 if compact else 0.36)
    ry = size * (0.26 if compact else 0.22)
    bbox = (cx - rx, cy - ry, cx + rx, cy + ry)
    draw.ellipse(bbox, fill=FELT + (255,), outline=FELT_BORDER + (255,), width=max(1, size // 64))

    if not compact:
        inset = size * 0.04
        draw.ellipse(
            (cx - rx + inset, cy - ry + inset, cx + rx - inset, cy + ry - inset),
            outline=(255, 255, 255, 40),
            width=max(1, size // 128),
        )

        suits = [
            ("\u2660", WHITE, (-0.52, -0.38)),
            ("\u2665", (255, 120, 120), (-0.52, 0.38)),
            ("\u2666", (255, 120, 120), (0.52, -0.38)),
            ("\u2663", WHITE, (0.52, 0.38)),
        ]
        suit_size = max(8, int(size * 0.14))
        font_suits = load_font(suit_size)
        for ch, color, (ox, oy) in suits:
            sx = cx + ox * size * 0.34
            sy = cy + oy * size * 0.28
            draw.text((sx, sy), ch, fill=color + (255,), font=font_suits, anchor="mm")

    # Gold "!" doubt badge
    badge_scale = 0.20 if compact else 0.11
    mark_size = max(10, int(size * (0.34 if compact else 0.22)))
    font_mark = load_font(mark_size)
    bw, bh = size * badge_scale, size * (0.30 if compact else 0.16)
    draw.rounded_rectangle(
        (cx - bw, cy - bh, cx + bw, cy + bh),
        radius=max(2, size // 24),
        fill=GOLD + (255,),
        outline=(180, 140, 40, 255),
        width=max(1, size // 128),
    )
    draw.text((cx, cy), "!", fill=BG_BOTTOM + (255,), font=font_mark, anchor="mm")

    # Subtle vignette for depth
    if size >= 64:
        overlay = Image.new("RGBA", (size, size), (0, 0, 0, 0))
        od = ImageDraw.Draw(overlay)
        od.ellipse(
            (pad, pad, size - pad, size - pad),
            outline=(0, 0, 0, 35),
            width=max(1, size // 48),
        )
        img = Image.alpha_composite(img.convert("RGBA"), overlay)

    return img.convert("RGB")


def write_app_icon_set() -> None:
    APP_ICON_DIR.mkdir(parents=True, exist_ok=True)
    images = []
    for filename, idiom, size_str, scale in IOS_SLOTS:
        base = max(float(x) for x in size_str.split("x"))
        multiplier = int(scale.replace("x", ""))
        px = round(base * multiplier)
        if idiom == "ios-marketing":
            px = 1024
        icon = draw_icon(px)
        out = APP_ICON_DIR / filename
        icon.save(out, "PNG", optimize=True)
        entry = {
            "filename": filename,
            "idiom": idiom,
            "scale": scale,
            "size": size_str,
        }
        images.append(entry)
        print(f"  {filename} ({px}px)")

    contents = {"images": images, "info": {"author": "generate_icons.py", "version": 1}}
    (APP_ICON_DIR / "Contents.json").write_text(json.dumps(contents, indent=2) + "\n")


def write_web_icons() -> None:
    WEB_ICON_DIR.mkdir(parents=True, exist_ok=True)
    for filename, px in WEB_SIZES.items():
        draw_icon(px).save(WEB_ICON_DIR / filename, "PNG", optimize=True)
        print(f"  web/{filename} ({px}px)")


def main() -> None:
    print("Generating iOS AppIcon…")
    write_app_icon_set()
    print("Generating web icons…")
    write_web_icons()
    print("Done.")


if __name__ == "__main__":
    main()
