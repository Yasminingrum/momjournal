import 'package:flutter/material.dart';
import '/core/constants/color_constants.dart';
import '/core/constants/text_constants.dart';
import 'custom_button.dart';

/// Empty State Widget
/// Displays empty states with optional action button
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.illustration,
    this.onAction,
    this.actionText,
    this.showAction = true,
  });
  
  final String? title;
  final String? message;
  final IconData? icon;
  final Widget? illustration;
  final VoidCallback? onAction;
  final String? actionText;
  final bool showAction;
  
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustration or Icon
            if (illustration != null)
              illustration!
            else
              Icon(
                icon ?? Icons.inbox_outlined,
                size: 80,
                color: ColorConstants.grey400,
              ),
            
            const SizedBox(height: 24),
            
            // Title
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
            
            // Message
            if (message != null)
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ColorConstants.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            
            // Action Button
            if (showAction && onAction != null) ...[
              const SizedBox(height: 24),
              PrimaryButton(
                text: actionText ?? 'Tambah',
                onPressed: onAction,
                icon: Icons.add,
              ),
            ],
          ],
        ),
      ),
    );
}

/// Empty Schedule State
class EmptyScheduleState extends StatelessWidget {
  const EmptyScheduleState({
    super.key,
    this.onAddSchedule,
  });
  
  final VoidCallback? onAddSchedule;
  
  @override
  Widget build(BuildContext context) => EmptyState(
      icon: Icons.calendar_today_outlined,
      title: TextConstants.emptySchedules,
      message: TextConstants.emptySchedulesDescription,
      onAction: onAddSchedule,
      actionText: TextConstants.addSchedule,
    );
}

/// Empty Journal State
class EmptyJournalState extends StatelessWidget {
  const EmptyJournalState({
    super.key,
    this.onAddJournal,
  });
  
  final VoidCallback? onAddJournal;
  
  @override
  Widget build(BuildContext context) => EmptyState(
      icon: Icons.edit_note_outlined,
      title: TextConstants.emptyJournals,
      message: TextConstants.emptyJournalsDescription,
      onAction: onAddJournal,
      actionText: TextConstants.addJournal,
    );
}

/// Empty Photo State
class EmptyPhotoState extends StatelessWidget {
  const EmptyPhotoState({
    super.key,
    this.onAddPhoto,
  });
  
  final VoidCallback? onAddPhoto;
  
  @override
  Widget build(BuildContext context) => EmptyState(
      icon: Icons.photo_library_outlined,
      title: TextConstants.emptyPhotos,
      message: TextConstants.emptyPhotosDescription,
      onAction: onAddPhoto,
      actionText: TextConstants.addPhoto,
    );
}

/// Empty Search Results State
class EmptySearchState extends StatelessWidget {
  const EmptySearchState({
    super.key,
    this.query,
    this.onClear,
  });
  
  final String? query;
  final VoidCallback? onClear;
  
  @override
  Widget build(BuildContext context) => EmptyState(
      icon: Icons.search_off,
      title: TextConstants.emptySearch,
      message: query != null
          ? 'Tidak ada hasil untuk "$query"\n${TextConstants.emptySearchDescription}'
          : TextConstants.emptySearchDescription,
      onAction: onClear,
      actionText: 'Hapus Pencarian',
      showAction: query != null && onClear != null,
    );
}

/// No Connection State
class NoConnectionState extends StatelessWidget {
  const NoConnectionState({
    super.key,
    this.onRetry,
  });
  
  final VoidCallback? onRetry;
  
  @override
  Widget build(BuildContext context) => EmptyState(
      icon: Icons.cloud_off_outlined,
      title: 'Tidak Ada Koneksi',
      message: 'Tidak dapat terhubung ke internet.\nPastikan Anda terhubung dan coba lagi.',
      onAction: onRetry,
      actionText: TextConstants.retry,
    );
}

/// Coming Soon State
class ComingSoonState extends StatelessWidget {
  const ComingSoonState({
    super.key,
    this.feature,
  });
  
  final String? feature;
  
  @override
  Widget build(BuildContext context) => EmptyState(
      icon: Icons.construction_outlined,
      title: 'Segera Hadir',
      message: feature != null
          ? '$feature akan segera tersedia!'
          : 'Fitur ini akan segera tersedia!',
      showAction: false,
    );
}

/// Under Maintenance State
class MaintenanceState extends StatelessWidget {
  const MaintenanceState({
    super.key,
    this.message,
  });
  
  final String? message;
  
  @override
  Widget build(BuildContext context) => EmptyState(
      icon: Icons.build_outlined,
      title: 'Dalam Perbaikan',
      message: message ?? 'Kami sedang melakukan perbaikan.\nSilakan coba lagi nanti.',
      showAction: false,
    );
}

/// No Notifications State
class NoNotificationsState extends StatelessWidget {
  const NoNotificationsState({super.key});
  
  @override
  Widget build(BuildContext context) => const EmptyState(
      icon: Icons.notifications_none_outlined,
      title: 'Tidak Ada Notifikasi',
      message: 'Anda belum memiliki notifikasi',
      showAction: false,
    );
}

/// Placeholder Card (for loading states)
class PlaceholderCard extends StatelessWidget {
  const PlaceholderCard({
    super.key,
    this.height = 100,
    this.width,
    this.borderRadius = 12,
    this.child,
  });
  
  final double height;
  final double? width;
  final double borderRadius;
  final Widget? child;
  
  @override
  Widget build(BuildContext context) => Container(
      height: height,
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstants.grey100,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: ColorConstants.grey300,
          style: BorderStyle.solid,
          width: 1,
        ),
      ),
      child: child ??
          const Center(
            child: Icon(
              Icons.add,
              size: 32,
              color: ColorConstants.grey400,
            ),
          ),
    );
}

/// Empty List Message
class EmptyListMessage extends StatelessWidget {
  const EmptyListMessage({
    required this.message, super.key,
    this.icon,
  });
  
  final String message;
  final IconData? icon;
  
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon ?? Icons.inbox_outlined,
            size: 48,
            color: ColorConstants.grey400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ColorConstants.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
}