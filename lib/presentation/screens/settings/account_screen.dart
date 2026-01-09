// ignore_for_file: lines_longer_than_80_chars

library;

import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/child_profile_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sync_provider.dart';
import '../../routes/app_router.dart';
import '../../widgets/dialogs/confirmation_dialog.dart';
import '../../widgets/dialogs/info_dialog.dart';
import 'edit_profile_screen.dart';
import 'export_data_screen.dart';

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

          // After null check, user is guaranteed non-null
          final nonNullUser = user;

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
                      backgroundImage: nonNullUser.photoURL != null
                          ? NetworkImage(nonNullUser.photoURL!)
                          : null,
                      child: nonNullUser.photoURL == null
                          ? Text(
                              nonNullUser.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                              style: const TextStyle(fontSize: 40),
                            )
                          : null,
                    ),

                    const SizedBox(height: 16),

                    // Name
                    Text(
                      nonNullUser.displayName ?? 'Pengguna',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Email
                    Text(
                      nonNullUser.email ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Child Profile Summary Card
              _buildChildProfileCard(context, nonNullUser, theme),

              const Divider(),

              // Account actions
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Edit Profil Anak'),
                subtitle: const Text('Ubah informasi anak'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const EditProfileScreen(),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const ExportDataScreen(),
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
                      'Made with â¤ï¸ for Moms',
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

  Widget _buildChildProfileCard(BuildContext context, User user, ThemeData theme) {
    final userId = user.uid;
    final isProfileComplete = ChildProfileHelper.isProfileComplete(userId);

    // If profile not complete, show prompt to fill
    if (!isProfileComplete) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.child_care,
                      color: Colors.orange[700],
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profil Anak Belum Lengkap',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Lengkapi profil untuk pengalaman lebih personal',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // If profile complete, show summary
    final childName = ChildProfileHelper.getChildName(userId);
    final childAge = ChildProfileHelper.getChildAgeString(userId);
    final childGender = ChildProfileHelper.getChildGender(userId);
    final genderDisplay = ChildProfileHelper.getGenderDisplay(childGender);
    final genderIcon = ChildProfileHelper.getGenderIcon(childGender);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    'Profil Anak',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Child Info
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      genderIcon,
                      color: theme.primaryColor,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          childName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (childAge.isNotEmpty)
                          Text(
                            childAge,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        if (genderDisplay.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            genderDisplay,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}