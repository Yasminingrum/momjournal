library;

import 'package:flutter/material.dart';
import '/core/constants/color_constants.dart';

/// Show category bottom sheet
/// 
/// Returns selected category name atau null jika dibatalkan
Future<String?> showCategoryBottomSheet(
  BuildContext context, {
  required List<Map<String, String>> categories, String? selectedCategory,
  VoidCallback? onManageCategories,
}) => showModalBottomSheet<String>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => CategoryBottomSheet(
      selectedCategory: selectedCategory,
      categories: categories,
      onManageCategories: onManageCategories,
    ),
  );

/// Category Bottom Sheet Widget
class CategoryBottomSheet extends StatelessWidget {

  const CategoryBottomSheet({
    required this.categories, super.key,
    this.selectedCategory,
    this.onManageCategories,
  });
  
  final String? selectedCategory;
  final List<Map<String, String>> categories;
  final VoidCallback? onManageCategories;

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
                if (onManageCategories != null)
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onManageCategories!();
                    },
                    icon: const Icon(Icons.settings),
                    tooltip: 'Kelola Kategori',
                  )
                else
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
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category['name'] == selectedCategory;
                
                return CategoryTile(
                  categoryName: category['name']!,
                  categoryIcon: category['icon']!,
                  categoryColor: category['colorHex']!,
                  isSelected: isSelected,
                  onTap: () => Navigator.pop(context, category['name']),
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

  const CategoryTile({
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.isSelected,
    required this.onTap,
    super.key,
  });
  
  final String categoryName;
  final String categoryIcon;
  final String categoryColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _parseColor(categoryColor);
    final icon = _getIconData(categoryIcon);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : null,
          border: Border(
            left: BorderSide(
              color: isSelected ? color : Colors.transparent,
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
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
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
                color: color,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String colorHex) {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return ColorConstants.categoryOther;
    }
  }

  IconData _getIconData(String iconName) {
    // Map icon names to IconData
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'bedtime':
        return Icons.bedtime;
      case 'medical_services':
        return Icons.medical_services;
      case 'stars':
        return Icons.stars;
      case 'celebration':
        return Icons.celebration;
      case 'school':
        return Icons.school;
      case 'sports_soccer':
        return Icons.sports_soccer;
      case 'music_note':
        return Icons.music_note;
      case 'brush':
        return Icons.brush;
      case 'favorite':
        return Icons.favorite;
      case 'pets':
        return Icons.pets;
      case 'cake':
        return Icons.cake;
      default:
        return Icons.more_horiz;
    }
  }
}