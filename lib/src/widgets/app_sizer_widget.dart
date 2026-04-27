import 'package:flutter/material.dart';

import '../app_sizes_provider.dart';
import '../helper/config_equals.dart';

/// ------------------------------------------------------------
/// AppSizer
/// ------------------------------------------------------------
/// The root widget that initializes the responsive system.
/// Wrap your [MaterialApp] with this widget.
class AppSizer extends StatefulWidget {
  /// Design width in pixels
  final double designWidth;

  /// Design height in pixels
  final double designHeight;

  /// Function to run before the app is built
  final Function(AppSizesNotifier notifier)? precalcFunction;

  /// Widget builder
  final Widget Function(BuildContext context) builder;

  /// Minimum text scale factor
  final double minTextScale;

  /// Maximum text scale factor
  final double maxTextScale;

  /// Text scale factor
  final double textScaleFactor;

  /// Use height for text scaling
  final bool useHeightForTextScale;

  /// Base extra large text size
  final double baseExtraLargeTextSize;

  /// Base large text size
  final double baseLargeTextSize;

  /// Base medium text size
  final double baseMediumTextSize;

  /// Base small text size
  final double baseSmallTextSize;

  /// Breakpoints
  final double tabletBreakpoint;
  final double tabletLargeBreakpoint;
  final double desktopBreakpoint;

  /// Debugger settings
  final bool isDebugLogs;

  const AppSizer({
    super.key,
    required this.designWidth,
    required this.designHeight,
    required this.builder,
    this.precalcFunction,
    this.minTextScale = 0.6,
    this.maxTextScale = 1.4,
    this.textScaleFactor = 1.0,
    this.useHeightForTextScale = false,
    this.baseExtraLargeTextSize = 26,
    this.baseLargeTextSize = 20,
    this.baseMediumTextSize = 16,
    this.baseSmallTextSize = 12,
    this.tabletBreakpoint = 600,
    this.tabletLargeBreakpoint = 900,
    this.desktopBreakpoint = 1100,
    this.isDebugLogs = false,
  });

  @override
  State<AppSizer> createState() => _AppSizerState();
}

class _AppSizerState extends State<AppSizer> with WidgetsBindingObserver {
  late AppSizesNotifier notifier;

  // Tracks whether we are operating above MaterialApp (MediaQuery unavailable).
  // When true, we rely on WidgetsBindingObserver to detect metric changes
  // because View.of(context) changes don't trigger automatic rebuilds.
  // When false, MediaQuery handles rebuilds for us — the observer is unused.
  bool _aboveMediaQuery = false;

  AppSizesNotifier _buildNotifier() => AppSizesNotifier(
        designWidth: widget.designWidth,
        designHeight: widget.designHeight,
        minTextScale: widget.minTextScale,
        maxTextScale: widget.maxTextScale,
        textScaleFactor: widget.textScaleFactor,
        useHeightForTextScale: widget.useHeightForTextScale,
        baseExtraLargeTextSize: widget.baseExtraLargeTextSize,
        baseLargeTextSize: widget.baseLargeTextSize,
        baseMediumTextSize: widget.baseMediumTextSize,
        baseSmallTextSize: widget.baseSmallTextSize,
        tabletBreakpoint: widget.tabletBreakpoint,
        tabletLargeBreakpoint: widget.tabletLargeBreakpoint,
        desktopBreakpoint: widget.desktopBreakpoint,
        isDebugLogs: widget.isDebugLogs,
      );

  @override
  void initState() {
    super.initState();
    notifier = _buildNotifier();
    // Observer is registered lazily in build() once we know whether
    // MediaQuery is available. See _aboveMediaQuery.
  }

  @override
  void didUpdateWidget(AppSizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only recreate the notifier if configuration actually changed.
    if (!configEquals(oldWidget, widget)) {
      notifier.dispose();
      notifier = _buildNotifier();
    }
  }

  @override
  void dispose() {
    if (_aboveMediaQuery) {
      WidgetsBinding.instance.removeObserver(this);
    }
    notifier.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // Only registered when _aboveMediaQuery is true (AppSizer is above
    // MaterialApp). In that case MediaQuery is null and View.of(context)
    // is used as a fallback — but View changes don't trigger rebuilds
    // automatically, so we must call setState here to drive a new build.
    //
    // When MediaQuery IS available (common case), this callback is never
    // registered, so this body never executes — no redundant rebuild.
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    late Size size;
    late Orientation orientation;

    if (mediaQuery != null) {
      // Common case: AppSizer is inside MaterialApp.
      // MediaQuery rebuilds this widget automatically on metric changes,
      // so we do NOT need WidgetsBindingObserver — unregister if we
      // previously registered (e.g. hot-reload moved AppSizer down the tree).
      if (_aboveMediaQuery) {
        WidgetsBinding.instance.removeObserver(this);
        _aboveMediaQuery = false;
      }
      size = mediaQuery.size;
      orientation = mediaQuery.orientation;
    } else {
      // Edge case: AppSizer is above MaterialApp (e.g. wrapping runApp directly).
      // MediaQuery is null so we fall back to View. View does NOT rebuild this
      // widget on metric changes, so we register the observer to get
      // didChangeMetrics callbacks and drive rebuilds manually via setState.
      if (!_aboveMediaQuery) {
        WidgetsBinding.instance.addObserver(this);
        _aboveMediaQuery = true;
      }
      final view = View.of(context);
      size = view.physicalSize / view.devicePixelRatio;
      orientation = size.width > size.height
          ? Orientation.landscape
          : Orientation.portrait;
    }

    notifier.update(size, orientation, precalcFunction: widget.precalcFunction);

    return AppSizesProvider(
      notifier: notifier,
      child: Builder(builder: widget.builder),
    );
  }
}
