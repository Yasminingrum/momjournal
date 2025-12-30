import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/schedule_entity.dart';
import '../../providers/schedule_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

/// Edit Schedule Screen with Multi-day Support
/// COMPLETE CLEAN VERSION - No ScheduleCategory enum
/// Location: lib/presentation/screens/schedule/edit_schedule_screen.dart
class EditScheduleScreen extends StatefulWidget {
  const EditScheduleScreen({
    required this.schedule,
    super.key,
  });

  final ScheduleEntity schedule;

  @override
  State<EditScheduleScreen> createState() => _EditScheduleScreenState();
}

class _EditScheduleScreenState extends State<EditScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  late DateTime _selectedDateTime;
  late String _selectedCategory;  // âœ… String instead of enum
  late bool _reminderEnabled;
  late int _reminderMinutes;
  bool _isLoading = false;
  
  // ðŸ†• Multi-day support
  late bool _isMultiDay;
  DateTime? _endDateTime;

  @override
  void initState() {
    super.initState();
    // Initialize dengan data dari schedule yang ada
    _titleController = TextEditingController(text: widget.schedule.title);
    _descriptionController = TextEditingController(text: widget.schedule.notes ?? '');
    _selectedDateTime = widget.schedule.dateTime;
    _selectedCategory = widget.schedule.category;  // âœ… Already String
    _reminderEnabled = widget.schedule.hasReminder;
    _reminderMinutes = widget.schedule.reminderMinutes;
    
    // ðŸ†• Initialize multi-day from existing schedule
    _isMultiDay = widget.schedule.isMultiDay;
    _endDateTime = widget.schedule.endDateTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Jadwal'),
        actions: [
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _handleDelete,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title field
            CustomTextField(
              controller: _titleController,
              label: 'Judul Jadwal',
              hint: 'Contoh: Imunisasi DPT',
              prefixIcon: Icons.title,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Judul harus diisi';
                }
                if (value.trim().length < 3) {
                  return 'Judul minimal 3 karakter';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Description field
            CustomTextField(
              controller: _descriptionController,
              label: 'Deskripsi (Opsional)',
              hint: 'Tambahkan catatan...',
              prefixIcon: Icons.notes,
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            // Category selector
            _buildCategorySelector(theme),

            const SizedBox(height: 16),

            // Date time selector
            _buildDateTimeSelector(theme),

            const SizedBox(height: 16),

            // ðŸ†• Multi-day checkbox
            _buildMultiDayCheckbox(),

            // ðŸ†• Conditional end date picker
            if (_isMultiDay) ...[
              const SizedBox(height: 16),
              _buildEndDatePicker(theme),
            ],

            const SizedBox(height: 24),

            // Reminder section
            _buildReminderSection(theme),

            const SizedBox(height: 32),

            // Update button
            CustomButton(
              text: 'Simpan Perubahan',
              onPressed: _isLoading ? null : _handleUpdate,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector(ThemeData theme) => InkWell(
      onTap: _showCategoryPicker,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getCategoryColor(_selectedCategory).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getCategoryIcon(_selectedCategory),
                color: _getCategoryColor(_selectedCategory),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kategori',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedCategory,
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );

  Widget _buildDateTimeSelector(ThemeData theme) => InkWell(
      onTap: _showDateTimePicker,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.calendar_today, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tanggal & Waktu',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDateTime(_selectedDateTime),
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );

  // ðŸ†• Multi-day checkbox
  Widget _buildMultiDayCheckbox() => CheckboxListTile(
      value: _isMultiDay,
      onChanged: (value) {
        setState(() {
          _isMultiDay = value ?? false;
          if (!_isMultiDay) {
            _endDateTime = null;
          } else {
            _endDateTime ??= _selectedDateTime.add(const Duration(days: 1));
          }
        });
      },
      title: const Text('Kegiatan Multi-Hari'),
      subtitle: _isMultiDay
          ? Text(
              'Jadwal akan berlangsung beberapa hari',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            )
          : null,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );

  // ðŸ†• End date picker
  Widget _buildEndDatePicker(ThemeData theme) => InkWell(
      onTap: _showEndDatePicker,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.blue.shade50,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.event, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tanggal Selesai',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _endDateTime != null
                        ? _formatDate(_endDateTime!)
                        : 'Pilih tanggal selesai',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: _endDateTime != null ? Colors.black : Colors.grey,
                    ),
                  ),
                  if (_endDateTime != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Durasi: ${_calculateDuration()} hari',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.blue),
          ],
        ),
      ),
    );

  Widget _buildReminderSection(ThemeData theme) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          value: _reminderEnabled,
          onChanged: (value) => setState(() => _reminderEnabled = value),
          title: const Text('Aktifkan Pengingat'),
          subtitle: _reminderEnabled
              ? Text('$_reminderMinutes menit sebelumnya')
              : const Text('Tidak ada pengingat'),
          contentPadding: EdgeInsets.zero,
        ),
        if (_reminderEnabled) ...[
          const SizedBox(height: 16),
          Text(
            'Waktu Pengingat',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [5, 15, 30, 60].map((minutes) {
              final isSelected = _reminderMinutes == minutes;
              return ChoiceChip(
                label: Text('$minutes menit'),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _reminderMinutes = minutes);
                  }
                },
              );
            }).toList(),
          ),
        ],
      ],
    );

  Future<void> _showCategoryPicker() async {
    final categories = [
      'Pemberian Makan/Menyusui',
      'Tidur',
      'Kesehatan',
      'Pencapaian',
      'Lainnya',
    ];

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Pilih Kategori',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Category list
            ...categories.map((category) {
              final isSelected = category == _selectedCategory;
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(category).withValues (alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(category),
                    color: _getCategoryColor(category),
                  ),
                ),
                title: Text(category),
                trailing: isSelected
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                selected: isSelected,
                onTap: () {
                  setState(() => _selectedCategory = category);
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _showDateTimePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (pickedTime != null && mounted) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          
          // Update end date if multi-day and end date is before new start date
          if (_isMultiDay && _endDateTime != null) {
            if (_endDateTime!.isBefore(_selectedDateTime)) {
              _endDateTime = _selectedDateTime.add(const Duration(days: 1));
            }
          }
        });
      }
    }
  }

  // ðŸ†• End date picker
  Future<void> _showEndDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _endDateTime ?? _selectedDateTime.add(const Duration(days: 1)),
      firstDate: _selectedDateTime,
      lastDate: DateTime(2030),
      helpText: 'Pilih Tanggal Selesai',
    );

    if (pickedDate != null && mounted) {
      // Ask if user wants to set specific time
      final bool? setTime = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Atur Waktu Selesai'),
          content: const Text('Apakah ingin mengatur waktu selesai tertentu?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Akhir Hari (23:59)'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Pilih Waktu'),
            ),
          ],
        ),
      );

      if ((setTime ?? false) && mounted) {
        // Show time picker
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: _endDateTime != null 
              ? TimeOfDay.fromDateTime(_endDateTime!)
              : const TimeOfDay(hour: 23, minute: 59),
        );

        if (pickedTime != null && mounted) {
          setState(() {
            _endDateTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
          });
        }
      } else if (setTime == false && mounted) {
        // Use end of day
        setState(() {
          _endDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            23,
            59,
          );
        });
      }
    }
  }


  // ðŸ†• Calculate duration
  int _calculateDuration() {
    if (_endDateTime == null) {
      return 0;
    }
    return _endDateTime!.difference(_selectedDateTime).inDays + 1;
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate end date for multi-day
    if (_isMultiDay && _endDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal selesai untuk kegiatan multi-hari')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final scheduleProvider = context.read<ScheduleProvider>();

      // Create updated schedule
      final updatedSchedule = ScheduleEntity(
        id: widget.schedule.id,
        userId: widget.schedule.userId,
        title: _titleController.text.trim(),
        category: _selectedCategory,
        dateTime: _selectedDateTime,
        endDateTime: _isMultiDay ? _endDateTime : null,  // ðŸ†• Multi-day support
        notes: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        hasReminder: _reminderEnabled,
        reminderMinutes: _reminderEnabled ? _reminderMinutes : 0,
        isCompleted: widget.schedule.isCompleted,
        createdAt: widget.schedule.createdAt,
        updatedAt: DateTime.now(),
      );

      final success = await scheduleProvider.updateSchedule(updatedSchedule);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jadwal berhasil diperbarui')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui jadwal: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleDelete() async {
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

    if ((confirmed ?? false) && mounted) {
      setState(() => _isLoading = true);

      try {
        final scheduleProvider = context.read<ScheduleProvider>();
        final success = await scheduleProvider.deleteSchedule(widget.schedule.id);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Jadwal berhasil dihapus')),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus jadwal: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
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
}