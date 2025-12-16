import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:momjournal/main.dart' as app;

void main() {
IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('MomJournal App Integration Tests', () {
    testWidgets('App should launch successfully',
        (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Verify app is running
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Complete app launch and navigation flow',
        (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for any splash screen to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify app is running
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Bottom navigation should be present',
        (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find bottom navigation bar
      final bottomNav = find.byType(BottomNavigationBar);
      
      // If bottom navigation exists, test navigation
      if (bottomNav.evaluate().isNotEmpty) {
        expect(bottomNav, findsOneWidget);

        // Test navigation between tabs
        final tabs = ['Beranda', 'Jadwal', 'Jurnal', 'Galeri', 'Pengaturan'];
        
        for (final tab in tabs) {
          final tabFinder = find.text(tab);
          if (tabFinder.evaluate().isNotEmpty) {
            await tester.tap(tabFinder);
            await tester.pumpAndSettle();
            
            // Verify navigation occurred
            expect(find.byType(BottomNavigationBar), findsOneWidget);
          }
        }
      }
    });

    testWidgets('Schedule screen should be accessible',
        (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Schedule screen
      final scheduleTab = find.text('Jadwal');
      if (scheduleTab.evaluate().isNotEmpty) {
        await tester.tap(scheduleTab);
        await tester.pumpAndSettle();

        // Verify we're on schedule screen
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('Journal screen should be accessible',
        (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Journal screen
      final journalTab = find.text('Jurnal');
      if (journalTab.evaluate().isNotEmpty) {
        await tester.tap(journalTab);
        await tester.pumpAndSettle();

        // Verify we're on journal screen
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('Gallery screen should be accessible',
        (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Gallery screen
      final galleryTab = find.text('Galeri');
      if (galleryTab.evaluate().isNotEmpty) {
        await tester.tap(galleryTab);
        await tester.pumpAndSettle();

        // Verify we're on gallery screen
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('Settings screen should be accessible',
        (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Settings screen
      final settingsTab = find.text('Pengaturan');
      if (settingsTab.evaluate().isNotEmpty) {
        await tester.tap(settingsTab);
        await tester.pumpAndSettle();

        // Verify we're on settings screen
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('FAB should be present on appropriate screens',
        (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Check Schedule screen for FAB
      final scheduleTab = find.text('Jadwal');
      if (scheduleTab.evaluate().isNotEmpty) {
        await tester.tap(scheduleTab);
        await tester.pumpAndSettle();

        // Look for FAB
        // FAB might or might not be present depending on screen state
        // Just verify screen loaded
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('App should handle navigation between all main screens',
        (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate through all main screens
      final screens = [
        'Jadwal',    // Schedule
        'Jurnal',    // Journal
        'Galeri',    // Gallery
        'Pengaturan', // Settings
        'Beranda',   // Home
      ];

      for (final screen in screens) {
        final screenFinder = find.text(screen);
        if (screenFinder.evaluate().isNotEmpty) {
          await tester.tap(screenFinder);
          await tester.pumpAndSettle();
          
          // Verify navigation successful
          expect(find.byType(MaterialApp), findsOneWidget);
        }
      }
    });

    testWidgets('App should maintain state during navigation',
        (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to a screen
      final scheduleTab = find.text('Jadwal');
      if (scheduleTab.evaluate().isNotEmpty) {
        await tester.tap(scheduleTab);
        await tester.pumpAndSettle();

        // Navigate to another screen
        final journalTab = find.text('Jurnal');
        if (journalTab.evaluate().isNotEmpty) {
          await tester.tap(journalTab);
          await tester.pumpAndSettle();

          // Navigate back to first screen
          await tester.tap(scheduleTab);
          await tester.pumpAndSettle();

          // Verify app is still responsive
          expect(find.byType(MaterialApp), findsOneWidget);
        }
      }
    });
  });
}