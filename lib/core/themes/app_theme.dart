import 'package:flutter/material.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

/// App Theme Factory
/// Provides light and dark themes for the application
class AppTheme {
  
  // Private constructor to prevent instantiation
  AppTheme._();
  /// Get light theme
  static ThemeData get lightTheme => LightTheme.theme;
  
  /// Get dark theme
  static ThemeData get darkTheme => DarkTheme.theme;
  
  /// Get theme mode based on system settings
  static ThemeMode get systemThemeMode => ThemeMode.system;
  
  /// Check if theme is dark
  static bool isDarkMode(BuildContext context) => Theme.of(context).brightness == Brightness.dark;
  
  /// Get current theme mode
  static Brightness getBrightness(BuildContext context) => Theme.of(context).brightness;
  
  // Common theme properties that don't change between light/dark
  
  /// Border radius for cards and containers
  static const double cardBorderRadius = 12;
  
  /// Border radius for buttons
  static const double buttonBorderRadius = 8;
  
  /// Border radius for text fields
  static const double textFieldBorderRadius = 8;
  
  /// Elevation for cards
  static const double cardElevation = 2;
  
  /// Elevation for app bar
  static const double appBarElevation = 0;
  
  /// Elevation for bottom sheet
  static const double bottomSheetElevation = 8;
  
  /// Elevation for dialog
  static const double dialogElevation = 24;
  
  /// Icon sizes
  static const double iconSizeSmall = 16;
  static const double iconSizeMedium = 24;
  static const double iconSizeLarge = 32;
  static const double iconSizeXLarge = 48;
  
  /// Spacing
  static const double spacingXS = 4;
  static const double spacingS = 8;
  static const double spacingM = 16;
  static const double spacingL = 24;
  static const double spacingXL = 32;
  
  /// Animation durations
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationLong = Duration(milliseconds: 500);
}