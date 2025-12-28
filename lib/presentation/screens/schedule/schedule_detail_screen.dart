import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/color_constants.dart';
import '../../../domain/entities/schedule_entity.dart';
import '../../providers/schedule_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/dialogs/confirmation_dialog.dart';
import 'edit_schedule_screen.dart';

class ScheduleDetailScreen extends StatelessWidget {
  const ScheduleDetailScreen({
    required this.schedule,
    super.key,
  });

  final ScheduleEntity schedule;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Jadwal'),
        actions: [
          // Edit button
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _handleEdit(context),
            tooltip: 'Edit Jadwal',
          ),
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _handleDelete(context),
            tooltip: 'Hapus Jadwal',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category badge
            _buildCategoryBadge(theme),

            const SizedBox(height: 24),

            // Title
            Text(
              schedule.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            if (schedule.notes != null && schedule.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                schedule.notes!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Date & Time card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      icon: Icons.calendar_today,
                      label: 'Tanggal',
                      value: _formatDate(schedule.dateTime),
                      theme: theme,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      icon: Icons.access_time,
                      label: 'Waktu',
                      value: _formatTime(schedule.dateTime),
                      theme: theme,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Reminder card
            if (schedule.hasReminder)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildInfoRow(
                    icon: Icons.notifications_active,
                    label: 'Pengingat',
                    value: _formatReminderTime(schedule.reminderMinutes),
                    theme: theme,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Status card
            Card(
              color: schedule.isCompleted ? Colors.green[50] : Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      schedule.isCompleted ? Icons.check_circle : Icons.pending,
                      color: schedule.isCompleted ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        schedule.isCompleted ? 'Selesai' : 'Belum Selesai',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: schedule.isCompleted
                              ? Colors.green[700]
                              : Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Toggle completion button
            Consumer<ScheduleProvider>(
              builder: (context, provider, child) => CustomButton(
                onPressed: provider.isLoading
                    ? null
                    : () => _handleToggleCompletion(context),
                text: schedule.isCompleted
                    ? 'Tandai Belum Selesai'
                    : 'Tandai Selesai',
                icon:
                    schedule.isCompleted ? Icons.remove_done : Icons.check,
                type: schedule.isCompleted
                    ? ButtonType.outlined
                    : ButtonType.elevated,
                isFullWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(ThemeData theme) {
    final categoryColor = _getCategoryColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: categoryColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCategoryIcon(),
            size: 18,
            color: categoryColor,
          ),
          const SizedBox(width: 8),
          Text(
            _getCategoryName(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: categoryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) =>
      Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      );

  Future<void> _handleEdit(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditScheduleScreen(schedule: schedule),
      ),
    );

    // Jika edit berhasil, pop screen ini juga untuk kembali ke list
    if ((result ?? false) && context.mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _handleToggleCompletion(BuildContext context) async {
    final provider = context.read<ScheduleProvider>();
    final updated = schedule.copyWith(
      isCompleted: !schedule.isCompleted,
      updatedAt: DateTime.now(),
    );

    final success = await provider.updateSchedule(updated);

    if (!context.mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updated.isCompleted
                ? 'Jadwal ditandai selesai'
                : 'Jadwal ditandai belum selesai',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Terjadi kesalahan'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await showDeleteConfirmation(
      context,
      itemName: 'jadwal ini',
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final provider = context.read<ScheduleProvider>();
    final success = await provider.deleteSchedule(schedule.id);

    if (!context.mounted) {
      return;
    }

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jadwal berhasil dihapus'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Terjadi kesalahan'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Color _getCategoryColor() {
    switch (schedule.category) {
      case ScheduleCategory.feeding:
        return ColorConstants.categoryFeeding;
      case ScheduleCategory.sleep:
        return ColorConstants.categorySleep;
      case ScheduleCategory.health:
        return ColorConstants.categoryHealth;
      case ScheduleCategory.milestone:
        return ColorConstants.categoryMilestone;
      case ScheduleCategory.other:
        return ColorConstants.categoryOther;
    }
  }

  IconData _getCategoryIcon() {
    switch (schedule.category) {
      case ScheduleCategory.feeding:
        return Icons.restaurant;
      case ScheduleCategory.sleep:
        return Icons.bedtime;
      case ScheduleCategory.health:
        return Icons.medical_services;
      case ScheduleCategory.milestone:
        return Icons.stars;
      case ScheduleCategory.other:
        return Icons.more_horiz;
    }
  }

  String _getCategoryName() {
    switch (schedule.category) {
      case ScheduleCategory.feeding:
        return 'Pemberian Makan/Menyusui';
      case ScheduleCategory.sleep:
        return 'Tidur';
      case ScheduleCategory.health:
        return 'Kesehatan';
      case ScheduleCategory.milestone:
        return 'Pencapaian';
      case ScheduleCategory.other:
        return 'Lainnya';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  String _formatReminderTime(int minutes) {
    if (minutes < 60) {
      return '$minutes menit sebelumnya';
    } else if (minutes == 60) {
      return '1 jam sebelumnya';
    } else {
      final hours = minutes ~/ 60;
      return '$hours jam sebelumnya';
    }
  }
}