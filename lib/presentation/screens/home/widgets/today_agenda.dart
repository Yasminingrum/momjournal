import 'package:flutter/material.dart';

/// TodayAgenda
/// Widget displaying today's schedule items in a compact list format.
/// Shows upcoming tasks, appointments, and reminders for the current day.
///
/// Features:
/// - Time-based sorting
/// - Category color indicators
/// - Empty state
/// - Loading state
/// - Quick view of today's events
class TodayAgenda extends StatelessWidget {
  final List<AgendaItem> items;
  final bool isLoading;
  final VoidCallback? onSeeAll;
  final VoidCallback? onItemTap;

  const TodayAgenda({
    super.key,
    required this.items,
    this.isLoading = false,
    this.onSeeAll,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Agenda',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  child: const Text('See All'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Content
        if (isLoading)
          _buildLoadingState()
        else if (items.isEmpty)
          _buildEmptyState(context)
        else
          _buildAgendaList(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildLoadingItem(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingItem() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks for today!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enjoy your free time or add a new schedule',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgendaList() {
    // Sort by time
    final sortedItems = List<AgendaItem>.from(items)
      ..sort((a, b) => a.time.compareTo(b.time));

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedItems.length > 5 ? 5 : sortedItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = sortedItems[index];
        return AgendaItemCard(
          item: item,
          onTap: onItemTap,
        );
      },
    );
  }
}

/// AgendaItemCard
/// Individual card for agenda item
class AgendaItemCard extends StatelessWidget {
  final AgendaItem item;
  final VoidCallback? onTap;

  const AgendaItemCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isPast = item.time.isBefore(now);
    final isUpcoming = item.time.isAfter(now) && 
        item.time.difference(now).inMinutes <= 30;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isUpcoming
            ? BorderSide(color: item.categoryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Time indicator
              _buildTimeIndicator(context, isPast),
              const SizedBox(width: 12),
              // Category indicator
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: item.categoryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: isPast 
                                ? TextDecoration.lineThrough 
                                : null,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.category,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: item.categoryColor,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    if (item.notes != null && item.notes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.notes!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Status icon
              if (isPast)
                Icon(
                  Icons.check_circle,
                  color: Colors.grey[400],
                  size: 20,
                )
              else if (isUpcoming)
                Icon(
                  Icons.notifications_active,
                  color: item.categoryColor,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeIndicator(BuildContext context, bool isPast) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPast ? Colors.grey[200] : item.categoryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            _formatTime(item.time),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isPast ? Colors.grey[600] : item.categoryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            _getTimeOfDay(item.time),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isPast ? Colors.grey[500] : item.categoryColor,
                ),
          ),
        ],
      ),
    );
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

/// AgendaItem
/// Data model for agenda item
class AgendaItem {
  final String id;
  final String title;
  final String category;
  final Color categoryColor;
  final DateTime time;
  final String? notes;
  final bool hasReminder;

  const AgendaItem({
    required this.id,
    required this.title,
    required this.category,
    required this.categoryColor,
    required this.time,
    this.notes,
    this.hasReminder = false,
  });
}

/// TodayAgendaSummary
/// Compact summary bar showing count and next event
class TodayAgendaSummary extends StatelessWidget {
  final int totalTasks;
  final int completedTasks;
  final AgendaItem? nextTask;
  final VoidCallback? onTap;

  const TodayAgendaSummary({
    super.key,
    required this.totalTasks,
    required this.completedTasks,
    this.nextTask,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Progress indicator
              CircularProgressIndicator(
                value: totalTasks > 0 ? completedTasks / totalTasks : 0,
                backgroundColor: Colors.grey[200],
                color: Theme.of(context).primaryColor,
                strokeWidth: 3,
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$completedTasks of $totalTasks tasks completed',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (nextTask != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Next: ${nextTask!.title}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Arrow
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}