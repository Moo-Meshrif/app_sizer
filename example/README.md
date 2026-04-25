# 📱 AppSizer Example

This is a demonstration app for the **AppSizer** package, showcasing how to build a fully responsive UI that adapts to mobile, tablet, and desktop screens with zero-lag performance.

## 🚀 How to Run

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/Moo-Meshrif/app_sizer.git
    cd app_sizer/example
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Run the app**:
    ```bash
    flutter run
    ```

## 🤖 Generator Demo

This example uses the automated pre-scaling tool. If you modify the UI and add more responsive values, you can re-generate the cache function by running:

```bash
dart run app_sizer:generate
```

Check [lib/main.dart](lib/main.dart) to see how the generated function is passed to the `AppSizer` widget.
