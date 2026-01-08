// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '/core/constants/text_constants.dart';
import '/data/datasources/local/hive_database.dart';
import '/presentation/providers/auth_provider.dart';
import '/presentation/providers/journal_provider.dart';
import '/presentation/providers/schedule_provider.dart';
import '/presentation/screens/gallery/gallery_screen.dart';
import '/presentation/screens/journal/journal_screen.dart';
import '/presentation/screens/schedule/schedule_screen.dart';
import '/presentation/screens/settings/settings_screen.dart';
import '../../../domain/entities/journal_entity.dart';

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
  Widget build(BuildContext context) => Scaffold(
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

/// Dashboard Screen showing overview of all features
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _childName;
  String? _userName;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadUserInfo();
      _loadData();
    });
  }

  Future<void> _loadUserInfo() async {
    final authProvider = context.read<AuthProvider>();
    final hiveDb = HiveDatabase();
    
    setState(() {
      _userName = authProvider.userDisplayName?.split(' ')[0];
      
      // Get child name from Hive
      final userBox = hiveDb.userBox;
      if (userBox.isNotEmpty) {
        final user = userBox.getAt(0);
        _childName = user?.childName;
      }
    });
  }

  Future<void> _loadData() async {
    final scheduleProvider = context.read<ScheduleProvider>();
    final journalProvider = context.read<JournalProvider>();

    await Future.wait([
      scheduleProvider.loadTodaySchedules(),
      journalProvider.loadTodayEntry(),
      journalProvider.loadWeeklyMoodStats(),
    ]);
  }

  // Navigate to Schedule tab
  void _navigateToSchedule() {
    final homeState = context.findAncestorStateOfType<_HomeScreenState>();
    homeState?.setState(() {
      homeState._currentIndex = 1;
    });
  }

  // Navigate to Journal tab
  void _navigateToJournal() {
    final homeState = context.findAncestorStateOfType<_HomeScreenState>();
    homeState?.setState(() {
      homeState._currentIndex = 2;
    });
  }

  // Navigate to Gallery tab
  void _navigateToGallery() {
    final homeState = context.findAncestorStateOfType<_HomeScreenState>();
    homeState?.setState(() {
      homeState._currentIndex = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Minimalist App Bar
            SliverAppBar(
              expandedHeight: 140,
              floating: false,
              pinned: true,
              backgroundColor: theme.primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.primaryColor,
                        theme.primaryColor.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildGreeting(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Content
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildQuickActions(),
                  const SizedBox(height: 20),
                  _buildMoodSection(),
                  const SizedBox(height: 20),
                  _buildTodayAgenda(),
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Selamat Pagi'
        : hour < 15
            ? 'Selamat Siang'
            : hour < 18
                ? 'Selamat Sore'
                : 'Selamat Malam';

    String displayName = 'Mom';
    if (_childName != null && _childName!.isNotEmpty) {
      displayName = 'Mom ${_childName!}';
    } else if (_userName != null && _userName!.isNotEmpty) {
      displayName = _userName!;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Hai, $displayName! 👋',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.photo_library_outlined,
                label: 'Add Gallery',
                color: theme.primaryColor,
                onTap: _navigateToGallery,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.calendar_today_outlined,
                label: 'Add Schedule',
                color: theme.primaryColor,
                onTap: _navigateToSchedule,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.book_outlined,
                label: 'Add Journal',
                color: theme.primaryColor,
                onTap: _navigateToJournal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMoodSection() {
    final theme = Theme.of(context);
    
    return Consumer<JournalProvider>(
      builder: (context, provider, child) {
        final totalEntries = provider.moodStats.values.fold<int>(0, (sum, count) => sum + count);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  TextConstants.moodThisWeek,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (totalEntries > 0)
                  GestureDetector(
                    onTap: _navigateToJournal,
                    child: Row(
                      children: [
                        Text(
                          'Lihat Semua',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: theme.primaryColor,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
              ),
              child: totalEntries == 0
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          children: [
                            Icon(Icons.mood_outlined, size: 32, color: theme.disabledColor),
                            const SizedBox(height: 8),
                            Text(
                              'Belum ada catatan mood',
                              style: TextStyle(
                                color: theme.disabledColor,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMoodStat(context, '😄', provider.moodStats[MoodType.veryHappy] ?? 0),
                        _buildMoodStat(context, '🙂', provider.moodStats[MoodType.happy] ?? 0),
                        _buildMoodStat(context, '😐', provider.moodStats[MoodType.neutral] ?? 0),
                        _buildMoodStat(context, '☹️', provider.moodStats[MoodType.sad] ?? 0),
                        _buildMoodStat(context, '😢', provider.moodStats[MoodType.verySad] ?? 0),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMoodStat(BuildContext context, String emoji, int count) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: count > 0 
                ? theme.primaryColor.withValues(alpha: 0.1) 
                : theme.disabledColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: count > 0 ? theme.primaryColor : theme.disabledColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTodayAgenda() {
    final theme = Theme.of(context);
    
    return Consumer<ScheduleProvider>(
      builder: (context, provider, child) {
        final schedules = provider.todaySchedules;
        final completedCount = schedules.where((s) => s.isCompleted).length;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  TextConstants.todayAgenda,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (schedules.isNotEmpty)
                  GestureDetector(
                    onTap: _navigateToSchedule,
                    child: Row(
                      children: [
                        Text(
                          '$completedCount/${schedules.length} selesai',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: theme.primaryColor,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (schedules.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.event_available, size: 32, color: theme.disabledColor),
                      const SizedBox(height: 8),
                      Text(
                        TextConstants.noSchedules,
                        style: TextStyle(
                          color: theme.disabledColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...schedules.take(5).map(
                    (schedule) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _getCategoryColor(theme, schedule.category)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _getCategoryIcon(schedule.category),
                            color: _getCategoryColor(theme, schedule.category),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          schedule.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            decoration: schedule.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: schedule.isCompleted
                                ? theme.disabledColor
                                : null,
                          ),
                        ),
                        subtitle: Text(
                          '${schedule.dateTime.hour}:'
                          '${schedule.dateTime.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                        trailing: schedule.isCompleted
                            ? Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                  size: 16,
                                ),
                              )
                            : InkWell(
                                onTap: () async {
                                  // Gunakan copyWith untuk update
                                  final updatedSchedule = schedule.copyWith(
                                    isCompleted: true,
                                    updatedAt: DateTime.now(),
                                  );
                                  
                                  await context
                                      .read<ScheduleProvider>()
                                      .updateSchedule(updatedSchedule);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: theme.disabledColor.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.circle_outlined,
                                    color: theme.disabledColor,
                                    size: 16,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
            if (schedules.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: TextButton(
                    onPressed: _navigateToSchedule,
                    child: Text('Lihat semua ${schedules.length} jadwal'),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Color _getCategoryColor(ThemeData theme, String category) {
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
        return theme.primaryColor;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Pemberian Makan/Menyusui':
        return Icons.restaurant;
      case 'Tidur':
        return Icons.bedtime;
      case 'Kesehatan':
        return Icons.favorite;
      case 'Pencapaian':
        return Icons.star;
      default:
        return Icons.event;
    }
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}