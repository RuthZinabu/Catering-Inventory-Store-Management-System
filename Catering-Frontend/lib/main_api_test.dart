import 'package:flutter/material.dart';
import 'app_wrapper.dart';

/// Test entry point for API integration testing
/// 
/// This is a separate main file for testing the API integration
/// without affecting the existing main.dart file.
/// 
/// To test with this entry point:
/// 1. Run: flutter run -t lib/main_api_test.dart
/// 2. Or create a new run configuration in your IDE pointing to this file
void main() {
  runApp(const CateringInventoryApp());
}

class CateringInventoryApp extends StatelessWidget {
  const CateringInventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppWrapper();
  }
}