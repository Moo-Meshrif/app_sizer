import 'dart:math';

import 'package:app_sizer/app_sizer.dart';
import 'package:flutter/material.dart';

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
  double _screenWidth = 375;
  double get screenWidth => _screenWidth;

  /// The current logical screen height.
  double _screenHeight = 812;
  double get screenHeight => _screenHeight;

  /// The calculated horizontal scaling factor.
  double _scaleW = 1.0;
  double get scaleW => _scaleW;

  /// The calculated vertical scaling factor.
  double _scaleH = 1.0;
  double get scaleH => _scaleH;

  /// The calculated text scaling factor.
  double _scaleText = 1.0;
  double get scaleText => _scaleText;

  /// The detected device type based on current screen width and breakpoints.
  DeviceType _deviceType = DeviceType.mobile;
  DeviceType get deviceType => _deviceType;

  /// Whether the device is currently in landscape orientation.
  bool _isLandscape = false;
  bool get isLandscape => _isLandscape;

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

  /// Call whenever screen metrics change.
  /// This method orchestrates the responsive calculations.
  void update(Size screenSize, Orientation orientation,
      {Function(AppSizesNotifier notifier)? precalcFunction}) {
    final bool dimensionsChanged = !_initialized ||
        screenSize.width != _screenWidth ||
        screenSize.height != _screenHeight ||
        (orientation == Orientation.landscape) != _isLandscape;

    if (dimensionsChanged) {
      _updateMetrics(screenSize, orientation);
      _calculateScaleFactors();
      _detectDeviceType();
      _calculateTextScale();
      _updateStandardSizes();
    }

    // 💡 FORCE SYNC: Always sync the singleton with the current state of this notifier.
    // This handles both the NEW scales calculated above AND restoration after a Hot Reload.
    PreScaleManager().updateScale(this);

    if (dimensionsChanged) {
      // Run pre-caching logic
      precalcFunction?.call(this);

      _initialized = true;
      notifyListeners();

      _logDebugInfo();
    }
  }

  /// Updates internal screen metrics.
  void _updateMetrics(Size screenSize, Orientation orientation) {
    _screenWidth = screenSize.width;
    _screenHeight = screenSize.height;
    _isLandscape = orientation == Orientation.landscape;
  }

  /// Calculates horizontal and vertical scale factors based on design dimensions.
  void _calculateScaleFactors() {
    final double designW = _isLandscape ? designHeight : designWidth;
    final double designH = _isLandscape ? designWidth : designHeight;

    _scaleW = _screenWidth / designW;
    _scaleH = _screenHeight / designH;
  }

  /// Determines the device type based on the current screen width and breakpoints.
  void _detectDeviceType() {
    if (_screenWidth >= desktopBreakpoint) {
      _deviceType = DeviceType.desktop;
    } else if (_screenWidth >= tabletLargeBreakpoint) {
      _deviceType = DeviceType.tabletLarge;
    } else if (_screenWidth >= tabletBreakpoint) {
      _deviceType = DeviceType.tablet;
    } else {
      _deviceType = DeviceType.mobile;
    }
  }

  /// Updates the text scaling factor.
  void _calculateTextScale() {
    final double designW = _isLandscape ? designHeight : designWidth;
    _scaleText = _computeTextScale(designW);
  }

  /// Internal helper to compute text scale based on device type and orientation.
  double _computeTextScale(double effectiveDesignW) {
    final double effectiveDesignH = _isLandscape ? designWidth : designHeight;
    double scale;

    if (_deviceType == DeviceType.mobile) {
      scale = _screenWidth / effectiveDesignW;
      if (useHeightForTextScale) {
        final double localScaleH = _screenHeight / effectiveDesignH;
        scale = min(scale, localScaleH);
      }
    } else if (_deviceType == DeviceType.tablet) {
      scale = _screenWidth / tabletBreakpoint;
    } else if (_deviceType == DeviceType.tabletLarge) {
      scale = _screenWidth / tabletLargeBreakpoint;
    } else {
      scale = _screenWidth / desktopBreakpoint;
    }

    return scale * textScaleFactor;
  }

  /// Recalculates standard app sizes (padding, radius, text sizes) based on new scales.
  void _updateStandardSizes() {
    screenHPadding = w(16);
    screenVPadding = h(10);
    cardRadius = r(12);
    inputRadius = r(8);
    extraLargeTextSize = sp(baseExtraLargeTextSize);
    largeTextSize = sp(baseLargeTextSize);
    mediumTextSize = sp(baseMediumTextSize);
    smallTextSize = sp(baseSmallTextSize);
  }

  /// Logs debug information to the console if isDebugLogs is enabled.
  void _logDebugInfo() {
    if (!isDebugLogs) return;

    assert(() {
      debugPrint(
          '📱 [Responsive] UI Scale Changed! (Landscape: $_isLandscape)');
      debugPrint(
          '   📏 Screen: ${_screenWidth.toStringAsFixed(1)}x${_screenHeight.toStringAsFixed(1)}');
      debugPrint('   🎯 Device: ${_deviceType.name.toUpperCase()}');
      debugPrint(
          '   📝 TextScale: ${_scaleText.toStringAsFixed(2)}, ScaleW: ${_scaleW.toStringAsFixed(2)}, ScaleH: ${_scaleH.toStringAsFixed(2)}');
      return true;
    }());
  }

  /// Selects a value based on the current [deviceType].
  T value<T>(T mobile, {T? tablet, T? largeTablet, T? desktop}) =>
      switch (_deviceType) {
        DeviceType.desktop => desktop ?? largeTablet ?? tablet ?? mobile,
        DeviceType.tabletLarge => largeTablet ?? tablet ?? mobile,
        DeviceType.tablet => tablet ?? mobile,
        DeviceType.mobile => mobile,
      };

  /// Reset calculation state.
  void reset() => _initialized = false;

  /// ------------------------------------------------------------
  /// Helpers for standard scaling
  /// ------------------------------------------------------------

  /// Scale [value] relative to screen height.
  double sh(double value) => value * _screenHeight;

  /// Scale [value] relative to screen width.
  double sw(double value) => value * _screenWidth;

  /// Scale [value] by width scaling factor.
  double w(double value) => value * _scaleW;

  /// Scale [value] by height scaling factor.
  double h(double value) => value * _scaleH;

  /// Scale [value] by the smaller of width or height scaling factors (useful for radius).
  double r(double value) => value * min(_scaleW, _scaleH);

  /// Scale [value] by height * width (diagonal-like scaling).
  double dg(double value) => value * _scaleH * _scaleW;

  /// Scale [value] by the larger of width or height scaling factors.
  double dm(double value) => value * max(_scaleW, _scaleH);

  /// Scale [value] for text, applying constraints and global text scale factor.
  double sp(double value) {
    final double responsiveFontSize = value * _scaleText;
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
