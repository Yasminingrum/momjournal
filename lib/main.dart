import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Core
import 'core/themes/app_theme.dart';

// Data Layer
import 'data/datasources/local/hive_database.dart';

// Presentation Layer - Providers
import 'presentation/providers/journal_provider.dart';
import 'presentation/providers/photo_provider.dart';
import 'presentation/providers/schedule_provider.dart';

// Presentation Layer - Screens
import 'presentation/screens/home/home_screen.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive database
  final hiveDatabase = HiveDatabase();
  await hiveDatabase.init();
  await hiveDatabase.openBoxes();

  // Debug: Print box statistics
  await hiveDatabase.printBoxStats();

  // Run the app
  runApp(MomJournalApp(hiveDatabase: hiveDatabase));
}

/// Root widget aplikasi MomJournal
class MomJournalApp extends StatelessWidget {
  final HiveDatabase hiveDatabase;

  const MomJournalApp({
    super.key,
    required this.hiveDatabase,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Schedule Provider
        ChangeNotifierProvider(
          create: (_) => ScheduleProvider(hiveDatabase),
        ),

        // Journal Provider
        ChangeNotifierProvider(
          create: (_) => JournalProvider(hiveDatabase),
        ),

        // Photo Provider
        ChangeNotifierProvider(
          create: (_) => PhotoProvider(hiveDatabase),
        ),
      ],
      child: Consumer<ScheduleProvider>(
        builder: (context, scheduleProvider, _) {
          // Get theme mode from provider (atau bisa dari settings)
          // For now, we'll use system theme
          return MaterialApp(
            title: 'MomJournal',
            debugShowCheckedModeBanner: false,

            // Theme configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system, // Follow system theme

            // Initial route
            home: const HomeScreen(),

            // Error handling
            builder: (context, child) {
              // Global error boundary
              ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                return _ErrorScreen(errorDetails: errorDetails);
              };

              return child ?? const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}

/// Error screen yang ditampilkan saat terjadi error
class _ErrorScreen extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const _ErrorScreen({required this.errorDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error icon
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red[400],
              ),
              const SizedBox(height: 24),

              // Error title
              const Text(
                'Oops! Terjadi Kesalahan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Error message
              const Text(
                'Aplikasi mengalami kesalahan. Silakan restart aplikasi.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Error details (hanya di debug mode)
              if (const bool.fromEnvironment('dart.vm.product') == false) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      errorDetails.exceptionAsString(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Restart button
              ElevatedButton.icon(
                onPressed: () {
                  // Restart app (akan di-implement dengan restart package)
                  // Untuk sekarang, keluar dari app
                  SystemNavigator.pop();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Restart Aplikasi'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}