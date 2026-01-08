import 'dart:math';

import 'package:flutter/material.dart';

import 'helper/prescale_manager.dart';

enum DeviceType { mobile, tablet, tabletLarge, desktop }

/// ------------------------------------------------------------
/// Main AppSizesNotifier
/// ------------------------------------------------------------
class AppSizesNotifier extends ChangeNotifier {
  final double designWidth;
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
  });

  double screenWidth = 375;
  double screenHeight = 812;
  // scale factors
  double scaleW = 1.0;
  double scaleH = 1.0;
  double scaleText = 1.0;
  DeviceType deviceType = DeviceType.mobile;
  bool isLandscape = false;

  // standard app sizes
  late double screenHPadding;
  late double screenVPadding;
  late double cardRadius;
  late double inputRadius;
  late double extraLargeTextSize;
  late double largeTextSize;
  late double mediumTextSize;
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
      deviceType = switch (screenWidth) {
        >= 1100 => DeviceType.desktop,
        >= 900 => DeviceType.tabletLarge,
        >= 600 => DeviceType.tablet,
        _ => DeviceType.mobile,
      };

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
    switch (deviceType) {
      case DeviceType.desktop:
        return desktop ?? largeTablet ?? tablet ?? mobile;
      case DeviceType.tabletLarge:
        return largeTablet ?? tablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      default:
        return mobile;
    }
  }

  /// Internal helper for text scale to keep it sane
  double _calculateTextScale(double effectiveDesignW) {
    double effectiveDesignH = isLandscape ? designWidth : designHeight;
    double scale;
    if (deviceType == DeviceType.mobile) {
      scale = screenWidth / effectiveDesignW;
      if (useHeightForTextScale) {
        double scaleH = screenHeight / effectiveDesignH;
        scale = min(scale, scaleH);
      }
    } else if (deviceType == DeviceType.tablet) {
      scale = screenWidth / 600;
    } else if (deviceType == DeviceType.tabletLarge) {
      scale = screenWidth / 900;
    } else {
      scale = screenWidth / 1100;
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
}

/// ------------------------------------------------------------
/// Extensions
/// ------------------------------------------------------------
extension AppSizesX on BuildContext {
  AppSizesNotifier get appSizes => AppSizesProvider.of(this);

  DeviceType get deviceType => appSizes.deviceType;

  double sh(double value) => appSizes.sh(value);

  double sw(double value) => appSizes.sw(value);

  TextStyle get extraLarge => TextStyle(
        fontSize: appSizes.extraLargeTextSize,
        fontWeight: FontWeight.bold,
      );

  TextStyle get large =>
      TextStyle(fontSize: appSizes.largeTextSize, fontWeight: FontWeight.bold);

  TextStyle get medium => TextStyle(fontSize: appSizes.mediumTextSize);

  TextStyle get small => TextStyle(fontSize: appSizes.smallTextSize);

  TextStyle get title => large;

  TextStyle get subtitle => medium;
}

extension ScaleX on num {
  double get w => PreScaleManager().getW(toDouble());
  double get h => PreScaleManager().getH(toDouble());
  double get sp => PreScaleManager().getSp(toDouble());
  double get r => PreScaleManager().getR(toDouble());
  SizedBox get vGap => SizedBox(height: h);
  SizedBox get hGap => SizedBox(width: w);

  int value(
    BuildContext context, {
    int? tablet,
    int? largeTablet,
    int? desktop,
  }) =>
      context.appSizes.value(
        toInt(),
        tablet: tablet,
        largeTablet: largeTablet,
        desktop: desktop,
      );
}

/// ------------------------------------------------------------
/// InheritedNotifier
/// ------------------------------------------------------------
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
  });

  @override
  State<AppSizer> createState() => _AppSizerState();
}

class _AppSizerState extends State<AppSizer> with WidgetsBindingObserver {
  late AppSizesNotifier notifier;
  @override
  void initState() {
    super.initState();
    notifier = AppSizesNotifier(
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
    );
    WidgetsBinding.instance.addObserver(this);
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

    return ListenableBuilder(
      listenable: notifier,
      builder: (context, _) => AppSizesProvider(
        notifier: notifier,
        child: widget.builder(context),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// AdaptiveLayout
/// ------------------------------------------------------------
class AdaptiveLayout extends StatelessWidget {
  const AdaptiveLayout({
    super.key,
    required this.mobileLayout,
    this.tabletLayout,
    this.desktopLayout,
  });

  final WidgetBuilder mobileLayout;
  final WidgetBuilder? tabletLayout, desktopLayout;
  @override
  Widget build(BuildContext context) => switch (context.deviceType) {
        DeviceType.mobile => mobileLayout(context),
        DeviceType.tablet ||
        DeviceType.tabletLarge =>
          tabletLayout?.call(context) ?? mobileLayout(context),
        DeviceType.desktop => desktopLayout?.call(context) ??
            tabletLayout?.call(context) ??
            mobileLayout(context),
      };
}
