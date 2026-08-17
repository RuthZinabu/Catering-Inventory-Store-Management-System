import 'package:flutter/material.dart';

/// Semantic colors shared by the entire application.
///
/// Keep feature-specific colors out of screens so palette changes remain a
/// single-file maintenance task.
abstract final class AppColors {
  static const primaryBlue = Color(0xFF6EC1E4);
  static const secondaryGray = Color(0xFF54595F);
  static const textGray = Color(0xFF7A7A7A);
  static const accentGreen = Color(0xFF61CE70);
  static const accentGold = Color(0xFFE8C45C);
  static const darkGreen = Color(0xFF283C2C);
  static const creamBackground = Color(0xFFFFFCEC);
  static const errorRed = Color(0xFFD1453B);

  static const cardSurface = Colors.white;
  static const softSurface = Color(0xFFFFFEF7);
  static const border = Color(0xFFE8E7DD);
  static const disabled = Color(0xFFB7B7B0);
}