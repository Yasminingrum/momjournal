/// Category Bottom Sheet
/// 
/// Bottom sheet untuk memilih kategori schedule
/// Location: lib/presentation/widgets/bottom_sheets/category_bottom_sheet.dart

import 'package:flutter/material.dart';
import '../../../domain/entities/schedule_entity.dart';
import '../../../core/constants/color_constants.dart';

/// Show category bottom sheet
/// 
/// Returns selected category atau null jika dibatalkan
Future<ScheduleCategory?> showCategoryBottomSheet(
  BuildContext context, {
  ScheduleCategory? selectedCategory,
}) async {
  return await showModalBottomSheet<ScheduleCategory>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => CategoryBottomSheet(
      selectedCategory: selectedCategory,
    ),
  );
}

/// Category Bottom Sheet Widget
class CategoryBottomSheet extends StatelessWidget {
  final ScheduleCategory? selectedCategory;

  const CategoryBottomSheet({
    super.key,
    this.selectedCategory,
  });

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
                  'Pilih Kategori',
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
          
          // Category list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: ScheduleCategory.values.length,
              itemBuilder: (context, index) {
                final category = ScheduleCategory.values[index];
                final isSelected = category == selectedCategory;
                
                return CategoryTile(
                  category: category,
                  isSelected: isSelected,
                  onTap: () => Navigator.pop(context, category),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Category Tile Widget
class CategoryTile extends StatelessWidget {
  final ScheduleCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryTile({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = _getCategoryColor(category);
    final categoryIcon = _getCategoryIcon(category);
    final categoryName = _getCategoryName(category);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? categoryColor.withOpacity(0.1) : null,
          border: Border(
            left: BorderSide(
              color: isSelected ? categoryColor : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                categoryIcon,
                color: categoryColor,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Category name
            Expanded(
              child: Text(
                categoryName,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            
            // Check icon
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: categoryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(ScheduleCategory category) {
    switch (category) {
      case ScheduleCategory.feeding:
        return ColorConstants.categoryFeeding;
      case ScheduleCategory.sleeping:
        return ColorConstants.categorySleeping;
      case ScheduleCategory.health:
        return ColorConstants.categoryHealth;
      case ScheduleCategory.milestone:
        return ColorConstants.categoryMilestone;
      case ScheduleCategory.other:
        return ColorConstants.categoryOther;
    }
  }

  IconData _getCategoryIcon(ScheduleCategory category) {
    switch (category) {
      case ScheduleCategory.feeding:
        return Icons.restaurant;
      case ScheduleCategory.sleeping:
        return Icons.bedtime;
      case ScheduleCategory.health:
        return Icons.medical_services;
      case ScheduleCategory.milestone:
        return Icons.stars;
      case ScheduleCategory.other:
        return Icons.more_horiz;
    }
  }

  String _getCategoryName(ScheduleCategory category) {
    switch (category) {
      case ScheduleCategory.feeding:
        return 'Pemberian Makan/Menyusui';
      case ScheduleCategory.sleeping:
        return 'Tidur';
      case ScheduleCategory.health:
        return 'Kesehatan';
      case ScheduleCategory.milestone:
        return 'Pencapaian';
      case ScheduleCategory.other:
        return 'Lainnya';
    }
  }
}