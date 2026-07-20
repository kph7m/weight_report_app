# Responsive report decoration assets

All PNGs use transparent backgrounds unless the asset is explicitly a background tile. Text and dynamic content are intentionally excluded.

## Three-slice assets

Compose each family as a horizontal `Row`: fixed-width `left`, `Expanded` center with `BoxFit.fill`, and fixed-width `right`. Keep all three pieces at the same rendered height.

- `report_today_title_{left,center,right}.png`
- `report_history_ribbon_{left,center,right}.png`
- `report_comment_title_{left,center,right}.png`

## Tiled assets

- `report_background_tile.png`: repeat or cover behind the report.
- `report_bottom_lace_tile.png`: repeat horizontally along the bottom, preserving aspect ratio.

## Free-position decorations

- `report_sparkle_gold.png`
- `report_sparkle_pink.png`
- `report_flower.png`
- `report_heart.png`

Place these decorations independently in a `Stack` so they can move or disappear at narrow breakpoints.
