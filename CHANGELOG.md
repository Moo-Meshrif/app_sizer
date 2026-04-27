# Changelog

## 0.0.3

*   **Fix**: Optimized `AppSizer.didUpdateWidget` to prevent spurious notifier recreations.
*   **Feature**: Added `AppSizerScope` for local design dimension overrides (ideal for dialogs or sidebars).
*   **Feature**: Added `AppSizerDebugOverlay` for on-screen responsive metrics visualization.
*   **Feature**: Enhanced `.value()` adaptive extensions.
*   **Tests**: Reorganized test suite into specialized unit and widget tests for better performance and reliability.

## 0.0.2

* **Fix**: Removed `generate_prescale.dart` export from main library to resolve Web platform compatibility issues caused by `dart:io` dependency.
* **Feature**: Added `dg` (diagonal) and `dm` (diameter) scaling extensions.

## 0.0.1

* Initial release of `app_sizer`.
