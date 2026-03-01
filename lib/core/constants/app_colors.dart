import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand — finance teal
  static const Color primary     = Color(0xFF00897B); // Teal 600
  static const Color primaryDark = Color(0xFF00695C); // Teal 800
  static const Color secondary   = Color(0xFF4DB6AC); // Teal 300

  // Surfaces
  static const Color background      = Color(0xFFF4F7F6);
  static const Color surface         = Color(0xFFFFFFFF);
  static const Color surfaceVariant  = Color(0xFFEDF2F1);
  static const Color outlineVariant  = Color(0xFFDAE5E3);

  // Semantic
  static const Color error   = Color(0xFFBA1A1A);
  static const Color income  = Color(0xFF2E7D32); // Green 800
  static const Color expense = Color(0xFFD32F2F); // Red 700

  // Category palette
  static const List<Color> categoryColors = [
    Color(0xFF26A69A), // teal
    Color(0xFF42A5F5), // blue
    Color(0xFFEF5350), // red
    Color(0xFFFFCA28), // amber
    Color(0xFF66BB6A), // green
    Color(0xFFAB47BC), // purple
    Color(0xFFFF7043), // deep orange
  ];
}
