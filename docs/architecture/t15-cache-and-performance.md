# T15 Cache and Baseline Performance

## Goal

Add baseline runtime optimizations without changing business behavior.

## Implemented

- Added generic TTL cache utility:
  - `lib/core/cache/ttl_cache.dart`
- Added HTML request-level short-term cache in fetcher:
  - cache key by URL + headers + charset
  - cache enabled by default
  - configurable TTL
- Added timeout normalization in fetcher:
  - lower bound: 3s
  - upper bound: 30s
- Improved reader UX performance:
  - adjacent image prefetch (prev/next)
  - loading indicator during image network loading

## Boundaries

- Cache is in-memory only.
- No persistent cache store in this step.
- No aggressive media preloading policy in this step.
