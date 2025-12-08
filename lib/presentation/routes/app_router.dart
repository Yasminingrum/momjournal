/// App Router
/// 
/// Centralized route definitions dan navigation
/// Location: lib/presentation/routes/app_router.dart

import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/setup_profile_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/schedule/schedule_screen.dart';
import '../screens/schedule/add_schedule_screen.dart';
import '../screens/schedule/schedule_detail_screen.dart';
import '../screens/journal/journal_screen.dart';
import '../screens/journal/add_journal_screen.dart';
import '../screens/journal/journal_detail_screen.dart';
import '../screens/gallery/gallery_screen.dart';
import '../screens/gallery/photo_detail_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/notification_settings_screen.dart';
import '../screens/settings/account_screen.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/entities/journal_entity.dart';
import '../../domain/entities/photo_entity.dart';

/// Route names constants
class Routes {
  // Auth & Onboarding
  static const String splash = '/';
  static const String login = '/login';
  static const String setupProfile = '/setup-profile';
  
  // Main App
  static const String home = '/home';
  
  // Schedule
  static const String schedule = '/schedule';
  static const String addSchedule = '/schedule/add';
  static const String scheduleDetail = '/schedule/detail';
  
  // Journal
  static const String journal = '/journal';
  static const String addJournal = '/journal/add';
  static const String journalDetail = '/journal/detail';
  
  // Gallery
  static const String gallery = '/gallery';
  static const String photoDetail = '/photo/detail';
  
  // Settings
  static const String settings = '/settings';
  static const String notificationSettings = '/settings/notifications';
  static const String account = '/settings/account';
}

/// App Router class
class AppRouter {
  /// Generate route based on settings
  static Route<dynamic> generateRoute(RouteSettings settings) {
    print('🗺️ Navigating to: ${settings.name}');
    
    switch (settings.name) {
      // ==================== AUTH & ONBOARDING ====================
      case Routes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
      
      case Routes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
      
      case Routes.setupProfile:
        return MaterialPageRoute(
          builder: (_) => const SetupProfileScreen(),
        );
      
      // ==================== MAIN APP ====================
      case Routes.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
      
      // ==================== SCHEDULE ====================
      case Routes.schedule:
        return MaterialPageRoute(
          builder: (_) => const ScheduleScreen(),
        );
      
      case Routes.addSchedule:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AddScheduleScreen(
            selectedDate: args?['selectedDate'] as DateTime?,
          ),
        );
      
      case Routes.scheduleDetail:
        final schedule = settings.arguments as ScheduleEntity;
        return MaterialPageRoute(
          builder: (_) => ScheduleDetailScreen(schedule: schedule),
        );
      
      // ==================== JOURNAL ====================
      case Routes.journal:
        return MaterialPageRoute(
          builder: (_) => const JournalScreen(),
        );
      
      case Routes.addJournal:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AddJournalScreen(
            selectedDate: args?['selectedDate'] as DateTime?,
          ),
        );
      
      case Routes.journalDetail:
        final journal = settings.arguments as JournalEntity;
        return MaterialPageRoute(
          builder: (_) => JournalDetailScreen(journal: journal),
        );
      
      // ==================== GALLERY ====================
      case Routes.gallery:
        return MaterialPageRoute(
          builder: (_) => const GalleryScreen(),
        );
      
      case Routes.photoDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PhotoDetailScreen(
            photo: args['photo'] as PhotoEntity,
            heroTag: args['heroTag'] as String,
          ),
        );
      
      // ==================== SETTINGS ====================
      case Routes.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
        );
      
      case Routes.notificationSettings:
        return MaterialPageRoute(
          builder: (_) => const NotificationSettingsScreen(),
        );
      
      case Routes.account:
        return MaterialPageRoute(
          builder: (_) => const AccountScreen(),
        );
      
      // ==================== 404 ====================
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Halaman tidak ditemukan',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Route: ${settings.name}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Kembali'),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
  
  /// Initial route
  static String get initialRoute => Routes.splash;
}

/// Navigation Helper Extensions
extension NavigationHelper on BuildContext {
  /// Push named route
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return Navigator.pushNamed<T>(this, routeName, arguments: arguments);
  }
  
  /// Push replacement
  Future<T?> pushReplacementNamed<T, TO>(String routeName, {Object? arguments}) {
    return Navigator.pushReplacementNamed<T, TO>(
      this,
      routeName,
      arguments: arguments,
    );
  }
  
  /// Push and remove until
  Future<T?> pushNamedAndRemoveUntil<T>(
    String routeName,
    bool Function(Route<dynamic>) predicate, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      this,
      routeName,
      predicate,
      arguments: arguments,
    );
  }
  
  /// Pop
  void pop<T>([T? result]) {
    Navigator.pop<T>(this, result);
  }
  
  /// Pop until
  void popUntil(bool Function(Route<dynamic>) predicate) {
    Navigator.popUntil(this, predicate);
  }
  
  /// Can pop
  bool canPop() {
    return Navigator.canPop(this);
  }
}

/// Quick Navigation Methods
class Nav {
  /// Navigate to home (clear stack)
  static Future<void> toHome(BuildContext context) {
    return Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.home,
      (route) => false,
    );
  }
  
  /// Navigate to login (clear stack)
  static Future<void> toLogin(BuildContext context) {
    return Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.login,
      (route) => false,
    );
  }
  
  /// Navigate to add schedule
  static Future<void> toAddSchedule(
    BuildContext context, {
    DateTime? selectedDate,
  }) {
    return Navigator.pushNamed(
      context,
      Routes.addSchedule,
      arguments: {'selectedDate': selectedDate},
    );
  }
  
  /// Navigate to schedule detail
  static Future<void> toScheduleDetail(
    BuildContext context,
    ScheduleEntity schedule,
  ) {
    return Navigator.pushNamed(
      context,
      Routes.scheduleDetail,
      arguments: schedule,
    );
  }
  
  /// Navigate to add journal
  static Future<void> toAddJournal(
    BuildContext context, {
    DateTime? selectedDate,
  }) {
    return Navigator.pushNamed(
      context,
      Routes.addJournal,
      arguments: {'selectedDate': selectedDate},
    );
  }
  
  /// Navigate to journal detail
  static Future<void> toJournalDetail(
    BuildContext context,
    JournalEntity journal,
  ) {
    return Navigator.pushNamed(
      context,
      Routes.journalDetail,
      arguments: journal,
    );
  }
  
  /// Navigate to photo detail
  static Future<void> toPhotoDetail(
    BuildContext context,
    PhotoEntity photo,
    String heroTag,
  ) {
    return Navigator.pushNamed(
      context,
      Routes.photoDetail,
      arguments: {
        'photo': photo,
        'heroTag': heroTag,
      },
    );
  }
}