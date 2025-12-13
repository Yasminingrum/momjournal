import 'package:flutter/material.dart';

/// QuickActionButton
/// Circular action button with icon and label for quick access to common actions.
/// Used on the home screen for quick navigation to add screens.
///
/// Features:
/// - Circular design with icon
/// - Label below icon
/// - Customizable colors
/// - Ripple effect on tap
/// - Disabled state
class QuickActionButton extends StatelessWidget {

  const QuickActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.enabled = true,
    this.size = 64,
  });
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool enabled;
  final double size;

  @override
  Widget build(BuildContext context) => Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular button
          Material(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(size / 2),
            child: InkWell(
              onTap: enabled ? onTap : null,
              borderRadius: BorderRadius.circular(size / 2),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: size * 0.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Label
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: enabled ? color : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
}

/// QuickActionsGrid
/// Grid layout of quick action buttons
class QuickActionsGrid extends StatelessWidget {

  const QuickActionsGrid({
    super.key,
    required this.actions,
    this.crossAxisCount = 3,
    this.spacing = 16,
  });
  final List<QuickActionItem> actions;
  final int crossAxisCount;
  final double spacing;

  @override
  Widget build(BuildContext context) => GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 1.0,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return QuickActionButton(
          label: action.label,
          icon: action.icon,
          color: action.color,
          onTap: action.onTap,
          enabled: action.enabled,
        );
      },
    );
}

/// QuickActionItem
/// Data model for quick action button
class QuickActionItem {

  const QuickActionItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.enabled = true,
  });
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool enabled;
}

/// Predefined quick actions for common use cases
class QuickActions {
  /// Add Schedule action
  static QuickActionItem addSchedule(VoidCallback onTap) => QuickActionItem(
      label: 'Add Schedule',
      icon: Icons.event_note,
      color: const Color(0xFF2196F3),
      onTap: onTap,
    );

  /// Write Journal action
  static QuickActionItem writeJournal(VoidCallback onTap) => QuickActionItem(
      label: 'Write Journal',
      icon: Icons.edit_note,
      color: const Color(0xFFFF9800),
      onTap: onTap,
    );

  /// Add Photo action
  static QuickActionItem addPhoto(VoidCallback onTap) => QuickActionItem(
      label: 'Add Photo',
      icon: Icons.add_a_photo,
      color: const Color(0xFF9C27B0),
      onTap: onTap,
    );

  /// View Schedule action
  static QuickActionItem viewSchedule(VoidCallback onTap) => QuickActionItem(
      label: 'View Schedule',
      icon: Icons.calendar_today,
      color: const Color(0xFF2196F3),
      onTap: onTap,
    );

  /// View Journal action
  static QuickActionItem viewJournal(VoidCallback onTap) => QuickActionItem(
      label: 'View Journal',
      icon: Icons.book,
      color: const Color(0xFFFF9800),
      onTap: onTap,
    );

  /// View Gallery action
  static QuickActionItem viewGallery(VoidCallback onTap) => QuickActionItem(
      label: 'View Gallery',
      icon: Icons.photo_library,
      color: const Color(0xFF9C27B0),
      onTap: onTap,
    );

  /// Set Reminder action
  static QuickActionItem setReminder(VoidCallback onTap) => QuickActionItem(
      label: 'Set Reminder',
      icon: Icons.notification_add,
      color: const Color(0xFFF44336),
      onTap: onTap,
    );

  /// Track Mood action
  static QuickActionItem trackMood(VoidCallback onTap) => QuickActionItem(
      label: 'Track Mood',
      icon: Icons.mood,
      color: const Color(0xFFFFC107),
      onTap: onTap,
    );

  /// Add Milestone action
  static QuickActionItem addMilestone(VoidCallback onTap) => QuickActionItem(
      label: 'Add Milestone',
      icon: Icons.stars,
      color: const Color(0xFF4CAF50),
      onTap: onTap,
    );
}

/// QuickActionsSection
/// Complete section with title and action buttons
class QuickActionsSection extends StatelessWidget {

  const QuickActionsSection({
    super.key,
    this.title = 'Quick Actions',
    required this.actions,
    this.crossAxisCount = 3,
  });
  final String title;
  final List<QuickActionItem> actions;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 16),
        // Actions grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: QuickActionsGrid(
            actions: actions,
            crossAxisCount: crossAxisCount,
          ),
        ),
      ],
    );
}