# T12 Video Content Parse

## Goal

Parse the actual video URL from selected detail items for `video` sites.

## Implemented

- Added `VideoContentLoader` abstraction and runtime implementation.
- Added `VideoContentPage`:
  - async video URL loading
  - loading/error/empty/display states
- Connected detail page action:
  - `Parse Video URL (T12)` for video sites
  - comic/gallery routes still go to image flow

## Boundaries

- This step only parses and displays video URL.
- Video playback integration is not included in this step (`T13`).
