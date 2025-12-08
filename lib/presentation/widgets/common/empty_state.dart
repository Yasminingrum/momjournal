import 'package:flutter/material.dart';
import '../../core/constants/color_constants.dart';
import '../../core/constants/text_constants.dart';
import 'custom_button.dart';

/// Empty State Widget
/// Displays empty states with optional action button
class EmptyState extends StatelessWidget {
  final String? title;
  final String? message;
  final IconData? icon;
  final Widget? illustration;
  final VoidCallback? onAction;
  final String? actionText;
  final bool showAction;
  
  const EmptyState({
    Key? key,
    this.title,
    this.message,
    this.icon,
    this.illustration,
    this.onAction,
    this.actionText,
    this.showAction = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Center(
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
                isFullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty Schedule State
class EmptyScheduleState extends StatelessWidget {
  final VoidCallback? onAddSchedule;
  
  const EmptyScheduleState({
    Key? key,
    this.onAddSchedule,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.calendar_today_outlined,
      title: TextConstants.emptySchedules,
      message: TextConstants.emptySchedulesDescription,
      onAction: onAddSchedule,
      actionText: TextConstants.addSchedule,
    );
  }
}

/// Empty Journal State
class EmptyJournalState extends StatelessWidget {
  final VoidCallback? onAddJournal;
  
  const EmptyJournalState({
    Key? key,
    this.onAddJournal,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.edit_note_outlined,
      title: TextConstants.emptyJournals,
      message: TextConstants.emptyJournalsDescription,
      onAction: onAddJournal,
      actionText: TextConstants.addJournal,
    );
  }
}

/// Empty Photo State
class EmptyPhotoState extends StatelessWidget {
  final VoidCallback? onAddPhoto;
  
  const EmptyPhotoState({
    Key? key,
    this.onAddPhoto,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.photo_library_outlined,
      title: TextConstants.emptyPhotos,
      message: TextConstants.emptyPhotosDescription,
      onAction: onAddPhoto,
      actionText: TextConstants.addPhoto,
    );
  }
}

/// Empty Search Results State
class EmptySearchState extends StatelessWidget {
  final String? query;
  final VoidCallback? onClear;
  
  const EmptySearchState({
    Key? key,
    this.query,
    this.onClear,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return EmptyState(
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
}

/// No Connection State
class NoConnectionState extends StatelessWidget {
  final VoidCallback? onRetry;
  
  const NoConnectionState({
    Key? key,
    this.onRetry,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.cloud_off_outlined,
      title: 'Tidak Ada Koneksi',
      message: 'Tidak dapat terhubung ke internet.\nPastikan Anda terhubung dan coba lagi.',
      onAction: onRetry,
      actionText: TextConstants.retry,
    );
  }
}

/// Coming Soon State
class ComingSoonState extends StatelessWidget {
  final String? feature;
  
  const ComingSoonState({
    Key? key,
    this.feature,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.construction_outlined,
      title: 'Segera Hadir',
      message: feature != null
          ? '$feature akan segera tersedia!'
          : 'Fitur ini akan segera tersedia!',
      showAction: false,
    );
  }
}

/// Under Maintenance State
class MaintenanceState extends StatelessWidget {
  final String? message;
  
  const MaintenanceState({
    Key? key,
    this.message,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.build_outlined,
      title: 'Dalam Perbaikan',
      message: message ?? 'Kami sedang melakukan perbaikan.\nSilakan coba lagi nanti.',
      showAction: false,
    );
  }
}

/// No Notifications State
class NoNotificationsState extends StatelessWidget {
  const NoNotificationsState({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.notifications_none_outlined,
      title: 'Tidak Ada Notifikasi',
      message: 'Anda belum memiliki notifikasi',
      showAction: false,
    );
  }
}

/// Placeholder Card (for loading states)
class PlaceholderCard extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;
  final Widget? child;
  
  const PlaceholderCard({
    Key? key,
    this.height = 100,
    this.width,
    this.borderRadius = 12,
    this.child,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
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
          Center(
            child: Icon(
              Icons.add,
              size: 32,
              color: ColorConstants.grey400,
            ),
          ),
    );
  }
}

/// Empty List Message
class EmptyListMessage extends StatelessWidget {
  final String message;
  final IconData? icon;
  
  const EmptyListMessage({
    Key? key,
    required this.message,
    this.icon,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Padding(
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
}