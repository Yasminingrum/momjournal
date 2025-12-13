// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';

/// JournalCard
/// Card widget for displaying journal entries in a list.
/// Shows date, mood, preview text, and provides actions.
///
/// Features:
/// - Mood indicator
/// - Text preview (truncated)
/// - Date/time display
/// - Swipe actions (edit/delete)
/// - Tap to read full entry
/// - Visual mood color
class JournalCard extends StatelessWidget {

  const JournalCard({
    required this.id, required this.date, required this.mood, required this.content, super.key,
    this.maxPreviewLines = 3,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });
  final String id;
  final DateTime date;
  final MoodLevel mood;
  final String content;
  final int maxPreviewLines;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => Dismissible(
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
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: mood.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (date + mood)
                Row(
                  children: [
                    // Date
                    Expanded(
                      child: Text(
                        _formatDate(date),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                      ),
                    ),
                    // Mood indicator
                    _buildMoodIndicator(),
                  ],
                ),
                const SizedBox(height: 12),
                // Content preview
                Text(
                  content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                  maxLines: maxPreviewLines,
                  overflow: TextOverflow.ellipsis,
                ),
                // Read more indicator
                if (content.length > 100) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Read more...',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: mood.color,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

  Widget _buildMoodIndicator() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: mood.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: mood.color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            mood.emoji,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 6),
          Text(
            mood.label,
            style: TextStyle(
              color: mood.color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );

  Widget _buildSwipeBackground(BuildContext context, {required bool isLeft}) => Container(
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isLeft ? Colors.blue : Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isLeft ? Icons.edit : Icons.delete,
        color: Colors.white,
        size: 28,
      ),
    );

  Future<bool> _confirmDelete(BuildContext context) async => await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Journal Entry'),
            content: const Text(
              'Are you sure you want to delete this journal entry? This action cannot be undone.',
            ),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today, ${_formatTime(date)}';
    } else if (dateOnly == yesterday) {
      return 'Yesterday, ${_formatTime(date)}';
    } else {
      return _formatFullDate(date);
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _formatFullDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

/// MoodLevel (same as in mood_selector.dart)
enum MoodLevel {
  verySad(
    emoji: '😢',
    label: 'Very Sad',
    color: Color(0xFFE53935),
    value: 1,
  ),
  sad(
    emoji: '😔',
    label: 'Sad',
    color: Color(0xFFFF9800),
    value: 2,
  ),
  neutral(
    emoji: '😐',
    label: 'Neutral',
    color: Color(0xFF9E9E9E),
    value: 3,
  ),
  happy(
    emoji: '😊',
    label: 'Happy',
    color: Color(0xFF66BB6A),
    value: 4,
  ),
  veryHappy(
    emoji: '😄',
    label: 'Very Happy',
    color: Color(0xFF4CAF50),
    value: 5,
  );

  final String emoji;
  final String label;
  final Color color;
  final int value;

  const MoodLevel({
    required this.emoji,
    required this.label,
    required this.color,
    required this.value,
  });
}

/// JournalListSection
/// Grouped journal list by month
class JournalListSection extends StatelessWidget {

  const JournalListSection({
    required this.monthYear, required this.journals, required this.onJournalTap, required this.onJournalEdit, required this.onJournalDelete, super.key,
  });
  final String monthYear;
  final List<JournalCardData> journals;
  final Function(String) onJournalTap;
  final Function(String) onJournalEdit;
  final Function(String) onJournalDelete;

  @override
  Widget build(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            monthYear,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        // Journal cards
        ...journals.map((journal) => JournalCard(
              id: journal.id,
              date: journal.date,
              mood: journal.mood,
              content: journal.content,
              onTap: () => onJournalTap(journal.id),
              onEdit: () => onJournalEdit(journal.id),
              onDelete: () => onJournalDelete(journal.id),
            ),),
      ],
    );
}

/// JournalCardData
/// Data model for journal card
class JournalCardData {

  const JournalCardData({
    required this.id,
    required this.date,
    required this.mood,
    required this.content,
  });
  final String id;
  final DateTime date;
  final MoodLevel mood;
  final String content;
}

/// CompactJournalCard
/// Smaller journal card for dashboard/preview
class CompactJournalCard extends StatelessWidget {

  const CompactJournalCard({
    required this.date, required this.mood, required this.content, super.key,
    this.onTap,
  });
  final DateTime date;
  final MoodLevel mood;
  final String content;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Mood emoji
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: mood.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  mood.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(date),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}';
    }
  }
}