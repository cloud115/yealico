# T11 Image Reader

## Goal

Provide basic comic/gallery reading experience:

- left/right page turning by tap
- swipe page turning
- page index display

## Implemented

- Added `ImageReaderPage`:
  - `PageView` for swipe navigation
  - tap zones for previous/next navigation
  - bottom page indicator (`current / total`)
  - zoomable image view (`InteractiveViewer`)
- Added `Open Reader (T11)` action in image content page.

## Boundaries

- Reader keeps basic behavior only.
- No reading history writeback in this step.
- No advanced preloading/cache strategy in this step.
