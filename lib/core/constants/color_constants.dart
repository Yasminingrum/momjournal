// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';

/// Color constants for the app theme
class ColorConstants {
  ColorConstants._();
  
  // Primary Colors
  static const Color primaryColor = Color(0xFF6750A4);
  static const Color primaryLight = Color(0xFFEADDFF);
  static const Color primaryDark = Color(0xFF4F378B);
  
  // Secondary Colors
  static const Color secondaryColor = Color(0xFF625B71);
  static const Color secondaryLight = Color(0xFFE8DEF8);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFFFFBFE);
  static const Color backgroundDark = Color(0xFF1C1B1F);
  static const Color surfaceLight = Color(0xFFFEF7FF);
  static const Color surfaceDark = Color(0xFF2B2930);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1C1B1F);
  static const Color textSecondary = Color(0xFF49454F);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color white = Color(0xFFFFFFFF);
  
  // Category Colors
  static const Color categoryFeeding = Color(0xFF2196F3);      // Blue
  static const Color categorySleep = Color(0xFF9C27B0);        // Purple
  static const Color categoryHealth = Color(0xFFF44336);       // Red
  static const Color categoryMilestone = Color(0xFF4CAF50);    // Green
  static const Color categoryOther = Color(0xFF9E9E9E);        // Grey
  
  // Mood Colors
  static const Color moodVeryHappy = Color(0xFF4CAF50);   // Green
  static const Color moodHappy = Color(0xFF8BC34A);       // Light Green
  static const Color moodNeutral = Color(0xFFFFEB3B);     // Yellow
  static const Color moodSad = Color(0xFFFF9800);         // Orange
  static const Color moodVerySad = Color(0xFFF44336);     // Red
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Status Light Colors (for backgrounds)
  static const Color successLight = Color(0xFFE8F5E9);   // Light green background
  static const Color warningLight = Color(0xFFFFF3E0);   // Light orange background
  static const Color errorLight = Color(0xFFFFEBEE);     // Light red background
  static const Color infoLight = Color(0xFFE3F2FD);      // Light blue background
  
  // UI Elements
  static const Color divider = Color(0xFFE0E0E0);
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color shadow = Color(0x1F000000);
  
  // Grey Shades
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  
  // Shimmer Colors
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
}