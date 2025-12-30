import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '/domain/entities/schedule_entity.dart';
import '/presentation/providers/category_provider.dart';
import '/presentation/providers/schedule_provider.dart';
import 'add_schedule_screen.dart';
import 'manage_categories_screen.dart';
import 'schedule_detail_screen.dart';

/// Schedule Screen with List, Month, Week, and Day views
/// FIXED VERSION - Multi-day schedule synchronized across all views
/// Location: lib/presentation/screens/schedule/schedule_screen.dart
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // View state
  int _selectedViewIndex = 0; // 0=List, 1=Month, 2=Week, 3=Day
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  final CalendarFormat _calendarFormat = CalendarFormat.month;

  final List<String> _viewTabs = ['List', 'Month', 'Week', 'Day'];

  // Filter states
  String? _filterCategory;
  bool _showOnlyCompleted = false;
  bool _showOnlyIncomplete = false;
  bool _showFilterPanel = false;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    final scheduleProvider = context.read<ScheduleProvider>();
    await scheduleProvider.loadSchedulesForMonth(
      _focusedDay.year,
      _focusedDay.month,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme),
      body: Column(
        children: [
          _buildViewSelector(),
          const SizedBox(height: 16),
          Expanded(
            child: _buildSelectedView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddSchedule,
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    String title = '';
    switch (_selectedViewIndex) {
      case 0:
        title = '${_selectedDay.day} ${_getMonthName(_selectedDay.month).toUpperCase()}';
        break;
      case 1:
        title = _getMonthName(_focusedDay.month).toUpperCase();
        break;
      case 2:
        title = 'WEEK ${_getWeekNumber(_selectedDay)}';
        break;
      case 3:
        title = '${_selectedDay.day} ${_getMonthName(_selectedDay.month).toUpperCase()}';
        break;
    }

    return AppBar(
      elevation: 0,
      centerTitle: true,
      actions: [
        // Category button in all views
        IconButton(
          icon: const Icon(Icons.category),
          onPressed: _navigateToManageCategories,
          tooltip: 'Kelola Kategori',
        ),
      ],
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Left Navigation - List View (Day)
          if (_selectedViewIndex == 0) ...[
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  _selectedDay = _selectedDay.subtract(const Duration(days: 1));
                });
              },
              tooltip: 'Hari Sebelumnya',
            ),
          ],
          
          // Left Navigation - Month View
          if (_selectedViewIndex == 1) ...[
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  _focusedDay = DateTime(
                    _focusedDay.year,
                    _focusedDay.month - 1,
                  );
                });
                _loadSchedules();
              },
              tooltip: 'Bulan Sebelumnya',
            ),
          ],
          
          // Left Navigation - Week View
          if (_selectedViewIndex == 2) ...[
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  _selectedDay = _selectedDay.subtract(const Duration(days: 7));
                });
              },
              tooltip: 'Minggu Sebelumnya',
            ),
          ],
          
          // Left Navigation - Day View
          if (_selectedViewIndex == 3) ...[
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  _selectedDay = _selectedDay.subtract(const Duration(days: 1));
                });
              },
              tooltip: 'Hari Sebelumnya',
            ),
          ],
          
          // Title
          Text(title),
          
          // Right Navigation - List View (Day)
          if (_selectedViewIndex == 0) ...[
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  _selectedDay = _selectedDay.add(const Duration(days: 1));
                });
              },
              tooltip: 'Hari Berikutnya',
            ),
          ],
          
          // Right Navigation - Month View
          if (_selectedViewIndex == 1) ...[
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  _focusedDay = DateTime(
                    _focusedDay.year,
                    _focusedDay.month + 1,
                  );
                });
                _loadSchedules();
              },
              tooltip: 'Bulan Berikutnya',
            ),
          ],
          
          // Right Navigation - Week View
          if (_selectedViewIndex == 2) ...[
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  _selectedDay = _selectedDay.add(const Duration(days: 7));
                });
              },
              tooltip: 'Minggu Berikutnya',
            ),
          ],
          
          // Right Navigation - Day View
          if (_selectedViewIndex == 3) ...[
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  _selectedDay = _selectedDay.add(const Duration(days: 1));
                });
              },
              tooltip: 'Hari Berikutnya',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildViewSelector() {
    final theme = Theme.of(context);
    
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: List.generate(_viewTabs.length, (index) => Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedViewIndex = index),
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedViewIndex == index
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    _viewTabs[index],
                    style: TextStyle(
                      color: _selectedViewIndex == index
                          ? Colors.white
                          : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),),
      ),
    );
  }

  Widget _buildSelectedView() {
    switch (_selectedViewIndex) {
      case 0:
        return _buildListView();
      case 1:
        return _buildMonthView();
      case 2:
        return _buildWeekView();
      case 3:
        return _buildDayView();
      default:
        return _buildListView();
    }
  }

  // ✅ FIXED: List View dengan multi-day schedule support
  Widget _buildListView() {
    final theme = Theme.of(context);
    final schedules = _getFilteredListSchedules();
    final activeFilters = _getActiveFilterCount();
    
    return Column(
      children: [
        // Filter bar
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => setState(() => _showFilterPanel = !_showFilterPanel),
                icon: Icon(
                  _showFilterPanel ? Icons.filter_list_off : Icons.filter_list,
                  size: 18,
                ),
                label: Text(
                  activeFilters > 0 ? 'Filter ($activeFilters)' : 'Filter',
                  style: const TextStyle(fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: activeFilters > 0 
                      ? theme.colorScheme.primaryContainer
                      : null,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              
              if (activeFilters > 0) ...[
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _clearAllFilters,
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('Clear', style: TextStyle(fontSize: 13)),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              ],
              
              const Spacer(),
              
              Text(
                '${schedules.length} jadwal',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        
        // Filter panel
        if (_showFilterPanel) _buildFilterOptionsPanel(),
        
        // Schedule list
        Expanded(
          child: schedules.isEmpty
              ? _buildEmptyState(activeFilters > 0)
              : RefreshIndicator(
                  onRefresh: _loadSchedules,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: schedules.length,
                    itemBuilder: (context, index) => _buildScheduleListItem(schedules[index]),
                  ),
                ),
        ),
      ],
    );
  }

  // ✅ Month View (sudah benar)
  Widget _buildMonthView() {
    final scheduleProvider = context.watch<ScheduleProvider>();
    final schedules = scheduleProvider.schedules;

    final selectedDaySchedules = schedules.where((schedule) {
      final selectedDayNormalized = DateTime(
        _selectedDay.year,
        _selectedDay.month,
        _selectedDay.day,
      );
      
      final scheduleDateNormalized = DateTime(
        schedule.dateTime.year,
        schedule.dateTime.month,
        schedule.dateTime.day,
      );
      
      if (schedule.isMultiDay && schedule.endDateTime != null) {
        final endDateNormalized = DateTime(
          schedule.endDateTime!.year,
          schedule.endDateTime!.month,
          schedule.endDateTime!.day,
        );
        
        return !selectedDayNormalized.isBefore(scheduleDateNormalized) &&
               !selectedDayNormalized.isAfter(endDateNormalized);
      }
      
      return isSameDay(schedule.dateTime, _selectedDay);
    }).toList();

    return Column(
      children: [
        _buildCalendar(schedules),
        const SizedBox(height: 8),
        Expanded(
          child: _buildSelectedDaySchedules(selectedDaySchedules),
        ),
      ],
    );
  }

  // ✅ FIXED: Week View dengan multi-day schedule support
  Widget _buildWeekView() => SingleChildScrollView(
      child: Column(
        children: [
          _buildWeekSelector(),
          const SizedBox(height: 16),
          _buildWeekTimeline(),
        ],
      ),
    );

  // ✅ FIXED: Day View dengan multi-day schedule support
  Widget _buildDayView() => Column(
      children: [
        _buildDaySelector(),
        const SizedBox(height: 8),
        Expanded(child: _buildDayTimeline()),
      ],
    );

  Widget _buildCalendar(List<ScheduleEntity> schedules) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: _calendarFormat,
        startingDayOfWeek: StartingDayOfWeek.monday,
        headerVisible: false,
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: theme.colorScheme.secondary.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: _getRandomEventColor(),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        eventLoader: (day) {
          final dayNormalized = DateTime(day.year, day.month, day.day);
          
          return schedules.where((schedule) {
            final scheduleDateNormalized = DateTime(
              schedule.dateTime.year,
              schedule.dateTime.month,
              schedule.dateTime.day,
            );
            
            if (schedule.isMultiDay && schedule.endDateTime != null) {
              final endDateNormalized = DateTime(
                schedule.endDateTime!.year,
                schedule.endDateTime!.month,
                schedule.endDateTime!.day,
              );
              
              return !dayNormalized.isBefore(scheduleDateNormalized) &&
                     !dayNormalized.isAfter(endDateNormalized);
            }
            
            return isSameDay(schedule.dateTime, day);
          }).toList();
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
          _loadSchedules();
        },
      ),
    );
  }

  Widget _buildWeekSelector() {
    final theme = Theme.of(context);
    final currentWeekStart = _getWeekStart(_selectedDay);
    final weekDates = List.generate(3, (i) => currentWeekStart.add(Duration(days: i * 7)));

    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weekDates.length,
        itemBuilder: (context, index) {
          final weekStart = weekDates[index];
          final weekEnd = weekStart.add(const Duration(days: 6));
          final isSelected = _isSameWeek(_selectedDay, weekStart);

          return GestureDetector(
            onTap: () => setState(() => _selectedDay = weekStart),
            child: Container(
              width: 120,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Week ${_getWeekNumber(weekStart)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${weekStart.day} - ${weekEnd.day}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    _getMonthName(weekStart.month),
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ✅ FIXED: Week timeline dengan multi-day schedule support
  Widget _buildWeekTimeline() {
    final scheduleProvider = context.watch<ScheduleProvider>();
    final schedules = scheduleProvider.schedules;
    final weekStart = _getWeekStart(_selectedDay);
    
    return Column(
      children: List.generate(7, (index) {
        final day = weekStart.add(Duration(days: index));
        
        // ✅ FIX: Filter dengan mempertimbangkan multi-day schedule
        final daySchedules = schedules.where((s) {
          final dayNormalized = DateTime(day.year, day.month, day.day);
          final scheduleDateNormalized = DateTime(
            s.dateTime.year,
            s.dateTime.month,
            s.dateTime.day,
          );
          
          if (s.isMultiDay && s.endDateTime != null) {
            final endDateNormalized = DateTime(
              s.endDateTime!.year,
              s.endDateTime!.month,
              s.endDateTime!.day,
            );
            
            return !dayNormalized.isBefore(scheduleDateNormalized) &&
                   !dayNormalized.isAfter(endDateNormalized);
          }
          
          return isSameDay(s.dateTime, day);
        }).toList();
        
        return _buildWeekDayCard(day, daySchedules);
      }),
    );
  }

  Widget _buildWeekDayCard(DateTime day, List<ScheduleEntity> schedules) {
    final theme = Theme.of(context);
    final isToday = isSameDay(day, DateTime.now());
    final isSelected = isSameDay(day, _selectedDay);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? theme.colorScheme.primaryContainer : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withValues(alpha: 0.2),
          width: isToday ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedDay = day),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Column(
                    children: [
                      Text(
                        _getDayName(day.weekday),
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isToday ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: schedules.isEmpty
                      ? Text(
                          'Tidak ada jadwal',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        )
                      : Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: schedules.take(3).map(_buildWeekScheduleItem).toList(),
                        ),
                ),
                if (schedules.length > 3)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '+${schedules.length - 3}',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeekScheduleItem(ScheduleEntity schedule) {
    final theme = Theme.of(context);
    final color = _getCategoryColor(schedule.category);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ Tampilkan indikator multi-day
          if (schedule.isMultiDay)
            Icon(
              Icons.date_range,
              size: 12,
              color: color,
            )
          else
            Text(
              _formatTime(schedule.dateTime),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          const SizedBox(width: 4),
          Icon(
            _getCategoryIcon(schedule.category),
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Container(
            constraints: const BoxConstraints(maxWidth: 60),
            child: Text(
              schedule.title,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    final theme = Theme.of(context);
    final centerDate = _selectedDay;
    
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        itemBuilder: (context, index) {
          final date = centerDate.subtract(Duration(days: 7 - index));
          final isSelected = isSameDay(date, _selectedDay);
          final isToday = isSameDay(date, DateTime.now());
          
          return GestureDetector(
            onTap: () => setState(() => _selectedDay = date),
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isToday
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withValues(alpha: 0.2),
                  width: isToday ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getDayName(date.weekday).substring(0, 3),
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    _getMonthName(date.month).substring(0, 3),
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ✅ FIXED: Day timeline dengan multi-day schedule support
  Widget _buildDayTimeline() {
    final scheduleProvider = context.watch<ScheduleProvider>();
    final schedules = scheduleProvider.schedules;
    
    // ✅ FIX: Pisahkan multi-day dan single-day schedules
    final dayNormalized = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
    );
    
    final multiDaySchedules = schedules.where((s) {
      if (!s.isMultiDay || s.endDateTime == null) {
        return false;
      }
      
      final scheduleDateNormalized = DateTime(
        s.dateTime.year,
        s.dateTime.month,
        s.dateTime.day,
      );
      final endDateNormalized = DateTime(
        s.endDateTime!.year,
        s.endDateTime!.month,
        s.endDateTime!.day,
      );
      
      return !dayNormalized.isBefore(scheduleDateNormalized) &&
             !dayNormalized.isAfter(endDateNormalized);
    }).toList();

    return Column(
      children: [
        // ✅ Tampilkan multi-day schedules di atas timeline
        if (multiDaySchedules.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jadwal Multi-Hari',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                ...multiDaySchedules.map(_buildMultiDayScheduleCard),
              ],
            ),
          ),
          const Divider(height: 1),
        ],
        
        // Timeline untuk single-day schedules
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 24,
            itemBuilder: (context, hour) {
              final hourSchedules = schedules.where((s) {
                // Hanya tampilkan single-day schedules di timeline
                if (s.isMultiDay) {
                  return false;
                }
                return s.dateTime.hour == hour && isSameDay(s.dateTime, _selectedDay);
              }).toList();

              return _buildHourRow(hour, hourSchedules);
            },
          ),
        ),
      ],
    );
  }

  // ✅ NEW: Widget untuk multi-day schedule card
  Widget _buildMultiDayScheduleCard(ScheduleEntity schedule) {
    final theme = Theme.of(context);
    final color = _getCategoryColor(schedule.category);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          Checkbox(
            value: schedule.isCompleted,
            onChanged: (value) => _handleToggleComplete(schedule.id, schedule.isCompleted),
            activeColor: color,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 8),
          
          Icon(
            _getCategoryIcon(schedule.category),
            color: color,
            size: 24,
          ),
          const SizedBox(width: 12),
          
          Expanded(
            child: GestureDetector(
              onTap: () => _navigateToDetail(schedule),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schedule.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: theme.colorScheme.onSurface,
                      decoration: schedule.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.date_range, size: 14, color: color),
                      const SizedBox(width: 4),
                      Text(
                        '${_formatDate(schedule.dateTime)} - ${_formatDate(schedule.endDateTime!)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourRow(int hour, List<ScheduleEntity> schedules) {
    final theme = Theme.of(context);
    final timeLabel = hour == 0
        ? '12:00 AM'
        : hour < 12
            ? '${hour.toString().padLeft(2, '0')}:00 AM'
            : hour == 12
                ? '12:00 PM'
                : '${(hour - 12).toString().padLeft(2, '0')}:00 PM';

    return Container(
      height: 80,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              timeLabel,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
          Expanded(
            child: schedules.isEmpty
                ? const SizedBox.shrink()
                : Column(
                    children: schedules.map(_buildDayScheduleCard).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayScheduleCard(ScheduleEntity schedule) {
    final theme = Theme.of(context);
    final color = _getCategoryColor(schedule.category);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 4, right: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          Checkbox(
            value: schedule.isCompleted,
            onChanged: (value) => _handleToggleComplete(schedule.id, schedule.isCompleted),
            activeColor: color,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 4),
          
          Expanded(
            child: GestureDetector(
              onTap: () => _navigateToDetail(schedule),
              child: Text(
                schedule.title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: theme.colorScheme.onSurface,
                  decoration: schedule.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          
          if (schedule.hasReminder)
            Icon(
              Icons.notifications,
              size: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
        ],
      ),
    );
  }

  Widget _buildScheduleListItem(ScheduleEntity schedule) {
    final theme = Theme.of(context);
    final color = _getCategoryColor(schedule.category);
    final now = DateTime.now();
    final isPast = schedule.dateTime.isBefore(now);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(schedule),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Checkbox(
                value: schedule.isCompleted,
                onChanged: (value) => _handleToggleComplete(schedule.id, schedule.isCompleted),
                activeColor: color,
              ),
              
              // ✅ Tampilkan info berbeda untuk multi-day
              if (schedule.isMultiDay && schedule.endDateTime != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: color, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getCategoryIcon(schedule.category),
                                  size: 14,
                                  color: color,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    schedule.category,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: color,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.date_range,
                                  size: 12,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Multi-hari',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        schedule.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                          decoration: schedule.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatDate(schedule.dateTime)} - ${_formatDate(schedule.endDateTime!)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      if (schedule.notes != null && schedule.notes!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          schedule.notes!,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                )
              else
                Container(
                  width: 60,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: isPast
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.1)
                        : color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        schedule.dateTime.hour == 0
                            ? '12'
                            : schedule.dateTime.hour > 12
                                ? '${schedule.dateTime.hour - 12}'
                                : '${schedule.dateTime.hour}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isPast
                              ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                              : color,
                        ),
                      ),
                      Text(
                        schedule.dateTime.minute.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: 12,
                          color: isPast
                              ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                              : color,
                        ),
                      ),
                      Text(
                        schedule.dateTime.hour >= 12 ? 'PM' : 'AM',
                        style: TextStyle(
                          fontSize: 10,
                          color: isPast
                              ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                              : color.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(width: 12),
              
              if (!schedule.isMultiDay)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: color, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getCategoryIcon(schedule.category),
                                  size: 14,
                                  color: color,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    schedule.category,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: color,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        schedule.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                          decoration: schedule.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (schedule.notes != null && schedule.notes!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          schedule.notes!,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (schedule.hasReminder)
                    Icon(
                      Icons.notifications_active,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                  if (isPast && !schedule.isCompleted) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Terlewat',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDaySchedules(List<ScheduleEntity> schedules) {
    final theme = Theme.of(context);
    
    if (schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada jadwal',
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }
    
    schedules.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: schedules.length,
      itemBuilder: (context, index) => _buildScheduleListItem(schedules[index]),
    );
  }

  Widget _buildFilterOptionsPanel() {
    final theme = Theme.of(context);
    final categoryProvider = context.watch<CategoryProvider>();
    final categories = categoryProvider.categories;
    
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Berdasarkan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          
          // Category filter
          Text(
            'Kategori:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Semua', style: TextStyle(fontSize: 12)),
                selected: _filterCategory == null,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _filterCategory = null);
                  }
                },
              ),
              ...categories.map((cat) => ChoiceChip(
                  label: Text(cat.name, style: const TextStyle(fontSize: 12)),
                  selected: _filterCategory == cat.name,
                  onSelected: (selected) {
                    setState(() {
                      _filterCategory = selected ? cat.name : null;
                    });
                  },
                ),),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Status filter
          Text(
            'Status:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            title: const Text('Hanya Selesai', style: TextStyle(fontSize: 13)),
            value: _showOnlyCompleted,
            onChanged: (value) {
              setState(() {
                _showOnlyCompleted = value ?? false;
                if (value ?? false) {
                  _showOnlyIncomplete = false;
                }
              });
            },
            dense: true,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            title: const Text('Hanya Belum Selesai', style: TextStyle(fontSize: 13)),
            value: _showOnlyIncomplete,
            onChanged: (value) {
              setState(() {
                _showOnlyIncomplete = value ?? false;
                if (value ?? false) {
                  _showOnlyCompleted = false;
                }
              });
            },
            dense: true,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool hasActiveFilters) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasActiveFilters ? Icons.filter_alt_off : Icons.event_busy,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            hasActiveFilters 
                ? 'Tidak ada jadwal sesuai filter'
                : 'Tidak ada jadwal',
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          if (hasActiveFilters) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: _clearAllFilters,
              child: const Text('Hapus Filter'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _navigateToAddSchedule() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute<bool>(
        builder: (context) => const AddScheduleScreen(),
      ),
    );
    
    if ((result ?? false) && mounted) {
      await _loadSchedules();
    }
  }

  Future<void> _navigateToDetail(ScheduleEntity schedule) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute<bool>(
        builder: (context) => ScheduleDetailScreen(schedule: schedule),
      ),
    );
    
    if ((result ?? false) && mounted) {
      await _loadSchedules();
    }
  }

  Future<void> _navigateToManageCategories() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const ManageCategoriesScreen(),
      ),
    );
  }

  Future<void> _handleToggleComplete(String scheduleId, bool wasCompleted) async {
    final scheduleProvider = context.read<ScheduleProvider>();
    
    final success = await scheduleProvider.toggleScheduleCompletion(scheduleId);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                wasCompleted ? Icons.replay : Icons.check_circle_outline,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  wasCompleted 
                      ? 'Ditandai belum selesai' 
                      : 'Ditandai selesai ✓',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: wasCompleted 
              ? const Color(0xFFFF9800)
              : const Color(0xFF4CAF50),
          duration: const Duration(milliseconds: 2000),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 6,
        ),
      );
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 22),
              SizedBox(width: 12),
              Text(
                'Gagal mengubah status jadwal',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          backgroundColor: Colors.red[700],
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  // ✅ FIXED: Filter untuk List View dengan multi-day support
  List<ScheduleEntity> _getFilteredListSchedules() {
    final scheduleProvider = context.watch<ScheduleProvider>();
    
    // ✅ FIX: Gunakan logika yang sama dengan Month View
    var schedules = scheduleProvider.schedules.where((s) {
      final selectedDayNormalized = DateTime(
        _selectedDay.year,
        _selectedDay.month,
        _selectedDay.day,
      );
      
      final scheduleDateNormalized = DateTime(
        s.dateTime.year,
        s.dateTime.month,
        s.dateTime.day,
      );
      
      if (s.isMultiDay && s.endDateTime != null) {
        final endDateNormalized = DateTime(
          s.endDateTime!.year,
          s.endDateTime!.month,
          s.endDateTime!.day,
        );
        
        return !selectedDayNormalized.isBefore(scheduleDateNormalized) &&
               !selectedDayNormalized.isAfter(endDateNormalized);
      }
      
      return isSameDay(s.dateTime, _selectedDay);
    }).toList();
    
    if (_filterCategory != null) {
      schedules = schedules.where((s) => s.category == _filterCategory).toList();
    }
    
    if (_showOnlyCompleted && !_showOnlyIncomplete) {
      schedules = schedules.where((s) => s.isCompleted).toList();
    } else if (_showOnlyIncomplete && !_showOnlyCompleted) {
      schedules = schedules.where((s) => !s.isCompleted).toList();
    }
    
    schedules.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    
    return schedules;
  }

  void _clearAllFilters() {
    setState(() {
      _filterCategory = null;
      _showOnlyCompleted = false;
      _showOnlyIncomplete = false;
    });
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_filterCategory != null) {
      count++;
    }
    if (_showOnlyCompleted) {
      count++;
    }
    if (_showOnlyIncomplete) {
      count++;
    }
    return count;
  }

  // Helper methods
  Color _getCategoryColor(String category) {
    try {
      final categoryProvider = context.read<CategoryProvider>();
      final categoryEntity = categoryProvider.getCategoryByName(category);
      
      if (categoryEntity != null) {
        return _parseColor(categoryEntity.colorHex);
      }
    } catch (e) {
      // Provider not available
    }
    
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
    try {
      final categoryProvider = context.read<CategoryProvider>();
      final categoryEntity = categoryProvider.getCategoryByName(category);
      
      if (categoryEntity != null) {
        return _parseIconData(categoryEntity.icon);
      }
    } catch (e) {
      // Provider not available
    }
    
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

  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      final colorHex = hex.length == 6 ? 'FF$hex' : hex;
      return Color(int.parse('0x$colorHex'));
    } catch (e) {
      return Colors.grey;
    }
  }

  IconData _parseIconData(String iconName) {
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

  String _getMonthName(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return months[month - 1];
  }

  String _getDayName(int weekday) {
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return days[weekday - 1];
  }

  String _formatDate(DateTime date) => '${date.day} ${_getMonthName(date.month)} ${date.year}';

  String _formatTime(DateTime time) {
    final hour = time.hour == 0 ? 12 : time.hour > 12 ? time.hour - 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  bool _isSameWeek(DateTime date1, DateTime date2) {
    final week1Start = _getWeekStart(date1);
    final week2Start = _getWeekStart(date2);
    return isSameDay(week1Start, week2Start);
  }

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return (daysSinceFirstDay / 7).ceil() + 1;
  }

  Color _getRandomEventColor() {
    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.green,
    ];
    return colors[DateTime.now().millisecond % colors.length];
  }
}