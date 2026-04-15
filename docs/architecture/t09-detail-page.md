# T09 Detail Parse and Display

## Goal

Parse and display detail-level items (chapters/albums/episodes) from a selected catalog item.

## Implemented

- Added `DetailLoader` abstraction and `RuntimeDetailLoader`.
- Added `DetailListPage`:
  - async detail loading
  - loading/error/empty/list states
  - detail item metadata rendering (`title`, `url`)
- Connected catalog item card action:
  - `Open Details (T09)` -> `DetailListPage`

## Boundaries

- This step only displays detail list.
- No content parsing page integration in this step (`T10+`).
- No persistence integration in this step.
