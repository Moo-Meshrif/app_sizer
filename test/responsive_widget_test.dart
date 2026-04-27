import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_sizer/app_sizer.dart';
import 'test_app_sizer_precalc.g.dart';

void main() {
  group('AppSizer Widget Tests', () {
    testWidgets('AppSizer initializes and provides notifier to descendants',
        (tester) async {
      late AppSizesNotifier captured;

      await tester.pumpWidget(
        AppSizer(
          precalcFunction: useTestAppSizerPrecalc,
          designWidth: 375,
          designHeight: 812,
          builder: (context) {
            captured = context.appSizes;
            return const MaterialApp(home: SizedBox.shrink());
          },
        ),
      );

      await tester.pumpAndSettle();
      expect(captured.designWidth, equals(375));
      expect(captured.designHeight, equals(812));
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('AdaptiveLayout Tests', () {
    Widget buildTestWidget({
      required DeviceType deviceType,
      required Widget child,
    }) {
      final notifier = AppSizesNotifier(
        designWidth: 375.0,
        designHeight: 812.0,
      );

      // Set appropriate size for device type
      final size = switch (deviceType) {
        DeviceType.mobile => const Size(375.0, 812.0),
        DeviceType.tablet => const Size(768.0, 1024.0),
        DeviceType.tabletLarge => const Size(1000.0, 1400.0),
        DeviceType.desktop => const Size(1920.0, 1080.0),
      };

      notifier.update(size, Orientation.portrait);

      return MaterialApp(
        home: AppSizesProvider(
          notifier: notifier,
          child: child,
        ),
      );
    }

    testWidgets('should render mobile layout for mobile device',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          deviceType: DeviceType.mobile,
          child: AdaptiveLayout(
            mobileLayout: (context) => const Text('Mobile'),
            tabletLayout: (context) => const Text('Tablet'),
            desktopLayout: (context) => const Text('Desktop'),
          ),
        ),
      );

      expect(find.text('Mobile'), findsOneWidget);
      expect(find.text('Tablet'), findsNothing);
      expect(find.text('Desktop'), findsNothing);
    });

    testWidgets('should render tablet layout for tablet device',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          deviceType: DeviceType.tablet,
          child: AdaptiveLayout(
            mobileLayout: (context) => const Text('Mobile'),
            tabletLayout: (context) => const Text('Tablet'),
            desktopLayout: (context) => const Text('Desktop'),
          ),
        ),
      );

      expect(find.text('Mobile'), findsNothing);
      expect(find.text('Tablet'), findsOneWidget);
      expect(find.text('Desktop'), findsNothing);
    });

    testWidgets('should render tablet layout for large tablet device',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          deviceType: DeviceType.tabletLarge,
          child: AdaptiveLayout(
            mobileLayout: (context) => const Text('Mobile'),
            tabletLayout: (context) => const Text('Tablet'),
            desktopLayout: (context) => const Text('Desktop'),
          ),
        ),
      );

      expect(find.text('Mobile'), findsNothing);
      expect(find.text('Tablet'), findsOneWidget);
      expect(find.text('Desktop'), findsNothing);
    });

    testWidgets('should render desktop layout for desktop device',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          deviceType: DeviceType.desktop,
          child: AdaptiveLayout(
            mobileLayout: (context) => const Text('Mobile'),
            tabletLayout: (context) => const Text('Tablet'),
            desktopLayout: (context) => const Text('Desktop'),
          ),
        ),
      );

      expect(find.text('Mobile'), findsNothing);
      expect(find.text('Tablet'), findsNothing);
      expect(find.text('Desktop'), findsOneWidget);
    });

    testWidgets('should fallback to mobile when tablet layout not provided',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          deviceType: DeviceType.tablet,
          child: AdaptiveLayout(
            mobileLayout: (context) => const Text('Mobile'),
            desktopLayout: (context) => const Text('Desktop'),
          ),
        ),
      );

      expect(find.text('Mobile'), findsOneWidget);
      expect(find.text('Desktop'), findsNothing);
    });

    testWidgets(
        'should fallback to tablet then mobile when desktop layout not provided',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          deviceType: DeviceType.desktop,
          child: AdaptiveLayout(
            mobileLayout: (context) => const Text('Mobile'),
            tabletLayout: (context) => const Text('Tablet'),
          ),
        ),
      );

      expect(find.text('Mobile'), findsNothing);
      expect(find.text('Tablet'), findsOneWidget);
    });

    testWidgets('should fallback to mobile when no other layouts provided',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          deviceType: DeviceType.desktop,
          child: AdaptiveLayout(
            mobileLayout: (context) => const Text('Mobile'),
          ),
        ),
      );

      expect(find.text('Mobile'), findsOneWidget);
    });
  });

  group('AppSizesX Extension Tests', () {
    testWidgets('should provide access to appSizes through context',
        (tester) async {
      final notifier = AppSizesNotifier(
        designWidth: 375.0,
        designHeight: 812.0,
      );
      notifier.update(const Size(375.0, 812.0), Orientation.portrait);

      late AppSizesNotifier capturedNotifier;

      await tester.pumpWidget(
        MaterialApp(
          home: AppSizesProvider(
            notifier: notifier,
            child: Builder(
              builder: (context) {
                capturedNotifier = context.appSizes;
                return Container();
              },
            ),
          ),
        ),
      );

      expect(capturedNotifier, equals(notifier));
    });

    testWidgets('should provide access to deviceType through context',
        (tester) async {
      final notifier = AppSizesNotifier(
        designWidth: 375.0,
        designHeight: 812.0,
      );
      notifier.update(const Size(768.0, 1024.0), Orientation.portrait);

      late DeviceType capturedDeviceType;

      await tester.pumpWidget(
        MaterialApp(
          home: AppSizesProvider(
            notifier: notifier,
            child: Builder(
              builder: (context) {
                capturedDeviceType = context.deviceType;
                return Container();
              },
            ),
          ),
        ),
      );

      expect(capturedDeviceType, equals(DeviceType.tablet));
    });

    testWidgets('should provide sh() method through context', (tester) async {
      final notifier = AppSizesNotifier(
        designWidth: 375.0,
        designHeight: 812.0,
      );
      notifier.update(const Size(375.0, 812.0), Orientation.portrait);

      late double result;

      await tester.pumpWidget(
        MaterialApp(
          home: AppSizesProvider(
            notifier: notifier,
            child: Builder(
              builder: (context) {
                result = context.sh(0.5);
                return Container();
              },
            ),
          ),
        ),
      );

      expect(result, equals(406.0)); // 812 * 0.5
    });

    testWidgets('should provide sw() method through context', (tester) async {
      final notifier = AppSizesNotifier(
        designWidth: 375.0,
        designHeight: 812.0,
      );
      notifier.update(const Size(375.0, 812.0), Orientation.portrait);

      late double result;

      await tester.pumpWidget(
        MaterialApp(
          home: AppSizesProvider(
            notifier: notifier,
            child: Builder(
              builder: (context) {
                result = context.sw(0.5);
                return Container();
              },
            ),
          ),
        ),
      );

      expect(result, equals(187.5)); // 375 * 0.5
    });

    testWidgets('should provide text style getters through context',
        (tester) async {
      final notifier = AppSizesNotifier(
        designWidth: 375.0,
        designHeight: 812.0,
      );
      notifier.update(const Size(375.0, 812.0), Orientation.portrait);

      late TextStyle extraLarge;
      late TextStyle large;
      late TextStyle medium;
      late TextStyle small;

      await tester.pumpWidget(
        MaterialApp(
          home: AppSizesProvider(
            notifier: notifier,
            child: Builder(
              builder: (context) {
                extraLarge = context.extraLarge;
                large = context.large;
                medium = context.medium;
                small = context.small;
                return Container();
              },
            ),
          ),
        ),
      );

      expect(extraLarge.fontSize, equals(26.0));
      expect(extraLarge.fontWeight, equals(FontWeight.bold));
      expect(large.fontSize, equals(20.0));
      expect(large.fontWeight, equals(FontWeight.bold));
      expect(medium.fontSize, equals(16.0));
      expect(small.fontSize, equals(12.0));
    });

    testWidgets('should expose isLandscape through context', (tester) async {
      final notifier = AppSizesNotifier(designWidth: 375, designHeight: 812);
      notifier.update(const Size(812, 375), Orientation.landscape);

      late bool result;
      await tester.pumpWidget(MaterialApp(
        home: AppSizesProvider(
          notifier: notifier,
          child: Builder(builder: (context) {
            result = context.appSizes.isLandscape;
            return Container();
          }),
        ),
      ));
      expect(result, isTrue);
    });

    testWidgets('should provide safe area metrics through context',
        (tester) async {
      // Mock MediaQuery with safe area insets
      final notifier = AppSizesNotifier(designWidth: 375, designHeight: 812);
      notifier.update(const Size(375, 812), Orientation.portrait);

      late double safeW;
      late double safeH;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(375, 812),
              padding: EdgeInsets.fromLTRB(10, 20, 10, 30),
              viewInsets: EdgeInsets.only(bottom: 50), // keyboard
            ),
            child: AppSizesProvider(
              notifier: notifier,
              child: Builder(builder: (context) {
                safeW = context.safeWidth;
                safeH = context.safeHeight;
                return Container();
              }),
            ),
          ),
        ),
      );

      // safeWidth = 375 - 10 - 10 = 355
      expect(safeW, equals(355.0));
      // safeHeight = 812 - 20 - 30 - 50 = 712
      expect(safeH, equals(712.0));
    });

    testWidgets('should provide srw() and srh() methods through context',
        (tester) async {
      final notifier = AppSizesNotifier(designWidth: 375, designHeight: 812);
      notifier.update(const Size(375, 812), Orientation.portrait);

      late double srw;
      late double srh;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(400, 800),
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 100),
            ),
            child: AppSizesProvider(
              notifier: notifier,
              child: Builder(builder: (context) {
                srw = context.srw(0.5); // 0.5 * (400 - 100) = 150
                srh = context.srh(0.1); // 0.1 * (800 - 200) = 60
                return Container();
              }),
            ),
          ),
        ),
      );

      expect(srw, equals(150.0));
      expect(srh, equals(60.0));
    });
  });

  group('ConstraintsX Extension Tests', () {
    test('should provide availableWidth and availableHeight', () {
      const constraints = BoxConstraints(maxWidth: 500, maxHeight: 1000);
      expect(constraints.availableWidth, equals(500.0));
      expect(constraints.availableHeight, equals(1000.0));
    });

    test('should provide aw() and ah() methods', () {
      const constraints = BoxConstraints(maxWidth: 500, maxHeight: 1000);
      expect(constraints.aw(0.5), equals(250.0));
      expect(constraints.ah(0.1), equals(100.0));
    });
  });

  group('AppSizerScope Tests', () {
    testWidgets('Scoped notifier uses overridden designWidth/designHeight',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppSizer(
            designWidth: 375,
            designHeight: 812,
            builder: (context) {
              return AppSizerScope(
                designWidth: 500,
                designHeight: 1000,
                child: Builder(builder: (context) {
                  final sizes = context.appSizes;
                  return Text('W:${sizes.designWidth} H:${sizes.designHeight}');
                }),
              );
            },
          ),
        ),
      );

      expect(find.text('W:500.0 H:1000.0'), findsOneWidget);
    });

    testWidgets('Non-overridden fields inherit from parent', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppSizer(
            designWidth: 375,
            designHeight: 812,
            tabletBreakpoint: 700,
            builder: (context) {
              return AppSizerScope(
                designWidth: 500,
                child: Builder(builder: (context) {
                  final sizes = context.appSizes;
                  return Text('B:${sizes.tabletBreakpoint}');
                }),
              );
            },
          ),
        ),
      );

      expect(find.text('B:700.0'), findsOneWidget);
    });

    testWidgets('Nested widgets use scoped values not parent values',
        (tester) async {
      // Force portrait to avoid landscape swapping logic in tests
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      late double parentScale;
      late double childScale;

      await tester.pumpWidget(
        MaterialApp(
          home: AppSizer(
            designWidth: 400,
            designHeight: 800,
            builder: (context) {
              parentScale = context.appSizes.scaleW;
              return AppSizerScope(
                designWidth: 800, // Double the width
                child: Builder(builder: (context) {
                  childScale = context.appSizes.scaleW;
                  return Container();
                }),
              );
            },
          ),
        ),
      );

      // Screen width is 400.
      // Parent: 400 / 400 = 1.0
      // Child: 400 / 800 = 0.5
      expect(parentScale, equals(1.0));
      expect(childScale, equals(0.5));
      expect(childScale, isNot(equals(parentScale)));
    });
  });

  group('AppSizerDebugOverlay Tests', () {
    testWidgets('should render debug hud when isDebugLogs is true',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppSizer(
            designWidth: 375,
            designHeight: 812,
            isDebugLogs: true,
            builder: (context) {
              return const AppSizerDebugOverlay(
                child: Scaffold(body: Text('Content')),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should find some texts from the HUD
      expect(find.textContaining('device :'), findsOneWidget);
      expect(find.textContaining('scaleW :'), findsOneWidget);
    });

    testWidgets('should NOT render debug hud when isDebugLogs is false',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AppSizer(
            designWidth: 375,
            designHeight: 812,
            isDebugLogs: false,
            builder: (context) {
              return const AppSizerDebugOverlay(
                child: Scaffold(body: Text('Content')),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('device :'), findsNothing);
    });
  });

  group('Rebuild Optimization', () {
    testWidgets('does not double-rebuild when MediaQuery is available',
        (tester) async {
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: AppSizer(
            designWidth: 375,
            designHeight: 812,
            builder: (context) {
              buildCount++;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final countAfterInit = buildCount;

      // Simulate a metric change
      tester.view.physicalSize = const Size(414, 896);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      addTearDown(() => tester.view.resetDevicePixelRatio());

      await tester.pump();

      // Should rebuild exactly once, not twice
      expect(buildCount, equals(countAfterInit + 1));

      // Reset
      await tester.binding.setSurfaceSize(null);
    });
  });

  group('Integration Tests', () {
    testWidgets('should integrate AppSizer with PreScaleManager',
        (tester) async {
      PreScaleManager().clear();

      await tester.pumpWidget(
        MaterialApp(
          home: AppSizer(
            precalcFunction: useTestAppSizerPrecalc,
            designWidth: 375.0,
            designHeight: 812.0,
            builder: (context) {
              // Access values through context to trigger caching
              final w = 100.w;
              final h = 50.h;
              final sp = 16.sp;
              return Column(
                children: [
                  SizedBox(width: w, height: h),
                  Text('Test', style: TextStyle(fontSize: sp)),
                ],
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify PreScaleManager has cached values
      // Note: The cache is populated during the update() call in AppSizer
      // via precalcAllScaledValues()
      expect(PreScaleManager().cacheSize, greaterThan(0));
    });

    testWidgets('should handle responsive value selection in context',
        (tester) async {
      final notifier = AppSizesNotifier(
        designWidth: 375.0,
        designHeight: 812.0,
      );
      notifier.update(const Size(768.0, 1024.0), Orientation.portrait);

      late int result;

      await tester.pumpWidget(
        MaterialApp(
          home: AppSizesProvider(
            notifier: notifier,
            child: Builder(
              builder: (context) {
                result = 2.value(context, tablet: 3, desktop: 4);
                return Container();
              },
            ),
          ),
        ),
      );

      expect(result, equals(3)); // Tablet value
    });
  });
}
