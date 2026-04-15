# T13 Video Player

## Goal

Integrate a playable video page for parsed video URLs.

## Implemented

- Added `VideoPlayerPage` based on `video_player`:
  - network URL initialization
  - play/pause control
  - timeline slider and time labels
  - error state for invalid/failed initialization
- Connected `VideoContentPage` action:
  - `Play Video (T13)` -> `VideoPlayerPage`

## Dependency

- Added `video_player` for cross-platform Android/Web playback support.

## Boundaries

- Basic playback controls only.
- Fullscreen/advanced player behavior can be enhanced later.
