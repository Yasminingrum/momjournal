import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

/// CalendarWidget
/// Interactive month calendar widget for schedule viewing and navigation.
/// Uses table_calendar package for rendering.
///
/// Features:
/// - Month/week view switching
/// - Event markers (colored dots)
/// - Selected date highlighting
/// - Swipe navigation between months
/// - Today indicator
/// - Category-based event coloring
class CalendarWidget extends StatefulWidget {

  const CalendarWidget({
    super.key,
    required this.focusedDay,
    this.selectedDay,
    required this.events,
    required this.onDaySelected,
    required this.onPageChanged,
    this.initialFormat = CalendarFormat.month,
  });
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Map<DateTime, List<CalendarEvent>> events;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;
  final CalendarFormat initialFormat;

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late CalendarFormat _calendarFormat;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _calendarFormat = widget.initialFormat;
    _selectedDay = widget.selectedDay;
  }

  @override
  Widget build(BuildContext context) => Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: widget.focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
            });
            widget.onDaySelected(selectedDay, focusedDay);
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: widget.onPageChanged,
          eventLoader: (day) {
            return widget.events[_normalizeDate(day)] ?? [];
          },
          // Styling
          calendarStyle: CalendarStyle(
            // Today
            todayDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
            // Selected day
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            // Weekend
            weekendTextStyle: TextStyle(
              color: Colors.red[400],
            ),
            // Outside days
            outsideDaysVisible: false,
            // Markers
            markerDecoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            markerSize: 7,
            markersMaxCount: 3,
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            formatButtonShowsNext: false,
            formatButtonDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            formatButtonTextStyle: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
            ),
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: Theme.of(context).primaryColor,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: Theme.of(context).primaryColor,
            ),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
            weekendStyle: TextStyle(
              color: Colors.red[400],
              fontWeight: FontWeight.w600,
            ),
          ),
          // Builders
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isEmpty) return const SizedBox.shrink();

              // Get unique category colors
              final eventList = events.cast<CalendarEvent>();
              final colors = eventList
                  .map((e) => e.categoryColor)
                  .toSet()
                  .take(3)
                  .toList();

              return Positioned(
                bottom: 1,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: colors.map((color) {
                    return Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ),
    );

  DateTime _normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);
}

/// CalendarEvent
/// Model for calendar event markers
class CalendarEvent {

  const CalendarEvent({
    required this.id,
    required this.title,
    required this.categoryColor,
    required this.time,
  });
  final String id;
  final String title;
  final Color categoryColor;
  final DateTime time;
}

/// CalendarLegend
/// Legend showing category colors
class CalendarLegend extends StatelessWidget {

  const CalendarLegend({
    super.key,
    required this.categories,
  });
  final List<CalendarCategory> categories;

  @override
  Widget build(BuildContext context) => Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 12,
          runSpacing: 8,
          children: categories.map((category) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: category.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  category.name,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
}

/// CalendarCategory
/// Model for calendar category
class CalendarCategory {

  const CalendarCategory({
    required this.name,
    required this.color,
    this.count = 0,
  });
  final String name;
  final Color color;
  final int count;
}

/// CompactCalendar
/// Smaller calendar widget for quick date picking
class CompactCalendar extends StatelessWidget {

  const CompactCalendar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.minDate,
    this.maxDate,
  });
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final DateTime? minDate;
  final DateTime? maxDate;

  @override
  Widget build(BuildContext context) => TableCalendar(
      firstDay: minDate ?? DateTime.utc(2020, 1, 1),
      lastDay: maxDate ?? DateTime.utc(2030, 12, 31),
      focusedDay: selectedDate,
      calendarFormat: CalendarFormat.month,
      selectedDayPredicate: (day) => isSameDay(selectedDate, day),
      onDaySelected: (selectedDay, focusedDay) {
        onDateSelected(selectedDay);
      },
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        leftChevronIcon: const Icon(Icons.chevron_left),
        rightChevronIcon: const Icon(Icons.chevron_right),
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
        ),
        outsideDaysVisible: false,
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(fontWeight: FontWeight.w600),
        weekendStyle: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
}