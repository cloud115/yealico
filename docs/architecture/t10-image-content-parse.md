# T10 Image Content Parse

## Goal

Parse image URL lists from selected detail items for `comic/gallery` sites.

## Implemented

- Added `ImageContentLoader` abstraction and runtime implementation.
- Added `ImageContentPage`:
  - async image URL loading
  - loading/error/empty/list states
- Connected detail page action:
  - `Parse Images (T10)` for non-video sites
  - video sites are marked for `T12`

## Boundaries

- This step only extracts and displays image URLs.
- No reader interaction (paging/gesture) is implemented in this step (`T11`).
- No video content parse/playback is implemented in this step (`T12+`).
