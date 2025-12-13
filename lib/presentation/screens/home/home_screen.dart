import 'package:flutter/material.dart';
import 'package:momjournal/data/models/journal_model.dart';
import 'package:momjournal/data/models/schedule_model.dart';
import 'package:provider/provider.dart';
import '/core/constants/app_constants.dart';
import '/core/constants/color_constants.dart';
import '/core/constants/text_constants.dart';
import '/presentation/providers/journal_provider.dart';
import '/presentation/providers/photo_provider.dart';
import '/presentation/providers/schedule_provider.dart';
import '/presentation/screens/gallery/gallery_screen.dart';
import '/presentation/screens/journal/journal_screen.dart';
import '/presentation/screens/schedule/schedule_screen.dart';
import '/presentation/screens/settings/settings_screen.dart';

/// Home Screen with bottom navigation and dashboard
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    ScheduleScreen(),
    JournalScreen(),
    GalleryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: TextConstants.navHome,
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: TextConstants.navSchedule,
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: TextConstants.navJournal,
          ),
          NavigationDestination(
            icon: Icon(Icons.photo_library_outlined),
            selectedIcon: Icon(Icons.photo_library),
            label: TextConstants.navGallery,
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: TextConstants.navSettings,
          ),
        ],
      ),
    );
  }
}

/// Dashboard Screen showing overview of all features
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final scheduleProvider = context.read<ScheduleProvider>();
    final journalProvider = context.read<JournalProvider>();
    final photoProvider = context.read<PhotoProvider>();

    await Future.wait([
      scheduleProvider.loadTodaySchedules(),
      journalProvider.loadTodayEntry(),
      journalProvider.loadWeeklyMoodStats(),
      photoProvider.init(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(TextConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              // TODO: Implement sync
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Syncing...')),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              _buildGreeting(),
              const SizedBox(height: 24),

              // Quick Actions
              _buildQuickActions(),
              const SizedBox(height: 24),

              // Today's Agenda
              _buildTodayAgenda(),
              const SizedBox(height: 24),

              // Mood This Week
              _buildMoodSection(),
              const SizedBox(height: 24),

              // Photo Memories
              _buildPhotoMemories(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    String greeting;
    
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          TextConstants.appTagline,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TextConstants.quickActions,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.event_note,
                label: 'Add Schedule',
                color: ColorConstants.categoryHealth,
                onTap: () {
                  // TODO: Navigate to add schedule
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.edit_note,
                label: 'Write Journal',
                color: ColorConstants.primaryColor,
                onTap: () {
                  // TODO: Navigate to add journal
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.add_a_photo,
                label: 'Add Photo',
                color: ColorConstants.categoryMilestone,
                onTap: () {
                  // TODO: Navigate to add photo
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTodayAgenda() {
    return Consumer<ScheduleProvider>(
      builder: (context, provider, child) {
        final schedules = provider.todaySchedules;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              TextConstants.todayAgenda,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            if (schedules.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      TextConstants.noSchedules,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
              )
            else
              ...schedules.take(3).map((schedule) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        Icons.circle,
                        color: _getCategoryColor(schedule.category),
                        size: 12,
                      ),
                      title: Text(schedule.title),
                      subtitle: Text(
                        '${schedule.dateTime.hour}:${schedule.dateTime.minute.toString().padLeft(2, '0')}',
                      ),
                      trailing: schedule.isCompleted
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                    ),
                  )),
          ],
        );
      },
    );
  }

  Widget _buildMoodSection() {
    return Consumer<JournalProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              TextConstants.moodThisWeek,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMoodStat('😄', provider.moodStats[MoodType.veryHappy] ?? 0),
                    _buildMoodStat('🙂', provider.moodStats[MoodType.happy] ?? 0),
                    _buildMoodStat('😐', provider.moodStats[MoodType.neutral] ?? 0),
                    _buildMoodStat('☹️', provider.moodStats[MoodType.sad] ?? 0),
                    _buildMoodStat('😢', provider.moodStats[MoodType.verySad] ?? 0),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMoodStat(String emoji, int count) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPhotoMemories() {
    return Consumer<PhotoProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  TextConstants.photoMemories,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to gallery
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FutureBuilder<int>(
              future: provider.getPhotoCount(),
              builder: (context, snapshot) {
                final count = snapshot.data ?? 0;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.photo_library, size: 48),
                          const SizedBox(height: 8),
                          Text(
                            '$count Photos',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Color _getCategoryColor(category) {
    switch (category) {
      case ScheduleCategory.feeding:
        return ColorConstants.categoryFeeding;
      case ScheduleCategory.sleep:
        return ColorConstants.categorySleep;
      case ScheduleCategory.health:
        return ColorConstants.categoryHealth;
      case ScheduleCategory.milestone:
        return ColorConstants.categoryMilestone;
      default:
        return ColorConstants.categoryOther;
    }
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}