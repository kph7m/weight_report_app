#!/usr/bin/env python3
"""Generate Android launcher icons for Weight Report.

The adaptive-icon foreground intentionally fills about 92% of the canvas so the
launcher icon appears large after Android applies its mask and safe zone.
"""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
SIZE = 1024
FOREGROUND_FILL_RATIO = 0.93

PINK = (250, 55, 125, 255)
DEEP_PINK = (239, 64, 130, 255)
LIGHT_PINK = (255, 235, 242, 255)
BG_PINK = (255, 164, 202, 255)


def draw_background(size: int = SIZE) -> Image.Image:
    image = Image.new("RGBA", (size, size), (255, 246, 250, 255))
    draw = ImageDraw.Draw(image)
    for y in range(size):
        alpha = y / max(size - 1, 1)
        r = int(255 * (1 - alpha) + BG_PINK[0] * alpha)
        g = int(250 * (1 - alpha) + BG_PINK[1] * alpha)
        b = int(253 * (1 - alpha) + BG_PINK[2] * alpha)
        draw.line([(0, y), (size, y)], fill=(r, g, b, 255))

    pad = int(size * 0.025)
    draw.rounded_rectangle(
        [pad, pad, size - pad, size - pad],
        radius=int(size * 0.20),
        outline=(247, 93, 155, 220),
        width=max(8, int(size * 0.012)),
    )
    return image


def draw_health_widgets(draw: ImageDraw.ImageDraw, scale: float = 1.0) -> None:
    def xy(values: list[float]) -> list[int]:
        return [int(v * scale) for v in values]

    # Weight scale.
    draw.rounded_rectangle(xy([58, 65, 405, 375]), radius=int(45 * scale), fill=PINK)
    draw.pieslice(xy([95, 95, 365, 310]), 180, 360, fill=(255, 255, 255, 255))
    ticks = [
        [217, 145, 231, 190],
        [165, 165, 182, 205],
        [295, 165, 312, 205],
        [125, 218, 160, 236],
        [332, 218, 367, 236],
    ]
    for tick in ticks:
        draw.rounded_rectangle(xy(tick), radius=int(7 * scale), fill=PINK)
    draw.line([tuple(xy([238, 245])), tuple(xy([257, 150]))], fill=PINK, width=int(13 * scale))
    draw.ellipse(xy([218, 228, 274, 284]), fill=PINK)
    draw.polygon([tuple(xy(p)) for p in ([210, 315], [242, 293], [278, 315], [278, 358], [242, 390], [210, 358])], fill=(255, 255, 255, 255))

    # Weight report chart.
    for yy in [450, 520, 590, 660]:
        draw.line([tuple(xy([40, yy])), tuple(xy([470, yy]))], fill=(249, 178, 203, 100), width=int(5 * scale))
    draw.line([tuple(xy([55, 420])), tuple(xy([55, 740]))], fill=(247, 100, 157, 165), width=int(6 * scale))
    draw.line([tuple(xy([55, 740])), tuple(xy([470, 740]))], fill=(247, 100, 157, 165), width=int(6 * scale))
    points = [[55, 420], [135, 480], [220, 520], [315, 585], [420, 650]]
    draw.line([tuple(xy(p)) for p in points], fill=(239, 64, 130, 230), width=int(10 * scale), joint="curve")
    for x, y in points:
        draw.ellipse(xy([x - 20, y - 20, x + 20, y + 20]), fill=DEEP_PINK)
    for index, height in enumerate([145, 185, 135, 95, 60]):
        x = 85 + index * 78
        draw.rounded_rectangle(xy([x, 740 - height, x + 48, 740]), radius=int(5 * scale), fill=(255, 185, 208, 105))

    # Calendar.
    draw.rounded_rectangle(xy([55, 690, 320, 935]), radius=int(34 * scale), fill=(255, 255, 255, 240), outline=(250, 80, 145, 210), width=int(6 * scale))
    draw.rounded_rectangle(xy([55, 690, 320, 755]), radius=int(34 * scale), fill=DEEP_PINK)
    draw.rectangle(xy([55, 725, 320, 755]), fill=DEEP_PINK)
    for x in [115, 250]:
        draw.rounded_rectangle(xy([x - 12, 665, x + 12, 742]), radius=int(12 * scale), fill=(255, 255, 255, 255), outline=(248, 70, 135, 190), width=int(5 * scale))
    for row in range(2):
        for col in range(3):
            x = 98 + 62 * col
            y = 800 + 62 * row
            draw.rounded_rectangle(xy([x, y, x + 38, y + 38]), radius=int(6 * scale), fill=(255, 206, 222, 230))
    draw.ellipse(xy([228, 842, 300, 914]), fill=DEEP_PINK)
    draw.line([tuple(xy([248, 876])), tuple(xy([262, 891])), tuple(xy([283, 858]))], fill=(255, 255, 255, 255), width=int(9 * scale))


def draw_sparkles(draw: ImageDraw.ImageDraw, scale: float = 1.0) -> None:
    for cx, cy, radius, color in [(806, 108, 38, (232, 85, 143, 230)), (890, 176, 28, (242, 194, 37, 235))]:
        cx, cy, radius = int(cx * scale), int(cy * scale), int(radius * scale)
        width = max(3, int(5 * scale))
        draw.line([(cx, cy - radius), (cx, cy + radius)], fill=color, width=width)
        draw.line([(cx - radius, cy), (cx + radius, cy)], fill=color, width=width)
        draw.line([(cx - radius // 2, cy - radius // 2), (cx + radius // 2, cy + radius // 2)], fill=color, width=max(2, width - 2))
        draw.line([(cx - radius // 2, cy + radius // 2), (cx + radius // 2, cy - radius // 2)], fill=color, width=max(2, width - 2))


def draw_foreground(size: int = SIZE) -> Image.Image:
    foreground = Image.new("RGBA", (size, size), (255, 255, 255, 0))
    draw = ImageDraw.Draw(foreground)

    content_scale = FOREGROUND_FILL_RATIO * size / SIZE
    draw_health_widgets(draw, content_scale)
    draw_sparkles(draw, content_scale)

    character = Image.open(ROOT / "assets/images/character_report.png").convert("RGBA")
    character = character.crop(character.getbbox())
    # Oversized on purpose: adaptive icon masks crop the outer area, and the
    # requested visual treatment allows slight clipping at the edges.
    character = character.resize((int(size * 0.80), int(size * 1.11)), Image.LANCZOS)
    foreground.alpha_composite(character, (int(size * 0.30), int(size * 0.00)))
    return foreground


def composite_legacy(background: Image.Image, foreground: Image.Image) -> Image.Image:
    legacy = background.copy()
    legacy.alpha_composite(foreground)
    mask = Image.new("L", legacy.size, 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle([0, 0, legacy.size[0], legacy.size[1]], radius=int(legacy.size[0] * 0.20), fill=255)
    legacy.putalpha(mask)
    return legacy


def save_resized(source: Image.Image, path: Path, size: int) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    source.resize((size, size), Image.LANCZOS).save(path)


def write_adaptive_xml(path: Path, foreground: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        "<adaptive-icon xmlns:android=\"http://schemas.android.com/apk/res/android\">\n"
        "    <background android:drawable=\"@drawable/ic_launcher_background\" />\n"
        f"    <foreground android:drawable=\"{foreground}\" />\n"
        "</adaptive-icon>\n"
    )


def main() -> None:
    background = draw_background()
    foreground = draw_foreground()
    legacy = composite_legacy(background, foreground)

    (ROOT / "assets/images").mkdir(parents=True, exist_ok=True)
    background.save(ROOT / "assets/images/app_icon_background.png")
    foreground.save(ROOT / "assets/images/app_icon_foreground.png")
    legacy.save(ROOT / "assets/images/app_icon.png")
    legacy.save(ROOT / "docs/screenshots/app-icon.png")

    res = ROOT / "android/app/src/main/res"
    (res / "drawable-nodpi").mkdir(parents=True, exist_ok=True)
    background.save(res / "drawable-nodpi/ic_launcher_background.png")
    foreground.save(res / "drawable-nodpi/ic_launcher_foreground.png")

    write_adaptive_xml(res / "mipmap-anydpi-v26/ic_launcher.xml", "@drawable/ic_launcher_foreground")
    write_adaptive_xml(res / "mipmap-anydpi-v26/ic_launcher_round.xml", "@drawable/ic_launcher_foreground")

    for folder, size in {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }.items():
        save_resized(legacy, res / folder / "ic_launcher.png", size)
        save_resized(legacy, res / folder / "ic_launcher_round.png", size)


if __name__ == "__main__":
    main()
