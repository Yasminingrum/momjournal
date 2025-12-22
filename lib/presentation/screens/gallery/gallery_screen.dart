import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '/core/constants/color_constants.dart';
import '/core/constants/text_constants.dart';
import '/domain/entities/photo_entity.dart';
import '/presentation/providers/photo_provider.dart';
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
  bool _sortNewestFirst = true;

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
        builder: (context, provider, child) {
          if (provider.isLoading && provider.photos.isEmpty) {
            return const _LoadingGrid();
          }

          if (provider.error != null) {
            return ErrorDisplayWidget(
              message: provider.error!,
              onRetry: _loadPhotos,
            );
          }

          if (provider.photos.isEmpty) {
            return const EmptyPhotoState();
          }

          return RefreshIndicator(
            onRefresh: _loadPhotos,
            child: Column(
              children: [
                // Filter chips
                _buildFilterChips(provider),
                // Photo grid
                Expanded(
                  child: _buildPhotoGrid(provider),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showImageSourceDialog(context),
        tooltip: TextConstants.addPhoto,
        child: const Icon(Icons.add_a_photo),
      ),
    );

  Widget _buildFilterChips(PhotoProvider provider) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Photo count
          Expanded(
            child: Text(
              '${_getFilteredPhotos(provider).length} Foto',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
          // Milestone filter chip
          FilterChip(
            label: const Text('Momen Spesial'),
            selected: _showMilestonesOnly,
            onSelected: (selected) {
              setState(() {
                _showMilestonesOnly = selected;
              });
            },
            avatar: Icon(
              Icons.stars,
              size: 18,
              color: _showMilestonesOnly ? Colors.white : Colors.amber,
            ),
            selectedColor: Colors.amber,
            checkmarkColor: Colors.white,
            labelStyle: TextStyle(
              color: _showMilestonesOnly ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );

  Widget _buildPhotoGrid(PhotoProvider provider) {
    final photos = _getFilteredPhotos(provider);
    final groupedPhotos = _groupPhotosByMonth(photos);

    if (photos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_alt_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada foto dengan filter ini',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _showMilestonesOnly = false;
                });
              },
              child: const Text('Hapus Filter'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedPhotos.length,
      itemBuilder: (context, index) {
        final entry = groupedPhotos.entries.elementAt(index);
        final monthYear = entry.key;
        final monthPhotos = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month header
            Padding(
              padding: const EdgeInsets.only(bottom: 12, top: 8),
              child: Text(
                monthYear,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            // Photo grid for this month
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: monthPhotos.length,
              itemBuilder: (context, photoIndex) {
                final photo = monthPhotos[photoIndex];
                return _PhotoCard(
                  photo: photo,
                  heroTag: 'photo_${photo.id}_$index',
                  onTap: () => _navigateToDetail(photo, index),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  List<PhotoEntity> _getFilteredPhotos(PhotoProvider provider) {
    var photos = provider.photos;

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
    Navigator.pushNamed(
      context,
      Routes.photoDetail,
      arguments: {
        'photo': photo,
        'heroTag': 'photo_${photo.id}_$index',
      },
    ).then((_) {
      // Reload photos after returning from detail (in case photo was deleted)
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

  /// Pick image and upload
  Future<void> _pickAndUploadImage(
    BuildContext context,
    ImageSource source,
  ) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) {
        return;
      }

      if (!context.mounted) {
        return;
      }

      // Get provider before async operations
      final photoProvider = context.read<PhotoProvider>();

      // Show loading indicator
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) => const Center(
            child: CircularProgressIndicator(),
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

/// Photo Card Widget
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
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Photo image
                _buildImage(),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                      stops: const [0.6, 1.0],
                    ),
                  ),
                ),
                // Milestone badge
                if (photo.isMilestone)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.stars, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Spesial',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Date
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Text(
                    _formatDate(photo.dateTaken),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

  Widget _buildImage() {
    // Check if it's a local file or network URL
    if (photo.localPath != null && photo.localPath!.isNotEmpty) {
      final file = File(photo.localPath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      }
    }

    // Try network image
    if (photo.cloudUrl != null && photo.cloudUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: photo.cloudUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() => Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(
          Icons.image,
          size: 48,
          color: Colors.grey,
        ),
      ),
    );

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final photoDate = DateTime(date.year, date.month, date.day);

    if (photoDate == today) {
      return 'Hari ini';
    } else if (photoDate == yesterday) {
      return 'Kemarin';
    } else {
      return DateFormat('d MMM yyyy', 'id_ID').format(date);
    }
  }
}

/// Loading Grid Widget
class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Loading header
          ShimmerLoading(
            child: Container(
              width: 120,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Loading grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: 6,
              itemBuilder: (context, index) => ShimmerLoading(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
}