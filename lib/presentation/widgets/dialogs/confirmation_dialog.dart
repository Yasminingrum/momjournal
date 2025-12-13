/// Confirmation Dialog
/// 
/// Reusable confirmation dialog untuk berbagai aksi
/// Location: lib/presentation/widgets/dialogs/confirmation_dialog.dart
library;

import 'package:flutter/material.dart';

/// Show confirmation dialog
/// 
/// Returns true jika user confirm, false jika cancel
Future<bool> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Ya',
  String cancelText = 'Tidak',
  bool isDangerous = false,
  Widget? icon,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => ConfirmationDialog(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      isDangerous: isDangerous,
      icon: icon,
    ),
  );
  
  return result ?? false;
}

/// Confirmation Dialog Widget
class ConfirmationDialog extends StatelessWidget {

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Ya',
    this.cancelText = 'Tidak',
    this.isDangerous = false,
    this.icon,
  });
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDangerous;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      icon: icon ??
          Icon(
            isDangerous ? Icons.warning_amber_rounded : Icons.help_outline,
            size: 48,
            color: isDangerous ? colorScheme.error : colorScheme.primary,
          ),
      title: Text(
        title,
        textAlign: TextAlign.center,
      ),
      content: Text(
        message,
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: isDangerous
              ? FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                )
              : null,
          child: Text(confirmText),
        ),
      ],
    );
  }
}

/// Delete Confirmation Dialog (preset)
Future<bool> showDeleteConfirmation(
  BuildContext context, {
  required String itemName,
  String message = 'Data yang dihapus tidak dapat dikembalikan.',
}) => showConfirmationDialog(
    context,
    title: 'Hapus $itemName?',
    message: message,
    confirmText: 'Hapus',
    cancelText: 'Batal',
    isDangerous: true,
    icon: const Icon(
      Icons.delete_forever,
      size: 48,
      color: Colors.red,
    ),
  );

/// Logout Confirmation Dialog (preset)
Future<bool> showLogoutConfirmation(BuildContext context) => showConfirmationDialog(
    context,
    title: 'Keluar dari Akun?',
    message: 'Anda akan logout dari aplikasi.',
    confirmText: 'Keluar',
    cancelText: 'Batal',
    icon: const Icon(
      Icons.logout,
      size: 48,
      color: Colors.orange,
    ),
  );

/// Discard Changes Confirmation
Future<bool> showDiscardChangesConfirmation(BuildContext context) => showConfirmationDialog(
    context,
    title: 'Buang Perubahan?',
    message: 'Perubahan yang belum disimpan akan hilang.',
    confirmText: 'Buang',
    cancelText: 'Batal',
    isDangerous: true,
  );