import 'package:flutter/material.dart';

/// ScheduleCard
/// Card widget for displaying individual schedule items in a list.
/// Shows time, title, category, and optional actions.
///
/// Features:
/// - Category color indicator
/// - Time display
/// - Reminder indicator
/// - Swipe actions (edit/delete)
/// - Completion checkbox
/// - Notes preview
class ScheduleCard extends StatelessWidget {

  const ScheduleCard({
    super.key,
    required this.id,
    required this.title,
    required this.dateTime,
    required this.category,
    required this.categoryColor,
    this.notes,
    this.hasReminder = false,
    this.isCompleted = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onCompletedChanged,
  });
  final String id;
  final String title;
  final DateTime dateTime;
  final String category;
  final Color categoryColor;
  final String? notes;
  final bool hasReminder;
  final bool isCompleted;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(bool?)? onCompletedChanged;

  @override
  Widget build(BuildContext context) {
    final isPast = dateTime.isBefore(DateTime.now());
    final isToday = _isToday(dateTime);
    final isUpcoming = dateTime.isAfter(DateTime.now()) &&
        dateTime.difference(DateTime.now()).inMinutes <= 60;

    return Dismissible(
      key: Key(id),
      background: _buildSwipeBackground(context, isLeft: true),
      secondaryBackground: _buildSwipeBackground(context, isLeft: false),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart && onDelete != null) {
          return _confirmDelete(context);
        } else if (direction == DismissDirection.startToEnd && onEdit != null) {
          onEdit!();
          return false;
        }
        return false;
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        elevation: isUpcoming ? 3 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isUpcoming
              ? BorderSide(color: categoryColor, width: 2)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Checkbox
                if (onCompletedChanged != null)
                  Checkbox(
                    value: isCompleted,
                    onChanged: onCompletedChanged,
                    activeColor: categoryColor,
                  ),
                // Category indicator
                Container(
                  width: 4,
                  height: 56,
                  decoration: BoxDecoration(
                    color: categoryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                // Time
                _buildTimeColumn(context, isPast),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: _buildContent(context, isPast),
                ),
                // Status icons
                _buildStatusIcons(context, isUpcoming),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeColumn(BuildContext context, bool isPast) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isPast
            ? Colors.grey[200]
            : categoryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            _formatTime(dateTime),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isPast ? Colors.grey[600] : categoryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            _getTimeOfDay(dateTime),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isPast ? Colors.grey[500] : categoryColor,
                ),
          ),
        ],
      ),
    );

  Widget _buildContent(BuildContext context, bool isPast) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                decoration: isCompleted
                    ? TextDecoration.lineThrough
                    : null,
                color: isPast && !isCompleted
                    ? Colors.grey[600]
                    : null,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        // Category
        Text(
          category,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: categoryColor,
                fontWeight: FontWeight.w500,
              ),
        ),
        // Notes preview
        if (notes != null && notes!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            notes!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );

  Widget _buildStatusIcons(BuildContext context, bool isUpcoming) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasReminder)
          Icon(
            isUpcoming
                ? Icons.notifications_active
                : Icons.notifications,
            color: isUpcoming ? categoryColor : Colors.grey[400],
            size: 20,
          ),
        if (isCompleted) ...[
          const SizedBox(height: 4),
          Icon(
            Icons.check_circle,
            color: categoryColor,
            size: 20,
          ),
        ],
      ],
    );

  Widget _buildSwipeBackground(BuildContext context, {required bool isLeft}) => Container(
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: isLeft ? Colors.blue : Colors.red,
      child: Icon(
        isLeft ? Icons.edit : Icons.delete,
        color: Colors.white,
        size: 28,
      ),
    );

  Future<bool> _confirmDelete(BuildContext context) async => await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Schedule'),
            content: const Text('Are you sure you want to delete this schedule?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getTimeOfDay(DateTime time) {
    if (time.hour < 12) return 'AM';
    return 'PM';
  }
}

/// ScheduleListSection
/// Grouped schedule list by date
class ScheduleListSection extends StatelessWidget {

  const ScheduleListSection({
    super.key,
    required this.date,
    required this.schedules,
    required this.onScheduleTap,
    required this.onScheduleEdit,
    required this.onScheduleDelete,
    required this.onCompletedChanged,
  });
  final DateTime date;
  final List<ScheduleCardData> schedules;
  final Function(String) onScheduleTap;
  final Function(String) onScheduleEdit;
  final Function(String) onScheduleDelete;
  final Function(String, bool) onCompletedChanged;

  @override
  Widget build(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            _formatDate(date),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _isToday(date)
                      ? Theme.of(context).primaryColor
                      : null,
                ),
          ),
        ),
        // Schedule cards
        ...schedules.map((schedule) => ScheduleCard(
              id: schedule.id,
              title: schedule.title,
              dateTime: schedule.dateTime,
              category: schedule.category,
              categoryColor: schedule.categoryColor,
              notes: schedule.notes,
              hasReminder: schedule.hasReminder,
              isCompleted: schedule.isCompleted,
              onTap: () => onScheduleTap(schedule.id),
              onEdit: () => onScheduleEdit(schedule.id),
              onDelete: () => onScheduleDelete(schedule.id),
              onCompletedChanged: (value) =>
                  onCompletedChanged(schedule.id, value ?? false),
            )),
      ],
    );

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today, ${_formatFullDate(date)}';
    } else if (dateOnly == tomorrow) {
      return 'Tomorrow, ${_formatFullDate(date)}';
    } else {
      return _formatFullDate(date);
    }
  }

  String _formatFullDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

/// ScheduleCardData
/// Data model for schedule card
class ScheduleCardData {

  const ScheduleCardData({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.category,
    required this.categoryColor,
    this.notes,
    this.hasReminder = false,
    this.isCompleted = false,
  });
  final String id;
  final String title;
  final DateTime dateTime;
  final String category;
  final Color categoryColor;
  final String? notes;
  final bool hasReminder;
  final bool isCompleted;
}