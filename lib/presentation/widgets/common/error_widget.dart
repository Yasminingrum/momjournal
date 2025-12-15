import 'package:flutter/material.dart';
import '/core/constants/color_constants.dart';
import '/core/constants/text_constants.dart';
import 'custom_button.dart';

/// Error Widget
/// Displays error states with retry option
class ErrorDisplayWidget extends StatelessWidget {
  
  const ErrorDisplayWidget({
    super.key,
    this.message,
    this.title,
    this.icon,
    this.onRetry,
    this.retryButtonText,
  });
  final String? message;
  final String? title;
  final IconData? icon;
  final VoidCallback? onRetry;
  final String? retryButtonText;
  
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: ColorConstants.error,
            ),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: ColorConstants.textPrimary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message ?? TextConstants.errorGeneric,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ColorConstants.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              PrimaryButton(
                text: retryButtonText ?? TextConstants.retry,
                onPressed: onRetry,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
}

/// Network Error Widget
class NetworkErrorWidget extends StatelessWidget {
  
  const NetworkErrorWidget({
    super.key,
    this.onRetry,
  });
  final VoidCallback? onRetry;
  
  @override
  Widget build(BuildContext context) => ErrorDisplayWidget(
      icon: Icons.wifi_off,
      title: 'Tidak Ada Koneksi',
      message: TextConstants.errorNoInternet,
      onRetry: onRetry,
    );
}

/// Not Found Error Widget
class NotFoundErrorWidget extends StatelessWidget {
  
  const NotFoundErrorWidget({
    super.key,
    this.message,
    this.onAction,
    this.actionText,
  });
  final String? message;
  final VoidCallback? onAction;
  final String? actionText;
  
  @override
  Widget build(BuildContext context) => ErrorDisplayWidget(
      icon: Icons.search_off,
      title: 'Tidak Ditemukan',
      message: message ?? 'Data yang Anda cari tidak ditemukan',
      onRetry: onAction,
      retryButtonText: actionText,
    );
}

/// Permission Denied Widget
class PermissionDeniedWidget extends StatelessWidget {
  
  const PermissionDeniedWidget({
    super.key,
    this.message,
    this.onSettings,
  });
  final String? message;
  final VoidCallback? onSettings;
  
  @override
  Widget build(BuildContext context) => ErrorDisplayWidget(
      icon: Icons.block,
      title: 'Izin Ditolak',
      message: message ?? TextConstants.errorPermissionDenied,
      onRetry: onSettings,
      retryButtonText: 'Buka Pengaturan',
    );
}

/// Inline Error Message
class InlineErrorMessage extends StatelessWidget {
  
  const InlineErrorMessage({
    required this.message, super.key,
    this.onDismiss,
  });
  final String message;
  final VoidCallback? onDismiss;
  
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorConstants.errorLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: ColorConstants.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: ColorConstants.error,
                fontSize: 14,
              ),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              color: ColorConstants.error,
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
}

/// Inline Success Message
class InlineSuccessMessage extends StatelessWidget {
  
  const InlineSuccessMessage({
    required this.message, super.key,
    this.onDismiss,
  });
  final String message;
  final VoidCallback? onDismiss;
  
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorConstants.successLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: ColorConstants.success,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: ColorConstants.success,
                fontSize: 14,
              ),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              color: ColorConstants.success,
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
}

/// Inline Warning Message
class InlineWarningMessage extends StatelessWidget {
  
  const InlineWarningMessage({
    required this.message, super.key,
    this.onDismiss,
  });
  final String message;
  final VoidCallback? onDismiss;
  
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorConstants.warningLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_outlined,
            color: ColorConstants.warning,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: ColorConstants.warning,
                fontSize: 14,
              ),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              color: ColorConstants.warning,
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
}

/// Inline Info Message
class InlineInfoMessage extends StatelessWidget {
  
  const InlineInfoMessage({
    required this.message, super.key,
    this.onDismiss,
  });
  final String message;
  final VoidCallback? onDismiss;
  
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorConstants.infoLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: ColorConstants.info,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: ColorConstants.info,
                fontSize: 14,
              ),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              color: ColorConstants.info,
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
}

/// Snackbar Helper
class SnackBarHelper {
  SnackBarHelper._();
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: ColorConstants.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: ColorConstants.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }
  
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: ColorConstants.info,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: ColorConstants.warning,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}