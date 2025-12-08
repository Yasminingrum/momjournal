/// Add Schedule Screen
/// 
/// Screen untuk menambah schedule baru
/// Location: lib/presentation/screens/schedule/add_schedule_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/schedule_entity.dart';
import '../../providers/schedule_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/bottom_sheets/category_bottom_sheet.dart';
import '../../widgets/bottom_sheets/time_picker_bottom_sheet.dart';
import '../../widgets/dialogs/info_dialog.dart';
import '../../../core/constants/color_constants.dart';

class AddScheduleScreen extends StatefulWidget {
  final DateTime? selectedDate;

  const AddScheduleScreen({
    super.key,
    this.selectedDate,
  });

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedDateTime;
  ScheduleCategory _selectedCategory = ScheduleCategory.other;
  bool _reminderEnabled = false;
  int _reminderMinutes = 15;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.selectedDate ?? DateTime.now();
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
        title: const Text('Tambah Jadwal'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title field
            CustomTextField(
              label: 'Judul Jadwal',
              controller: _titleController,
              hintText: 'Contoh: Imunisasi DPT',
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
              label: 'Deskripsi (Opsional)',
              controller: _descriptionController,
              hintText: 'Tambahkan catatan...',
              prefixIcon: Icons.notes,
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            // Category selector
            _buildCategorySelector(theme),

            const SizedBox(height: 16),

            // Date time selector
            _buildDateTimeSelector(theme),

            const SizedBox(height: 24),

            // Reminder section
            _buildReminderSection(theme),

            const SizedBox(height: 32),

            // Save button
            CustomButton(
              onPressed: _isLoading ? null : _handleSave,
              label: _isLoading ? 'Menyimpan...' : 'Simpan Jadwal',
              type: ButtonType.primary,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector(ThemeData theme) {
    return Card(
      child: InkWell(
        onTap: _selectCategory,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getCategoryColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(),
                  color: _getCategoryColor(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kategori',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getCategoryName(),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeSelector(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tanggal & Waktu',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20),
                          const SizedBox(width: 8),
                          Text(_formatDate(_selectedDateTime!)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _selectTime,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, size: 20),
                          const SizedBox(width: 8),
                          Text(_formatTime(_selectedDateTime!)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_active),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pengingat',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_reminderEnabled)
                        Text(
                          _formatReminderTime(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                Switch(
                  value: _reminderEnabled,
                  onChanged: (value) {
                    setState(() {
                      _reminderEnabled = value;
                    });
                  },
                ),
              ],
            ),
            if (_reminderEnabled) ...[
              const SizedBox(height: 12),
              InkWell(
                onTap: _selectReminderTime,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatReminderTime()),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _selectCategory() async {
    final category = await showCategoryBottomSheet(
      context,
      selectedCategory: _selectedCategory,
    );

    if (category != null) {
      setState(() {
        _selectedCategory = category;
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime!,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDateTime!.hour,
          _selectedDateTime!.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime!),
    );

    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime!.year,
          _selectedDateTime!.month,
          _selectedDateTime!.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _selectReminderTime() async {
    final minutes = await showTimePickerBottomSheet(
      context,
      selectedMinutes: _reminderMinutes,
    );

    if (minutes != null) {
      setState(() {
        _reminderMinutes = minutes;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final schedule = ScheduleEntity.create(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dateTime: _selectedDateTime!,
      category: _selectedCategory,
      isReminderEnabled: _reminderEnabled,
      reminderMinutesBefore: _reminderMinutes,
    );

    final scheduleProvider = context.read<ScheduleProvider>();
    final success = await scheduleProvider.createSchedule(schedule);

    if (!mounted) return;

    if (success) {
      await showSuccessDialog(
        context,
        title: 'Berhasil',
        message: 'Jadwal berhasil ditambahkan',
        onPressed: () => Navigator.pop(context),
      );
    } else {
      setState(() {
        _isLoading = false;
      });

      await showErrorDialog(
        context,
        title: 'Gagal',
        message: scheduleProvider.errorMessage ?? 'Terjadi kesalahan',
      );

      scheduleProvider.clearError();
    }
  }

  Color _getCategoryColor() {
    switch (_selectedCategory) {
      case ScheduleCategory.feeding:
        return ColorConstants.categoryFeeding;
      case ScheduleCategory.sleeping:
        return ColorConstants.categorySleeping;
      case ScheduleCategory.health:
        return ColorConstants.categoryHealth;
      case ScheduleCategory.milestone:
        return ColorConstants.categoryMilestone;
      case ScheduleCategory.other:
        return ColorConstants.categoryOther;
    }
  }

  IconData _getCategoryIcon() {
    switch (_selectedCategory) {
      case ScheduleCategory.feeding:
        return Icons.restaurant;
      case ScheduleCategory.sleeping:
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
    switch (_selectedCategory) {
      case ScheduleCategory.feeding:
        return 'Pemberian Makan/Menyusui';
      case ScheduleCategory.sleeping:
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
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatReminderTime() {
    if (_reminderMinutes < 60) {
      return '$_reminderMinutes menit sebelumnya';
    } else if (_reminderMinutes == 60) {
      return '1 jam sebelumnya';
    } else {
      final hours = _reminderMinutes ~/ 60;
      return '$hours jam sebelumnya';
    }
  }
}