import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_sizer/app_sizer.dart';

void main() {
  group('PreScaleManager Cache Tests', () {
    late PreScaleManager manager;
    late AppSizesNotifier notifier;

    setUp(() {
      manager = PreScaleManager();
      manager.clear(); // Clear cache before each test

      // Create a test notifier with known scale factors
      notifier = AppSizesNotifier(
        designWidth: 375.0,
        designHeight: 812.0,
      );
      // Update with screen dimensions (same as design = 1.0 scale)
      notifier.update(const Size(375.0, 812.0), Orientation.portrait);

      // Clear again after notifier update to ensure clean state
      manager.clear();
    });

    test('should cache width values after first calculation', () {
      // Verify value is not cached initially
      expect(manager.isCachedW(100.0), isFalse);

      // First call - should calculate and cache
      final firstCall = manager.w(notifier, 100.0);

      // Verify the value is now cached
      expect(manager.isCachedW(100.0), isTrue);
      expect(manager.getW(100.0), equals(firstCall));

      // Second call - should return cached value
      final secondCall = manager.w(notifier, 100.0);

      expect(secondCall, equals(firstCall));
      expect(secondCall, equals(100.0)); // Should be 100 since scale is 1.0
      expect(manager.isCachedW(100.0), isTrue); // Still cached
    });

    test('should cache height values after first calculation', () {
      // Verify value is not cached initially
      expect(manager.isCachedH(50.0), isFalse);

      // First call - should calculate and cache
      final firstCall = manager.h(notifier, 50.0);

      // Verify the value is now cached
      expect(manager.isCachedH(50.0), isTrue);
      expect(manager.getH(50.0), equals(firstCall));

      // Second call - should return cached value
      final secondCall = manager.h(notifier, 50.0);

      expect(secondCall, equals(firstCall));
      expect(secondCall, equals(50.0)); // Should be 50 since scale is 1.0
      expect(manager.isCachedH(50.0), isTrue); // Still cached
    });

    test('should cache text/sp values after first calculation', () {
      // Verify value is not cached initially
      expect(manager.isCachedSp(16.0), isFalse);

      // First call - should calculate and cache
      final firstCall = manager.sp(notifier, 16.0);

      // Verify the value is now cached
      expect(manager.isCachedSp(16.0), isTrue);
      expect(manager.getSp(16.0), equals(firstCall));

      // Second call - should return cached value
      final secondCall = manager.sp(notifier, 16.0);

      expect(secondCall, equals(firstCall));
      expect(manager.isCachedSp(16.0), isTrue); // Still cached
    });

    test('should cache radius values after first calculation', () {
      // Verify value is not cached initially
      expect(manager.isCachedR(12.0), isFalse);

      // First call - should calculate and cache
      final firstCall = manager.r(notifier, 12.0);

      // Verify the value is now cached
      expect(manager.isCachedR(12.0), isTrue);
      expect(manager.getR(12.0), equals(firstCall));

      // Second call - should return cached value
      final secondCall = manager.r(notifier, 12.0);

      expect(secondCall, equals(firstCall));
      expect(manager.isCachedR(12.0), isTrue); // Still cached
    });

    test('should cache different values independently', () {
      // Cache multiple width values
      final w100 = manager.w(notifier, 100.0);
      final w200 = manager.w(notifier, 200.0);
      final w300 = manager.w(notifier, 300.0);

      // Verify all are cached
      expect(manager.isCachedW(100.0), isTrue);
      expect(manager.isCachedW(200.0), isTrue);
      expect(manager.isCachedW(300.0), isTrue);

      // Verify all are cached correctly
      expect(manager.getW(100.0), equals(w100));
      expect(manager.getW(200.0), equals(w200));
      expect(manager.getW(300.0), equals(w300));

      // Verify they're different values
      expect(w100, isNot(equals(w200)));
      expect(w200, isNot(equals(w300)));
    });

    test('should cache w, h, sp, and r values separately', () {
      // Use the same number for all types
      const testValue = 20.0;

      final wValue = manager.w(notifier, testValue);
      final hValue = manager.h(notifier, testValue);
      final spValue = manager.sp(notifier, testValue);
      final rValue = manager.r(notifier, testValue);

      // Verify all are cached separately
      expect(manager.isCachedW(testValue), isTrue);
      expect(manager.isCachedH(testValue), isTrue);
      expect(manager.isCachedSp(testValue), isTrue);
      expect(manager.isCachedR(testValue), isTrue);

      // Verify all cached values are retrievable
      expect(manager.getW(testValue), equals(wValue));
      expect(manager.getH(testValue), equals(hValue));
      expect(manager.getSp(testValue), equals(spValue));
      expect(manager.getR(testValue), equals(rValue));

      // Verify cache has 4 entries (one for each type)
      expect(manager.cacheSize, equals(4));
    });

    test('should clear cache when scale factors change', () {
      // Cache some values with initial scale
      final initialW = manager.w(notifier, 100.0);
      final initialH = manager.h(notifier, 50.0);

      // Verify values are cached
      expect(manager.isCachedW(100.0), isTrue);
      expect(manager.isCachedH(50.0), isTrue);
      expect(manager.getW(100.0), equals(initialW));
      expect(manager.getH(50.0), equals(initialH));

      // Create new notifier with different dimensions (different scale)
      final newNotifier = AppSizesNotifier(
        designWidth: 375.0,
        designHeight: 812.0,
      );
      // Update with doubled screen dimensions (2x scale)
      newNotifier.update(const Size(750.0, 1624.0), Orientation.portrait);

      // Call with new notifier - should clear cache and recalculate
      final newW = manager.w(newNotifier, 100.0);
      final newH = manager.h(newNotifier, 50.0);

      // Cache should have been cleared and rebuilt with new values
      expect(manager.isCachedW(100.0), isTrue);
      expect(manager.isCachedH(50.0), isTrue);

      // Values should be different (scaled by 2x)
      expect(newW, isNot(equals(initialW)));
      expect(newH, isNot(equals(initialH)));
      expect(newW, equals(200.0)); // 100 * 2.0 scale
      expect(newH, equals(100.0)); // 50 * 2.0 scale
    });

    test('should handle manual cache clear', () {
      // Cache some values with scale factor 1.0
      final cachedW = manager.w(notifier, 100.0);
      final cachedH = manager.h(notifier, 50.0);
      final cachedSp = manager.sp(notifier, 16.0);
      final cachedR = manager.r(notifier, 12.0);

      // Verify values are actually cached
      expect(manager.isCachedW(100.0), isTrue);
      expect(manager.isCachedH(50.0), isTrue);
      expect(manager.isCachedSp(16.0), isTrue);
      expect(manager.isCachedR(12.0), isTrue);
      expect(manager.cacheSize, equals(4));

      // Verify cached values are retrievable
      expect(manager.getW(100.0), equals(cachedW));
      expect(manager.getH(50.0), equals(cachedH));
      expect(manager.getSp(16.0), equals(cachedSp));
      expect(manager.getR(12.0), equals(cachedR));

      // Verify these are the expected scaled values (scale = 1.0)
      expect(cachedW, equals(100.0));
      expect(cachedH, equals(50.0));
      expect(cachedSp, equals(16.0));
      expect(cachedR, equals(12.0));

      // Clear cache manually
      manager.clear();

      // After clear, verify cache is empty
      expect(manager.isCachedW(100.0), isFalse);
      expect(manager.isCachedH(50.0), isFalse);
      expect(manager.isCachedSp(16.0), isFalse);
      expect(manager.isCachedR(12.0), isFalse);
      expect(manager.cacheSize, equals(0));

      // After clear, getW/getH/getSp/getR should return fallback values
      // since _lastScaleW/H/Text are null after clear
      // The fallback logic returns the original number when scale is null
      expect(manager.getW(100.0), equals(100.0)); // Returns original number
      expect(manager.getH(50.0), equals(50.0)); // Returns original number
      expect(manager.getSp(16.0), equals(16.0)); // Returns original number
      expect(manager.getR(12.0), equals(12.0)); // Returns original number

      // Now test with a different scale to verify cache vs fallback behavior
      final scaledNotifier = AppSizesNotifier(
        designWidth: 375.0,
        designHeight: 812.0,
      );
      // Update with 2x screen dimensions (scale = 2.0)
      scaledNotifier.update(const Size(750.0, 1624.0), Orientation.portrait);

      // Cache a value with 2x scale
      final scaledW = manager.w(scaledNotifier, 100.0);
      expect(scaledW, equals(200.0)); // 100 * 2.0 scale

      // Value should be cached
      expect(manager.isCachedW(100.0), isTrue);
      expect(manager.getW(100.0), equals(200.0));

      // Clear cache again
      manager.clear();

      // After clear, verify value is not cached
      expect(manager.isCachedW(100.0), isFalse);
      expect(manager.cacheSize, equals(0));

      // After clear, getW should return original number (fallback)
      // NOT the cached scaled value, proving cache was cleared
      expect(manager.getW(100.0), equals(100.0)); // Fallback to original
    });

    test('should precalculate list of values', () {
      final testValues = [10.0, 20.0, 30.0, 40.0, 50.0];

      // Verify values are not cached initially
      for (final value in testValues) {
        expect(manager.isCachedW(value), isFalse);
      }

      // Precalculate width values
      manager.precalcList(notifier, testValues, type: 'w');

      // All values should now be cached
      for (final value in testValues) {
        expect(manager.isCachedW(value), isTrue);
        expect(manager.getW(value), equals(value)); // Scale is 1.0
      }
    });

    test('should handle different types in precalcList', () {
      final testValues = [10.0, 20.0, 30.0];

      // Precalculate for all types
      manager.precalcList(notifier, testValues, type: 'w');
      manager.precalcList(notifier, testValues, type: 'h');
      manager.precalcList(notifier, testValues, type: 'sp');
      manager.precalcList(notifier, testValues, type: 'r');

      // Verify all types are cached
      for (final value in testValues) {
        expect(manager.isCachedW(value), isTrue);
        expect(manager.isCachedH(value), isTrue);
        expect(manager.isCachedSp(value), isTrue);
        expect(manager.isCachedR(value), isTrue);
      }

      // Verify cache size: 3 values × 4 types = 12 entries
      expect(manager.cacheSize, equals(12));
    });

    test('should maintain singleton instance', () {
      final instance1 = PreScaleManager();
      final instance2 = PreScaleManager();

      // Should be the same instance
      expect(identical(instance1, instance2), isTrue);

      // Cache in one instance should be available in the other
      instance1.w(notifier, 100.0);
      expect(instance2.getW(100.0), equals(100.0));
    });

    test('should handle scaled dimensions correctly', () {
      // Create notifier with different screen size
      final scaledNotifier = AppSizesNotifier(
        designWidth: 375.0,
        designHeight: 812.0,
      );
      // Update with 2x screen dimensions
      scaledNotifier.update(const Size(750.0, 1624.0), Orientation.portrait);

      // Test width scaling
      final w100 = manager.w(scaledNotifier, 100.0);
      expect(w100, equals(200.0)); // 100 * 2.0 scale
      expect(manager.getW(100.0), equals(200.0));

      // Test height scaling
      final h50 = manager.h(scaledNotifier, 50.0);
      expect(h50, equals(100.0)); // 50 * 2.0 scale
      expect(manager.getH(50.0), equals(100.0));
    });

    test('should cache values with decimal precision', () {
      const testValue = 16.5;

      final wValue = manager.w(notifier, testValue);
      final hValue = manager.h(notifier, testValue);

      // Verify cached values maintain precision
      expect(manager.getW(testValue), equals(wValue));
      expect(manager.getH(testValue), equals(hValue));
      expect(wValue, equals(16.5)); // Scale is 1.0
      expect(hValue, equals(16.5)); // Scale is 1.0
    });
  });
}
