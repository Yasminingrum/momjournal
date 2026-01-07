import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/presentation/providers/auth_provider.dart';
import '/presentation/providers/theme_provider.dart';
import '/presentation/routes/app_router.dart';

import 'package:flutter/foundation.dart';
import '/core/utils/seed_database.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        children: [
          // Profile Section
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profil'),
            subtitle: Text(authProvider.userEmail ?? 'Atur informasi profil Anda'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              debugPrint('ðŸ”¥ Profile tapped');
              Navigator.pushNamed(context, Routes.account);
            },
          ),

          // Notifications Section
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifikasi'),
            subtitle: const Text('Atur preferensi notifikasi'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              debugPrint('ðŸ”¥ Notifications tapped');
              Navigator.pushNamed(context, Routes.notificationSettings);
            },
          ),

          // Theme Section
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Tema'),
            subtitle: Text(themeProvider.currentThemeTypeName),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              debugPrint('ðŸ”¥ Theme tapped');
              _showThemeDialog(context);
            },
          ),

          const Divider(height: 32),

          // About Section
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Tentang'),
            subtitle: const Text('Versi aplikasi dan informasi'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              debugPrint('ðŸ”¥ About tapped');
              _showAboutDialog(context);
            },
          ),

          // Privacy Policy
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Kebijakan Privasi'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              debugPrint('ðŸ”¥ Privacy Policy tapped');
              Navigator.pushNamed(context, Routes.privacyPolicy);
            },
          ),

          // Help & Support
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Bantuan & Dukungan'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              debugPrint('ðŸ”¥ Help & Support tapped');
              Navigator.pushNamed(context, Routes.helpSupport);
            },
          ),


          // Developer Tools Section
          if (kDebugMode) ...[
            const Divider(height: 32),
            const SeedDataButton(),
            const ClearDataButton(),
          ],

          const SizedBox(height: 16),

          // App Version
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'MomJournal',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Versi 1.0.0',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show theme selection dialog
  void _showThemeDialog(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    final currentType = themeProvider.themeType;
    
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
          title: const Text('Pilih Tema'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<AppThemeType>(
                    title: const Text('Terang'),
                    subtitle: const Text('Mode terang'),
                    secondary: const Icon(Icons.light_mode),
                    value: AppThemeType.light,
                    groupValue: currentType,
                    onChanged: (AppThemeType? value) {
                      if (value != null) {
                        _handleThemeChange(context, dialogContext, themeProvider, value, 'Mode terang diaktifkan');
                      }
                    },
                  ),
                  RadioListTile<AppThemeType>(
                    title: const Text('Gelap'),
                    subtitle: const Text('Mode gelap'),
                    secondary: const Icon(Icons.dark_mode),
                    value: AppThemeType.dark,
                    groupValue: currentType,
                    onChanged: (AppThemeType? value) {
                      if (value != null) {
                        _handleThemeChange(context, dialogContext, themeProvider, value, 'Mode gelap diaktifkan');
                      }
                    },
                  ),
                  RadioListTile<AppThemeType>(
                    title: const Text('LazyDays'),
                    subtitle: const Text('Tema pastel yang lembut'),
                    secondary: const Icon(Icons.palette),
                    value: AppThemeType.lazydays,
                    groupValue: currentType,
                    onChanged: (AppThemeType? value) {
                      if (value != null) {
                        _handleThemeChange(context, dialogContext, themeProvider, value, 'Tema LazyDays diaktifkan');
                      }
                    },
                  ),
                ],
              ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('BATAL'),
            ),
          ],
        ),
    );
  }

  // Handle theme change with feedback
  void _handleThemeChange(
    BuildContext context,
    BuildContext dialogContext,
    ThemeProvider themeProvider,
    AppThemeType value,
    String message,
  ) {
    themeProvider.setThemeType(value);
    Navigator.pop(dialogContext);
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Show about dialog
  void _showAboutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
          title: const Text('Tentang MomJournal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo/Icon
                Center(
                  child: Icon(
                    Icons.book,
                    size: 64,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 16),

                // App Name
                const Center(
                  child: Text(
                    'MomJournal',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    'Versi 1.0.0',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                const Text(
                  'Aplikasi pendamping Anda untuk mengelola jadwal, mencatat momen, '
                  'dan menyimpan kenangan berharga perjalanan parenting Anda.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Contact
                const Text(
                  'Â© 2025 MomJournal. Hak cipta dilindungi.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('TUTUP'),
            ),
          ],
        ),
    );
  }

}