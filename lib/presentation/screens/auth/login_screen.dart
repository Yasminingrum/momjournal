/// Login Screen
/// 
/// Screen untuk login dengan Google Sign-In
/// Location: lib/presentation/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_router.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/dialogs/info_dialog.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            // Show loading overlay when authenticating
            if (authProvider.isLoading) {
              return Stack(
                children: [
                  _buildContent(context, theme, colorScheme, size),
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: LoadingOverlay(
                        message: 'Masuk dengan Google...',
                      ),
                    ),
                  ),
                ],
              );
            }

            return _buildContent(context, theme, colorScheme, size);
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    Size size,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        height: size.height - 48,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            
            // Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                Icons.book_rounded,
                size: 56,
                color: colorScheme.primary,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // App name
            Text(
              'MomJournal',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Tagline
            Text(
              'Kelola jadwal, dokumentasikan perjalanan,\ndan jaga kesehatan mental Anda',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 60),
            
            // Features list
            _FeatureItem(
              icon: Icons.calendar_today,
              title: 'Manajemen Jadwal',
              description: 'Atur jadwal harian anak dengan mudah',
            ),
            
            const SizedBox(height: 16),
            
            _FeatureItem(
              icon: Icons.edit_note,
              title: 'Jurnal Harian',
              description: 'Catat momen dan perasaan Anda',
            ),
            
            const SizedBox(height: 16),
            
            _FeatureItem(
              icon: Icons.photo_library,
              title: 'Galeri Foto',
              description: 'Simpan kenangan indah bersama si kecil',
            ),
            
            const SizedBox(height: 16),
            
            _FeatureItem(
              icon: Icons.cloud_upload,
              title: 'Backup Otomatis',
              description: 'Data aman tersimpan di cloud',
            ),
            
            const Spacer(),
            
            // Google Sign-In Button
            CustomButton.icon(
              onPressed: () => _handleGoogleSignIn(context),
              label: 'Masuk dengan Google',
              icon: Icons.g_mobiledata_rounded,
              type: ButtonType.primary,
              isFullWidth: true,
            ),
            
            const SizedBox(height: 12),
            
            // Terms & Privacy
            Text(
              'Dengan masuk, Anda menyetujui\nSyarat & Ketentuan serta Kebijakan Privasi',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    
    final success = await authProvider.signInWithGoogle();
    
    if (!context.mounted) return;
    
    if (success) {
      // Navigate to home
      Navigator.pushReplacementNamed(context, Routes.home);
    } else {
      // Show error dialog
      await showErrorDialog(
        context,
        title: 'Login Gagal',
        message: authProvider.errorMessage ?? 'Terjadi kesalahan',
      );
      
      authProvider.clearError();
    }
  }
}

/// Feature Item Widget
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}