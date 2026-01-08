import 'package:flutter/material.dart';
import 'package:app_sizer/app_sizer.dart';
import 'responsive_page.dart';
import 'app_sizer_precalc.g.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => AppSizer(
        precalcFunction: useAppSizerPrecalc,
        designWidth: 375,
        designHeight: 812,
        builder: (context) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Responsive Test',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
          home: const ResponsivePage(),
        ),
      );
}
