import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_sizer/app_sizer.dart';

void main() {
  group('AppSizesNotifier Tests', () {
    late AppSizesNotifier notifier;

    setUp(() {
      // Clear PreScaleManager cache before each test
      PreScaleManager().clear();

      notifier = AppSizesNotifier(
        designWidth: 375.0,
        designHeight: 812.0,
      );
    });

    group('Basic Scaling', () {
      test('should calculate 1:1 scale when screen matches design size', () {
        notifier.update(const Size(375.0, 812.0), Orientation.portrait);

        expect(notifier.scaleW, equals(1.0));
        expect(notifier.scaleH, equals(1.0));
        expect(notifier.screenWidth, equals(375.0));
        expect(notifier.screenHeight, equals(812.0));
      });

      test('should calculate 2x scale when screen is double design size', () {
        notifier.update(const Size(750.0, 1624.0), Orientation.portrait);

        expect(notifier.scaleW, equals(2.0));
        expect(notifier.scaleH, equals(2.0));
      });

      test('should calculate fractional scale for smaller screens', () {
        notifier.update(const Size(320.0, 568.0), Orientation.portrait);

        expect(notifier.scaleW, closeTo(0.853, 0.01));
        expect(notifier.scaleH, closeTo(0.699, 0.01));
      });

      test('should handle different aspect ratios', () {
        notifier.update(const Size(414.0, 896.0), Orientation.portrait);

        expect(notifier.scaleW, closeTo(1.104, 0.01));
        expect(notifier.scaleH, closeTo(1.103, 0.01));
      });
    });

    group('Device Type Detection', () {
      test('should detect mobile device (< 600px width)', () {
        notifier.update(const Size(375.0, 812.0), Orientation.portrait);
        expect(notifier.deviceType, equals(DeviceType.mobile));
      });

      test('should detect tablet device (600-899px width)', () {
        notifier.update(const Size(768.0, 1024.0), Orientation.portrait);
        expect(notifier.deviceType, equals(DeviceType.tablet));
      });

      test('should detect large tablet device (900-1099px width)', () {
        notifier.update(const Size(1000.0, 1400.0), Orientation.portrait);
        expect(notifier.deviceType, equals(DeviceType.tabletLarge));
      });

      test('should detect desktop device (>= 1100px width)', () {
        notifier.update(const Size(1920.0, 1080.0), Orientation.landscape);
        expect(notifier.deviceType, equals(DeviceType.desktop));
      });

      test('should detect device type at exact breakpoint boundaries', () {
        // Exactly 600px - should be tablet
        notifier.update(const Size(600.0, 800.0), Orientation.portrait);
        expect(notifier.deviceType, equals(DeviceType.tablet));

        // Exactly 900px - should be tabletLarge
        notifier.update(const Size(900.0, 1200.0), Orientation.portrait);
        expect(notifier.deviceType, equals(DeviceType.tabletLarge));

        // Exactly 1100px - should be desktop
        notifier.update(const Size(1100.0, 800.0), Orientation.landscape);
        expect(notifier.deviceType, equals(DeviceType.desktop));
      });
    });

    group('Orientation Handling', () {
      test('should handle portrait orientation correctly', () {
        notifier.update(const Size(375.0, 812.0), Orientation.portrait);

        expect(notifier.isLandscape, isFalse);
        expect(notifier.scaleW, equals(1.0));
        expect(notifier.scaleH, equals(1.0));
      });

      test('should handle landscape orientation correctly', () {
        // In landscape, design dimensions are swapped
        // designW becomes designHeight (812), designH becomes designWidth (375)
        notifier.update(const Size(812.0, 375.0), Orientation.landscape);

        expect(notifier.isLandscape, isTrue);
        expect(notifier.screenWidth, equals(812.0));
        expect(notifier.screenHeight, equals(375.0));
        expect(notifier.scaleW, equals(1.0)); // 812 / 812
        expect(notifier.scaleH, equals(1.0)); // 375 / 375
      });

      test('should change device type when rotating to landscape', () {
        // Portrait mobile
        notifier.update(const Size(375.0, 812.0), Orientation.portrait);
        expect(notifier.deviceType, equals(DeviceType.mobile));

        // Landscape - width becomes 812, which is > 600 (tablet range)
        notifier.update(const Size(812.0, 375.0), Orientation.landscape);
        expect(notifier.deviceType, equals(DeviceType.tablet));
      });

      test('should maintain correct scaling when rotating', () {
        // Portrait
        notifier.update(const Size(375.0, 812.0), Orientation.portrait);
        final portraitW = notifier.w(100.0);
        final portraitH = notifier.h(100.0);

        // Landscape
        notifier.update(const Size(812.0, 375.0), Orientation.landscape);
        final landscapeW = notifier.w(100.0);
        final landscapeH = notifier.h(100.0);

        // Both should be 100 since design matches screen in both orientations
        expect(portraitW, equals(100.0));
        expect(portraitH, equals(100.0));
        expect(landscapeW, equals(100.0));
        expect(landscapeH, equals(100.0));
      });
    });

    group('Scaling Methods', () {
      setUp(() {
        notifier.update(const Size(750.0, 1624.0), Orientation.portrait);
        // This gives us scaleW = 2.0, scaleH = 2.0
      });

      test('w() should scale width values correctly', () {
        expect(notifier.w(100.0), equals(200.0));
        expect(notifier.w(50.0), equals(100.0));
        expect(notifier.w(0.0), equals(0.0));
      });

      test('h() should scale height values correctly', () {
        expect(notifier.h(100.0), equals(200.0));
        expect(notifier.h(50.0), equals(100.0));
        expect(notifier.h(0.0), equals(0.0));
      });

      test('r() should use minimum scale factor', () {
        // Both scaleW and scaleH are 2.0, so min is 2.0
        expect(notifier.r(10.0), equals(20.0));

        // Test with different scales
        notifier.update(const Size(750.0, 812.0), Orientation.portrait);
        // scaleW = 2.0, scaleH = 1.0, min = 1.0
        expect(notifier.r(10.0), equals(10.0));
      });

      test('dg() should use both scale factors (diagonal)', () {
        notifier.update(const Size(750.0, 1624.0), Orientation.portrait);
        // scaleW = 2.0, scaleH = 2.0, dg = 2 * 2 = 4.0
        expect(notifier.dg(10.0), equals(40.0));

        notifier.update(const Size(750.0, 812.0), Orientation.portrait);
        // scaleW = 2.0, scaleH = 1.0, dg = 2 * 1 = 2.0
        expect(notifier.dg(10.0), equals(20.0));
      });

      test('dm() should use maximum scale factor (diameter)', () {
        notifier.update(const Size(750.0, 1624.0), Orientation.portrait);
        // scaleW = 2.0, scaleH = 2.0, max = 2.0
        expect(notifier.dm(10.0), equals(20.0));

        notifier.update(const Size(750.0, 812.0), Orientation.portrait);
        // scaleW = 2.0, scaleH = 1.0, max = 2.0
        expect(notifier.dm(10.0), equals(20.0));

        notifier.update(const Size(187.5, 1624.0), Orientation.portrait);
        // scaleW = 0.5, scaleH = 2.0, max = 2.0
        expect(notifier.dm(10.0), equals(20.0));
      });

      test('sp() should scale text with clamping', () {
        // scaleText for tablet at 750px width = 750/600 = 1.25
        // sp clamps between 0.6x and 1.4x of original by default
        // For 16.0: 16 * 1.25 = 20.0 (within 9.6-22.4 range, so no clamping)
        final result = notifier.sp(16.0);
        expect(result, equals(20.0));
      });

      test('sp() should clamp to lower limit for small scales', () {
        notifier.update(const Size(200.0, 400.0), Orientation.portrait);
        // scaleText for mobile at 200px = 200/375 = 0.533
        // For 16.0: 16 * 0.533 = 8.53, but clamped to 16 * 0.6 = 9.6
        final result = notifier.sp(16.0);
        expect(result, equals(9.6)); // Lower limit
      });

      test('sp() should not clamp when within limits', () {
        notifier.update(const Size(375.0, 812.0), Orientation.portrait);
        // scaleText = 1.0, so 16 * 1.0 = 16 (within 12.8-19.2 range)
        expect(notifier.sp(16.0), equals(16.0));
      });

      test('sh() should scale by screen height fraction', () {
        notifier.update(const Size(375.0, 812.0), Orientation.portrait);
        expect(notifier.sh(0.5), equals(406.0)); // 812 * 0.5
        expect(notifier.sh(1.0), equals(812.0));
      });

      test('sw() should scale by screen width fraction', () {
        notifier.update(const Size(375.0, 812.0), Orientation.portrait);
        expect(notifier.sw(0.5), equals(187.5)); // 375 * 0.5
        expect(notifier.sw(1.0), equals(375.0));
      });
    });

    group('Text Scale Calculation', () {
      test('should use screen/design ratio for mobile devices', () {
        notifier.update(const Size(375.0, 812.0), Orientation.portrait);
        expect(notifier.deviceType, equals(DeviceType.mobile));
        expect(notifier.scaleText, equals(1.0)); // 375/375
      });

      test('should use screen/600 ratio for tablet devices', () {
        notifier.update(const Size(768.0, 1024.0), Orientation.portrait);
        expect(notifier.deviceType, equals(DeviceType.tablet));
        expect(notifier.scaleText, closeTo(1.28, 0.01)); // 768/600
      });

      test('should use screen/900 ratio for large tablet devices', () {
        notifier.update(const Size(1000.0, 1400.0), Orientation.portrait);
        expect(notifier.deviceType, equals(DeviceType.tabletLarge));
        expect(notifier.scaleText, closeTo(1.111, 0.01)); // 1000/900
      });

      test('should use screen/1100 ratio for desktop devices', () {
        notifier.update(const Size(1920.0, 1080.0), Orientation.landscape);
        expect(notifier.deviceType, equals(DeviceType.desktop));
        expect(notifier.scaleText, closeTo(1.745, 0.01)); // 1920/1100
      });
    });

    group('Enhanced Text Scaling', () {
      test('should support custom min/max text scale', () {
        final customNotifier = AppSizesNotifier(
          designWidth: 375.0,
          designHeight: 812.0,
          minTextScale: 0.5,
          maxTextScale: 1.5,
        );

        // Very small screen: 200px width (scale = 200/375 = 0.533)
        customNotifier.update(const Size(200.0, 400.0), Orientation.portrait);

        // With 0.5 min scale, 16.0 * 0.533 = 8.53 should NOT be clamped to 12.8 (0.8)
        // but it should be 8.53.
        expect(customNotifier.sp(16.0), closeTo(8.53, 0.01));
      });

      test('should support global textScaleFactor', () {
        final customNotifier = AppSizesNotifier(
          designWidth: 375.0,
          designHeight: 812.0,
          textScaleFactor: 1.2,
        );

        customNotifier.update(const Size(375.0, 812.0), Orientation.portrait);

        // 16.0 * 1.0 (scale) * 1.2 (factor) = 19.2
        expect(customNotifier.sp(16.0), equals(19.2));
      });

      test('should support useHeightForTextScale', () {
        final customNotifier = AppSizesNotifier(
          designWidth: 375.0,
          designHeight: 812.0,
          useHeightForTextScale: true,
        );

        // Normal width, but very short height
        customNotifier.update(const Size(375.0, 406.0), Orientation.portrait);

        // width scale = 1.0
        // height scale = 406/812 = 0.5
        // scaleText should be 0.5
        expect(customNotifier.scaleText, equals(0.5));

        // 16.0 * 0.5 = 8.0, clamped by default min 0.6 to 9.6
        expect(customNotifier.sp(16.0), equals(9.6));
      });
    });

    group('Custom Base Text Sizes', () {
      test('should support custom base sizes', () {
        final customNotifier = AppSizesNotifier(
          designWidth: 375.0,
          designHeight: 812.0,
          baseMediumTextSize: 18.0,
        );
        customNotifier.update(const Size(375.0, 812.0), Orientation.portrait);
        expect(customNotifier.mediumTextSize, equals(18.0));
      });
    });

    group('Capped Scaling Methods', () {
      setUp(() {
        notifier.update(const Size(750.0, 1624.0), Orientation.portrait);
        // scaleW = 2.0, scaleH = 2.0
      });

      test('wMax() should scale and clamp to max width', () {
        // 100 * 2.0 = 200, capped at 150 -> 150
        expect(notifier.wMax(100.0, 150.0), equals(150.0));
        // 50 * 2.0 = 100, capped at 150 -> 100
        expect(notifier.wMax(50.0, 150.0), equals(100.0));
      });

      test('hMax() should scale and clamp to max height', () {
        // 100 * 2.0 = 200, capped at 150 -> 150
        expect(notifier.hMax(100.0, 150.0), equals(150.0));
        // 50 * 2.0 = 100, capped at 150 -> 100
        expect(notifier.hMax(50.0, 150.0), equals(100.0));
      });

      test('rMax() should scale and clamp to max radius', () {
        // 100 * 2.0 = 200, capped at 150 -> 150
        expect(notifier.rMax(100.0, 150.0), equals(150.0));
        // 50 * 2.0 = 100, capped at 150 -> 100
        expect(notifier.rMax(50.0, 150.0), equals(100.0));
      });
    });

    group('Adaptive Value Selection', () {
      test('should return mobile value for mobile device', () {
        notifier.update(const Size(375.0, 812.0), Orientation.portrait);
        expect(notifier.value(10, tablet: 20, desktop: 30), equals(10));
      });

      test('should return tablet value for tablet device', () {
        notifier.update(const Size(768.0, 1024.0), Orientation.portrait);
        expect(notifier.value(10, tablet: 20, desktop: 30), equals(20));
      });

      test('should fallback to mobile when tablet value not provided', () {
        notifier.update(const Size(768.0, 1024.0), Orientation.portrait);
        expect(notifier.value(10, desktop: 30), equals(10));
      });

      test('should return largeTablet value for large tablet device', () {
        notifier.update(const Size(1000.0, 1400.0), Orientation.portrait);
        expect(
          notifier.value(10, tablet: 20, largeTablet: 25, desktop: 30),
          equals(25),
        );
      });

      test('should fallback through tablet to mobile for large tablet', () {
        notifier.update(const Size(1000.0, 1400.0), Orientation.portrait);
        // No largeTablet, use tablet
        expect(notifier.value(10, tablet: 20, desktop: 30), equals(20));
        // No largeTablet or tablet, use mobile
        expect(notifier.value(10, desktop: 30), equals(10));
      });

      test('should return desktop value for desktop device', () {
        notifier.update(const Size(1920.0, 1080.0), Orientation.landscape);
        expect(notifier.value(10, tablet: 20, desktop: 30), equals(30));
      });

      test('should fallback through all levels for desktop', () {
        notifier.update(const Size(1920.0, 1080.0), Orientation.landscape);
        // No desktop, use largeTablet
        expect(
          notifier.value(10, tablet: 20, largeTablet: 25),
          equals(25),
        );
        // No desktop or largeTablet, use tablet
        expect(notifier.value(10, tablet: 20), equals(20));
        // No desktop, largeTablet, or tablet, use mobile
        expect(notifier.value(10), equals(10));
      });
    });

    group('Standard Sizes', () {
      test('should calculate standard sizes correctly', () {
        notifier.update(const Size(375.0, 812.0), Orientation.portrait);

        expect(notifier.screenHPadding, equals(16.0));
        expect(notifier.screenVPadding, equals(10.0));
        expect(notifier.cardRadius, equals(12.0));
        expect(notifier.inputRadius, equals(8.0));
        expect(notifier.extraLargeTextSize, equals(26.0));
        expect(notifier.largeTextSize, equals(20.0));
        expect(notifier.mediumTextSize, equals(16.0));
        expect(notifier.smallTextSize, equals(12.0));
      });

      test('should scale standard sizes with screen size', () {
        notifier.update(const Size(750.0, 1624.0), Orientation.portrait);

        // All should be doubled (scale = 2.0)
        expect(notifier.screenHPadding, equals(32.0));
        expect(notifier.screenVPadding, equals(20.0));
        expect(notifier.cardRadius, equals(24.0));
        expect(notifier.inputRadius, equals(16.0));
        // Text sizes use sp() which clamps, so they won't be exactly 2x
        expect(notifier.extraLargeTextSize, greaterThan(26.0));
        expect(notifier.largeTextSize, greaterThan(20.0));
      });
    });

    group('Update Optimization', () {
      test('should not recalculate if size unchanged', () {
        notifier.update(const Size(375.0, 812.0), Orientation.portrait);
        final firstScaleW = notifier.scaleW;

        // Update with same size
        notifier.update(const Size(375.0, 812.0), Orientation.portrait);
        expect(notifier.scaleW, equals(firstScaleW));
      });

      test('should recalculate if size changes', () {
        notifier.update(const Size(375.0, 812.0), Orientation.portrait);
        expect(notifier.scaleW, equals(1.0));

        notifier.update(const Size(750.0, 1624.0), Orientation.portrait);
        expect(notifier.scaleW, equals(2.0));
      });

      test('should reset initialization flag', () {
        notifier.update(const Size(375.0, 812.0), Orientation.portrait);
        notifier.reset();

        // After reset, next update should recalculate even with same size
        notifier.update(const Size(375.0, 812.0), Orientation.portrait);
        expect(notifier.scaleW, equals(1.0));
      });
    });
  });

  group('ScaleX Extension Tests', () {
    late AppSizesNotifier notifier;

    setUp(() {
      PreScaleManager().clear();
      notifier = AppSizesNotifier(
        designWidth: 375.0,
        designHeight: 812.0,
      );
      notifier.update(const Size(750.0, 1624.0), Orientation.portrait);
      // This gives us scaleW = 2.0, scaleH = 2.0
    });

    test('should scale width using .w extension', () {
      final result = 100.w;
      expect(result, equals(200.0));
    });

    test('should scale height using .h extension', () {
      final result = 50.h;
      expect(result, equals(100.0));
    });

    test('should scale radius using .r extension', () {
      final result = 12.r;
      expect(result, equals(24.0));
    });

    test('should scale diagonal using .dg extension', () {
      final result = 10.dg;
      expect(result, equals(40.0)); // 10 * 2.0 * 2.0
    });

    test('should scale diameter using .dm extension', () {
      final result = 10.dm;
      expect(result, equals(20.0)); // 10 * max(2.0, 2.0)
    });

    test('should scale text using .sp extension', () {
      final result = 16.sp;
      // scaleText = 1.25, 16 * 1.25 = 20.0 (within 9.6-22.4 range)
      expect(result, equals(20.0));
    });

    test('should work with int values', () {
      expect(100.w, equals(200.0));
      expect(50.h, equals(100.0));
    });

    test('should work with double values', () {
      expect(100.0.w, equals(200.0));
      expect(50.5.h, equals(101.0));
    });

    test('should create vertical gap using .vGap', () {
      final gap = 20.vGap;
      expect(gap, isA<SizedBox>());
      expect(gap.height, equals(40.0)); // 20 * 2.0 scale
      expect(gap.width, isNull);
    });

    test('should create horizontal gap using .hGap', () {
      final gap = 20.hGap;
      expect(gap, isA<SizedBox>());
      expect(gap.width, equals(40.0)); // 20 * 2.0 scale
      expect(gap.height, isNull);
    });

    test('should scale and clamp using .wMax extension', () {
      expect(100.wMax(150), equals(150.0));
      expect(50.wMax(150), equals(100.0));
    });

    test('should scale and clamp using .hMax extension', () {
      expect(100.hMax(150), equals(150.0));
      expect(50.hMax(150), equals(100.0));
    });

    test('should scale and clamp using .rMax extension', () {
      expect(100.rMax(150), equals(150.0));
      expect(50.rMax(150), equals(100.0));
    });

    test('should create vertical gap with max using .vGapMax', () {
      final gap = 100.vGapMax(150);
      expect(gap.height, equals(150.0));
    });

    test('should create horizontal gap with max using .hGapMax', () {
      final gap = 100.hGapMax(150);
      expect(gap.width, equals(150.0));
    });
  });

  group('Edge Cases', () {
    test('should handle zero design dimensions gracefully', () {
      expect(
        () => AppSizesNotifier(designWidth: 0, designHeight: 812.0),
        returnsNormally,
      );
    });

    test('should handle very large screen sizes', () {
      final notifier = AppSizesNotifier(
        designWidth: 375.0,
        designHeight: 812.0,
      );
      notifier.update(const Size(3840.0, 2160.0), Orientation.landscape);

      expect(notifier.deviceType, equals(DeviceType.desktop));
      expect(notifier.scaleW, greaterThan(1.0));
    });

    test('should handle very small screen sizes', () {
      final notifier = AppSizesNotifier(
        designWidth: 375.0,
        designHeight: 812.0,
      );
      notifier.update(const Size(240.0, 320.0), Orientation.portrait);

      expect(notifier.deviceType, equals(DeviceType.mobile));
      expect(notifier.scaleW, lessThan(1.0));
    });

    test('should handle negative values in scaling methods', () {
      final notifier = AppSizesNotifier(
        designWidth: 375.0,
        designHeight: 812.0,
      );
      notifier.update(const Size(375.0, 812.0), Orientation.portrait);

      expect(notifier.w(-10.0), equals(-10.0));
      expect(notifier.h(-10.0), equals(-10.0));
      // Note: sp() uses clamp() which doesn't support negative bounds
      // so we don't test negative values for sp()
    });

    test('should handle decimal precision in scaling', () {
      final notifier = AppSizesNotifier(
        designWidth: 375.0,
        designHeight: 812.0,
      );
      notifier.update(const Size(375.0, 812.0), Orientation.portrait);

      expect(notifier.w(10.5), equals(10.5));
      expect(notifier.h(20.75), equals(20.75));
    });
  });
}
