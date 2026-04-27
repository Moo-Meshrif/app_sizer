import '../widgets/app_sizer_widget.dart';

/// Returns true when both [AppSizer] widgets share identical configuration
/// (all fields except [builder] and [precalcFunction], which don't affect
/// the notifier). Used by [_AppSizerState.didUpdateWidget] to avoid
/// recreating the notifier on unrelated hot-reload changes.
bool configEquals(AppSizer a, AppSizer b) =>
    a.designWidth == b.designWidth &&
    a.designHeight == b.designHeight &&
    a.minTextScale == b.minTextScale &&
    a.maxTextScale == b.maxTextScale &&
    a.textScaleFactor == b.textScaleFactor &&
    a.useHeightForTextScale == b.useHeightForTextScale &&
    a.baseExtraLargeTextSize == b.baseExtraLargeTextSize &&
    a.baseLargeTextSize == b.baseLargeTextSize &&
    a.baseMediumTextSize == b.baseMediumTextSize &&
    a.baseSmallTextSize == b.baseSmallTextSize &&
    a.tabletBreakpoint == b.tabletBreakpoint &&
    a.tabletLargeBreakpoint == b.tabletLargeBreakpoint &&
    a.desktopBreakpoint == b.desktopBreakpoint &&
    a.isDebugLogs == b.isDebugLogs;
