# T14 Error and Logging Policy

## Goal

Implement dev/prod user-facing error split and unified internal logging.

## Implemented

- Added runtime config holder:
  - `lib/core/config/app_runtime.dart`
  - initialized in bootstrap
- Added internal logger:
  - `lib/core/logging/app_logger.dart`
- Added user-facing error policy:
  - `lib/core/errors/app_error_policy.dart`
  - dev mode: detailed message
  - prod mode: generic fallback message
- Applied policy to pages:
  - home import mapping error snackbars
  - rule import page error rendering
  - catalog/detail/image/video async load error states
  - video player init errors
- Validation issue details are shown only in dev mode.

## Boundaries

- Logging currently writes to debug output only.
- Persistent/remote log sink is not included in this step.
