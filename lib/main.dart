import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

// Core
import 'core/themes/app_theme.dart';
import 'core/themes/lazydays_theme.dart';
import 'data/datasources/local/category_local_datasource.dart';
// Data Layer - Local Datasources
import 'data/datasources/local/hive_database.dart';
import 'data/datasources/local/journal_local_datasource.dart';
import 'data/datasources/local/photo_local_datasource.dart';
import 'data/datasources/local/schedule_local_datasource.dart';
// Data Layer - Remote Datasources
import 'data/datasources/remote/auth_remote_datasource.dart';
import 'data/datasources/remote/category_remote_datasource.dart';
import 'data/datasources/remote/firebase_service.dart';
import 'data/datasources/remote/journal_remote_datasource.dart';
import 'data/datasources/remote/photo_remote_datasource.dart';
import 'data/datasources/remote/schedule_remote_datasource.dart';
// Data Layer - Repositories
import 'data/repositories/auth_repository.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/sync_repository.dart';
// Presentation Layer - Providers
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/category_provider.dart';
import 'presentation/providers/journal_provider.dart';
import 'presentation/providers/notification_provider.dart';
import 'presentation/providers/photo_provider.dart';
import 'presentation/providers/schedule_provider.dart';
import 'presentation/providers/sync_provider.dart';
import 'presentation/providers/theme_provider.dart';
// Presentation Layer - Routes
import 'presentation/routes/app_router.dart';
// Services
import 'services/notification_service.dart';

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
  Widget build(BuildContext context) => MultiProvider(
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
          lazy: false,
        ),

        // Notification Provider
        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => NotificationProvider(
            notificationService: notificationService,
          ),
        ),

        // ✅ Sync Provider - HARUS DIBUAT SEBELUM AuthProvider
        ChangeNotifierProvider<SyncProvider>(
          create: (context) => SyncProvider(
            repository: context.read<SyncRepository>(),
          ),
        ),

        // ✅ Category Provider - HARUS DIBUAT SEBELUM AuthProvider
        ChangeNotifierProvider<CategoryProvider>(
          create: (context) {
            final categoryLocalDataSource = CategoryLocalDataSource(
              hiveDatabase.categoryBox,
            );
            
            final categoryRemoteDataSource = CategoryRemoteDataSource(
              FirebaseFirestore.instance,
            );
            
            final categoryRepository = CategoryRepository(
              localDataSource: categoryLocalDataSource,
              remoteDataSource: categoryRemoteDataSource,
            );
            
            return CategoryProvider(
              repository: categoryRepository,
            );
          },
        ),

        // ✅ Auth Provider - UPDATED dengan SyncProvider + CategoryProvider dependency
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            authRepository: context.read<AuthRepository>(),
            syncProvider: context.read<SyncProvider>(),
            categoryProvider: context.read<CategoryProvider>(),
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
          builder: (context, themeProvider, child) => MaterialApp(
              key: ValueKey(themeProvider.themeType), // Key untuk proper rebuild
              title: 'MomJournal',
              debugShowCheckedModeBanner: false,


            // ==================== LOCALIZATION FIX ====================
            // Add localization delegates to fix MaterialLocalizations error
            // IMPORTANT: Remove 'const' because delegates are not compile-time constants
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('id', 'ID'), // Indonesian
              Locale('en', 'US'), // English
            ],
            locale: const Locale('id', 'ID'), // Default to Indonesian

            // Theme configuration - support multiple themes
            theme: themeProvider.isLazydaysTheme 
                ? LazydaysTheme.theme 
                : AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            // ==================== ROUTING ====================
            // Initial route - mulai dari splash screen untuk auth check
            initialRoute: Routes.splash,
            onGenerateRoute: AppRouter.generateRoute,

            // Error handling
            builder: (context, child) {
              // Error widget untuk menangkap error yang tidak tertangani
              ErrorWidget.builder = (FlutterErrorDetails errorDetails) => Scaffold(
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Oops! Something went wrong',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            errorDetails.exception.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              return child ?? const SizedBox();
            },
          ),
        ),
    );
}