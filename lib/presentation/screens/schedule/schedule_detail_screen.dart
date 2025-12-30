import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/schedule_entity.dart';
import '../../providers/schedule_provider.dart';
import 'edit_schedule_screen.dart';

/// Schedule Detail Screen
/// COMPLETE CLEAN VERSION - No ScheduleCategory enum
/// Location: lib/presentation/screens/schedule/schedule_detail_screen.dart
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
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEdit(context),
          ),
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _handleDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with category color
            _buildHeader(theme),

            const SizedBox(height: 24),

            // Details section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    schedule.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Category
                  _buildInfoRow(
                    icon: _getCategoryIcon(schedule.category),
                    iconColor: _getCategoryColor(schedule.category),
                    label: 'Kategori',
                    value: schedule.category,
                  ),

                  const SizedBox(height: 16),

                  // Date & Time
                  _buildDateTimeInfo(theme),

                  const SizedBox(height: 16),

                  // Reminder
                  _buildInfoRow(
                    icon: Icons.notifications,
                    iconColor: schedule.hasReminder ? Colors.orange : Colors.grey,
                    label: 'Pengingat',
                    value: schedule.hasReminder
                        ? '${schedule.reminderMinutes} menit sebelumnya'
                        : 'Tidak aktif',
                  ),

                  const SizedBox(height: 16),

                  // Status
                  _buildInfoRow(
                    icon: schedule.isCompleted
                        ? Icons.check_circle
                        : _isOverdue(schedule)
                            ? Icons.warning
                            : Icons.schedule,
                    iconColor: schedule.isCompleted
                        ? Colors.green
                        : _isOverdue(schedule)
                            ? Colors.red
                            : Colors.blue,
                    label: 'Status',
                    value: schedule.isCompleted
                        ? 'Selesai'
                        : _isOverdue(schedule)
                            ? 'Terlewat'
                            : 'Belum selesai',
                  ),

                  if (schedule.notes != null && schedule.notes!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    
                    // Notes
                    Text(
                      'Catatan',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        schedule.notes!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Timestamps
                  _buildTimestamps(theme),

                  const SizedBox(height: 32),

                  // Action buttons
                  if (!schedule.isCompleted) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _handleMarkComplete(context),
                        icon: const Icon(Icons.check),
                        label: const Text('Tandai Selesai'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _getCategoryColor(schedule.category).withValues (alpha: 0.1),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getCategoryColor(schedule.category),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getCategoryIcon(schedule.category),
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            schedule.category,
            style: theme.textTheme.titleMedium?.copyWith(
              color: _getCategoryColor(schedule.category),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

  Widget _buildDateTimeInfo(ThemeData theme) => _buildInfoRow(
      icon: Icons.access_time,
      iconColor: Colors.blue,
      label: 'Waktu',
      value: _formatDateTime(schedule.dateTime),
    );

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) => Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );

  Widget _buildTimestamps(ThemeData theme) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informasi',
          style: theme.textTheme.titleSmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dibuat',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  Text(
                    _formatDate(schedule.createdAt),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Diperbarui',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  Text(
                    _formatDate(schedule.updatedAt),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );

  void _navigateToEdit(BuildContext context) {
    Navigator.push<bool?>(
      context,
      MaterialPageRoute<bool?>(
        builder: (context) => EditScheduleScreen(schedule: schedule),
      ),
    ).then((updated) {
      if (updated ?? false) {
        Navigator.pop(context, true);
      }
    });
  }

  Future<void> _handleMarkComplete(BuildContext context) async {
    try {
      final scheduleProvider = context.read<ScheduleProvider>();
      final success = await scheduleProvider.markAsCompleted(schedule.id);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jadwal ditandai selesai')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menandai selesai: $e')),
        );
      }
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Jadwal'),
        content: const Text('Apakah Anda yakin ingin menghapus jadwal ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if ((confirmed ?? false) && context.mounted) {
      try {
        final scheduleProvider = context.read<ScheduleProvider>();
        final success = await scheduleProvider.deleteSchedule(schedule.id);

        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Jadwal berhasil dihapus')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus jadwal: $e')),
          );
        }
      }
    }
  }

  // Helper methods
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Pemberian Makan/Menyusui':
        return Colors.orange;
      case 'Tidur':
        return Colors.blue;
      case 'Kesehatan':
        return Colors.red;
      case 'Pencapaian':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Pemberian Makan/Menyusui':
        return Icons.restaurant;
      case 'Tidur':
        return Icons.bedtime;
      case 'Kesehatan':
        return Icons.medical_services;
      case 'Pencapaian':
        return Icons.stars;
      default:
        return Icons.more_horiz;
    }
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 
                    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour == 0 ? 12 : time.hour > 12 ? time.hour - 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _formatDateTime(DateTime dateTime) => '${_formatDate(dateTime)}, ${_formatTime(dateTime)}';

  // Helper to check if schedule is overdue
  bool _isOverdue(ScheduleEntity schedule) {
    if (schedule.isCompleted) {
      return false;
    }
    return schedule.dateTime.isBefore(DateTime.now());
  }
}