# Responsive report decoration assets

All PNGs use transparent backgrounds unless the asset is explicitly a background tile. Text and dynamic content are intentionally excluded.

## Three-slice assets

Compose each family as a horizontal `Row`: fixed-width `left`, `Expanded` center with `BoxFit.fill`, and fixed-width `right`. Keep all three pieces at the same rendered height.

- `report_today_title_{left,center,right}.png`
- `report_history_ribbon_{left,center,right}.png`
- `report_comment_title_{left,center,right}.png`

## Tiled assets

- `report_background_tile.png`: repeat or cover behind the report.

## Free-position decorations

- `report_sparkle_gold.png`
- `report_sparkle_pink.png`
- `report_flower.png`
- `report_heart.png`

Place these decorations independently in a `Stack` so they can move or disappear at narrow breakpoints.

## Comment panel assets

The `めたんからのひとこと` panel is split into independently scalable pieces so the AI comment remains live Flutter text.

- `report_comment_panel_frame.png`: transparent ornamental frame. Render it behind the panel with `centerSlice: Rect.fromLTWH(180, 180, 408, 450)` and `fit: BoxFit.fill` so the corners, bottom wave, and bow keep their shape.
- `report_comment_heading_{left,center,right}.png`: three-slice heading ribbon. Keep the two caps fixed and stretch only the center below a Flutter-rendered heading.
- `report_comment_divider.png`: dotted separator between comment paragraphs; stretch it horizontally.
- `report_comment_ornament.png`: optional flower-and-heart end ornament for free positioning.

A contact sheet for reviewing these assets is stored at `docs/specs/report-comment-assets-preview.png`.
