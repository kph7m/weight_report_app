#!/usr/bin/env python3
"""Generate launcher icons from the supplied app icon asset.

This script intentionally does not draw, synthesize, or alter the artwork.
It delegates all platform-size generation to flutter_launcher_icons using
``assets/images/app_icon.png`` as the single source image.
"""
from __future__ import annotations

import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FLUTTER = Path("/workspace/flutter/bin/flutter")
SOURCE_ICON = ROOT / "assets/images/app_icon.png"


def main() -> None:
    if not SOURCE_ICON.is_file():
        raise FileNotFoundError(f"Missing source icon: {SOURCE_ICON}")

    subprocess.run(
        [str(FLUTTER), "pub", "run", "flutter_launcher_icons"],
        cwd=ROOT,
        check=True,
    )


if __name__ == "__main__":
    main()
