import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import 'manage_categories_screen.dart'; 

/// Add Schedule Screen with Multi-day Support
/// COMPLETE CLEAN VERSION - No ScheduleCategory enum
/// Location: lib/presentation/screens/schedule/add_schedule_screen.dart
class AddScheduleScreen extends StatefulWidget {
  const AddScheduleScreen({
    super.key,
    this.selectedDate,
  });

  final DateTime? selectedDate;

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  late DateTime _selectedDateTime;
  String _selectedCategory = 'Lainnya';  // âœ… String instead of enum
  bool _reminderEnabled = false;
  int _reminderMinutes = 15;
  bool _isLoading = false;
  
  // ðŸ†• Multi-day support
  bool _isMultiDay = false;
  DateTime? _endDateTime;

  bool _isRecurring = false;
  String _recurrencePattern = 'daily';  // daily, weekly
  int _recurrenceCount = 7;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.selectedDate ?? DateTime.now();
    _initializeCategories();
  }

  Future<void> _initializeCategories() async {
    final categoryProvider = context.read<CategoryProvider>();
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.uid;
    
    if (userId != null) {
      // Initialize defaults if DB is empty
      await categoryProvider.initializeDefaultCategories(userId);
      // Then load all categories
      await categoryProvider.loadCategories(userId);
    }
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
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 48,  // âœ… Extra bottom padding
            ),
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
            const SizedBox(height: 16),

            _buildRecurringSchedule(theme),

            // ðŸ†• Conditional end date picker
            if (_isMultiDay) ...[
              const SizedBox(height: 16),
              _buildEndDatePicker(theme),
            ],

            const SizedBox(height: 24),

            // Reminder section
            _buildReminderSection(theme),

            const SizedBox(height: 32),

            // Save button
            CustomButton(
              text: 'Simpan Jadwal',
              onPressed: _isLoading ? null : _handleSave,
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
                color: _getCategoryColor(_selectedCategory).withValues (alpha: 0.1),
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
                    _selectedCategory,  // âœ… Direct String usage
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
            // Set default end date to next day
            _endDateTime = _selectedDateTime.add(const Duration(days: 1));
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
    // âœ… Load categories dari CategoryProvider
    final categoryProvider = context.read<CategoryProvider>();
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.uid;
    
    List<String> categories = [];
    
    if (userId != null) {
      // Load categories from provider
      await categoryProvider.loadCategories(userId);
      categories = categoryProvider.categories
          .map((cat) => cat.name)
          .toList();
    }
    
    // Fallback to default categories if empty
    if (categories.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memuat kategori. Silakan coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pilih Kategori',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  TextButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute<bool>(
                          builder: (context) => const ManageCategoriesScreen(),
                        ),
                      );
                      
                      if (mounted && userId != null) {
                        await categoryProvider.loadCategories(userId);
                      }
                    },
                    icon: const Icon(Icons.settings, size: 16),
                    label: const Text('Kelola'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            // Category list
            Expanded(
              child: ListView(
                controller: scrollController,
                children: categories.map((category) {
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
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
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
  // 🆕 End date picker with time support
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
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: const TimeOfDay(hour: 23, minute: 59),
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

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    //Auto-calculate endDateTime untuk recurring
    if (_isRecurring) {
      // Recurring schedule, auto-calculate end date
      if (_recurrencePattern == 'daily') {
        _endDateTime = _selectedDateTime.add(
          Duration(days: _recurrenceCount - 1),
        );
      } else {  // weekly
        _endDateTime = _selectedDateTime.add(
          Duration(days: (_recurrenceCount - 1) * 7),
        );
      }
      
      // Set time to end of day
      _endDateTime = DateTime(
        _endDateTime!.year,
        _endDateTime!.month,
        _endDateTime!.day,
        23,
        59,
        59,
      );
      
      debugPrint('✅ Auto-calculated end date for recurring: $_endDateTime');
    }

    // Validate end date for multi-day (but not for recurring, already auto-calculated)
    if (_isMultiDay && _endDateTime == null && !_isRecurring) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal selesai untuk kegiatan multi-hari')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final scheduleProvider = context.read<ScheduleProvider>();
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.user?.uid;

      if (userId == null) {
        throw Exception('User not logged in');
      }

      // âœ… RECURRING SCHEDULE LOGIC
      if (_isRecurring) {
        // Create multiple schedules
        int successCount = 0;
        
        for (int i = 0; i < _recurrenceCount; i++) {
          DateTime scheduleDate;
          
          if (_recurrencePattern == 'daily') {
            // Add i days
            scheduleDate = _selectedDateTime.add(Duration(days: i));
          } else {
            // Add i weeks
            scheduleDate = _selectedDateTime.add(Duration(days: i * 7));
          }

          final success = await scheduleProvider.createSchedule(
            title: _titleController.text.trim(),
            category: _selectedCategory,
            dateTime: scheduleDate,
            endDateTime: _isMultiDay 
                ? _endDateTime?.add(Duration(
                    days: _recurrencePattern == 'daily' ? i : i * 7,
                  ),)
                : null,
            notes: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            hasReminder: _reminderEnabled,
            reminderMinutes: _reminderEnabled ? _reminderMinutes : null,
            userId: userId,
          );

          if (success) {
            successCount++;
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '$successCount jadwal berulang berhasil ditambahkan',
              ),
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        // Single schedule (existing logic)
        final success = await scheduleProvider.createSchedule(
          title: _titleController.text.trim(),
          category: _selectedCategory,
          dateTime: _selectedDateTime,
          endDateTime: _isMultiDay ? _endDateTime : null,
          notes: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          hasReminder: _reminderEnabled,
          reminderMinutes: _reminderEnabled ? _reminderMinutes : null,
          userId: userId,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Jadwal berhasil ditambahkan')),
          );
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan jadwal: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  Widget _buildRecurringSchedule(ThemeData theme) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recurring checkbox
        CheckboxListTile(
          value: _isRecurring,
          onChanged: (value) {
            setState(() => _isRecurring = value ?? false);
          },
          title: const Text('Jadwal Berulang'),
          subtitle: _isRecurring
              ? Text(
                  _recurrencePattern == 'daily'
                      ? 'Setiap hari, $_recurrenceCount kali'
                      : 'Setiap minggu, $_recurrenceCount kali',
                  style: theme.textTheme.bodySmall,
                )
              : const Text('Buat jadwal berulang otomatis'),
        ),

        // Recurring options
        if (_isRecurring) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pattern selector
                Text(
                  'Pola Pengulangan',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Harian'),
                        selected: _recurrencePattern == 'daily',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _recurrencePattern = 'daily');
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Mingguan'),
                        selected: _recurrencePattern == 'weekly',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _recurrencePattern = 'weekly');
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Count selector
                Text(
                  'Jumlah Pengulangan',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: _recurrenceCount > 1
                          ? () => setState(() => _recurrenceCount--)
                          : null,
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$_recurrenceCount kali',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: _recurrenceCount < 30
                          ? () => setState(() => _recurrenceCount++)
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _recurrencePattern == 'daily'
                      ? 'Jadwal akan dibuat untuk $_recurrenceCount hari berturut-turut'
                      : 'Jadwal akan dibuat untuk $_recurrenceCount minggu berturut-turut',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );

  // Helper methods
  Color _getCategoryColor(String category) {
    // âœ… Try to get from CategoryProvider first
    try {
      final categoryProvider = context.read<CategoryProvider>();
      final categoryEntity = categoryProvider.getCategoryByName(category);
      
      if (categoryEntity != null) {
        return _parseColor(categoryEntity.colorHex);
      }
    } catch (e) {
      // Provider not available, use fallback
    }
    
    // Fallback untuk backward compatibility
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

  // âœ… TAMBAHKAN helper method
  Color _parseColor(String hexColor) {
    try {
      // Remove # if present
      final hex = hexColor.replaceAll('#', '');
      // Add FF for alpha if not present
      final colorHex = hex.length == 6 ? 'FF$hex' : hex;
      return Color(int.parse('0x$colorHex'));
    } catch (e) {
      return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
  // âœ… Try to get from CategoryProvider first
  try {
    final categoryProvider = context.read<CategoryProvider>();
    final categoryEntity = categoryProvider.getCategoryByName(category);
    
    if (categoryEntity != null) {
      return _parseIconData(categoryEntity.icon);
    }
  } catch (e) {
    // Provider not available, use fallback
  }
  
    // Fallback untuk backward compatibility
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

  // âœ… TAMBAHKAN helper method
  IconData _parseIconData(String iconName) {
    // Map icon names to IconData
    const iconMap = {
      'restaurant': Icons.restaurant,
      'bedtime': Icons.bedtime,
      'medical_services': Icons.medical_services,
      'stars': Icons.stars,
      'favorite': Icons.favorite,
      'sports_soccer': Icons.sports_soccer,
      'school': Icons.school,
      'work': Icons.work,
      'home': Icons.home,
      'shopping_cart': Icons.shopping_cart,
      'fitness_center': Icons.fitness_center,
      'local_hospital': Icons.local_hospital,
      'child_care': Icons.child_care,
      'toys': Icons.toys,
      'cake': Icons.cake,
      'celebration': Icons.celebration,
      'more_horiz': Icons.more_horiz,
    };
    
    return iconMap[iconName] ?? Icons.more_horiz;
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