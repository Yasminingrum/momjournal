import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '/domain/entities/journal_entity.dart';
import '/presentation/providers/journal_provider.dart';
import '/presentation/routes/app_router.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<JournalProvider>().loadAllJournals();
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _showDateRangePicker(context),
            tooltip: 'Filter by date',
          ),
        ],
      ),
      body: Consumer<JournalProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
            onPressed: () => provider.loadAllJournals(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.journals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No journal entries yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to create your first entry',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadAllJournals,
            child: Column(
              children: [
                // Mood stats summary
                if (provider.moodStats.isNotEmpty) _buildMoodStatsCard(provider),
                
                // Journal list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.journals.length,
                    itemBuilder: (context, index) {
                      final journal = provider.journals[index];
                      return _buildJournalCard(context, journal, provider);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, Routes.addJournal).then((result) {
            if (result == true && mounted) {
              context.read<JournalProvider>().loadAllJournals();
            }
          });
        },
        tooltip: 'Add Journal',
        child: const Icon(Icons.add),
      ),
    );

  Widget _buildMoodStatsCard(JournalProvider provider) => Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Mood Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: provider.moodStats.entries.map((entry) => Chip(
                  avatar: Text(
                    _getMoodEmoji(entry.key),
                    style: const TextStyle(fontSize: 18),
                  ),
                  label: Text('${entry.value}'),
                ),).toList(),
            ),
          ],
        ),
      ),
    );

  Widget _buildJournalCard(
    BuildContext context,
    JournalEntity journal,
    JournalProvider provider,
  ) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showJournalDetails(context, journal, provider),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Mood emoji
                  Text(
                    journal.moodEmoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  
                  // Date and time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateFormat.format(journal.date),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          timeFormat.format(journal.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Sync indicator
                  if (!journal.isSynced)
                    Icon(
                      Icons.cloud_off,
                      size: 20,
                      color: Colors.grey[400],
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Content preview
              Text(
                journal.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showJournalDetails(
    BuildContext context,
    JournalEntity journal,
    JournalProvider provider,
  ) {
    final dateFormat = DateFormat('EEEE, MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Header with mood and date
              Row(
                children: [
                  Text(
                    journal.moodEmoji,
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateFormat.format(journal.date),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Created at ${timeFormat.format(journal.createdAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Text(
                    journal.content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          Routes.addJournal,
                          arguments: journal,
                        ).then((result) {
                          if (result == true) {
                            provider.loadAllJournals();
                          }
                        });
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmDelete(context, journal, provider),
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    JournalEntity journal,
    JournalProvider provider,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Journal'),
        content: const Text('Are you sure you want to delete this journal entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close bottom sheet
              
              final success = await provider.deleteJournal(journal.id);
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Journal deleted successfully'
                          : 'Failed to delete journal',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showDateRangePicker(BuildContext context) {
    final provider = context.read<JournalProvider>();
    
    showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
    ).then((picked) {
      if (picked != null && mounted) {
        provider.loadJournalsByDateRange(picked.start, picked.end);
      }
    });
  }

  String _getMoodEmoji(MoodType mood) {
    switch (mood) {
      case MoodType.veryHappy:
        return '😄';
      case MoodType.happy:
        return '🙂';
      case MoodType.neutral:
        return '😐';
      case MoodType.sad:
        return '☹️';
      case MoodType.verySad:
        return '😢';
    }
  }
}