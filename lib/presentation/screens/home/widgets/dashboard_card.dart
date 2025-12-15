import 'package:flutter/material.dart';

/// DashboardCard
/// Reusable card widget for displaying summary information on the home dashboard.
/// Supports various content types with icon, title, value, and optional action.
///
/// Features:
/// - Customizable colors and icons
/// - Animated value changes
/// - Optional tap action
/// - Loading and error states
/// - Responsive sizing
class DashboardCard extends StatelessWidget {

  const DashboardCard({
    required this.title, required this.value, required this.icon, required this.color, super.key,
    this.backgroundColor,
    this.onTap,
    this.isLoading = false,
    this.subtitle,
    this.trailing,
  });
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool isLoading;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: backgroundColor ?? color.withValues (alpha:0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isLoading
              ? _buildLoading()
              : _buildContent(context),
        ),
      ),
    );

  Widget _buildContent(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues (alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const Spacer(),
            // Trailing widget (optional)
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: 16),
        // Title
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 4),
        // Value
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        // Subtitle (optional)
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ],
    );

  Widget _buildLoading() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.grey[400],
                size: 24,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 16,
          width: 100,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 32,
          width: 60,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
}

/// ScheduleDashboardCard
/// Specialized dashboard card for schedule summary
class ScheduleDashboardCard extends StatelessWidget {

  const ScheduleDashboardCard({
    required this.todayCount, required this.upcomingCount, required this.onTap, super.key,
    this.isLoading = false,
  });
  final int todayCount;
  final int upcomingCount;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => DashboardCard(
      title: 'Today\'s Schedule',
      value: todayCount.toString(),
      subtitle: upcomingCount > 0 
          ? '$upcomingCount upcoming this week'
          : 'All caught up!',
      icon: Icons.calendar_today,
      color: const Color(0xFF2196F3),
      onTap: onTap,
      isLoading: isLoading,
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
    );
}

/// JournalDashboardCard
/// Specialized dashboard card for journal summary
class JournalDashboardCard extends StatelessWidget {

  const JournalDashboardCard({
    required this.todayMood, required this.weeklyCount, required this.onTap, super.key,
    this.isLoading = false,
  });
  final String todayMood;
  final int weeklyCount;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => DashboardCard(
      title: 'Today\'s Mood',
      value: todayMood.isEmpty ? '—' : todayMood,
      subtitle: '$weeklyCount entries this week',
      icon: Icons.mood,
      color: const Color(0xFFFF9800),
      onTap: onTap,
      isLoading: isLoading,
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
    );
}

/// PhotoDashboardCard
/// Specialized dashboard card for photo gallery summary
class PhotoDashboardCard extends StatelessWidget {

  const PhotoDashboardCard({
    required this.totalPhotos, required this.thisMonthCount, required this.onTap, super.key,
    this.isLoading = false,
  });
  final int totalPhotos;
  final int thisMonthCount;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => DashboardCard(
      title: 'Photo Memories',
      value: totalPhotos.toString(),
      subtitle: '$thisMonthCount added this month',
      icon: Icons.photo_library,
      color: const Color(0xFF9C27B0),
      onTap: onTap,
      isLoading: isLoading,
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
    );
}

/// MilestoneDashboardCard
/// Specialized dashboard card for milestone tracking
class MilestoneDashboardCard extends StatelessWidget {

  const MilestoneDashboardCard({
    required this.milestoneCount, required this.onTap, super.key,
    this.latestMilestone,
    this.isLoading = false,
  });
  final int milestoneCount;
  final String? latestMilestone;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => DashboardCard(
      title: 'Milestones',
      value: milestoneCount.toString(),
      subtitle: latestMilestone ?? 'No milestones yet',
      icon: Icons.star,
      color: const Color(0xFFFFC107),
      onTap: onTap,
      isLoading: isLoading,
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
    );
}