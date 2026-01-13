import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/photo_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/photo_provider.dart';
import '../../providers/sync_provider.dart';
import '../../widgets/dialogs/confirmation_dialog.dart';
import '../../widgets/dialogs/info_dialog.dart';

class PhotoDetailScreen extends StatefulWidget {

  const PhotoDetailScreen({
    required this.photo, 
    required this.heroTag,
    this.allPhotos, // New: untuk swipe support
    super.key,
  });
  
  final PhotoEntity photo;
  final String heroTag;
  final List<PhotoEntity>? allPhotos; // New: list semua foto untuk swipe

  @override
  State<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<PhotoDetailScreen> {
  late TextEditingController _captionController;
  bool _isEditingCaption = false;
  late PageController _pageController; // New: untuk swipe
  late int _currentIndex; // New: track current photo index
  late PhotoEntity _currentPhoto; // New: track current photo

  @override
  void initState() {
    super.initState();
    _currentPhoto = widget.photo;
    _captionController = TextEditingController(text: _currentPhoto.caption);
    
    // Setup page controller untuk swipe
    if (widget.allPhotos != null) {
      _currentIndex = widget.allPhotos!.indexWhere((p) => p.id == widget.photo.id);
      if (_currentIndex == -1) {
        _currentIndex = 0;
      }
      _pageController = PageController(initialPage: _currentIndex);
    } else {
      _currentIndex = 0;
      _pageController = PageController();
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    _pageController.dispose(); // New: cleanup page controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photoProvider = context.watch<PhotoProvider>();
    
    // Get updated photo from provider (in case it changed)
    final currentPhotoFromProvider = photoProvider.photos
        .firstWhere(
          (p) => p.id == _currentPhoto.id,
          orElse: () => _currentPhoto,
        );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Favorite button
          IconButton(
            icon: Icon(
              currentPhotoFromProvider.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: currentPhotoFromProvider.isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: () => _toggleFavorite(context, currentPhotoFromProvider),
          ),
          // Milestone button
          IconButton(
            icon: Icon(
              currentPhotoFromProvider.isMilestone ? Icons.stars : Icons.stars_outlined,
              color: currentPhotoFromProvider.isMilestone ? Colors.amber : Colors.white,
            ),
            onPressed: () => _toggleMilestone(context, currentPhotoFromProvider),
          ),
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _handleDelete,
          ),
        ],
      ),
      body: Column(
        children: [
          // Photo dengan swipe support
          Expanded(
            child: widget.allPhotos != null && widget.allPhotos!.isNotEmpty
                ? PageView.builder(
                    controller: _pageController,
                    itemCount: widget.allPhotos!.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                        _currentPhoto = widget.allPhotos![index];
                        _captionController.text = _currentPhoto.caption ?? '';
                        _isEditingCaption = false;
                      });
                    },
                    itemBuilder: (context, index) {
                      final photo = widget.allPhotos![index];
                      return Center(
                        child: Hero(
                          tag: '${widget.heroTag}_$index',
                          child: InteractiveViewer(
                            minScale: 0.5,
                            maxScale: 4,
                            child: _buildPhotoImage(photo),
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Hero(
                      tag: widget.heroTag,
                      child: InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 4,
                        child: _buildPhotoImage(currentPhotoFromProvider),
                      ),
                    ),
                  ),
          ),

          // Photo info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.black87,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Page indicator (jika ada multiple photos)
                if (widget.allPhotos != null && widget.allPhotos!.length > 1)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        '${_currentIndex + 1} / ${widget.allPhotos!.length}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                
                // Caption editor
                _buildCaptionSection(context, currentPhotoFromProvider),
                
                const SizedBox(height: 12),
                
                // Category selector
                _buildCategorySection(context, currentPhotoFromProvider),

                const SizedBox(height: 12),

                // Milestone badge
                if (currentPhotoFromProvider.isMilestone)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.stars, size: 16, color: Colors.black87),
                        SizedBox(width: 4),
                        Text(
                          'Milestone',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 8),

                // Date
                Text(
                  _formatDate(currentPhotoFromProvider.dateTaken),
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ///Build caption section with edit capability
  Widget _buildCaptionSection(BuildContext context, PhotoEntity photo) {
    if (_isEditingCaption) {
      return Row(
        children: [
          Expanded(
            child: TextField(
              controller: _captionController,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Tambahkan caption...',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white54),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                filled: true,
                fillColor: Colors.black54,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              maxLines: 3,
              minLines: 1,
              autofocus: true,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: () => _saveCaption(context, photo),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () {
              setState(() {
                _isEditingCaption = false;
                _captionController.text = photo.caption ?? '';
              });
            },
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _isEditingCaption = true;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade700),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                photo.caption?.isEmpty ?? true 
                    ? 'Tap untuk menambahkan caption...' 
                    : photo.caption!,
                style: TextStyle(
                  color: photo.caption?.isEmpty ?? true 
                      ? Colors.grey 
                      : Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(Icons.edit, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  /// Build category section
  Widget _buildCategorySection(BuildContext context, PhotoEntity photo) => GestureDetector(
      onTap: () => _showCategoryPicker(context, photo),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade700),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.folder_outlined, color: Colors.grey, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                photo.category?.isEmpty ?? true 
                    ? 'Pilih kategori...' 
                    : photo.category!,
                style: TextStyle(
                  color: photo.category?.isEmpty ?? true 
                      ? Colors.grey 
                      : Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );

  /// Toggle favorite status
  Future<void> _toggleFavorite(BuildContext context, PhotoEntity photo) async {
    final provider = context.read<PhotoProvider>();
    final messenger = ScaffoldMessenger.of(context);
    
    final success = await provider.togglePhotoFavorite(photo.id);
    
    if (!mounted) {
      return;
    }
    
    if (success) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            photo.isFavorite 
                ? 'Dihapus dari favorit' 
                : 'Ditambahkan ke favorit',
          ),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Toggle milestone status
  Future<void> _toggleMilestone(BuildContext context, PhotoEntity photo) async {
    final provider = context.read<PhotoProvider>();
    final messenger = ScaffoldMessenger.of(context);
    
    final updatedPhoto = photo.copyWith(
      isMilestone: !photo.isMilestone,
      updatedAt: DateTime.now(),
    );
    
    final success = await provider.updatePhoto(updatedPhoto);
    
    if (!mounted) {
      return;
    }
    
    if (success) {
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                updatedPhoto.isMilestone ? Icons.stars : Icons.stars_outlined,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                updatedPhoto.isMilestone 
                    ? 'Ditandai sebagai Milestone' 
                    : 'Milestone dihapus',
              ),
            ],
          ),
          backgroundColor: updatedPhoto.isMilestone ? Colors.amber.shade700 : Colors.grey.shade700,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Gagal mengubah status milestone'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Save caption
  Future<void> _saveCaption(BuildContext context, PhotoEntity photo) async {
    final newCaption = _captionController.text.trim();
    final provider = context.read<PhotoProvider>();
    final messenger = ScaffoldMessenger.of(context);
    
    final success = await provider.updatePhotoCaption(photo.id, newCaption);
    
    if (!mounted) {
      return;
    }
    
    if (success) {
      if (mounted) {
        setState(() {
          _isEditingCaption = false;
        });
      }
      
      if (!mounted) {
        return;
      }
      
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Caption berhasil disimpan'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Show category picker
  /// UPDATED: Show category picker using CategoryProvider
  Future<void> _showCategoryPicker(BuildContext context, PhotoEntity photo) async {
    final categoryProvider = context.read<CategoryProvider>();
    final authProvider = context.read<AuthProvider>();
    final photoProvider = context.read<PhotoProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final userId = authProvider.user?.uid;
    
    if (userId == null) {
      return;
    }
    
    // Load categories if not loaded yet
    if (categoryProvider.categories.isEmpty) {
      await categoryProvider.loadCategories(userId);
    }
    
    final photoCategories = categoryProvider.photoCategories;
    
    if (!mounted) {
      return;
    }
    
    if (photoCategories.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Belum ada kategori tersedia'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    final selected = await showModalBottomSheet<CategoryEntity?>(
      context: context,
      backgroundColor: Colors.grey.shade900,
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
                  'Pilih Kategori',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (photo.category != null)
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hapus'),
                  ),
              ],
            ),
          ),
          const Divider(color: Colors.grey),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: photoCategories.length,
              itemBuilder: (context, index) {
                final category = photoCategories[index];
                final isSelected = photo.category == category.name;
                
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _parseColor(category.colorHex).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getIconData(category.icon),
                      color: _parseColor(category.colorHex),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    category.name,
                    style: TextStyle(
                      color: isSelected ? Colors.blue : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected 
                      ? const Icon(Icons.check, color: Colors.blue) 
                      : null,
                  onTap: () => Navigator.pop(context, category),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Selesai',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    
    if (!mounted) {
      return;
    }
    
    if (selected != null) {
      // User selected a category
      final success = await photoProvider.updatePhotoCategory(photo.id, selected.name);
      
      if (!mounted) {
        return;
      }
      
      if (success) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Kategori diubah menjadi: ${selected.name}'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else if (photo.category != null) {
      // User clicked "Hapus" - remove category
      final success = await photoProvider.updatePhotoCategory(photo.id, null);
      
      if (!mounted) {
        return;
      }
      
      if (success) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Kategori dihapus'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Helper: Parse color hex string to Color
  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  /// Helper: Convert icon name string to IconData
  IconData _getIconData(String iconName) {
    const iconMap = {
      'restaurant': Icons.restaurant,
      'bedtime': Icons.bedtime,
      'medical_services': Icons.medical_services,
      'toys': Icons.toys,
      'sports': Icons.sports,
      'cake': Icons.cake,
      'beach_access': Icons.beach_access,
      'family_restroom': Icons.family_restroom,
      'stars': Icons.stars,
      'wb_sunny': Icons.wb_sunny,
      'more_horiz': Icons.more_horiz,
      'photo_library': Icons.photo_library,
    };
    return iconMap[iconName] ?? Icons.folder;
  }

  Widget _buildPhotoImage(PhotoEntity photo) {
    final hasLocalFile = photo.localPath != null && 
                         File(photo.localPath!).existsSync();
    
    if (hasLocalFile) {
      return Image.file(
        File(photo.localPath!),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            _buildCloudImage(photo),
      );
    } else {
      return _buildCloudImage(photo);
    }
  }

  Widget _buildCloudImage(PhotoEntity photo) {
    if (photo.cloudUrl == null || photo.cloudUrl!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 64, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Foto tidak tersedia',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: photo.cloudUrl!,
      fit: BoxFit.contain,
      placeholder: (context, url) => const Center(
        child: CircularProgressIndicator(),
      ),
      errorWidget: (context, url, error) => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 8),
            Text(
              'Gagal memuat foto',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hari ini';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmationDialog(
        title: 'Hapus Foto',
        message: 'Apakah Anda yakin ingin menghapus foto ini?',
        confirmText: 'Hapus',
        cancelText: 'Batal',
      ),
    );

    if ((confirmed ?? false) && mounted) {
      final provider = context.read<PhotoProvider>();
      
      // Delete dengan remote sync support
      final success = await provider.deletePhoto(
        _currentPhoto.id,
        onDeleteRemote: (photoId) async {
          // Hapus dari Firebase juga via SyncProvider
          try {
            final syncProvider = context.read<SyncProvider>();
            await syncProvider.deletePhotoRemote(photoId);
          } catch (e) {
            debugPrint('Failed to delete from remote (SyncProvider not available): $e');
            // Continue even if remote deletion fails
          }
        },
      );

      if (mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto berhasil dihapus'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          await showDialog<void>(
            context: context,
            builder: (context) => InfoDialog(
              title: 'Gagal',
              message: provider.error ?? 'Gagal menghapus foto',
            ),
          );
        }
      }
    }
  }
}