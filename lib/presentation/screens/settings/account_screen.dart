// ignore_for_file: lines_longer_than_80_chars

library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/sync_provider.dart';
import '../../routes/app_router.dart';
import '../../widgets/dialogs/confirmation_dialog.dart';
import '../../widgets/dialogs/info_dialog.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Akun'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;

          if (user == null) {
            return const Center(
              child: Text('Tidak ada informasi pengguna'),
            );
          }

          return ListView(
            children: [
              // Profile header
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: user.photoURL != null
                          ? NetworkImage(user.photoURL!)
                          : null,
                      child: user.photoURL == null
                          ? Text(
                              user.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                              style: const TextStyle(fontSize: 40),
                            )
                          : null,
                    ),

                    const SizedBox(height: 16),

                    // Name
                    Text(
                      user.displayName ?? 'Pengguna',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Email
                    Text(
                      user.email ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Account actions
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Edit Profil Anak'),
                subtitle: const Text('Ubah informasi anak'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur akan segera tersedia'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.cloud_sync),
                title: const Text('Sinkronisasi Data'),
                subtitle: Consumer<SyncProvider>(
                  builder: (context, syncProvider, child) => Text(syncProvider.lastSyncTimeFormatted),
                ),
                trailing: Consumer<SyncProvider>(
                  builder: (context, syncProvider, child) {
                    if (syncProvider.isSyncing) {
                      return const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    }
                    return const Icon(Icons.arrow_forward_ios, size: 16);
                  },
                ),
                onTap: () => _handleManualSync(context),
              ),

              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Ekspor Data'),
                subtitle: const Text('Unduh semua data Anda'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur akan segera tersedia'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),

              const Divider(height: 32),

              // Danger zone
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Zona Berbahaya',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.logout, color: Colors.orange),
                title: const Text(
                  'Keluar',
                  style: TextStyle(color: Colors.orange),
                ),
                subtitle: const Text('Logout dari aplikasi'),
                onTap: () => _handleLogout(context),
              ),

              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text(
                  'Hapus Akun',
                  style: TextStyle(color: Colors.red),
                ),
                subtitle: const Text('Hapus akun dan semua data'),
                onTap: () => _handleDeleteAccount(context),
              ),

              const SizedBox(height: 32),

              // App info
              Center(
                child: Column(
                  children: [
                    Text(
                      'MomJournal v1.0.0',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Made with ❤️ for Moms',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Future<void> _handleManualSync(BuildContext context) async {
    final syncProvider = context.read<SyncProvider>();
    
    final success = await syncProvider.syncAll();

    if (!context.mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil disinkronkan'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      await showErrorDialog(
        context,
        title: 'Sinkronisasi Gagal',
        message: syncProvider.errorMessage ?? 'Terjadi kesalahan',
      );
      syncProvider.clearError();
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showLogoutConfirmation(context);

    if (!confirmed || !context.mounted) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signOut();

    if (!context.mounted) {
      return;
    }

    if (success) {
      await Nav.toLogin(context);
    } else {
      await showErrorDialog(
        context,
        title: 'Logout Gagal',
        message: authProvider.errorMessage ?? 'Terjadi kesalahan',
      );
      authProvider.clearError();
    }
  }

  Future<void> _handleDeleteAccount(BuildContext context) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Hapus Akun?',
      message: 'Semua data Anda akan dihapus secara permanen. '
          'Tindakan ini tidak dapat dibatalkan.',
      confirmText: 'Hapus Akun',
      cancelText: 'Batal',
      isDangerous: true,
      icon: const Icon(
        Icons.delete_forever,
        size: 48,
        color: Colors.red,
      ),
    );

    if (!confirmed || !context.mounted) {
      return;
    }

    // Read provider before any async call
    final authProvider = context.read<AuthProvider>();

    // Show loading
    if (!context.mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final success = await authProvider.deleteAccount();

    if (!context.mounted) {
      return;
    }

    Navigator.pop(context); // Close loading

    if (success) {
      await Nav.toLogin(context);
    } else {
      await showErrorDialog(
        context,
        title: 'Gagal Menghapus Akun',
        message: authProvider.errorMessage ?? 'Terjadi kesalahan',
      );
      authProvider.clearError();
    }
  }
}