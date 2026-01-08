import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/presentation/providers/auth_provider.dart';
import '/presentation/providers/category_provider.dart';

/// Manage Categories Screen - FINAL VERSION
/// Fixed all errors with proper AuthProvider usage
class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
  }

  Future<void> _loadCategories() async {
    if (!mounted) {
      return;
    }
    
    final authProvider = context.read<AuthProvider>();
    final categoryProvider = context.read<CategoryProvider>();
    
    final user = authProvider.user;
    if (user != null) {
      await categoryProvider.loadCategories(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryProvider = context.watch<CategoryProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Kategori'),
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddCategoryDialog(user.uid),
              tooltip: 'Tambah Kategori',
            ),
        ],
      ),
      body: categoryProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : categoryProvider.error != null
              ? Center(child: Text('Error: ${categoryProvider.error}'))
              : categoryProvider.categories.isEmpty
                  ? const Center(child: Text('Belum ada kategori'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: categoryProvider.categories.length,
                      itemBuilder: (context, index) {
                        final category = categoryProvider.categories[index];
                        final color = _parseColor(category.colorHex);
                        final icon = _getIconData(category.icon);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(icon, color: color),
                            ),
                            title: Text(
                              category.name,
                              style: theme.textTheme.bodyLarge,
                            ),
                            subtitle: category.isDefault 
                                ? const Text('Default', style: TextStyle(fontSize: 12))
                                : null,
                            trailing: category.isDefault
                                ? null
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => _showEditCategoryDialog(category.id),
                                        tooltip: 'Edit',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () => _deleteCategory(category.id, category.name),
                                        tooltip: 'Hapus',
                                      ),
                                    ],
                                  ),
                          ),
                        );
                      },
                    ),
    );
  }

  void _showAddCategoryDialog(String userId) {
    final nameController = TextEditingController();
    String selectedIcon = 'more_horiz';
    String selectedColor = '#95A5A6';
    final categoryProvider = context.read<CategoryProvider>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tambah Kategori Baru'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Kategori',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedIcon,
                  decoration: const InputDecoration(
                    labelText: 'Icon',
                    border: OutlineInputBorder(),
                  ),
                  items: _availableIcons.map((icon) => DropdownMenuItem(
                      value: icon['name'],
                      child: Row(
                        children: [
                          Icon(_getIconData(icon['name']!)),
                          const SizedBox(width: 8),
                          Text(icon['label']!),
                        ],
                      ),
                    ),).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedIcon = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableColors.map((colorHex) {
                    final color = _parseColor(colorHex);
                    final isSelected = selectedColor == colorHex;
                    return GestureDetector(
                      onTap: () => setState(() => selectedColor = colorHex),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.black, width: 3)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                
                if (name.isEmpty) {
                  if (!mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Nama kategori tidak boleh kosong')),
                  );
                  return;
                }

                if (categoryProvider.categoryExists(name)) {
                  if (!mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Kategori dengan nama ini sudah ada')),
                  );
                  return;
                }

                final success = await categoryProvider.createCategory(
                  userId: userId,
                  name: name,
                  icon: selectedIcon,
                  colorHex: selectedColor,
                );

                if (success && mounted) {
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Kategori berhasil ditambahkan')),
                  );
                }
              },
              child: const Text('Tambah'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCategoryDialog(String categoryId) {
    final categoryProvider = context.read<CategoryProvider>();
    final category = categoryProvider.categories.firstWhere((c) => c.id == categoryId);
    
    final nameController = TextEditingController(text: category.name);
    String selectedIcon = category.icon;
    String selectedColor = category.colorHex;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Kategori'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Kategori',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedIcon,
                  decoration: const InputDecoration(
                    labelText: 'Icon',
                    border: OutlineInputBorder(),
                  ),
                  items: _availableIcons.map((icon) => DropdownMenuItem(
                      value: icon['name'],
                      child: Row(
                        children: [
                          Icon(_getIconData(icon['name']!)),
                          const SizedBox(width: 8),
                          Text(icon['label']!),
                        ],
                      ),
                    ),).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedIcon = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableColors.map((colorHex) {
                    final color = _parseColor(colorHex);
                    final isSelected = selectedColor == colorHex;
                    return GestureDetector(
                      onTap: () => setState(() => selectedColor = colorHex),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.black, width: 3)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                
                if (name.isEmpty) {
                  if (!mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Nama kategori tidak boleh kosong')),
                  );
                  return;
                }

                if (categoryProvider.categoryExists(name, excludeId: categoryId)) {
                  if (!mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Kategori dengan nama ini sudah ada')),
                  );
                  return;
                }

                final success = await categoryProvider.updateCategory(
                  id: categoryId,
                  name: name,
                  icon: selectedIcon,
                  colorHex: selectedColor,
                );

                if (success && mounted) {
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Kategori berhasil diupdate')),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteCategory(String categoryId, String categoryName) {
    final categoryProvider = context.read<CategoryProvider>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text('Yakin ingin menghapus kategori "$categoryName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await categoryProvider.deleteCategory(categoryId);
              
              if (mounted) {
                Navigator.of(dialogContext).pop();
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kategori berhasil dihapus')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menghapus: ${categoryProvider.error}')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String colorHex) {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'beach_access':
        return Icons.beach_access;
      case 'bedtime':
        return Icons.bedtime;
      case 'brush':
        return Icons.brush;
      case 'cake':
        return Icons.cake;
      case 'celebration':
        return Icons.celebration;
      case 'family_restroom':
        return Icons.family_restroom;
      case 'favorite':
        return Icons.favorite;
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'medical_services':
        return Icons.medical_services;
      case 'music_note':
        return Icons.music_note;
      case 'pets':
        return Icons.pets;
      case 'restaurant':
        return Icons.restaurant;
      case 'school':
        return Icons.school;
      case 'sports_soccer':
        return Icons.sports_soccer;
      case 'stars':
        return Icons.stars;
      case 'toys':
        return Icons.toys;
      case 'work':
        return Icons.work;
      default:
        return Icons.more_horiz; // Lainnya
    }
  }

  final List<Map<String, String>> _availableIcons = [
    {'name': 'beach_access', 'label': 'Liburan'},
    {'name': 'bedtime', 'label': 'Tidur'},
    {'name': 'brush', 'label': 'Seni'},
    {'name': 'cake', 'label': 'Ulang Tahun'},
    {'name': 'celebration', 'label': 'Perayaan'},
    {'name': 'family_restroom', 'label': 'Keluarga'},
    {'name': 'favorite', 'label': 'Favorit'},
    {'name': 'medical_services', 'label': 'Kesehatan'},
    {'name': 'wb_sunny', 'label': 'Keseharian'},
    {'name': 'music_note', 'label': 'Musik'},
    {'name': 'pets', 'label': 'Hewan'},
    {'name': 'restaurant', 'label': 'Makan'},
    {'name': 'school', 'label': 'Sekolah'},
    {'name': 'sports_soccer', 'label': 'Olahraga'},
    {'name': 'stars', 'label': 'Pencapaian'},
    {'name': 'toys', 'label': 'Bermain'},
    {'name': 'work', 'label': 'Pekerjaan'},
    {'name': 'more_horiz', 'label': 'Lainnya'},
  ];

  final List<String> _availableColors = [
    '#4A90E2',
    '#9B59B6',
    '#E74C3C',
    '#2ECC71',
    '#F39C12',
    '#1ABC9C',
    '#E91E63',
    '#795548',
    '#607D8B',
    '#95A5A6',
  ];
}