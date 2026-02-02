# 📱 AppSizer

<div align="center">

**A powerful, performance-optimized Flutter package for building responsive UIs that adapt seamlessly across all platforms.**

[![Flutter](https://img.shields.io/badge/Flutter-3.5.4+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5.4+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

[Features](#-features) • [Installation](#-installation) • [Quick Start](#-quick-start) • [Documentation](#-documentation) • [Examples](#-examples)

</div>

---

## ✨ Features

- 🎯 **Smart Scaling** - Automatic UI scaling based on design dimensions
- 📐 **Multiple Scale Types** - Width, height, radius, and text scaling
- 🖥️ **Device Detection** - Automatic mobile, tablet, and desktop detection
- ⚡ **Performance Optimized** - Built-in caching with `PreScaleManager`
- 🎨 **Adaptive Layouts** - Easy conditional rendering for different devices
- 🔧 **Developer Friendly** - Intuitive extensions and clean API
- 🚀 **Zero Dependencies** - Pure Flutter implementation
- 📱 **Orientation Support** - Seamless portrait/landscape handling

## 📦 Installation

Add `app_sizer` to your `pubspec.yaml`:

```yaml
dependencies:
  app_sizer:
    git:
      url: https://github.com/Moo-Meshrif/app_sizer
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
      designWidth: 375,  // Your design dimensions (e.g., iPhone 11)
      designHeight: 812, // Your design dimensions
      // Optional: Full Configuration
      minTextScale: 0.6,          // Minimum allowed text scale factor
      maxTextScale: 1.4,          // Maximum allowed text scale factor
      textScaleFactor: 1.0,       // Global multiplier for all .sp values
      useHeightForTextScale: false, // Use min(scaleW, scaleH) for text scaling
      baseExtraLargeTextSize: 26, // Base size for context.extraLarge (26.sp)
      baseLargeTextSize: 20,      // Base size for context.large (20.sp)
      baseMediumTextSize: 16,     // Base size for context.medium (16.sp)
      baseSmallTextSize: 12,      // Base size for context.small (12.sp)
      tabletBreakpoint: 600,      // Mobile < 600 <= Tablet
      tabletLargeBreakpoint: 900, // Tablet < 900 <= TabletLarge
      desktopBreakpoint: 1100,    // TabletLarge < 1100 <= Desktop
      // Optional: Pass pre-calculated values for zero-runtime-cost scaling
      // precalcFunction: useAppSizerPrecalc, 
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

## 📖 Documentation

### Scaling Extensions

AppSizer provides easy-to-use getter extensions for `num`:

| Extension | Description | Use Case |
|-----------|-------------|----------|
| `.w` | Width scaling | Horizontal dimensions, widths |
| `.h` | Height scaling | Vertical dimensions, heights |
| `.r` | Radius scaling | Border radius, circular elements |
| `.sp` | Text scaling | Font sizes, text dimensions |
| `.sh` | Screen Height % | `0.5.sh` is 50% of screen height |
| `.sw` | Screen Width % | `0.5.sw` is 50% of screen width |
| `.vGap` | Vertical Gap | Returns a `SizedBox` with scaled height |
| `.hGap` | Horizontal Gap| Returns a `SizedBox` with scaled width |

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

### Device Types

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

### Adaptive Layout

Build responsive UIs with ease:

```dart
AdaptiveLayout(
  mobileLayout: (context) => ListView(
    children: items.map((item) => ListTile(title: Text(item))).toList(),
  ),
  tabletLayout: (context) => GridView.count(
    crossAxisCount: 2,
    children: items.map((item) => Card(child: Text(item))).toList(),
  ),
  tabletLargeLayout: (context) => GridView.count(
    crossAxisCount: 3,
    children: items.map((item) => Card(child: Text(item))).toList(),
  ),
  desktopLayout: (context) => GridView.count(
    crossAxisCount: 4,
    children: items.map((item) => Card(child: Text(item))).toList(),
  ),
)
```

### Context Extensions

Quickly access typography and sizes through `context`:

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

### Adaptive Values

Use the `.value()` extension on numbers to provide different values per device type:

```dart
int columns = 2.value(
  context,
  tablet: 3,
  largeTablet: 4,
  desktop: 6,
);
```

### Performance Optimization

AppSizer uses `PreScaleManager` to cache scaled values for optimal performance:

```dart
// Values are automatically cached
final width = 100.w;  // Calculated once
final sameWidth = 100.w;  // Retrieved from cache ⚡

// Cache is automatically invalidated on screen size changes
```

### Accessing App Sizes

Get direct access to scaling factors:

```dart
final sizes = AppSizesProvider.of(context);

print('Scale Width: ${sizes.scaleW}');
print('Scale Height: ${sizes.scaleH}');
print('Scale Text: ${sizes.scaleText}');
print('Device Type: ${sizes.deviceType}');
```

## 💡 Examples

### Responsive Card

```dart
Card(
  margin: EdgeInsets.all(16.r),
  child: Padding(
    padding: EdgeInsets.all(20.r),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Title',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        12.vGap,
        Text(
          'Description text that scales beautifully across all devices.',
          style: TextStyle(fontSize: 14.sp),
        ),
      ],
    ),
  ),
)
```

### Responsive Grid

```dart
GridView.builder(
  padding: EdgeInsets.all(16.r),
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: context.deviceType == DeviceType.mobile ? 2 : 4,
    crossAxisSpacing: 16.r,
    mainAxisSpacing: 16.r,
  ),
  itemCount: items.length,
  itemBuilder: (context, index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Text(
          items[index],
          style: TextStyle(fontSize: 16.sp),
        ),
      ),
    );
  },
)
```

### Responsive AppBar

```dart
AppBar(
  toolbarHeight: 60.h,
  title: Text(
    'AppSizer',
    style: TextStyle(fontSize: 20.sp),
  ),
  actions: [
    IconButton(
      icon: Icon(Icons.search, size: 24.r),
      onPressed: () {},
    ),
    8.hGap,
  ],
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

```
┌─────────────────────────────────────────────────────┐
│                    AppSizer                         │
│  - Initializes with design size                     │
│  - Listens to screen size changes                   │
└─────────────────┬───────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────┐
│              AppSizesNotifier                       │
│  - Calculates scaling factors                       │
│  - Detects device type                              │
│  - Notifies listeners on changes                    │
└─────────────────┬───────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────┐
│              PreScaleManager                        │
│  - Caches scaled values                             │
│  - Invalidates cache on size changes                │
└─────────────────┬───────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────┐
│           Your Responsive UI                        │
│  - Uses .w, .h, .r, .sp                             │
│  - Adapts to all screen sizes                       │
└─────────────────────────────────────────────────────┘
```

## 🎯 Best Practices

### 1. Choose the Right Design Size

Use your design mockup dimensions (typically iPhone 11 or similar):

```dart
AppSizer(
  designWidth: 375,
  designHeight: 812,
  child: MyApp(),
)
```

### 2. Use Appropriate Scaling Methods

- **`.w`** for horizontal spacing, widths
- **`.h`** for vertical spacing, heights
- **`.r`** for border radius, icon sizes, padding
- **`.sp`** for font sizes

### 3. Combine with MediaQuery When Needed

```dart
final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

Container(
  width: isLandscape ? 400.w : 300.w,
  height: isLandscape ? 200.h : 300.h,
)
```

### 4. Test on Multiple Devices

Always test your responsive UI on:
- Small phones (< 375px width)
- Standard phones (375-414px width)
- Tablets (600-1024px width)
- Desktops (> 1200px width)

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

### Pre-generate Scaled Values

For even better performance, use the automated code generator:

```bash
dart run app_sizer:generate
```

This scans your project and generates pre-calculated values. 

#### Automated Setup
The generator targets your project's `lib/` directory by default and automatically injects the setup call into your `main.dart`!

Check out our [example/lib/main.dart](example/lib/main.dart) to see how it looks.

> **Note**: For a developer reference of the generated file, see [example/lib/app_sizer_precalc.g.dart](example/lib/app_sizer_precalc.g.dart) (or `lib/app_sizer_precalc.g.dart` in your project).

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

Built with ❤️ for the Flutter community.

---

<div align="center">

**[⬆ Back to Top](#-appsizer)**

Made with Flutter 💙

</div>
