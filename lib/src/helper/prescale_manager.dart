import 'dart:math';
import '../responsive.dart';

/// ------------------------------------------------------------
/// PreScaleManager
/// ------------------------------------------------------------
/// Singleton to cache pre-calculated scaled numbers
/// to optimize performance (avoids repeated multiplications)
class PreScaleManager {
  PreScaleManager._private();
  static final PreScaleManager _instance = PreScaleManager._private();
  factory PreScaleManager() => _instance;

  /// Cache: original Figma number -> scaled number
  final Map<String, double> _cache = {};

  /// Track last used scale factor to invalidate cache on change
  double? _lastScaleW;
  double? _lastScaleH;
  double? _lastScaleText;
  double _minTextScale = 0.6;
  double _maxTextScale = 1.4;

  /// Clear cache manually (orientation / device change)
  void clear() {
    _cache.clear();
    _lastScaleW = null;
    _lastScaleH = null;
    _lastScaleText = null;
  }

  /// ------------------------------------------------------------
  /// Get scaled width
  double w(AppSizesNotifier sizes, double number) {
    updateScale(sizes);
    final key = 'w$number'; // key is original Figma number
    if (_cache.containsKey(key)) return _cache[key]!;

    final scaled = sizes.w(number);
    _cache[key] = scaled;
    return scaled;
  }

  /// Get scaled height
  double h(AppSizesNotifier sizes, double number) {
    updateScale(sizes);
    final key = 'h$number'; // negative key to separate w/h caches
    if (_cache.containsKey(key)) return _cache[key]!;

    final scaled = sizes.h(number);
    _cache[key] = scaled;
    return scaled;
  }

  /// Get scaled text
  double sp(AppSizesNotifier sizes, double number) {
    updateScale(sizes);
    final key = 'sp$number'; // offset to avoid collisions
    if (_cache.containsKey(key)) return _cache[key]!;

    final scaled = sizes.sp(number);
    _cache[key] = scaled;
    return scaled;
  }

  /// Get scaled radius
  double r(AppSizesNotifier sizes, double number) {
    updateScale(sizes);
    final key = 'r$number'; // offset to avoid collisions
    if (_cache.containsKey(key)) return _cache[key]!;

    final scaled = sizes.r(number);
    _cache[key] = scaled;
    return scaled;
  }

  /// Precalculate a list of numbers for width, height, or text
  void precalcList(
    AppSizesNotifier notifier,
    List<double> numbers, {
    String type = 'w',
  }) {
    updateScale(notifier);
    for (final num in numbers) {
      switch (type) {
        case 'w':
          w(notifier, num); // Call manager method to cache
          break;
        case 'h':
          h(notifier, num); // Call manager method to cache
          break;
        case 'sp':
          sp(notifier, num); // Call manager method to cache
          break;
        case 'r':
          r(notifier, num); // Call manager method to cache
          break;
      }
    }
  }

  /// Check if scale factors changed and clear cache if needed
  void updateScale(AppSizesNotifier sizes) {
    if (_lastScaleW != sizes.scaleW ||
        _lastScaleH != sizes.scaleH ||
        _lastScaleText != sizes.scaleText ||
        _minTextScale != sizes.minTextScale ||
        _maxTextScale != sizes.maxTextScale) {
      _cache.clear();
      _lastScaleW = sizes.scaleW;
      _lastScaleH = sizes.scaleH;
      _lastScaleText = sizes.scaleText;
      _minTextScale = sizes.minTextScale;
      _maxTextScale = sizes.maxTextScale;
    }
  }

  /// Retrieve cached value, or calculate and cache on the fly
  double getW(double number) {
    if (_lastScaleW == null) return number;
    return _cache.putIfAbsent('w$number', () => number * _lastScaleW!);
  }

  double getH(double number) {
    if (_lastScaleH == null) return number;
    return _cache.putIfAbsent('h$number', () => number * _lastScaleH!);
  }

  double getSp(double number) {
    if (_lastScaleText == null) return number;
    return _cache.putIfAbsent('sp$number', () {
      double responsiveFontSize = number * _lastScaleText!;
      return responsiveFontSize.clamp(
        number * _minTextScale,
        number * _maxTextScale,
      );
    });
  }

  double getR(double number) {
    if (_lastScaleW == null || _lastScaleH == null) return number;
    return _cache.putIfAbsent(
        'r$number', () => number * min(_lastScaleW!, _lastScaleH!));
  }

  /// ------------------------------------------------------------
  /// Cache inspection methods
  /// ------------------------------------------------------------
  /// Check if a width value is cached
  bool isCachedW(double number) => _cache.containsKey('w$number');

  /// Check if a height value is cached
  bool isCachedH(double number) => _cache.containsKey('h$number');

  /// Check if a text/sp value is cached
  bool isCachedSp(double number) => _cache.containsKey('sp$number');

  /// Check if a radius value is cached
  bool isCachedR(double number) => _cache.containsKey('r$number');

  /// Get cache size (for testing)
  int get cacheSize => _cache.length;
}
