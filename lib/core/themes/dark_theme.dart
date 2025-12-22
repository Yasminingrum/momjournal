import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/color_constants.dart';

class DarkTheme {
  const DarkTheme._();

  static ThemeData get theme => ThemeData(
        // Use Material 3
        useMaterial3: true,

        // Brightness
        brightness: Brightness.dark,

        // Color Scheme
        colorScheme: const ColorScheme.dark(
          primary: ColorConstants.primaryLight,
          primaryContainer: ColorConstants.primaryDark,
          secondary: ColorConstants.secondaryLight,
          secondaryContainer: ColorConstants.secondaryColor,
          tertiary: ColorConstants.secondaryColor,
          surface: ColorConstants.surfaceDark,
          error: Color(0xFFCF6679), // Material Design dark error color
          onPrimary: ColorConstants.textPrimaryDark,
          onSecondary: ColorConstants.textPrimaryDark,
          onSurface: ColorConstants.textPrimaryDark,
          onError: ColorConstants.textPrimaryDark,
        ),

        // Scaffold Background
        scaffoldBackgroundColor: ColorConstants.backgroundDark,

        // App Bar Theme
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: ColorConstants.surfaceDark,
          foregroundColor: ColorConstants.textPrimary,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          titleTextStyle: TextStyle(
            color: ColorConstants.textPrimaryDark,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(
            color: ColorConstants.textPrimaryDark,
          ),
        ),

        // Card Theme
        cardTheme: CardThemeData(
          color: ColorConstants.surfaceDark,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),

        // Elevated Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorConstants.primaryDark,
            foregroundColor: ColorConstants.textPrimaryDark,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Floating Action Button Theme
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: ColorConstants.primaryDark,
          foregroundColor: ColorConstants.textPrimaryDark,
          elevation: 4,
          shape: CircleBorder(),
        ),

        // Input Decoration Theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF424242), // grey800 equivalent
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF757575)), // grey600
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF757575)), // grey600
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: ColorConstants.primaryLight,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFCF6679)), // error
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Color(0xFFCF6679), // error
              width: 2,
            ),
          ),
          labelStyle: const TextStyle(
            color: ColorConstants.textSecondaryDark,
            fontSize: 16,
          ),
          hintStyle: const TextStyle(
            color: ColorConstants.textSecondaryDark,
            fontSize: 16,
          ),
          errorStyle: const TextStyle(
            color: Color(0xFFCF6679), // error
            fontSize: 12,
          ),
        ),

        // Checkbox Theme
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return ColorConstants.primaryLight;
            }
            return const Color(0xFF757575); // grey600
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
            return const Color(0xFF757575); // grey600
          }),
        ),

        // Switch Theme
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return ColorConstants.primaryLight;
            }
            return const Color(0xFF757575); // grey600
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return ColorConstants.primaryDark;
            }
            return const Color(0xFF757575); // grey600
          }),
        ),

        // Chip Theme
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFF757575), // grey600
          selectedColor: ColorConstants.primaryDark,
          disabledColor: const Color(0xFF424242), // grey800
          labelStyle: const TextStyle(
            color: ColorConstants.textPrimaryDark,
            fontSize: 14,
          ),
          secondaryLabelStyle: const TextStyle(
            color: ColorConstants.textSecondaryDark,
            fontSize: 14,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        // Dialog Theme
        dialogTheme: DialogThemeData(
          backgroundColor: ColorConstants.surfaceDark,
          elevation: 24,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titleTextStyle: const TextStyle(
            color: ColorConstants.textPrimaryDark,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          contentTextStyle: const TextStyle(
            color: ColorConstants.textSecondaryDark,
            fontSize: 16,
          ),
        ),

        // Bottom Sheet Theme
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: ColorConstants.surfaceDark,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
        ),

        // Snack Bar Theme
        snackBarTheme: SnackBarThemeData(
          backgroundColor: ColorConstants.surfaceDark,
          contentTextStyle: const TextStyle(
            color: ColorConstants.textPrimaryDark,
            fontSize: 14,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),

        // Bottom Navigation Bar Theme
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: ColorConstants.surfaceDark,
          selectedItemColor: ColorConstants.primaryLight,
          unselectedItemColor: ColorConstants.textSecondaryDark,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
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
        dividerTheme: const DividerThemeData(
          color: Color(0xFF4A3F5C), // Darker purple-grey for dividers
          thickness: 1,
          space: 1,
        ),

        // Icon Theme
        iconTheme: const IconThemeData(
          color: ColorConstants.textPrimaryDark,
          size: 24,
        ),

        // Text Theme
        textTheme: const TextTheme(
          // Display styles (largest)
          displayLarge: TextStyle(
            fontSize: 57,
            fontWeight: FontWeight.w400,
            color: ColorConstants.textPrimaryDark,
          ),
          displayMedium: TextStyle(
            fontSize: 45,
            fontWeight: FontWeight.w400,
            color: ColorConstants.textPrimaryDark,
          ),
          displaySmall: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w400,
            color: ColorConstants.textPrimaryDark,
          ),

          // Headline styles
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: ColorConstants.textPrimaryDark,
          ),
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: ColorConstants.textPrimaryDark,
          ),
          headlineSmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: ColorConstants.textPrimaryDark,
          ),

          // Title styles
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: ColorConstants.textPrimaryDark,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ColorConstants.textPrimaryDark,
          ),
          titleSmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ColorConstants.textPrimaryDark,
          ),

          // Body styles
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: ColorConstants.textPrimaryDark,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: ColorConstants.textPrimaryDark,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: ColorConstants.textSecondaryDark,
          ),

          // Label styles (buttons, etc)
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ColorConstants.textPrimaryDark,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: ColorConstants.textPrimaryDark,
          ),
          labelSmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: ColorConstants.textPrimaryDark,
          ),
        ),
      );
}