library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/journal_entity.dart';
import '../../providers/journal_provider.dart';

class JournalDetailScreen extends StatelessWidget {

  const JournalDetailScreen({
    required this.journal, super.key,
  });
  final JournalEntity journal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Jurnal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _handleEdit(context),
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _handleDelete(context),
            tooltip: 'Hapus',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date and mood section
            Row(
              children: [
                // Mood emoji
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _getMoodColor(journal.mood).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getMoodColor(journal.mood).withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _getMoodEmoji(journal.mood),
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Date and mood label
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(journal.date),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dibuat ${_formatDateTime(journal.createdAt)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
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
            
            const SizedBox(height: 24),

            // Content section
            Text(
              'Catatan Harian',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            
            const SizedBox(height: 16),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                journal.content,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.8,
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Mood label section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _getMoodColor(journal.mood).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getMoodColor(journal.mood).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mood,
                    color: _getMoodColor(journal.mood),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Mood: ${_getMoodLabel(journal.mood)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _getMoodColor(journal.mood),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100), // Extra space for safe area
          ],
        ),
      ),
    );
  }
  
  void _handleEdit(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/journal/add',
      arguments: journal,
    );
  }

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Jurnal'),
        content: const Text('Jurnal yang dihapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final provider = context.read<JournalProvider>();
    final success = await provider.deleteJournal(journal.id);

    if (!context.mounted) {
      return;
    }

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jurnal berhasil dihapus'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Terjadi kesalahan'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _getMoodEmoji(MoodType mood) {
    switch (mood) {
      case MoodType.veryHappy:
        return '😄';
      case MoodType.happy:
        return '😊';
      case MoodType.neutral:
        return '😐';
      case MoodType.sad:
        return '😔';
      case MoodType.verySad:
        return '😢';
    }
  }

  Color _getMoodColor(MoodType mood) {
    switch (mood) {
      case MoodType.veryHappy:
        return Colors.green;
      case MoodType.happy:
        return Colors.lightGreen;
      case MoodType.neutral:
        return Colors.amber;
      case MoodType.sad:
        return Colors.orange;
      case MoodType.verySad:
        return Colors.red;
    }
  }

  String _getMoodLabel(MoodType mood) {
    switch (mood) {
      case MoodType.veryHappy:
        return 'Sangat Bahagia';
      case MoodType.happy:
        return 'Bahagia';
      case MoodType.neutral:
        return 'Biasa Saja';
      case MoodType.sad:
        return 'Sedih';
      case MoodType.verySad:
        return 'Sangat Sedih';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    
    final dayNames = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
    ];
    
    final dayName = dayNames[date.weekday - 1];
    return '$dayName, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatDateTime(DateTime dateTime) => '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
}