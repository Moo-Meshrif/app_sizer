// ignore_for_file: avoid_print

import '../tool/generate_prescale.dart';

/// CLI entrypoint for the app_sizer PreScale Generator.
///
/// Usage:
///   dart run app_sizer:generate_prescale
///   dart run app_sizer:generate_prescale lib --output lib/app_sizer_precalc.g.dart
///   dart run app_sizer:generate_prescale lib --name myPrecalcFn --output lib/precalc.g.dart
///
/// This file intentionally contains no logic — it is a thin shell that
/// delegates entirely to [runGenerator] in `tool/generate_prescale.dart`.
///
/// Architecture rationale:
///   bin/  → pub.dev allows dart:io here; this is the user-facing CLI entry.
///   tool/ → dart:io allowed; holds the actual generator implementation.
///   lib/  → must remain Web-safe; zero dart:io allowed.
void main(List<String> args) => runGenerator(args);
