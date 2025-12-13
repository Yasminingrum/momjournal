/// Info Dialog
/// 
/// Dialog untuk menampilkan informasi ke user
/// Location: lib/presentation/widgets/dialogs/info_dialog.dart
library;

import 'package:flutter/material.dart';

/// Show info dialog
Future<void> showInfoDialog(
  BuildContext context, {
  required String title,
  required String message,
  String buttonText = 'OK',
  Widget? icon,
  VoidCallback? onPressed,
}) async {
  await showDialog(
    context: context,
    builder: (context) => InfoDialog(
      title: title,
      message: message,
      buttonText: buttonText,
      icon: icon,
      onPressed: onPressed,
    ),
  );
}

/// Info Dialog Widget
class InfoDialog extends StatelessWidget {

  const InfoDialog({
    required this.title, required this.message, super.key,
    this.buttonText = 'OK',
    this.icon,
    this.onPressed,
  });
  final String title;
  final String message;
  final String buttonText;
  final Widget? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      icon: icon ??
          Icon(
            Icons.info_outline,
            size: 48,
            color: colorScheme.primary,
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
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            onPressed?.call();
          },
          child: Text(buttonText),
        ),
      ],
    );
  }
}

/// Success Dialog (preset)
Future<void> showSuccessDialog(
  BuildContext context, {
  required String title,
  required String message,
  VoidCallback? onPressed,
}) => showInfoDialog(
    context,
    title: title,
    message: message,
    icon: const Icon(
      Icons.check_circle_outline,
      size: 48,
      color: Colors.green,
    ),
    onPressed: onPressed,
  );

/// Error Dialog (preset)
Future<void> showErrorDialog(
  BuildContext context, {
  required String title,
  required String message,
  VoidCallback? onPressed,
}) => showInfoDialog(
    context,
    title: title,
    message: message,
    buttonText: 'Tutup',
    icon: const Icon(
      Icons.error_outline,
      size: 48,
      color: Colors.red,
    ),
    onPressed: onPressed,
  );

/// Warning Dialog (preset)
Future<void> showWarningDialog(
  BuildContext context, {
  required String title,
  required String message,
  VoidCallback? onPressed,
}) => showInfoDialog(
    context,
    title: title,
    message: message,
    icon: const Icon(
      Icons.warning_amber_rounded,
      size: 48,
      color: Colors.orange,
    ),
    onPressed: onPressed,
  );