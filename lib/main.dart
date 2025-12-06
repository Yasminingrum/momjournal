import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/color_constants.dart';
import 'domain/entities/user_entity.dart';
import 'domain/entities/schedule_entity.dart';
import 'domain/entities/journal_entity.dart';
import 'domain/entities/photo_entity.dart';
import 'presentation/providers/schedule_provider.dart';
import 'presentation/providers/journal_provider.dart';
import 'presentation/providers/photo_provider.dart';
import 'presentation/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive Adapters
  // Note: In production, you would run build_runner to generate these adapters
  // For now, we'll use manual registration when adapters are generated
  
  runApp(const MomJournalApp());
}

class MomJournalApp extends StatelessWidget {
  const MomJournalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScheduleProvider()..init()),
        ChangeNotifierProvider(create: (_) => JournalProvider()..init()),
        ChangeNotifierProvider(create: (_) => PhotoProvider()..init()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: ColorConstants.primaryColor,
            brightness: Brightness.light,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            elevation: 4,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: ColorConstants.primaryColor,
            brightness: Brightness.dark,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}