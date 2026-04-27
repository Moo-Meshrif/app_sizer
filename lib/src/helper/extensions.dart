import 'package:app_sizer/app_sizer.dart';
import 'package:flutter/material.dart';

/// ------------------------------------------------------------
/// Extensions
/// ------------------------------------------------------------
extension AppSizesX on BuildContext {
  /// Provides access to the [AppSizesNotifier] from the current context.
  AppSizesNotifier get appSizes => AppSizesProvider.of(this);

  /// The currently detected [DeviceType].
  DeviceType get deviceType => appSizes.deviceType;

  double get tabletBreakpoint => appSizes.tabletBreakpoint;
  double get tabletLargeBreakpoint => appSizes.tabletLargeBreakpoint;
  double get desktopBreakpoint => appSizes.desktopBreakpoint;

  /// Scales [value] relative to the screen height.
  double sh(double value) => appSizes.sh(value);

  /// Scales [value] relative to the screen width.
  double sw(double value) => appSizes.sw(value);

  /// ------------------------------------------------------------
  /// Safe size helpers
  ///
  /// "Safe" = screen size minus system-occupied space
  /// (status bar, notch, bottom nav bar, keyboard insets).
  /// Use these when you need a fraction of the truly usable area.
  ///
  /// [safeWidth]  — usable logical width  (excludes horizontal padding)
  /// [safeHeight] — usable logical height (excludes top/bottom padding
  ///                     and soft-keyboard inset)
  ///
  /// [srw(value)] — fraction of [safeWidth],  e.g. context.srw(0.5)
  /// [srh(value)] — fraction of [safeHeight], e.g. context.srh(0.3)
  /// ------------------------------------------------------------

  /// Usable width: screen width minus horizontal system padding (e.g. safe-area insets).
  double get safeWidth {
    final mq = MediaQuery.of(this);
    return mq.size.width - mq.padding.horizontal;
  }

  /// Usable height: screen height minus vertical system padding and
  /// the soft-keyboard inset so layouts don't overlap the keyboard.
  double get safeHeight {
    final mq = MediaQuery.of(this);
    return mq.size.height - mq.padding.vertical - mq.viewInsets.bottom;
  }

  /// Returns [value] × [safeWidth]. [value] is a fraction in [0, 1].
  ///
  /// Example: `context.srw(0.5)` → half the usable screen width.
  double srw(double value) => value * safeWidth;

  /// Returns [value] × [safeHeight]. [value] is a fraction in [0, 1].
  ///
  /// Example: `context.srh(0.3)` → 30 % of the usable screen height.
  double srh(double value) => value * safeHeight;

  /// ------------------------------------------------------------
  /// Helper for getting values based on device type
  /// ------------------------------------------------------------
  /// Returns a value based on the current device type.
  ///
  /// Example: `context.value(20, tablet: 24, largeTablet: 28, desktop: 32)`
  /// returns 20 for mobile, 24 for tablet, 28 for large tablet, and 32 for desktop.
  T value<T>(T mobile, {T? tablet, T? largeTablet, T? desktop}) =>
      appSizes.value<T>(
        mobile,
        tablet: tablet,
        largeTablet: largeTablet,
        desktop: desktop,
      );

  /// ------------------------------------------------------------
  /// Helper for getting text styles based on device type
  /// ------------------------------------------------------------

  /// Returns a [TextStyle] with extra-large font size.
  TextStyle get extraLarge => TextStyle(
        fontSize: appSizes.extraLargeTextSize,
        fontWeight: FontWeight.bold,
      );

  /// Returns a [TextStyle] with large font size.
  TextStyle get large => TextStyle(
        fontSize: appSizes.largeTextSize,
        fontWeight: FontWeight.bold,
      );

  /// Returns a [TextStyle] with medium font size.
  TextStyle get medium => TextStyle(fontSize: appSizes.mediumTextSize);

  /// Returns a [TextStyle] with small font size.
  TextStyle get small => TextStyle(fontSize: appSizes.smallTextSize);

  /// Returns a [TextStyle] with large font size (alias for [large]).
  TextStyle get title => large;

  /// Returns a [TextStyle] with medium font size (alias for [medium]).
  TextStyle get subtitle => medium;
}

/// ------------------------------------------------------------
/// ConstraintsX — available space inside a layout slot
///
/// Use inside [LayoutBuilder] to size widgets relative to the
/// space actually available to them, accounting for siblings,
/// padding, and any other widgets that have already consumed space.
///
/// ```dart
/// LayoutBuilder(
///   builder: (context, constraints) {
///     return Column(children: [
///       Container(
///         width:  constraints.aw(0.6),  // 60 % of available width
///         height: constraints.ah(0.4),  // 40 % of available height
///       ),
///     ]);
///   },
/// )
/// ```
/// ------------------------------------------------------------
extension ConstraintsX on BoxConstraints {
  /// Available width of this layout slot (= [maxWidth]).
  double get availableWidth => maxWidth;

  /// Available height of this layout slot (= [maxHeight]).
  double get availableHeight => maxHeight;

  /// Returns [value] × [availableWidth]. [value] is a fraction in [0, 1].
  ///
  /// Example: `constraints.aw(0.5)` → half the slot's width.
  double aw(double value) => value * availableWidth;

  /// Returns [value] × [availableHeight]. [value] is a fraction in [0, 1].
  ///
  /// Example: `constraints.ah(0.3)` → 30 % of the slot's height.
  double ah(double value) => value * availableHeight;
}

extension ScaleX on num {
  /// Scaled width based on [designWidth].
  double get w => PreScaleManager().getW(toDouble());

  /// Scaled height based on [designHeight].
  double get h => PreScaleManager().getH(toDouble());

  /// Scaled text/font size.
  double get sp => PreScaleManager().getSp(toDouble());

  /// Scaled radius based on the smaller screen dimension.
  double get r => PreScaleManager().getR(toDouble());

  /// Scaled diagonal based on both width and height scale factors.
  double get dg => PreScaleManager().getDg(toDouble());

  /// Scaled diameter based on the larger screen dimension.
  double get dm => PreScaleManager().getDm(toDouble());

  /// A vertical gap (SizedBox) with scaled height.
  SizedBox get vGap => SizedBox(height: h);

  /// A horizontal gap (SizedBox) with scaled width.
  SizedBox get hGap => SizedBox(width: w);

  /// Scale by width, capped at [max] logical pixels.
  /// Ideal for horizontal padding and icon sizes that should not grow
  /// unboundedly on tablets or desktops.
  ///
  /// Example: `16.wMax(24)` → scales from design width but caps at 24 px.
  double wMax(double max) => PreScaleManager().getWMax(toDouble(), max);

  /// Scale by height, capped at [max] logical pixels.
  double hMax(double max) => PreScaleManager().getHMax(toDouble(), max);

  /// Scale by the shorter axis (used for radii / symmetric sizes),
  /// capped at [max] logical pixels.
  double rMax(double max) => PreScaleManager().getRMax(toDouble(), max);

  /// A [SizedBox] gap whose height is capped at [max] logical pixels.
  SizedBox vGapMax(double max) => SizedBox(height: hMax(max));

  /// A [SizedBox] gap whose width is capped at [max] logical pixels.
  SizedBox hGapMax(double max) => SizedBox(width: wMax(max));

  /// Returns a specific integer value based on the current [DeviceType].
  ///
  /// This is useful for providing different counts (like crossAxisCount in a GridView)
  /// or other non-scaled values for different devices.
  int value(
    BuildContext context, {
    int? tablet,
    int? largeTablet,
    int? desktop,
  }) =>
      context.appSizes.value<int>(
        toInt(),
        tablet: tablet,
        largeTablet: largeTablet,
        desktop: desktop,
      );
}
