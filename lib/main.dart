import 'package:flutter/material.dart';
import 'app.dart';

void main() {
  MaterialApp(
theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
      
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: Colors.black),
        bodyMedium: TextStyle(color: Colors.black),
      ),
),
  );
  runApp(const CateringInventoryApp());
}
