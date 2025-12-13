/// Time Picker Bottom Sheet
/// 
/// Bottom sheet untuk memilih waktu pengingat
/// Location: lib/presentation/widgets/bottom_sheets/time_picker_bottom_sheet.dart
library;

import 'package:flutter/material.dart';

/// Show time picker bottom sheet
/// 
/// Returns waktu pengingat dalam menit, atau null jika dibatalkan
Future<int?> showTimePickerBottomSheet(
  BuildContext context, {
  int? selectedMinutes,
}) async => showModalBottomSheet<int>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => TimePickerBottomSheet(
      selectedMinutes: selectedMinutes,
    ),
  );

/// Time Picker Bottom Sheet Widget
class TimePickerBottomSheet extends StatelessWidget {

  const TimePickerBottomSheet({
    super.key,
    this.selectedMinutes,
  });
  final int? selectedMinutes;

  // Pilihan waktu pengingat (dalam menit)
  static const List<int> reminderOptions = [
    5,    // 5 menit
    10,   // 10 menit
    15,   // 15 menit
    30,   // 30 menit
    60,   // 1 jam
    120,  // 2 jam
    1440, // 1 hari
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Waktu Pengingat',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Time options
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: reminderOptions.length,
              itemBuilder: (context, index) {
                final minutes = reminderOptions[index];
                final isSelected = minutes == selectedMinutes;
                
                return TimeOptionTile(
                  minutes: minutes,
                  isSelected: isSelected,
                  onTap: () => Navigator.pop(context, minutes),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Time Option Tile Widget
class TimeOptionTile extends StatelessWidget {

  const TimeOptionTile({
    required this.minutes, required this.isSelected, required this.onTap, super.key,
  });
  final int minutes;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : null,
          border: Border(
            left: BorderSide(
              color: isSelected ? colorScheme.primary : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            // Clock icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary.withOpacity(0.2)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.access_time,
                color: isSelected ? colorScheme.primary : Colors.grey[600],
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Time text
            Expanded(
              child: Text(
                _formatMinutes(minutes),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            
            // Check icon
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: colorScheme.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) {
      return '$minutes menit sebelumnya';
    } else if (minutes == 60) {
      return '1 jam sebelumnya';
    } else if (minutes < 1440) {
      final hours = minutes ~/ 60;
      return '$hours jam sebelumnya';
    } else if (minutes == 1440) {
      return '1 hari sebelumnya';
    } else {
      final days = minutes ~/ 1440;
      return '$days hari sebelumnya';
    }
  }
}