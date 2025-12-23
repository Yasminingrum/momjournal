library;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../data/datasources/local/hive_database.dart';

/// Enum untuk jenis theme yang tersedia
enum AppThemeType {
  light,
  dark,
  lazydays,
}

class ThemeProvider with ChangeNotifier {
  ThemeProvider({required HiveDatabase hiveDatabase})
      : _hiveDatabase = hiveDatabase {
    _loadThemeTypeSync();
  }

  final HiveDatabase _hiveDatabase;
  static const String _themeTypeKey = 'theme_type';

  AppThemeType _themeType = AppThemeType.light;
  bool _isInitialized = false;

  /// Current theme type
  AppThemeType get themeType => _themeType;

  /// Check if provider is initialized
  bool get isInitialized => _isInitialized;

  /// Get theme mode for MaterialApp
  /// LazyDays theme always uses light mode
  ThemeMode get themeMode {
    switch (_themeType) {
      case AppThemeType.light:
        return ThemeMode.light;
      case AppThemeType.dark:
        return ThemeMode.dark;
      case AppThemeType.lazydays:
        return ThemeMode.light; // LazyDays menggunakan light mode
    }
  }

  /// Is dark mode active
  bool get isDarkMode => _themeType == AppThemeType.dark;

  /// Is LazyDays theme active
  bool get isLazydaysTheme => _themeType == AppThemeType.lazydays;

  /// Load theme type from storage synchronously (tanpa notifyListeners)
  void _loadThemeTypeSync() {
    try {
      final box = _hiveDatabase.settingsBox;
      final savedType = box.get(_themeTypeKey, defaultValue: 'light') as String;
      
      _themeType = _parseThemeType(savedType);
      _isInitialized = true;
      // TIDAK memanggil notifyListeners() di constructor
    } catch (e) {
      debugPrint('❌ Error loading theme type: $e');
      _themeType = AppThemeType.light;
      _isInitialized = true;
    }
  }

  /// Set theme type
  Future<void> setThemeType(AppThemeType type) async {
    if (_themeType == type) {
      return;
    }

    _themeType = type;
    
    // Notify listeners setelah frame selesai untuk menghindari rebuild issues
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    // Save to storage
    try {
      final box = _hiveDatabase.settingsBox;
      await box.put(_themeTypeKey, _themeTypeToString(type));
      debugPrint('✅ Theme type saved: ${_themeTypeToString(type)}');
    } catch (e) {
      debugPrint('❌ Error saving theme type: $e');
    }
  }

  /// Toggle between themes (Light -> Dark -> LazyDays -> Light)
  Future<void> toggleTheme() async {
    final newType = switch (_themeType) {
      AppThemeType.light => AppThemeType.dark,
      AppThemeType.dark => AppThemeType.lazydays,
      AppThemeType.lazydays => AppThemeType.light,
    };
    await setThemeType(newType);
  }

  /// Parse theme type from string
  AppThemeType _parseThemeType(String type) {
    switch (type.toLowerCase()) {
      case 'light':
        return AppThemeType.light;
      case 'dark':
        return AppThemeType.dark;
      case 'lazydays':
        return AppThemeType.lazydays;
      default:
        return AppThemeType.light;
    }
  }

  /// Convert theme type to string
  String _themeTypeToString(AppThemeType type) {
    switch (type) {
      case AppThemeType.light:
        return 'light';
      case AppThemeType.dark:
        return 'dark';
      case AppThemeType.lazydays:
        return 'lazydays';
    }
  }

  /// Get theme type display name
  String getThemeTypeName(AppThemeType type) {
    switch (type) {
      case AppThemeType.light:
        return 'Terang';
      case AppThemeType.dark:
        return 'Gelap';
      case AppThemeType.lazydays:
        return 'LazyDays';
    }
  }

  /// Get current theme type display name
  String get currentThemeTypeName => getThemeTypeName(_themeType);

  /// Get all available themes
  List<AppThemeType> get availableThemes => AppThemeType.values;
}