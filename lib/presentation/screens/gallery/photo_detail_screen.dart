import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/photo_entity.dart';
import '../../providers/photo_provider.dart';
import '../../widgets/dialogs/confirmation_dialog.dart';
import '../../widgets/dialogs/info_dialog.dart';

class PhotoDetailScreen extends StatelessWidget {

  const PhotoDetailScreen({
    required this.photo, required this.heroTag, super.key,
  });
  
  final PhotoEntity photo;
  final String heroTag;

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
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
                tag: heroTag,
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4,
                  child: _buildPhotoImage(),
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
                // Caption
                if (photo.caption != null && photo.caption!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      photo.caption!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),

                // Milestone badge
                if (photo.isMilestone)
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
                        SizedBox(width: 6),
                        Text(
                          'Momen Spesial',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),

                // Date
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(photo.capturedAt),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

  /// Build photo image - prioritas: localPath > cloudUrl
  Widget _buildPhotoImage() {
    // Prioritaskan local file jika ada
    if (photo.localPath != null && photo.localPath!.isNotEmpty) {
      final file = File(photo.localPath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        );
      }
    }

    // Fallback ke cloud URL jika ada
    if (photo.cloudUrl != null && photo.cloudUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: photo.cloudUrl!,
        fit: BoxFit.contain,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
        errorWidget: (context, url, error) => _buildErrorWidget(),
      );
    }

    // Jika tidak ada keduanya, tampilkan error
    return _buildErrorWidget();
  }

  Widget _buildErrorWidget() => const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            'Foto tidak dapat dimuat',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await showDeleteConfirmation(
      context,
      itemName: 'Foto',
      message: 'Foto yang dihapus tidak dapat dikembalikan.',
    );

    if (!confirmed || !context.mounted) {
      return;
    }

    final provider = context.read<PhotoProvider>();
    final success = await provider.deletePhoto(photo.id);

    if (!context.mounted) {
      return;
    }

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto berhasil dihapus'),
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

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}