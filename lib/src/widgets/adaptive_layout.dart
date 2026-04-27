import 'package:flutter/material.dart';

import '../helper/device_type.dart';
import '../app_sizes_provider.dart';

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
  Widget build(BuildContext context) =>
      switch (AppSizesProvider.of(context).deviceType) {
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
