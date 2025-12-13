/// Journal Detail Screen
/// 
/// Screen untuk melihat detail journal entry
/// Location: lib/presentation/screens/journal/journal_detail_screen.dart
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/journal_entity.dart';
import '../../providers/journal_provider.dart';
import '../../widgets/dialogs/confirmation_dialog.dart';
import '../../widgets/dialogs/info_dialog.dart';

class JournalDetailScreen extends StatelessWidget {

  const JournalDetailScreen({
    super.key,
    required this.journal,
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
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _handleDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date
            Text(
              _formatDate(journal.date),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 24),

            // Mood display
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: _getMoodColor(journal.mood).withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getMoodColor(journal.mood),
                    width: 4,
                  ),
                ),
                child: Center(
                  child: Text(
                    _getMoodEmoji(journal.mood),
                    style: const TextStyle(fontSize: 64),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Mood label
            Center(
              child: Text(
                _getMoodLabel(journal.mood),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getMoodColor(journal.mood),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Content
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                journal.content,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Metadata
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ditulis pada ${_formatDateTime(journal.createdAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await showDeleteConfirmation(
      context,
      itemName: 'Jurnal',
      message: 'Jurnal yang dihapus tidak dapat dikembalikan.',
    );

    if (!confirmed || !context.mounted) return;

    final provider = context.read<JournalProvider>();
    final success = await provider.deleteJournal(journal.id);

    if (!context.mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jurnal berhasil dihapus'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      await showErrorDialog(
        context,
        title: 'Gagal',
        message: provider.errorMessage ?? 'Terjadi kesalahan',
      );
      provider.clearError();
    }
  }

  String _getMoodEmoji(Mood mood) {
    switch (mood) {
      case Mood.veryHappy:
        return '😄';
      case Mood.happy:
        return '😊';
      case Mood.neutral:
        return '😐';
      case Mood.sad:
        return '😔';
      case Mood.verySad:
        return '😢';
    }
  }

  Color _getMoodColor(Mood mood) {
    switch (mood) {
      case Mood.veryHappy:
        return Colors.green;
      case Mood.happy:
        return Colors.lightGreen;
      case Mood.neutral:
        return Colors.amber;
      case Mood.sad:
        return Colors.orange;
      case Mood.verySad:
        return Colors.red;
    }
  }

  String _getMoodLabel(Mood mood) {
    switch (mood) {
      case Mood.veryHappy:
        return 'Sangat Bahagia';
      case Mood.happy:
        return 'Bahagia';
      case Mood.neutral:
        return 'Biasa Saja';
      case Mood.sad:
        return 'Sedih';
      case Mood.verySad:
        return 'Sangat Sedih';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}, '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}