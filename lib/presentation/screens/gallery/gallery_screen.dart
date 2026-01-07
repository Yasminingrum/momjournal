import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '/core/constants/color_constants.dart';
import '/core/constants/text_constants.dart';
import '/domain/entities/category_entity.dart';
import '/domain/entities/photo_entity.dart';
import '/presentation/providers/auth_provider.dart';
import '/presentation/providers/category_provider.dart';
import '/presentation/providers/photo_provider.dart';
import '/presentation/providers/sync_provider.dart';
import '/presentation/routes/app_router.dart';
import '/presentation/widgets/common/empty_state.dart';
import '/presentation/widgets/common/error_widget.dart';
import '/presentation/widgets/common/loading_indicator.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  bool _showMilestonesOnly = false;
  bool _showFavoritesOnly = false;  // Ã°Å¸â€ â€¢ ADDED
  bool _sortNewestFirst = true;
  String? _selectedCategory;  // Ã°Å¸â€ â€¢ ADDED

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final provider = context.read<PhotoProvider>();
    await provider.loadPhotos();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text(TextConstants.navGallery),
        actions: [
          // Ã°Å¸â€ â€¢ Category filter button
          IconButton(
            icon: Icon(
              _selectedCategory != null ? Icons.folder : Icons.folder_outlined,
              color: _selectedCategory != null ? ColorConstants.primaryColor : null,
            ),
            onPressed: _showCategoryFilter,
          ),
          // Ã°Å¸â€ â€¢ Favorite filter button
          IconButton(
            icon: Icon(
              _showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
              color: _showFavoritesOnly ? Colors.red : null,
            ),
            onPressed: _toggleFavoriteFilter,
          ),
          // Sort button
          PopupMenuButton<bool>(
            icon: Icon(
              _sortNewestFirst ? Icons.arrow_downward : Icons.arrow_upward,
            ),
            tooltip: 'Sort',
            onSelected: (value) {
              setState(() {
                _sortNewestFirst = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: true,
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_downward,
                      size: 20,
                      color: _sortNewestFirst
                          ? ColorConstants.primaryColor
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Terbaru',
                      style: TextStyle(
                        color: _sortNewestFirst
                            ? ColorConstants.primaryColor
                            : null,
                        fontWeight: _sortNewestFirst
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: false,
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      size: 20,
                      color: !_sortNewestFirst
                          ? ColorConstants.primaryColor
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Terlama',
                      style: TextStyle(
                        color: !_sortNewestFirst
                            ? ColorConstants.primaryColor
                            : null,
                        fontWeight: !_sortNewestFirst
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<PhotoProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingIndicator();
          }

          if (provider.error != null) {
            return ErrorDisplayWidget(
              message: provider.error!,
              onRetry: _loadPhotos,
            );
          }

          final filteredPhotos = _getFilteredPhotos(provider);

          if (filteredPhotos.isEmpty) {
            return EmptyState(
              icon: Icons.photo_library_outlined,
              title: _getEmptyStateTitle(),
              message: _getEmptyStateMessage(),
              actionText: _selectedCategory != null || _showFavoritesOnly || _showMilestonesOnly
                  ? 'Hapus Filter'
                  : 'Tambah Foto',
              onAction: _selectedCategory != null || _showFavoritesOnly || _showMilestonesOnly
                  ? _clearAllFilters
                  : () => _showImageSourceDialog(context),
            );
          }

          // Group photos by month
          final groupedPhotos = _groupPhotosByMonth(filteredPhotos);

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: groupedPhotos.length,
            itemBuilder: (context, index) {
              final monthYear = groupedPhotos.keys.elementAt(index);
              final photos = groupedPhotos[monthYear]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    child: Text(
                      monthYear,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Photo grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: photos.length,
                    itemBuilder: (context, photoIndex) {
                      final photo = photos[photoIndex];
                      final globalIndex =
                          filteredPhotos.indexOf(photo);
                      return _PhotoCard(
                        photo: photo,
                        heroTag: 'photo_${photo.id}_$globalIndex',
                        onTap: () => _navigateToDetail(photo, globalIndex),
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showImageSourceDialog(context),
        child: const Icon(Icons.add_a_photo),
      ),
    );

  String _getEmptyStateTitle() {
    if (_showFavoritesOnly) {
      return 'Belum ada foto favorit';
    }
    if (_selectedCategory != null) {
      return 'Belum ada foto di kategori ini';
    }
    if (_showMilestonesOnly) {
      return 'Belum ada milestone';
    }
    return 'Belum ada foto';
  }

  String _getEmptyStateMessage() {
    if (_showFavoritesOnly) {
      return 'Favoritkan foto untuk melihatnya di sini';
    }
    if (_selectedCategory != null) {
      return 'Tambahkan foto ke kategori $_selectedCategory';
    }
    if (_showMilestonesOnly) {
      return 'Tandai foto sebagai milestone';
    }
    return 'Mulai dokumentasikan momen berharga Anda';
  }

  /// Ã°Å¸â€ â€¢ Toggle favorite filter
  Future<void> _toggleFavoriteFilter() async {
    setState(() {
      _showFavoritesOnly = !_showFavoritesOnly;
      if (_showFavoritesOnly) {
        _showMilestonesOnly = false;
      }
    });
    await _loadPhotos();
  }

  /// âœ… UPDATED: Show category filter with CategoryProvider
  Future<void> _showCategoryFilter() async {
    final categoryProvider = context.read<CategoryProvider>();
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.uid;
    
    if (userId == null) {
      return;
    }
    
    // Load categories if not loaded
    if (categoryProvider.categories.isEmpty) {
      await categoryProvider.loadCategories(userId);
    }
    
    final photoCategories = categoryProvider.photoCategories;
    
    if (!mounted) {
      return;
    }
    
    if (photoCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Belum ada kategori tersedia'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    final selected = await showModalBottomSheet<CategoryEntity>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Kategori',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_selectedCategory != null)
                  TextButton(
                    onPressed: () => Navigator.pop(context, null),
                    child: const Text('Hapus Filter'),
                  ),
              ],
            ),
          ),
          const Divider(),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: photoCategories.length,
              itemBuilder: (context, index) {
                final category = photoCategories[index];
                final isSelected = _selectedCategory == category.name;
                
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(int.parse(category.colorHex.replaceFirst('#', '0xFF'))).withValues (alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getIconData(category.icon),
                      color: Color(int.parse(category.colorHex.replaceFirst('#', '0xFF'))),
                    ),
                  ),
                  title: Text(
                    category.name,
                    style: TextStyle(
                      color: isSelected ? ColorConstants.primaryColor : null,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected 
                      ? const Icon(Icons.check, color: ColorConstants.primaryColor) 
                      : null,
                  onTap: () => Navigator.pop(context, category),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
    
    if (selected != null && mounted) {
      setState(() {
        _selectedCategory = selected.name;
        if (_selectedCategory != null) {
          _showMilestonesOnly = false;
          _showFavoritesOnly = false;
        }
      });
      await _loadPhotos();
    } else if (selected == null && _selectedCategory != null && mounted) {
      // User cleared filter
      setState(() {
        _selectedCategory = null;
      });
      await _loadPhotos();
    }
  }

  // âœ… Helper method untuk convert icon string ke IconData
  IconData _getIconData(String iconName) {
    const iconMap = {
      'restaurant': Icons.restaurant,
      'bedtime': Icons.bedtime,
      'medical_services': Icons.medical_services,
      'toys': Icons.toys,
      'cake': Icons.cake,
      'beach_access': Icons.beach_access,
      'family_restroom': Icons.family_restroom,
      'stars': Icons.stars,
      'wb_sunny': Icons.wb_sunny,
      'more_horiz': Icons.more_horiz,
      'sports': Icons.sports,
    };
    return iconMap[iconName] ?? Icons.folder;
}

  /// Ã°Å¸â€ â€¢ Clear all filters
  Future<void> _clearAllFilters() async {
    setState(() {
      _selectedCategory = null;
      _showFavoritesOnly = false;
      _showMilestonesOnly = false;
    });
    await _loadPhotos();
  }

  List<PhotoEntity> _getFilteredPhotos(PhotoProvider provider) {
    var photos = provider.photos;

    // Filter by category
    if (_selectedCategory != null) {
      photos = photos.where((p) => p.category == _selectedCategory).toList();
    }

    // Filter by favorite
    if (_showFavoritesOnly) {
      photos = photos.where((p) => p.isFavorite).toList();
    }

    // Filter by milestone
    if (_showMilestonesOnly) {
      photos = photos.where((p) => p.isMilestone).toList();
    }

    // Sort
    photos.sort((a, b) {
      if (_sortNewestFirst) {
        return b.dateTaken.compareTo(a.dateTaken);
      } else {
        return a.dateTaken.compareTo(b.dateTaken);
      }
    });

    return photos;
  }

  Map<String, List<PhotoEntity>> _groupPhotosByMonth(
    List<PhotoEntity> photos,
  ) {
    final grouped = <String, List<PhotoEntity>>{};

    for (final photo in photos) {
      final monthYear = DateFormat('MMMM yyyy', 'id_ID').format(photo.dateTaken);
      grouped.putIfAbsent(monthYear, () => []).add(photo);
    }

    return grouped;
  }

  void _navigateToDetail(PhotoEntity photo, int index) {
    // Get all filtered photos untuk swipe support
    final provider = context.read<PhotoProvider>();
    final filteredPhotos = _getFilteredPhotos(provider);
    
    Navigator.pushNamed(
      context,
      Routes.photoDetail,
      arguments: {
        'photo': photo,
        'heroTag': 'photo_${photo.id}_$index',
        'allPhotos': filteredPhotos, // NEW: pass all photos untuk swipe
      },
    ).then((_) {
      // Reload photos after returning from detail (in case photo was deleted/updated)
      _loadPhotos();
    });
  }

  /// Show dialog to choose image source (Camera or Gallery)
  Future<void> _showImageSourceDialog(BuildContext context) async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
          title: const Text('Pilih Sumber Foto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera'),
                onTap: () {
                  Navigator.pop(dialogContext, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () {
                  Navigator.pop(dialogContext, ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
    );

    if (source != null && context.mounted) {
      await _pickAndUploadImage(context, source);
    }
  }

  /// Pick image and upload
  Future<void> _pickAndUploadImage(
    BuildContext context,
    ImageSource source,
  ) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,      // Ã°Å¸â€Â§ Reduce dari 1920 ke 1024
        maxHeight: 1024,     // Ã°Å¸â€Â§ Reduce dari 1920 ke 1024
        imageQuality: 70,    // Ã°Å¸â€Â§ Reduce dari 85 ke 70
      );

      if (image == null) {
        return;
      }

      if (!context.mounted) {
        return;
      }

      // Get provider before async operations
      final photoProvider = context.read<PhotoProvider>();

      // Show loading indicator with message
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) => WillPopScope(
          onWillPop: () async => false,
          child: const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Mengunggah foto...',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Mohon tunggu sebentar',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );

      try {
        // Upload photo using provider
        final success = await photoProvider.uploadPhoto(
          imagePath: image.path,
          caption: '',
          isMilestone: false,
        );

        if (!context.mounted) {
          return;
        }

        // Close loading dialog
        Navigator.of(context).pop();

        if (!context.mounted) {
          return;
        }

        if (success) {
          // âœ… AUTO SYNC after successful photo upload
          final syncProvider = context.read<SyncProvider>();
          debugPrint('ðŸ”„ Gallery: Auto sync after photo upload...');
          await syncProvider.syncAll();
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto berhasil ditambahkan!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gagal menambahkan foto: ${photoProvider.errorMessage ?? "Terjadi kesalahan"}',
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (uploadError) {
        if (!context.mounted) {
          return;
        }

        // Make sure dialog is closed
        Navigator.of(context).pop();

        if (!context.mounted) {
          return;
        }

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambahkan foto: $uploadError'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      // Close loading dialog if open
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih foto: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

/// Photo Card Widget (UPDATED with favorite indicator)
class _PhotoCard extends StatelessWidget {
  const _PhotoCard({
    required this.photo,
    required this.heroTag,
    required this.onTap,
  });

  final PhotoEntity photo;
  final String heroTag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: heroTag,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo image
            _buildPhotoImage(),
            
            // Ã°Å¸â€ â€¢ Favorite indicator
            if (photo.isFavorite)
              const Positioned(
                top: 4,
                right: 4,
                child: Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 20,
                ),
              ),
            
            // Milestone badge
            if (photo.isMilestone)
              const Positioned(
                bottom: 4,
                left: 4,
                child: Icon(
                  Icons.stars,
                  color: Colors.amber,
                  size: 20,
                ),
              ),

            // Ã°Å¸â€ â€¢ Category badge
            if (photo.category != null && photo.category!.isNotEmpty)
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    photo.category!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

  Widget _buildPhotoImage() {
    // Try local file first
    if (photo.localPath != null && File(photo.localPath!).existsSync()) {
      return Image.file(
        File(photo.localPath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildCloudImage(),
      );
    }

    return _buildCloudImage();
  }

  Widget _buildCloudImage() {
    if (photo.cloudUrl == null || photo.cloudUrl!.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: photo.cloudUrl!,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[300],
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[300],
        child: const Icon(Icons.error_outline, color: Colors.red),
      ),
    );
  }
}