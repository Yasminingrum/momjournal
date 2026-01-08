// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '/core/constants/color_constants.dart';
import '/core/constants/text_constants.dart';
import '/data/datasources/local/hive_database.dart';
import '/data/repositories/sync_repository.dart';
import '/presentation/providers/auth_provider.dart';
import '/presentation/providers/journal_provider.dart';
import '/presentation/providers/photo_provider.dart';
import '/presentation/providers/schedule_provider.dart';
import '/presentation/providers/sync_provider.dart';
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
    final photoProvider = context.read<PhotoProvider>();

    await Future.wait([
      scheduleProvider.loadTodaySchedules(),
      journalProvider.loadTodayEntry(),
      journalProvider.loadWeeklyMoodStats(),
      photoProvider.init(),
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
  Widget build(BuildContext context) => Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Custom App Bar with gradient
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        ColorConstants.primaryColor,
                        ColorConstants.primaryColor.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
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
                  _buildSyncStatus(),
                  const SizedBox(height: 16),
                  _buildQuickStats(),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  _buildTodayAgenda(),
                  const SizedBox(height: 24),
                  _buildMoodSection(),
                  const SizedBox(height: 24),
                  _buildPhotoMemories(),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );

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
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Hai, $displayName! 👋',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          TextConstants.appTagline,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSyncStatus() => Consumer<SyncProvider>(
      builder: (context, syncProvider, child) {
        if (syncProvider.status == SyncStatus.idle) {
          return const SizedBox.shrink();
        }

        Color bgColor;
        IconData icon;
        String message;

        switch (syncProvider.status) {
          case SyncStatus.syncing:
            bgColor = Colors.blue.shade50;
            icon = Icons.sync;
            message = 'Sedang sync data...';
          case SyncStatus.success:
            bgColor = Colors.green.shade50;
            icon = Icons.check_circle;
            message = 'Sync berhasil';
          case SyncStatus.error:
            bgColor = Colors.red.shade50;
            icon = Icons.error;
            message = syncProvider.errorMessage ?? 'Sync gagal';
          default:
            return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: bgColor == Colors.blue.shade50 ? Colors.blue : bgColor == Colors.green.shade50 ? Colors.green : Colors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    color: bgColor == Colors.blue.shade50 ? Colors.blue.shade900 : bgColor == Colors.green.shade50 ? Colors.green.shade900 : Colors.red.shade900,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  Widget _buildQuickStats() => Consumer3<ScheduleProvider, JournalProvider, PhotoProvider>(
      builder: (context, scheduleProvider, journalProvider, photoProvider, child) => Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.event_note,
                label: 'Jadwal Hari Ini',
                value: '${scheduleProvider.todaySchedules.length}',
                color: ColorConstants.categoryHealth,
                onTap: _navigateToSchedule,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FutureBuilder<int>(
                future: photoProvider.getPhotoCount(),
                builder: (context, snapshot) => _StatCard(
                    icon: Icons.photo_library,
                    label: 'Total Foto',
                    value: '${snapshot.data ?? 0}',
                    color: ColorConstants.categoryMilestone,
                    onTap: _navigateToGallery,
                  ),
              ),
            ),
          ],
        ),
    );

  Widget _buildQuickActions() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aksi Cepat',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Icon(Icons.bolt, color: ColorConstants.primaryColor, size: 20),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.event_note,
                label: 'Tambah\nJadwal',
                gradient: LinearGradient(
                  colors: [
                    ColorConstants.categoryHealth, 
                    ColorConstants.categoryHealth.withValues(alpha: 0.7),
                  ],
                ),
                onTap: _navigateToSchedule,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.edit_note,
                label: 'Tulis\nJurnal',
                gradient: LinearGradient(
                  colors: [
                    ColorConstants.primaryColor, 
                    ColorConstants.primaryColor.withValues(alpha: 0.7),
                  ],
                ),
                onTap: _navigateToJournal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.add_a_photo,
                label: 'Upload\nFoto',
                gradient: LinearGradient(
                  colors: [
                    ColorConstants.categoryMilestone, 
                    ColorConstants.categoryMilestone.withValues(alpha: 0.7),
                  ],
                ),
                onTap: _navigateToGallery,
              ),
            ),
          ],
        ),
      ],
    );

  Widget _buildTodayAgenda() => Consumer<ScheduleProvider>(
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
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (schedules.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: ColorConstants.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$completedCount/${schedules.length} selesai',
                      style: const TextStyle(
                        fontSize: 12,
                        color: ColorConstants.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (schedules.isEmpty)
              Card(
                elevation: 0,
                color: Colors.grey[50],
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.event_available, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          TextConstants.noSchedules,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...schedules.take(3).map(
                    (schedule) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _getCategoryColor(schedule.category).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getCategoryIcon(schedule.category),
                            color: _getCategoryColor(schedule.category),
                          ),
                        ),
                        title: Text(
                          schedule.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            decoration: schedule.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Text(
                          '${schedule.dateTime.hour}:'
                          '${schedule.dateTime.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 13),
                        ),
                        trailing: schedule.isCompleted
                            ? Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                  size: 20,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
            if (schedules.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton(
                  onPressed: _navigateToSchedule,
                  child: Text('Lihat semua ${schedules.length} jadwal'),
                ),
              ),
          ],
        );
      },
    );

  Widget _buildMoodSection() => Consumer<JournalProvider>(
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
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (totalEntries > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: ColorConstants.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$totalEntries catatan',
                      style: const TextStyle(
                        fontSize: 12,
                        color: ColorConstants.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: totalEntries == 0
                    ? Center(
                        child: Column(
                          children: [
                            Icon(Icons.mood, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text(
                              'Belum ada catatan mood minggu ini',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : Row(
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

  Widget _buildMoodStat(String emoji, int count) => Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 36)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: count > 0 
                ? ColorConstants.primaryColor.withValues(alpha: 0.1) 
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: count > 0 ? ColorConstants.primaryColor : Colors.grey,
            ),
          ),
        ),
      ],
    );

  Widget _buildPhotoMemories() => Consumer<PhotoProvider>(
      builder: (context, provider, child) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  TextConstants.photoMemories,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton.icon(
                  onPressed: _navigateToGallery,
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('Lihat Semua'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FutureBuilder<int>(
              future: provider.getPhotoCount(),
              builder: (context, snapshot) {
                final count = snapshot.data ?? 0;
                return Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: InkWell(
                    onTap: _navigateToGallery,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: ColorConstants.categoryMilestone.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.photo_library,
                                size: 48,
                                color: ColorConstants.categoryMilestone,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '$count Foto',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Kenangan tersimpan',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
    );

  Color _getCategoryColor(String category) {
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.gradient,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
}