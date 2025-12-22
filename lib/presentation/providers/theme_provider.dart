library;

import 'package:flutter/material.dart';
import '../../data/datasources/local/hive_database.dart';

class ThemeProvider with ChangeNotifier {
  ThemeProvider({required HiveDatabase hiveDatabase})
      : _hiveDatabase = hiveDatabase {
    _loadThemeMode();
  }

  final HiveDatabase _hiveDatabase;
  static const String _themeModeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  /// Current theme mode
  ThemeMode get themeMode => _themeMode;

  /// Is dark mode active (considering system theme)
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      // This will be determined by the system
      return false; // Default, will be overridden by system
    }
    return _themeMode == ThemeMode.dark;
  }

  /// Load theme mode from storage
  Future<void> _loadThemeMode() async {
    try {
      final box = _hiveDatabase.settingsBox;
      final savedMode = box.get(_themeModeKey, defaultValue: 'system') as String;
      
      _themeMode = _parseThemeMode(savedMode);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading theme mode: $e');
      _themeMode = ThemeMode.system;
    }
  }

  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) {
      return;
    }

    _themeMode = mode;
    notifyListeners();

    // Save to storage
    try {
      final box = _hiveDatabase.settingsBox;
      await box.put(_themeModeKey, _themeModeToString(mode));
      debugPrint('✅ Theme mode saved: ${_themeModeToString(mode)}');
    } catch (e) {
      debugPrint('❌ Error saving theme mode: $e');
    }
  }

  /// Toggle between light and dark (skip system)
  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    await setThemeMode(newMode);
  }

  /// Parse theme mode from string
  ThemeMode _parseThemeMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'lazydays':
        return ThemeMode.light; 
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// Convert theme mode to string
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// Get theme mode display name
  String getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Terang';
      case ThemeMode.dark:
        return 'Gelap';
      case ThemeMode.system:
        return 'Sistem';
    }
  }

  /// Get current theme mode display name
  String get currentThemeModeName => getThemeModeName(_themeMode);
}
