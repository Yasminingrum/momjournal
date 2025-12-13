// ignore_for_file: lines_longer_than_80_chars

library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/journal_entity.dart';
import '../../providers/journal_provider.dart';
import '../../widgets/common/custom_button.dart';

class AddJournalScreen extends StatefulWidget {

  const AddJournalScreen({
    super.key,
    this.selectedDate,
  });
  final DateTime? selectedDate;

  @override
  State<AddJournalScreen> createState() => _AddJournalScreenState();
}

class _AddJournalScreenState extends State<AddJournalScreen> {
  final _contentController = TextEditingController();
  MoodType _selectedMood = MoodType.neutral;
  DateTime? _selectedDate;
  bool _isLoading = false;
  int _characterCount = 0;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();
    _contentController.addListener(_updateCharacterCount);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _updateCharacterCount() {
    setState(() {
      _characterCount = _contentController.text.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tulis Jurnal'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Date selector
          _buildDateSelector(theme),

          const SizedBox(height: 24),

          // Mood selector
          Text(
            'Bagaimana perasaanmu hari ini?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          _buildMoodSelector(),

          const SizedBox(height: 32),

          // Content field
          Text(
            'Ceritakan harimu',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: _contentController,
            maxLines: 10,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Tulis di sini...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              counterText: '$_characterCount/500 karakter',
            ),
          ),

          const SizedBox(height: 24),

          // Save button
          CustomButton(
            onPressed: _isLoading ? null : _handleSave,
            text: _isLoading ? 'Menyimpan...' : 'Simpan Jurnal',
            type: ButtonType.elevated,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(ThemeData theme) => Card(
      child: InkWell(
        onTap: _selectDate,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.calendar_today),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tanggal',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(_selectedDate!),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );

  Widget _buildMoodSelector() => Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: MoodType.values.map((mood) {
        final isSelected = _selectedMood == mood;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedMood = mood;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isSelected ? 70 : 60,
            height: isSelected ? 70 : 60,
            decoration: BoxDecoration(
              color: isSelected ? _getMoodColor().withValues(alpha: 0.2) : Colors.grey[100],
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? _getMoodColor() : Colors.transparent,
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                _getMoodEmoji(mood),
                style: TextStyle(
                  fontSize: isSelected ? 36 : 28,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate!,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleSave() async {
    final content = _contentController.text.trim();

    if (content.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan tulis sesuatu di jurnal'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (content.length < 10) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konten jurnal minimal 10 karakter'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final journalProvider = context.read<JournalProvider>();
    final success = await journalProvider.createJournal(
      mood: _selectedMood,
      content: content,
      date: _selectedDate,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jurnal berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(journalProvider.error ?? 'Terjadi kesalahan'),
          backgroundColor: Colors.red,
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

  Color _getMoodColor() {
    switch (_selectedMood) {
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

  String _formatDate(DateTime date) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}