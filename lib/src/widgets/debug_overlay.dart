import 'package:flutter/material.dart';
import 'package:app_sizer/app_sizer.dart';

/// An on-screen HUD that displays live responsive metrics.
///
/// Wrap any widget to overlay scale information on top of it:
/// ```dart
/// AppSizerDebugOverlay(
///   child: MyWidget(),
/// )
/// ```
///
/// Only renders when [AppSizesNotifier.isDebugLogs] is `true` **and** the app
/// is running in debug mode. In release builds this widget is always a
/// transparent pass-through — zero runtime cost.
class AppSizerDebugOverlay extends StatelessWidget {
  /// The widget below this overlay in the widget tree.
  final Widget child;

  /// Where to anchor the HUD within the overlay.
  ///
  /// Defaults to [Alignment.bottomRight].
  final Alignment alignment;

  /// Opacity of the debug HUD panel.
  ///
  /// Defaults to `0.85`.
  final double opacity;

  /// Creates an [AppSizerDebugOverlay].
  const AppSizerDebugOverlay({
    super.key,
    required this.child,
    this.alignment = Alignment.bottomRight,
    this.opacity = 0.85,
  });

  @override
  Widget build(BuildContext context) {
    // Always return child in release mode — zero overhead.
    bool show = false;
    assert(() {
      show = context.appSizes.isDebugLogs;
      return true;
    }());
    if (!show) return child;

    return ListenableBuilder(
      listenable: context.appSizes,
      builder: (context, _) {
        final s = context.appSizes;
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            children: [
              child,
              Positioned.fill(
                child: Align(
                  alignment: alignment,
                  child: Opacity(
                    opacity: opacity,
                    child: _DebugHud(sizes: s),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Internal HUD panel that renders the live scale metrics.
class _DebugHud extends StatelessWidget {
  final AppSizesNotifier sizes;

  const _DebugHud({required this.sizes});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(6),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 11,
          color: Colors.greenAccent,
          height: 1.6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('device : ${sizes.deviceType.name}'),
            Text(
              'screen : '
              '${sizes.screenWidth.toStringAsFixed(0)}'
              '×'
              '${sizes.screenHeight.toStringAsFixed(0)}',
            ),
            Text('scaleW : ${sizes.scaleW.toStringAsFixed(3)}'),
            Text('scaleH : ${sizes.scaleH.toStringAsFixed(3)}'),
            Text('scaleT : ${sizes.scaleText.toStringAsFixed(3)}'),
            Text('orient : ${sizes.isLandscape ? "landscape" : "portrait"}'),
            Text('cache  : ${PreScaleManager().cacheSize} entries'),
          ],
        ),
      ),
    );
  }
}
