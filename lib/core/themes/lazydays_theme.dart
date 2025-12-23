import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ColorConstants {
  // Pastel palette from the image
  static const Color primaryLight = Color(0xFF97B3AE); // Sage green-blue
  static const Color primaryDark = Color(0xFF7A9A94); // Darker variant
  static const Color secondaryColor = Color(0xFFF2C3B9); // Pastel pink
  static const Color secondaryLight = Color(0xFFF0DDD6); // Light beige-pink
  static const Color accentColor = Color(0xFFD2E0D3); // Mint green
  static const Color neutralColor = Color(0xFFD6CBBF); // Warm beige
  static const Color backgroundLight = Color(0xFFF0EEEA); // Off-white background

  // Text colors
  static const Color textPrimary = Color(0xFF333333); // Dark gray
  static const Color textSecondary = Color(0xFF666666); // Medium gray
  static const Color textHint = Color(0xFF999999); // Light gray
  
  // Surface colors
  static const Color surfaceLight = Color(0xFFFFFFFF); // White
  static const Color surfaceVariant = Color(0xFFF7F7F7); // Very light gray

  // Error colors
  static const Color errorColor = Color(0xFFD32F2F); // Material Design red
  static const Color errorLight = Color(0xFFFFCDD2); // Light red
}

class LazydaysTheme {
  const LazydaysTheme._();

  static final ThemeData theme = ThemeData(
        // Use Material 3
        useMaterial3: true,

        // Brightness
        brightness: Brightness.light,

        // Color Scheme
        colorScheme: const ColorScheme.light(
          primary: ColorConstants.primaryLight,
          primaryContainer: ColorConstants.primaryDark,
          secondary: ColorConstants.secondaryColor,
          secondaryContainer: ColorConstants.secondaryLight,
          tertiary: ColorConstants.accentColor,
          surface: ColorConstants.surfaceLight,
          surfaceContainerHighest: ColorConstants.surfaceVariant,
          error: ColorConstants.errorColor,
          onPrimary: Color(0xFFFFFFFF), // White text on primary
          onSecondary: ColorConstants.textPrimary,
          onSurface: ColorConstants.textPrimary,
          onError: Color(0xFFFFFFFF), // White text on error
        ),

        // Scaffold Background
        scaffoldBackgroundColor: ColorConstants.backgroundLight,

        // App Bar Theme
        appBarTheme: const AppBarTheme(
          elevation: 1,
          centerTitle: false,
          backgroundColor: ColorConstants.surfaceLight,
          foregroundColor: ColorConstants.textPrimary,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          titleTextStyle: TextStyle(
            color: ColorConstants.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            
          ),
          iconTheme: IconThemeData(
            color: ColorConstants.primaryLight,
            size: 24,
          ),
        ),

        // Card Theme
        cardTheme: CardThemeData(
          color: ColorConstants.surfaceLight,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: ColorConstants.neutralColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),

        // Elevated Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorConstants.primaryLight,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              
            ),
          ),
        ),

        // Text Button Theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: ColorConstants.primaryLight,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              
            ),
          ),
        ),

        // Outlined Button Theme
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: ColorConstants.primaryLight,
            side: const BorderSide(
              color: ColorConstants.primaryLight,
              width: 1.5,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              
            ),
          ),
        ),

        // Floating Action Button Theme
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: ColorConstants.primaryLight,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: CircleBorder(),
        ),

        // Input Decoration Theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: ColorConstants.surfaceLight,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: ColorConstants.neutralColor.withValues(alpha: 0.5),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: ColorConstants.neutralColor.withValues(alpha: 0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: ColorConstants.primaryLight,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: ColorConstants.errorColor,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: ColorConstants.errorColor,
              width: 2,
            ),
          ),
          labelStyle: const TextStyle(
            color: ColorConstants.textSecondary,
            fontSize: 14,
            
          ),
          hintStyle: const TextStyle(
            color: ColorConstants.textHint,
            fontSize: 14,
            
          ),
          errorStyle: const TextStyle(
            color: ColorConstants.errorColor,
            fontSize: 12,
            
          ),
        ),

        // Checkbox Theme
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return ColorConstants.primaryLight;
            }
            return ColorConstants.neutralColor.withValues(alpha: 0.5);
          }),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        // Radio Theme
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return ColorConstants.primaryLight;
            }
            return ColorConstants.neutralColor.withValues(alpha: 0.5);
          }),
        ),

        // Switch Theme
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return ColorConstants.primaryLight;
            }
            return ColorConstants.neutralColor;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return ColorConstants.primaryLight.withValues(alpha: 0.5);
            }
            return ColorConstants.neutralColor.withValues(alpha: 0.3);
          }),
        ),

        // Chip Theme
        chipTheme: ChipThemeData(
          backgroundColor: ColorConstants.surfaceVariant,
          selectedColor: ColorConstants.accentColor,
          disabledColor: ColorConstants.neutralColor.withValues(alpha:0.2),
          labelStyle: const TextStyle(
            color: ColorConstants.textPrimary,
            fontSize: 14,
            
          ),
          secondaryLabelStyle: const TextStyle(
            color: ColorConstants.textSecondary,
            fontSize: 14,
            
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        // Dialog Theme
        dialogTheme: DialogThemeData(
          backgroundColor: ColorConstants.surfaceLight,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titleTextStyle: const TextStyle(
            color: ColorConstants.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            
          ),
          contentTextStyle: const TextStyle(
            color: ColorConstants.textSecondary,
            fontSize: 14,
            
          ),
        ),

        // Bottom Sheet Theme
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: ColorConstants.surfaceLight,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
        ),

        // Snack Bar Theme
        snackBarTheme: SnackBarThemeData(
          backgroundColor: ColorConstants.surfaceLight,
          contentTextStyle: const TextStyle(
            color: ColorConstants.textPrimary,
            fontSize: 14,
            
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: ColorConstants.primaryLight.withValues(alpha: 0.2),
            ),
          ),
        ),

        // Bottom Navigation Bar Theme
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: ColorConstants.surfaceLight,
          selectedItemColor: ColorConstants.primaryLight,
          unselectedItemColor: ColorConstants.textSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 4,
          selectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            
          ),
        ),

        // Divider Theme
        dividerTheme: DividerThemeData(
          color: ColorConstants.neutralColor.withValues(alpha: 0.3),
          thickness: 1,
          space: 1,
        ),

        // Icon Theme
        iconTheme: const IconThemeData(
          color: ColorConstants.textSecondary,
          size: 24,
        ),

        // List Tile Theme
        listTileTheme: const ListTileThemeData(
          tileColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          titleTextStyle: TextStyle(
            color: ColorConstants.textPrimary,
            fontSize: 16,
            
          ),
          subtitleTextStyle: TextStyle(
            color: ColorConstants.textSecondary,
            fontSize: 14,
            
          ),
          leadingAndTrailingTextStyle: TextStyle(
            color: ColorConstants.textSecondary,
            fontSize: 14,
            
          ),
        ),

        // Progress Indicator Theme
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          linearTrackColor: ColorConstants.neutralColor,
          color: ColorConstants.primaryLight,
        ),

        // Text Theme
        textTheme: const TextTheme(
          // Display styles (largest)
          displayLarge: TextStyle(
            fontSize: 57,
            fontWeight: FontWeight.w300,
            color: ColorConstants.textPrimary,
            
          ),
          displayMedium: TextStyle(
            fontSize: 45,
            fontWeight: FontWeight.w300,
            color: ColorConstants.textPrimary,
            
          ),
          displaySmall: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w400,
            color: ColorConstants.textPrimary,
            
          ),

          // Headline styles
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: ColorConstants.textPrimary,
            
          ),
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: ColorConstants.textPrimary,
            
          ),
          headlineSmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: ColorConstants.textPrimary,
            
          ),

          // Title styles
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: ColorConstants.textPrimary,
            
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ColorConstants.textPrimary,
            
          ),
          titleSmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ColorConstants.textPrimary,
            
          ),

          // Body styles
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: ColorConstants.textPrimary,
            
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: ColorConstants.textPrimary,
            
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: ColorConstants.textSecondary,
            
          ),

          // Label styles (buttons, etc)
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: ColorConstants.textPrimary,
            
          ),
          labelSmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: ColorConstants.textSecondary,
            
          ),
        ),
      );
}