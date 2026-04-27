# 📱 AppSizer

<div align="center">

**A powerful, performance-optimized Flutter package for building responsive UIs that adapt seamlessly across all platforms.**

</div>

## ✨ Features

- 🎯 **Smart Scaling** - Automatic UI scaling based on design dimensions
- 📐 **Multiple Scale Types** - Width, height, radius, and text scaling
- 🖥️ **Device Detection** - Automatic mobile, tablet, and desktop detection
- ⚡ **Performance Optimized** - Built-in caching with `PreScaleManager`
- 🎨 **Adaptive Layouts** - Easy conditional rendering for different devices
- 🔧 **Developer Friendly** - Intuitive extensions and clean API
- 📏 **Capped Scaling** - Prevent UI elements from growing too large on big screens
- 🚀 **Zero Dependencies** - Pure Flutter implementation
- 📱 **Orientation Support** - Seamless portrait/landscape handling

## 📦 Installation

Add AppSizer to your `pubspec.yaml`:

```yaml
dependencies:
  app_sizer: latest_version
```

Then run:

```bash
flutter pub get
```

## 🚀 Quick Start

### 1. Wrap Your App

Wrap your root widget with `AppSizer`:

```dart
import 'package:app_sizer/app_sizer.dart';

void main() {
  runApp(
    AppSizer(
      designWidth: 375,
      designHeight: 812,
      builder: (context) => const MyApp(),
    ),
  );
}
```

#### AppSizer Configuration

| Parameter | Default | Description |
|-----------|---------|-------------|
| `designWidth` | **Required** | The width of your design mockup (px) |
| `designHeight` | **Required** | The height of your design mockup (px) |
| `minTextScale` | `0.6` | Minimum allowed text scale factor |
| `maxTextScale` | `1.4` | Maximum allowed text scale factor |
| `textScaleFactor` | `1.0` | Global multiplier for all `.sp` values |
| `useHeightForTextScale` | `false` | If true, uses min(scaleW, scaleH) for mobile text scaling |
| `baseExtraLargeTextSize` | `26` | Base size for `context.extraLarge` |
| `baseLargeTextSize` | `20` | Base size for `context.large` |
| `baseMediumTextSize` | `16` | Base size for `context.medium` |
| `baseSmallTextSize` | `12` | Base size for `context.small` |
| `tabletBreakpoint` | `600` | Width threshold for Tablet device type |
| `tabletLargeBreakpoint` | `900` | Width threshold for TabletLarge device type |
| `desktopBreakpoint` | `1100` | Width threshold for Desktop device type |
| `isDebugLogs` | `false` | Enable/disable debug logs for dimension changes |

### 2. Use Responsive Extensions

Make your UI responsive with simple getter extensions:

```dart
import 'package:app_sizer/app_sizer.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.r), // Responsive padding
        child: Column(
          children: [
            // Responsive width & height
            Container(
              width: 200.w,
              height: 100.h,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            
            20.vGap, // Responsive vertical gap
            
            // Responsive text
            Text(
              'Hello AppSizer!',
              style: TextStyle(fontSize: 24.sp),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 3. Build Adaptive Layouts

Create different layouts for different devices:

```dart
AdaptiveLayout(
  mobileLayout: (context) => MobileLayout(),
  tabletLayout: (context) => TabletLayout(),
  tabletLargeLayout: (context) => TabletLargeLayout(),
  desktopLayout: (context) => DesktopLayout(),
)
```

## 💡 Pro Tip
Check out the [example directory](example/) for a complete, production-ready demonstration of `app_sizer` in action.

## 📖 Documentation

### 🔧 Extensions

AppSizer provides several extensions to make your UI responsive with minimal code.

#### 1. Scaling Extensions (num)

Use these on any `num` (int or double) to scale values based on screen dimensions:

| Extension | Description | Use Case |
|-----------|-------------|----------|
| `.w` | Width scaling | Horizontal dimensions, widths |
| `.h` | Height scaling | Vertical dimensions, heights |
| `.r` | Radius scaling | Border radius, circular elements |
| `.dg` | Diagonal scaling | Diagonal based on both width and height |
| `.dm` | Diameter scaling | Diameter based on larger screen dimension |
| `.sp` | Text scaling | Font sizes, text dimensions |
| `.sh` | Screen Height % | `0.5.sh` is 50% of screen height |
| `.sw` | Screen Width % | `0.5.sw` is 50% of screen width |
| `.vGap` | Vertical Gap | Returns a `SizedBox` with scaled height |
| `.hGap` | Horizontal Gap| Returns a `SizedBox` with scaled width |
| `.wMax(cap)`| Capped Width | Scales by width but never exceeds `cap` px |
| `.hMax(cap)`| Capped Height | Scales by height but never exceeds `cap` px |
| `.rMax(cap)`| Capped Radius | Scales by radius but never exceeds `cap` px |
| `.vGapMax(cap)`| Capped V-Gap | `SizedBox` with height scaled but capped |
| `.hGapMax(cap)`| Capped H-Gap | `SizedBox` with width scaled but capped |

**Example:**

```dart
Container(
  width: 300.w,        // Scales based on screen width
  height: 200.h,       // Scales based on screen height
  padding: EdgeInsets.all(16.r),  // Scales proportionally
  child: Text(
    'Responsive Text',
    style: context.large.copyWith(fontSize: 18.sp), // Use built-in styles
  ),
)
```

#### 2. Context Extensions (BuildContext)

Quickly access typography and breakpoints directly from `context`:

| Extension | Description |
|-----------|-------------|
| `context.extraLarge` | Bold text (26sp) |
| `context.large` | Bold text (20sp) |
| `context.medium` | Normal text (16sp) |
| `context.small` | Normal text (12sp) |
| `context.title` | Alias for `large` |
| `context.subtitle` | Alias for `medium` |
| `context.deviceType` | Direct access to current `DeviceType` |
| `context.tabletBreakpoint` | Access to configured tablet breakpoint |
| `context.tabletLargeBreakpoint` | Access to configured tabletLarge breakpoint |
| `context.desktopBreakpoint` | Access to configured desktop breakpoint |
| `context.safeWidth` | Screen width minus horizontal system padding |
| `context.safeHeight` | Screen height minus vertical padding & keyboard inset |
| `context.srw(fraction)` | Returns `fraction` * `safeWidth` (0.0 to 1.0) |
| `context.srh(fraction)` | Returns `fraction` * `safeHeight` (0.0 to 1.0) |
| `context.appSizes` | Access the full `AppSizesNotifier` |

#### 3. Constraints Extensions (BoxConstraints)

Use these inside a `LayoutBuilder` to size widgets relative to the space actually available to them:

| Extension | Description |
|-----------|-------------|
| `constraints.availableWidth` | Available width of this layout slot |
| `constraints.availableHeight`| Available height of this layout slot |
| `constraints.aw(fraction)` | Returns `fraction` * `availableWidth` (0.0 to 1.0) |
| `constraints.ah(fraction)` | Returns `fraction` * `availableHeight` (0.0 to 1.0) |

**Example:**

```dart
LayoutBuilder(
  builder: (context, constraints) {
    return Container(
      width: constraints.aw(0.5),   // 50% of available width
      height: constraints.ah(0.3),  // 30% of available height
      color: Colors.red,
    );
  },
)
```

#### 4. Adaptive Values (.value)

The `.value()` extension allows you to provide different values for different device types in a single line:

```dart
int columns = 2.value(
  context,
  tablet: 3,
  largeTablet: 4,
  desktop: 6,
);
```

#### 4. Capped Scaling

Sometimes you want an element to scale up on larger screens, but only to a certain point. `wMax`, `hMax`, and `rMax` allow you to set an upper limit in logical pixels.

```dart
Padding(
  // Scales from 16px (design) but never exceeds 24px
  padding: EdgeInsets.symmetric(horizontal: 16.wMax(24)), 
  child: Column(
    children: [
      Icon(Icons.star, size: 24.rMax(32)), // Caps at 32px
      20.vGapMax(30), // Gap scales but stops at 30px
      const Text('Beautifully Capped!'),
    ],
  ),
)
```

#### 5. Accessing App Sizes

Get direct access to all scaling factors and device metrics:

```dart
final sizes = context.appSizes;

print('Scale Width: ${sizes.scaleW}');
print('Scale Height: ${sizes.scaleH}');
print('Scale Text: ${sizes.scaleText}');
print('Device Type: ${sizes.deviceType}');
```

### 📱 Device & Layout

#### Device Types

AppSizer automatically detects the device type:

```dart
final deviceType = context.deviceType;

switch (deviceType) {
  case DeviceType.mobile:
    // Mobile-specific logic
    break;
  case DeviceType.tablet:
    // Tablet (portrait) logic
    break;
  case DeviceType.tabletLarge:
    // Large tablet / Small laptop logic
    break;
  case DeviceType.desktop:
    // Large screens
    break;
}
```

**Default Breakpoints:**

- **Mobile**: width < 600px
- **Tablet**: 600px ≤ width < 900px
- **TabletLarge**: 900px ≤ width < 1100px
- **Desktop**: width ≥ 1100px

#### Adaptive Layout

Build responsive UIs with ease:

```dart
AdaptiveLayout(
  mobileLayout: (context) => const Column(
    children: [
      MyHeader(),
      Expanded(child: MyContent()),
      MyBottomNav(),
    ],
  ),
  tabletLayout: (context) => Row(
    children: [
      MyNavigationRail(),
      const Expanded(child: MyContent()),
    ],
  ),
  desktopLayout: (context) => Row(
    children: [
      MySidebar(),
      const Expanded(
        child: Column(
          children: [
            MyHeader(),
            Expanded(child: MyContent()),
          ],
        ),
      ),
    ],
  ),
)
```

## 🏗️ Architecture

### Core Components

1. **AppSizer** - Root widget that initializes the responsive system
2. **AppSizesNotifier** - Manages scaling factors and device detection
3. **PreScaleManager** - Caches scaled values for performance
4. **Extensions** - Convenient `.w`, `.h`, `.r`, `.sp` getter extensions
5. **AdaptiveLayout** - Conditional rendering based on device type

### How It Works

#### 🏗️ Architecture Visualization

```text
                          💠 AppSizer Core
                         ══════════════════
               ┌──────────────────┴──────────────────┐
               │                                     │
        🏁 Initialization                     🚀 Performance
        ─────────────────                     ───────────────
        • Design Specs                        • Pre-Scale Cache
        • Screen Metrics                      • Zero-Lag Sync
        • Breakpoints                         • Memory-Safe
               │                                     │
               └──────────────────┬──────────────────┘
                                  ▼
                         ⚙️ AppSizesNotifier
                        ────────────────────
                        • Scaling Calculus
                        • Device Detection
                                  │
                                  ▼
                         🔗 AppSizesProvider
                        ────────────────────
           📱 Mobile          📟 Tablet          💻 Desktop
               └──────────────────┬──────────────────┘
                                  ▼
                        ✨ Universal Extensions
                        (.w, .h, .sp, .r, etc.)
```

---

### 🚀 How Pre-Scaling Works

`app_sizer` uses a high-performance caching layer called **PreScaleManager** to ensure your app stays fast even with complex layouts.

#### 1. Smart Caching
When you use an extension like `100.w`, the calculation isn't just `100 * scaleFactor`. The result is cached in a specialized `Map`. The next time that same widget (or any other widget) asks for `100.w`, the value is returned instantly from memory.

#### 2. Performance First
By avoiding repetitive floating-point math during every frame of an animation or scroll, `app_sizer` maintains a rock-solid 60/120 FPS. This is especially important on lower-end devices.

#### 3. Automatic Invalidation
You don't need to worry about stale data. Whenever the device orientation changes or the window is resized, `PreScaleManager` automatically:
*   Clears the entire cache.
*   Triggers a re-calculation of current values.
*   Notifies the UI to rebuild with new, accurate scales.

#### 4. Performance Optimization (CLI)
To ensure your app stays ultra-smooth even on lower-end devices, `app_sizer` includes a built-in generator that "warms up" the cache by pre-calculating all your responsive values.

Run this command in your terminal:
```bash
dart run app_sizer:generate_prescale
```

This command will:
1.  **Scan** your project for all `.w`, `.h`, `.sp`, `.r`, `.dg`, and `.dm` extensions.
2.  **Generate** the `lib/app_sizer_precalc.g.dart` file containing all your used values.
3.  **Inject** the necessary setup into your `AppSizer` widget in `main.dart`.

By using the generator, you ensure that every responsive value is cached and ready before the first frame is even drawn.

---

### 🎨 Using with Themes (Important Hint)

If you want to use responsive values (like `.sp`, `.r`, `.w`, `.h`) inside your `ThemeData`, it is highly recommended to wrap your theme inside the `builder` of `MaterialApp`. This ensures that the responsive values are calculated correctly whenever the screen size or orientation changes.

> **💡 Note**: Using responsive extensions in a global static `ThemeData` variable will NOT work because those values are only calculated once at startup.

```dart
AppSizer(
  designWidth: 375,
  designHeight: 812,
  builder: (context) => MaterialApp(
    // Use the builder to ensure theme stays responsive
    builder: (context, child) {
      return Theme(
        data: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: TextTheme(
            // Use .sp for responsive font sizes
            bodyMedium: TextStyle(fontSize: 16.sp),
            titleLarge: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
          ),
          cardTheme: CardTheme(
            // Use .r for responsive radius
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
        child: child!,
      );
    },
    home: const HomePage(),
  ),
);
```

## 🔧 Advanced Usage

### Custom Breakpoints

You can easily customize breakpoints through the `AppSizer` constructor:

```dart
AppSizer(
  designWidth: 375,
  designHeight: 812,
  tabletBreakpoint: 700,
  tabletLargeBreakpoint: 1000,
  desktopBreakpoint: 1400,
  builder: (context) => MyApp(),
)
```

### Debug Logging

Enable `isDebugLogs: true` to see helpful information in your console whenever the screen dimensions change:

- 📱 Current orientation (Landscape/Portrait)
- 📏 Screen dimensions in logical pixels
- 🎯 Detected device type (Mobile, Tablet, etc.)
- 📝 Exact scale factors being applied (ScaleW, ScaleH, TextScale)

```dart
AppSizer(
  isDebugLogs: true, // Perfect for debugging responsive layouts
  designWidth: 375,
  designHeight: 812,
  builder: (context) => MyApp(),
)
```

## 🔄 Migration from flutter_screenutil

Migrating from `flutter_screenutil` is straightforward as most extensions use the same naming convention.

### 1. Initialization

Replace `ScreenUtilInit` with `AppSizer`.

**Old (flutter_screenutil):**
```dart
ScreenUtilInit(
  designSize: const Size(360, 690),
  builder: (context, child) => MaterialApp(...),
)
```

**New (app_sizer):**
```dart
AppSizer(
  designWidth: 360,
  designHeight: 690,
  builder: (context) => MaterialApp(...),
)
```

### 2. Extensions

Most extensions are identical and require no changes:

| flutter_screenutil | **app_sizer** |
| :--- | :--- |
| `10.w` | `10.w` |
| `10.h` | `10.h` |
| `10.r` | `10.r` |
| `10.sp` | `10.sp` |

### 3. Screen Metrics

**Old (flutter_screenutil):**
```dart
ScreenUtil().screenWidth
ScreenUtil().screenHeight
```

**New (app_sizer):**
```dart
context.appSizes.screenWidth
context.appSizes.screenHeight
```

### 4. Key Benefits of AppSizer

- **🚀 Performance-First Architecture**: Built from the ground up with `PreScaleManager` caching. While other packages struggle with UI thread lag during heavy animations, `AppSizer` serves values from a zero-latency memory cache.
- **🤖 Automated CLI**: No more manual maintenance. The `dart run app_sizer:generate` tool is a unique feature that automates your scaling setup, a capability not found in legacy responsive packages.
- **📱 True All-in-One**: Combines scaling, device detection (`mobile`, `tablet`, `desktop`), and adaptive layouts into a single, cohesive API.
- **📏 Built-in Caps**: Native support for `.wMax()`, `.hMax()`, and `.rMax()` prevents "UI explosion" on large desktop monitors or tablets.

---

## 🤝 Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.