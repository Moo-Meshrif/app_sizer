import 'dart:math';
import '../responsive.dart';

/// ------------------------------------------------------------
/// PreScaleManager
/// ------------------------------------------------------------
/// Singleton to cache pre-calculated scaled numbers
/// to optimize performance (avoids repeated multiplications)
/// A singleton manager that handles caching of scaled values to optimize performance.
class PreScaleManager {
  PreScaleManager._private();
  static final PreScaleManager _instance = PreScaleManager._private();

  /// Access the single instance of [PreScaleManager].
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
  /// Clears the entire cache and resets scale tracking.
  void clear() {
    _cache.clear();
    _lastScaleW = null;
    _lastScaleH = null;
    _lastScaleText = null;
    _minTextScale = 0.6;
    _maxTextScale = 1.4;
  }

  /// ------------------------------------------------------------
  /// Get scaled width
  /// Internal helper to calculate and cache scaled width.
  double w(AppSizesNotifier sizes, double number) {
    updateScale(sizes);
    final key = 'w$number'; // key is original Figma number
    if (_cache.containsKey(key)) return _cache[key]!;

    final scaled = sizes.w(number);
    _cache[key] = scaled;
    return scaled;
  }

  /// Get scaled height
  /// Internal helper to calculate and cache scaled height.
  double h(AppSizesNotifier sizes, double number) {
    updateScale(sizes);
    final key = 'h$number'; // negative key to separate w/h caches
    if (_cache.containsKey(key)) return _cache[key]!;

    final scaled = sizes.h(number);
    _cache[key] = scaled;
    return scaled;
  }

  /// Get scaled text
  /// Internal helper to calculate and cache scaled text size.
  double sp(AppSizesNotifier sizes, double number) {
    updateScale(sizes);
    final key = 'sp$number'; // offset to avoid collisions
    if (_cache.containsKey(key)) return _cache[key]!;

    final scaled = sizes.sp(number);
    _cache[key] = scaled;
    return scaled;
  }

  /// Get scaled radius
  /// Internal helper to calculate and cache scaled radius.
  double r(AppSizesNotifier sizes, double number) {
    updateScale(sizes);
    final key = 'r$number'; // offset to avoid collisions
    if (_cache.containsKey(key)) return _cache[key]!;

    final scaled = sizes.r(number);
    _cache[key] = scaled;
    return scaled;
  }

  /// Get scaled diagonal
  /// Internal helper to calculate and cache scaled diagonal.
  double dg(AppSizesNotifier sizes, double number) {
    updateScale(sizes);
    final key = 'dg$number';
    if (_cache.containsKey(key)) return _cache[key]!;

    final scaled = sizes.dg(number);
    _cache[key] = scaled;
    return scaled;
  }

  /// Get scaled diameter
  /// Internal helper to calculate and cache scaled diameter.
  double dm(AppSizesNotifier sizes, double number) {
    updateScale(sizes);
    final key = 'dm$number';
    if (_cache.containsKey(key)) return _cache[key]!;

    final scaled = sizes.dm(number);
    _cache[key] = scaled;
    return scaled;
  }

  /// Precalculate a list of numbers for width, height, or text
  /// Pre-calculates a list of [numbers] for the given [type] ('w', 'h', 'sp', 'r', 'dg', or 'dm').
  void precalcList(
    AppSizesNotifier notifier,
    List<double> numbers, {
    String type = 'w',
  }) {
    assert(
      ['w', 'h', 'sp', 'r', 'dg', 'dm'].contains(type),
      'Invalid type "$type". Must be one of: w, h, sp, r, dg, dm.',
    );
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
        case 'dg':
          dg(notifier, num); // Call manager method to cache
          break;
        case 'dm':
          dm(notifier, num); // Call manager method to cache
          break;
      }
    }
  }

  /// Check if scale factors changed and clear cache if needed
  /// Checks if scale factors have changed and invalidates the cache if necessary.
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
  /// Returns the cached scaled width for [number], or calculates it if not present.
  double getW(double number) {
    if (_lastScaleW == null) return number;
    return _cache.putIfAbsent('w$number', () => number * _lastScaleW!);
  }

  /// Returns the cached scaled height for [number], or calculates it if not present.
  double getH(double number) {
    if (_lastScaleH == null) return number;
    return _cache.putIfAbsent('h$number', () => number * _lastScaleH!);
  }

  /// Returns the cached scaled text size for [number], or calculates it if not present.
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

  /// Returns the cached scaled radius for [number], or calculates it if not present.
  double getR(double number) {
    if (_lastScaleW == null || _lastScaleH == null) return number;
    return _cache.putIfAbsent(
        'r$number', () => number * min(_lastScaleW!, _lastScaleH!));
  }

  /// Returns the cached scaled diagonal for [number], or calculates it if not present.
  double getDg(double number) {
    if (_lastScaleW == null || _lastScaleH == null) return number;
    return _cache.putIfAbsent(
        'dg$number', () => number * _lastScaleW! * _lastScaleH!);
  }

  /// Returns the cached scaled diameter for [number], or calculates it if not present.
  double getDm(double number) {
    if (_lastScaleW == null || _lastScaleH == null) return number;
    return _cache.putIfAbsent(
        'dm$number', () => number * max(_lastScaleW!, _lastScaleH!));
  }

  /// Capped variants — scale and clamp to [max] logical pixels.
  /// Cache key encodes both the base value and the cap so different
  /// [max] values for the same base are cached independently.

  /// Returns the cached scaled width for [number] capped at [max], or calculates it if not present.
  double getWMax(double number, double max) {
    if (_lastScaleW == null) return number.clamp(0.0, max);
    return _cache.putIfAbsent(
      'wmax${number}_$max',
      () => (number * _lastScaleW!).clamp(0.0, max),
    );
  }

  /// Returns the cached scaled height for [number] capped at [max], or calculates it if not present.
  double getHMax(double number, double max) {
    if (_lastScaleH == null) return number.clamp(0.0, max);
    return _cache.putIfAbsent(
      'hmax${number}_$max',
      () => (number * _lastScaleH!).clamp(0.0, max),
    );
  }

  /// Returns the cached scaled radius for [number] capped at [max], or calculates it if not present.
  double getRMax(double number, double max) {
    if (_lastScaleW == null || _lastScaleH == null) {
      return number.clamp(0.0, max);
    }
    return _cache.putIfAbsent(
      'rmax${number}_$max',
      () => (number * min(_lastScaleW!, _lastScaleH!)).clamp(0.0, max),
    );
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
