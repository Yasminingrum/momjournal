import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/photo_entity.dart';
import '../../providers/photo_provider.dart';
import '../../widgets/dialogs/confirmation_dialog.dart';
import '../../widgets/dialogs/info_dialog.dart';

class PhotoDetailScreen extends StatefulWidget {

  const PhotoDetailScreen({
    required this.photo, 
    required this.heroTag, 
    super.key,
  });
  
  final PhotoEntity photo;
  final String heroTag;

  @override
  State<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<PhotoDetailScreen> {
  late TextEditingController _captionController;
  bool _isEditingCaption = false;

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController(text: widget.photo.caption);
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photoProvider = context.watch<PhotoProvider>();
    
    // Get updated photo from provider (in case it changed)
    final currentPhoto = photoProvider.photos
        .firstWhere(
          (p) => p.id == widget.photo.id,
          orElse: () => widget.photo,
        );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // 🆕 Favorite button
          IconButton(
            icon: Icon(
              currentPhoto.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: currentPhoto.isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: () => _toggleFavorite(context, currentPhoto),
          ),
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _handleDelete(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Photo with hero animation
          Expanded(
            child: Center(
              child: Hero(
                tag: widget.heroTag,
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4,
                  child: _buildPhotoImage(currentPhoto),
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
                // 🆕 Caption editor
                _buildCaptionSection(context, currentPhoto),
                
                const SizedBox(height: 12),
                
                // 🆕 Category selector
                _buildCategorySection(context, currentPhoto),

                const SizedBox(height: 12),

                // Milestone badge
                if (currentPhoto.isMilestone)
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
                  _formatDate(currentPhoto.dateTaken),
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

  /// 🆕 Build caption section with edit capability
  Widget _buildCaptionSection(BuildContext context, PhotoEntity photo) {
    if (_isEditingCaption) {
      return Row(
        children: [
          Expanded(
            child: TextField(
              controller: _captionController,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'Tambahkan caption...',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
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

  /// 🆕 Build category section
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

  /// 🆕 Toggle favorite status
  Future<void> _toggleFavorite(BuildContext context, PhotoEntity photo) async {
    final provider = context.read<PhotoProvider>();
    final success = await provider.togglePhotoFavorite(photo.id);
    
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
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

  /// 🆕 Save caption
  Future<void> _saveCaption(BuildContext context, PhotoEntity photo) async {
    final newCaption = _captionController.text.trim();
    final provider = context.read<PhotoProvider>();
    
    final success = await provider.updatePhotoCaption(photo.id, newCaption);
    
    if (mounted && success) {
      setState(() {
        _isEditingCaption = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Caption berhasil disimpan'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// 🆕 Show category picker
  Future<void> _showCategoryPicker(BuildContext context, PhotoEntity photo) async {
    final provider = context.read<PhotoProvider>();
    final categories = await provider.getCategories();
    
    // Predefined categories
    final defaultCategories = [
      'Ulang Tahun',
      'Liburan',
      'Milestone',
      'Keluarga',
      'Teman',
      'Acara Khusus',
    ];
    
    // Combine default with existing
    final allCategories = {...defaultCategories, ...categories}.toList()..sort();
    
    if (!mounted) {
      return;
    }
    
    final selected = await showModalBottomSheet<String>(
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
                    onPressed: () => Navigator.pop(context, ''),
                    child: const Text('Hapus'),
                  ),
              ],
            ),
          ),
          const Divider(color: Colors.grey),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: allCategories.length,
              itemBuilder: (context, index) {
                final category = allCategories[index];
                final isSelected = category == photo.category;
                
                return ListTile(
                  leading: Icon(
                    Icons.folder,
                    color: isSelected ? Colors.blue : Colors.grey,
                  ),
                  title: Text(
                    category,
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
          const SizedBox(height: 16),
        ],
      ),
    );
    
    if (selected != null && mounted) {
      final newCategory = selected.isEmpty ? null : selected;
      final success = await provider.updatePhotoCategory(photo.id, newCategory);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newCategory == null 
                  ? 'Kategori dihapus' 
                  : 'Kategori diubah menjadi: $newCategory',
            ),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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

  Future<void> _handleDelete(BuildContext context) async {
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
      final success = await provider.deletePhoto(widget.photo.id);

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