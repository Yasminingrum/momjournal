import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '/domain/entities/schedule_entity.dart';
import '/presentation/providers/schedule_provider.dart';
import '/presentation/routes/app_router.dart';
import '/presentation/screens/schedule/edit_schedule_screen.dart';
import '/presentation/screens/schedule/schedule_detail_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  ScheduleCategory? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _showCompletedOnly = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ScheduleProvider>().loadSchedulesForDate(_selectedDate);
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
            tooltip: 'Pilih Tanggal',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              if (value == 'completed') {
                setState(() {
                  _showCompletedOnly = !_showCompletedOnly;
                });
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'completed',
                child: Row(
                  children: [
                    Icon(
                      _showCompletedOnly 
                        ? Icons.check_box 
                        : Icons.check_box_outline_blank,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('Tampilkan Selesai'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateHeader(),
          _buildCategoryFilter(),
          Expanded(child: _buildScheduleList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(
            context, 
            Routes.addSchedule,
          );
          if (result == true && mounted) {
            await context.read<ScheduleProvider>().loadSchedulesForDate(_selectedDate);
          }
        },
        tooltip: 'Tambah Jadwal',
        child: const Icon(Icons.add),
      ),
    );

  Widget _buildDateHeader() => Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeDate(-1),
          ),
          Column(
            children: [
              Text(
                DateFormat('EEEE', 'id_ID').format(_selectedDate),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeDate(1),
          ),
        ],
      ),
    );

  Widget _buildCategoryFilter() => SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        children: [
          _buildCategoryChip('Semua', null),
          _buildCategoryChip('Makan', ScheduleCategory.feeding),
          _buildCategoryChip('Tidur', ScheduleCategory.sleep),
          _buildCategoryChip('Kesehatan', ScheduleCategory.health),
          _buildCategoryChip('Pencapaian', ScheduleCategory.milestone),
          _buildCategoryChip('Lainnya', ScheduleCategory.other),
        ],
      ),
    );

  Widget _buildCategoryChip(String label, ScheduleCategory? category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
          if (mounted) {
            if (category == null) {
              context.read<ScheduleProvider>().loadSchedulesForDate(_selectedDate);
            } else {
              context.read<ScheduleProvider>().filterByCategory(category);
            }
          }
        },
        selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildScheduleList() => Consumer<ScheduleProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(provider.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    provider.loadSchedulesForDate(_selectedDate);
                  },
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        final schedules = provider.schedules.where((schedule) {
          if (_showCompletedOnly) {
            return schedule.isCompleted;
          }
          return true;
        }).toList();

        if (schedules.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada jadwal',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tekan tombol + untuk menambah jadwal',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        // Group schedules by time
        schedules.sort((a, b) => a.dateTime.compareTo(b.dateTime));

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: schedules.length,
          itemBuilder: (context, index) {
            final schedule = schedules[index];
            return _buildScheduleCard(schedule);
          },
        );
      },
    );

  Widget _buildScheduleCard(ScheduleEntity schedule) {
    final timeFormat = DateFormat('HH:mm');
    final categoryColor = _getCategoryColor(schedule.category);
    final isOverdue = schedule.dateTime.isBefore(DateTime.now()) 
        && !schedule.isCompleted;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: schedule.isCompleted ? 1 : 2,
      child: InkWell(
        onTap: () => _showScheduleOptions(schedule),
        child: Opacity(
          opacity: schedule.isCompleted ? 0.6 : 1.0,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Time
                Container(
                  width: 60,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        timeFormat.format(schedule.dateTime),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: categoryColor,
                          fontSize: 16,
                        ),
                      ),
                      if (isOverdue)
                        const Icon(
                          Icons.warning,
                          size: 16,
                          color: Colors.red,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              schedule.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                decoration: schedule.isCompleted 
                                  ? TextDecoration.lineThrough 
                                  : null,
                              ),
                            ),
                          ),
                          if (schedule.hasReminder)
                            const Icon(
                              Icons.notifications_active,
                              size: 16,
                              color: Colors.orange,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getCategoryDisplayName(schedule.category),
                        style: TextStyle(
                          fontSize: 12,
                          color: categoryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (schedule.notes != null && schedule.notes!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          schedule.notes!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Status
                if (schedule.isCompleted)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 24,
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    color: Colors.grey,
                    onPressed: () => _markAsCompleted(schedule),
                    tooltip: 'Tandai Selesai',
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showScheduleOptions(ScheduleEntity schedule) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.visibility),
            title: const Text('Lihat Detail'),
            onTap: () async {
              Navigator.pop(context);
              // ✅ NEW - Navigate to detail screen
              await Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => ScheduleDetailScreen(schedule: schedule),
                ),
              );
              // Reload schedules after returning from detail
              if (mounted) {
                await context.read<ScheduleProvider>().loadSchedulesForDate(_selectedDate);
              }
            },
          ),
          if (!schedule.isCompleted)
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Tandai Selesai'),
              onTap: () {
                Navigator.pop(context);
                _markAsCompleted(schedule);
              },
            ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit'),
            onTap: () async {
              Navigator.pop(context);
              // ✅ NEW - Navigate to edit screen
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute<bool>(
                  builder: (context) => EditScheduleScreen(schedule: schedule),
                ),
              );
              // Reload schedules if edit was successful
              if (result == true && mounted) {
                await context.read<ScheduleProvider>().loadSchedulesForDate(_selectedDate);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Hapus', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _confirmDelete(schedule);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _markAsCompleted(ScheduleEntity schedule) async {
    final provider = context.read<ScheduleProvider>();
    final success = await provider.markAsCompleted(schedule.id);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success 
              ? 'Jadwal ditandai selesai' 
              : 'Gagal menandai jadwal',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmDelete(ScheduleEntity schedule) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Jadwal'),
        content: Text('Apakah Anda yakin ingin menghapus "${schedule.title}"?'),
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
      final provider = context.read<ScheduleProvider>();
      final success = await provider.deleteSchedule(schedule.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success 
                ? 'Jadwal berhasil dihapus' 
                : 'Gagal menghapus jadwal',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('id', 'ID'),
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
      });
      if (mounted) {
        await context.read<ScheduleProvider>().loadSchedulesForDate(picked);
      }
    }
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
    if (mounted) {
      context.read<ScheduleProvider>().loadSchedulesForDate(_selectedDate);
    }
  }

  Color _getCategoryColor(ScheduleCategory category) {
    switch (category) {
      case ScheduleCategory.feeding:
        return Colors.blue;
      case ScheduleCategory.sleep:
        return Colors.purple;
      case ScheduleCategory.health:
        return Colors.red;
      case ScheduleCategory.milestone:
        return Colors.green;
      case ScheduleCategory.other:
        return Colors.grey;
    }
  }

  String _getCategoryDisplayName(ScheduleCategory category) {
    switch (category) {
      case ScheduleCategory.feeding:
        return 'Pemberian Makan';
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
}