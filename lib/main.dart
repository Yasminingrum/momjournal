import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

// Services
import '/services/notification_service.dart';
// Core
import 'core/themes/app_theme.dart';
// Data Layer - Local Datasources
import 'data/datasources/local/hive_database.dart';
import 'data/datasources/local/journal_local_datasource.dart';
import 'data/datasources/local/photo_local_datasource.dart';
import 'data/datasources/local/schedule_local_datasource.dart';
// Data Layer - Remote Datasources
import 'data/datasources/remote/auth_remote_datasource.dart';
import 'data/datasources/remote/firebase_service.dart';
import 'data/datasources/remote/journal_remote_datasource.dart';
import 'data/datasources/remote/photo_remote_datasource.dart';
import 'data/datasources/remote/schedule_remote_datasource.dart';
// Data Layer - Repositories
import 'data/repositories/auth_repository.dart';
import 'data/repositories/sync_repository.dart';
// Presentation Layer - Providers
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/journal_provider.dart';
import 'presentation/providers/notification_provider.dart';
import 'presentation/providers/photo_provider.dart';
import 'presentation/providers/schedule_provider.dart';
import 'presentation/providers/sync_provider.dart';
import 'presentation/providers/theme_provider.dart';
// Presentation Layer - Routes
import 'presentation/routes/app_router.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Indonesian locale untuk DateFormat
  await initializeDateFormatting('id_ID', null);

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

  // Initialize Firebase menggunakan FirebaseService
  await FirebaseService().initialize();

  // Initialize Notification Service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Initialize local datasources
  final journalLocalDataSource = JournalLocalDataSource();
  await journalLocalDataSource.init();

  final photoLocalDataSource = PhotoLocalDataSource();
  await photoLocalDataSource.init();

  // Run the app
  runApp(
    MomJournalApp(
      hiveDatabase: hiveDatabase,
      notificationService: notificationService,
      journalLocalDataSource: journalLocalDataSource,
      photoLocalDataSource: photoLocalDataSource,
    ),
  );
}


/// Root widget aplikasi MomJournal
class MomJournalApp extends StatelessWidget {
  const MomJournalApp({
    required this.hiveDatabase,
    required this.notificationService,
    required this.journalLocalDataSource,
    required this.photoLocalDataSource,
    super.key,
  });

  final HiveDatabase hiveDatabase;
  final NotificationService notificationService;
  final JournalLocalDataSource journalLocalDataSource;
  final PhotoLocalDataSource photoLocalDataSource;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ==================== LOCAL DATASOURCES ====================
        Provider<ScheduleLocalDataSource>(
          create: (_) => ScheduleLocalDataSource(hiveDatabase),
        ),
        Provider<JournalLocalDataSource>(
          create: (_) => journalLocalDataSource,
        ),
        Provider<PhotoLocalDataSource>(
          create: (_) => photoLocalDataSource,
        ),

        // ==================== REMOTE DATASOURCES ====================
        Provider<AuthRemoteDatasource>(
          create: (_) => AuthRemoteDatasourceImpl(),
        ),
        Provider<ScheduleRemoteDatasource>(
          create: (_) => ScheduleRemoteDatasourceImpl(),
        ),
        Provider<JournalRemoteDatasource>(
          create: (_) => JournalRemoteDatasourceImpl(),
        ),
        Provider<PhotoRemoteDatasource>(
          create: (_) => PhotoRemoteDatasourceImpl(),
        ),

        // ==================== REPOSITORIES ====================
        // Auth Repository
        Provider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(
            remoteDatasource: context.read<AuthRemoteDatasource>(),
          ),
        ),

        // Sync Repository
        Provider<SyncRepository>(
          create: (context) => SyncRepositoryImpl(
            scheduleLocal: context.read<ScheduleLocalDataSource>(),
            scheduleRemote: context.read<ScheduleRemoteDatasource>(),
            journalLocal: context.read<JournalLocalDataSource>(),
            journalRemote: context.read<JournalRemoteDatasource>(),
            photoLocal: context.read<PhotoLocalDataSource>(),
            photoRemote: context.read<PhotoRemoteDatasource>(),
          ),
        ),

        // ==================== PROVIDERS ====================
        // Theme Provider (harus di atas MaterialApp)
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(hiveDatabase: hiveDatabase),
        ),

        // Notification Provider
        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => NotificationProvider(
            notificationService: notificationService,
          ),
        ),

        // Sync Provider
        ChangeNotifierProvider<SyncProvider>(
          create: (context) => SyncProvider(
            repository: context.read<SyncRepository>(),
          ),
        ),

        // Auth Provider
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            authRepository: context.read<AuthRepository>(),
          ),
        ),

        // Schedule Provider - creates its own repository instance
        ChangeNotifierProvider<ScheduleProvider>(
          create: (_) => ScheduleProvider()..loadAllSchedules(),
        ),

        // Journal Provider - creates its own repository instance
        ChangeNotifierProvider<JournalProvider>(
          create: (_) => JournalProvider()..loadAllJournals(),
        ),

        // Photo Provider - creates its own repository instance
        ChangeNotifierProvider<PhotoProvider>(
          create: (_) => PhotoProvider()..loadPhotos(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'MomJournal',
            debugShowCheckedModeBanner: false,

            // Theme configuration - menggunakan ThemeProvider
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            // ==================== ROUTING ====================
            // Initial route - mulai dari splash screen untuk auth check
            initialRoute: Routes.splash,
            onGenerateRoute: AppRouter.generateRoute,

            // Error handling
            builder: (context, child) {
              // Global error boundary
              ErrorWidget.builder = (FlutterErrorDetails errorDetails) =>
                  _ErrorScreen(errorDetails: errorDetails);

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
  const _ErrorScreen({required this.errorDetails});

  final FlutterErrorDetails errorDetails;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
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
              if (!const bool.fromEnvironment('dart.vm.product')) ...[
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
                onPressed: SystemNavigator.pop,
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