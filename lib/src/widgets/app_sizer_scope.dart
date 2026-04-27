import 'package:flutter/material.dart';
import 'package:app_sizer/app_sizer.dart';

/// Overrides [AppSizer] settings for a subtree.
///
/// Useful for dialogs, bottom sheets, embedded web views, or sidebars
/// that have their own Figma frame dimensions — independent of the root
/// [AppSizer] configuration.
///
/// All non-overridden fields are inherited from the nearest ancestor
/// [AppSizesProvider] in the widget tree.
///
/// Example:
/// ```dart
/// AppSizerScope(
///   designWidth: 320,
///   designHeight: 600,
///   child: MyDialog(),
/// )
/// ```
class AppSizerScope extends StatefulWidget {
  /// Optional override for the design width. Inherits from parent if null.
  final double? designWidth;

  /// Optional override for the design height. Inherits from parent if null.
  final double? designHeight;

  /// Optional override for minimum text scale. Inherits from parent if null.
  final double? minTextScale;

  /// Optional override for maximum text scale. Inherits from parent if null.
  final double? maxTextScale;

  /// The widget subtree that will use the scoped notifier.
  final Widget child;

  /// Creates an [AppSizerScope] that applies overridden design dimensions
  /// to [child] and its descendants.
  const AppSizerScope({
    super.key,
    this.designWidth,
    this.designHeight,
    this.minTextScale,
    this.maxTextScale,
    required this.child,
  });

  @override
  State<AppSizerScope> createState() => _AppSizerScopeState();
}

class _AppSizerScopeState extends State<AppSizerScope> {
  late AppSizesNotifier _scopedNotifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final parent = AppSizesProvider.of(context);

    _scopedNotifier = AppSizesNotifier(
      designWidth: widget.designWidth ?? parent.designWidth,
      designHeight: widget.designHeight ?? parent.designHeight,
      minTextScale: widget.minTextScale ?? parent.minTextScale,
      maxTextScale: widget.maxTextScale ?? parent.maxTextScale,
      // Inherit all remaining config from parent
      textScaleFactor: parent.textScaleFactor,
      useHeightForTextScale: parent.useHeightForTextScale,
      baseExtraLargeTextSize: parent.baseExtraLargeTextSize,
      baseLargeTextSize: parent.baseLargeTextSize,
      baseMediumTextSize: parent.baseMediumTextSize,
      baseSmallTextSize: parent.baseSmallTextSize,
      tabletBreakpoint: parent.tabletBreakpoint,
      tabletLargeBreakpoint: parent.tabletLargeBreakpoint,
      desktopBreakpoint: parent.desktopBreakpoint,
    );

    _scopedNotifier.update(
      Size(parent.screenWidth, parent.screenHeight),
      parent.isLandscape ? Orientation.landscape : Orientation.portrait,
    );
  }

  @override
  Widget build(BuildContext context) => AppSizesProvider(
        notifier: _scopedNotifier,
        child: widget.child,
      );
}
