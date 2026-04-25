import 'dart:math';

import 'package:flutter/material.dart';

import 'helper/prescale_manager.dart';
import 'helper/extensions.dart';

export 'helper/extensions.dart';

/// Represents the different types of devices supported by the responsive system.
enum DeviceType { mobile, tablet, tabletLarge, desktop }

/// ------------------------------------------------------------
/// Main AppSizesNotifier
/// ------------------------------------------------------------
/// The core state notifier that manages all screen metrics and scaling factors.
class AppSizesNotifier extends ChangeNotifier {
  /// The reference width from the design (e.g., Figma or Adobe XD).
  final double designWidth;

  /// The reference height from the design.
  final double designHeight;

  /// Global settings for text scaling
  final double minTextScale;
  final double maxTextScale;
  final double textScaleFactor;
  final bool useHeightForTextScale;

  /// Base text sizes
  final double baseExtraLargeTextSize;
  final double baseLargeTextSize;
  final double baseMediumTextSize;
  final double baseSmallTextSize;

  /// Breakpoints
  final double tabletBreakpoint;
  final double tabletLargeBreakpoint;
  final double desktopBreakpoint;

  /// Debugger settings
  final bool isDebugLogs;

  AppSizesNotifier({
    required this.designWidth,
    required this.designHeight,
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

  /// The current logical screen width.
  double screenWidth = 375;

  /// The current logical screen height.
  double screenHeight = 812;

  /// The calculated horizontal scaling factor.
  double scaleW = 1.0;

  /// The calculated vertical scaling factor.
  double scaleH = 1.0;

  /// The calculated text scaling factor.
  double scaleText = 1.0;

  /// The detected device type based on current screen width and breakpoints.
  DeviceType deviceType = DeviceType.mobile;

  /// Whether the device is currently in landscape orientation.
  bool isLandscape = false;

  // standard app sizes
  /// Standard horizontal padding for the screen.
  late double screenHPadding;

  /// Standard vertical padding for the screen.
  late double screenVPadding;

  /// Standard radius for cards.
  late double cardRadius;

  /// Standard radius for input fields.
  late double inputRadius;

  /// Scaled extra large text size.
  late double extraLargeTextSize;

  /// Scaled large text size.
  late double largeTextSize;

  /// Scaled medium text size.
  late double mediumTextSize;

  /// Scaled small text size.
  late double smallTextSize;

  bool _initialized = false;

  /// Call whenever screen metrics change
  void update(Size screenSize, Orientation orientation,
      {Function(AppSizesNotifier notifier)? precalcFunction}) {
    final bool dimensionsChanged = !_initialized ||
        screenSize.width != screenWidth ||
        screenSize.height != screenHeight ||
        (orientation == Orientation.landscape) != isLandscape;

    if (dimensionsChanged) {
      // 0️⃣ Update internal metrics
      screenWidth = screenSize.width;
      screenHeight = screenSize.height;
      isLandscape = orientation == Orientation.landscape;

      // 1️⃣ Determine design adjustment
      double designW = isLandscape ? designHeight : designWidth;
      double designH = isLandscape ? designWidth : designHeight;

      // 2️⃣ Calculate scale factors
      scaleW = screenWidth / designW;
      scaleH = screenHeight / designH;

      // 3️⃣ Determine device type
      if (screenWidth >= desktopBreakpoint) {
        deviceType = DeviceType.desktop;
      } else if (screenWidth >= tabletLargeBreakpoint) {
        deviceType = DeviceType.tabletLarge;
      } else if (screenWidth >= tabletBreakpoint) {
        deviceType = DeviceType.tablet;
      } else {
        deviceType = DeviceType.mobile;
      }

      // 4️⃣ Text Scale
      scaleText = _calculateTextScale(designW);

      // 5️⃣ Update standard sizes
      screenHPadding = w(16);
      screenVPadding = h(10);
      cardRadius = r(12);
      inputRadius = r(8);
      extraLargeTextSize = sp(baseExtraLargeTextSize);
      largeTextSize = sp(baseLargeTextSize);
      mediumTextSize = sp(baseMediumTextSize);
      smallTextSize = sp(baseSmallTextSize);
    }

    // 💡 FORCE SYNC: Always sync the singleton with the current state of this notifier.
    // This handles both the NEW scales calculated above AND restoration after a Hot Reload.
    PreScaleManager().updateScale(this);

    if (dimensionsChanged) {
      // 6️⃣ Run pre-caching logic
      precalcFunction?.call(this);

      _initialized = true;
      notifyListeners();

      if (!isDebugLogs) return;
      // 7️⃣ Log
      assert(() {
        debugPrint(
            '📱 [Responsive] UI Scale Changed! (Landscape: $isLandscape)');
        debugPrint(
            '   📏 Screen: ${screenWidth.toStringAsFixed(1)}x${screenHeight.toStringAsFixed(1)}');
        debugPrint('   🎯 Device: ${deviceType.name.toUpperCase()}');
        debugPrint(
            '   📝 TextScale: ${scaleText.toStringAsFixed(2)}, ScaleW: ${scaleW.toStringAsFixed(2)}, ScaleH: ${scaleH.toStringAsFixed(2)}');
        return true;
      }());
    }
  }

  int value(int mobile, {int? tablet, int? largeTablet, int? desktop}) {
    return switch (deviceType) {
      DeviceType.desktop => desktop ?? largeTablet ?? tablet ?? mobile,
      DeviceType.tabletLarge => largeTablet ?? tablet ?? mobile,
      DeviceType.tablet => tablet ?? mobile,
      DeviceType.mobile => mobile,
    };
  }

  /// Internal helper for text scale to keep it sane
  double _calculateTextScale(double effectiveDesignW) {
    double effectiveDesignH = isLandscape ? designWidth : designHeight;
    double scale;
    if (deviceType == DeviceType.mobile) {
      scale = screenWidth / effectiveDesignW;
      if (useHeightForTextScale) {
        double localScaleH = screenHeight / effectiveDesignH;
        scale = min(scale, localScaleH);
      }
    } else if (deviceType == DeviceType.tablet) {
      scale = screenWidth / tabletBreakpoint;
    } else if (deviceType == DeviceType.tabletLarge) {
      scale = screenWidth / tabletLargeBreakpoint;
    } else {
      scale = screenWidth / desktopBreakpoint;
    }

    return scale * textScaleFactor;
  }

  /// Reset calculation
  void reset() => _initialized = false;

  /// ------------------------------------------------------------
  /// Helpers for standard scaling
  /// ------------------------------------------------------------
  double sh(double value) => value * screenHeight;
  double sw(double value) => value * screenWidth;
  double w(double value) => value * scaleW;
  double h(double value) => value * scaleH;
  double r(double value) => value * min(scaleW, scaleH);
  double sp(double value) {
    double responsiveFontSize = value * scaleText;
    return responsiveFontSize.clamp(
      value * minTextScale,
      value * maxTextScale,
    );
  }

  /// ------------------------------------------------------------
  /// Capped scaling helpers — prevent values from growing too large
  /// on wide/large screens. Ideal for padding, icon sizes, gaps, etc.
  ///
  /// [max] is an absolute pixel cap in logical pixels.
  /// ------------------------------------------------------------

  /// Scale [value] by width, but never exceed [max] logical pixels.
  double wMax(double value, double max) => w(value).clamp(0.0, max);

  /// Scale [value] by height, but never exceed [max] logical pixels.
  double hMax(double value, double max) => h(value).clamp(0.0, max);

  /// Scale [value] by the shorter axis (radius), but never exceed [max].
  double rMax(double value, double max) => r(value).clamp(0.0, max);
}

/// ------------------------------------------------------------
/// InheritedNotifier
/// ------------------------------------------------------------
/// An InheritedWidget that provides [AppSizesNotifier] to its descendants.
class AppSizesProvider extends InheritedNotifier<AppSizesNotifier> {
  const AppSizesProvider({
    super.key,
    required super.notifier,
    required super.child,
  });

  static AppSizesNotifier of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<AppSizesProvider>();
    assert(provider != null, 'AppSizesProvider not found in widget tree');
    return provider!.notifier!;
  }
}

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
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(AppSizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.designWidth != widget.designWidth ||
        oldWidget.designHeight != widget.designHeight ||
        oldWidget.minTextScale != widget.minTextScale ||
        oldWidget.maxTextScale != widget.maxTextScale ||
        oldWidget.textScaleFactor != widget.textScaleFactor ||
        oldWidget.useHeightForTextScale != widget.useHeightForTextScale ||
        oldWidget.baseExtraLargeTextSize != widget.baseExtraLargeTextSize ||
        oldWidget.baseLargeTextSize != widget.baseLargeTextSize ||
        oldWidget.baseMediumTextSize != widget.baseMediumTextSize ||
        oldWidget.baseSmallTextSize != widget.baseSmallTextSize ||
        oldWidget.tabletBreakpoint != widget.tabletBreakpoint ||
        oldWidget.tabletLargeBreakpoint != widget.tabletLargeBreakpoint ||
        oldWidget.desktopBreakpoint != widget.desktopBreakpoint ||
        oldWidget.isDebugLogs != widget.isDebugLogs) {
      notifier = _buildNotifier();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // We don't need to do anything here anymore if we update in build
    // but keeping it for manual triggers if needed.
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // If AppSizer is above MaterialApp, MediaQuery.maybeOf(context) will be null.
    // We fallback to View.of(context) to get the physical dimensions.
    final mediaQuery = MediaQuery.maybeOf(context);
    late Size size;
    late Orientation orientation;

    if (mediaQuery != null) {
      size = mediaQuery.size;
      orientation = mediaQuery.orientation;
    } else {
      final view = View.of(context);
      size = view.physicalSize / view.devicePixelRatio;
      orientation = size.width > size.height
          ? Orientation.landscape
          : Orientation.portrait;
    }

    // Initial calculation or update on build
    notifier.update(size, orientation, precalcFunction: widget.precalcFunction);

    return AppSizesProvider(
      notifier: notifier,
      child: Builder(builder: widget.builder),
    );
  }
}

/// ------------------------------------------------------------
/// AdaptiveLayout
/// ------------------------------------------------------------
/// A widget that builds different layouts based on the current [DeviceType].
class AdaptiveLayout extends StatelessWidget {
  /// The default layout used for mobile devices.
  final WidgetBuilder mobileLayout;

  /// Optional layout used for tablet devices.
  final WidgetBuilder? tabletLayout;

  /// Optional layout used for large tablets.
  final WidgetBuilder? tabletLargeLayout;

  /// Optional layout used for desktop devices.
  final WidgetBuilder? desktopLayout;

  /// Creates an adaptive layout.
  const AdaptiveLayout({
    super.key,
    required this.mobileLayout,
    this.tabletLayout,
    this.tabletLargeLayout,
    this.desktopLayout,
  });

  @override
  Widget build(BuildContext context) => switch (context.deviceType) {
        DeviceType.mobile => mobileLayout(context),
        DeviceType.tablet =>
          tabletLayout?.call(context) ?? mobileLayout(context),
        DeviceType.tabletLarge => tabletLargeLayout?.call(context) ??
            tabletLayout?.call(context) ??
            mobileLayout(context),
        DeviceType.desktop => desktopLayout?.call(context) ??
            tabletLargeLayout?.call(context) ??
            tabletLayout?.call(context) ??
            mobileLayout(context),
      };
}
