import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// PhotoGrid
/// Grid layout for displaying photo gallery with lazy loading.
/// Supports different grid configurations and photo selection.
///
/// Features:
/// - Responsive grid (2-4 columns)
/// - Lazy loading with placeholders
/// - Cached images
/// - Date section headers
/// - Milestone badges
/// - Selection mode
/// - Pull to refresh
class PhotoGrid extends StatelessWidget {

  const PhotoGrid({
    super.key,
    required this.photos,
    this.crossAxisCount = 3,
    this.spacing = 4,
    this.showHeaders = true,
    this.selectionMode = false,
    this.selectedPhotoIds = const {},
    this.onPhotoTap,
    this.onPhotoSelected,
    this.isLoading = false,
  });
  final List<PhotoGridItem> photos;
  final int crossAxisCount;
  final double spacing;
  final bool showHeaders;
  final bool selectionMode;
  final Set<String> selectedPhotoIds;
  final Function(String)? onPhotoTap;
  final Function(String, bool)? onPhotoSelected;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingGrid();
    }

    if (photos.isEmpty) {
      return _buildEmptyState(context);
    }

    if (showHeaders) {
      return _buildGridWithHeaders();
    }

    return _buildSimpleGrid();
  }

  Widget _buildSimpleGrid() => GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 1.0,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        return _buildPhotoTile(photos[index]);
      },
    );

  Widget _buildGridWithHeaders() {
    // Group photos by date
    final groupedPhotos = <String, List<PhotoGridItem>>{};
    for (final photo in photos) {
      final dateKey = _formatDateHeader(photo.createdAt);
      groupedPhotos.putIfAbsent(dateKey, () => []).add(photo);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: groupedPhotos.length,
      itemBuilder: (context, sectionIndex) {
        final dateKey = groupedPhotos.keys.elementAt(sectionIndex);
        final sectionPhotos = groupedPhotos[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                dateKey,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Photo grid for this section
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(4),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: 1,
              ),
              itemCount: sectionPhotos.length,
              itemBuilder: (context, index) => _buildPhotoTile(sectionPhotos[index]),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPhotoTile(PhotoGridItem photo) {
    final isSelected = selectedPhotoIds.contains(photo.id);

    return GestureDetector(
      onTap: () {
        if (selectionMode && onPhotoSelected != null) {
          onPhotoSelected!(photo.id, !isSelected);
        } else if (onPhotoTap != null) {
          onPhotoTap!(photo.id);
        }
      },
      onLongPress: () {
        if (onPhotoSelected != null) {
          onPhotoSelected!(photo.id, true);
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Photo image
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CachedNetworkImage(
              imageUrl: photo.thumbnailUrl ?? photo.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          // Selection overlay
          if (selectionMode)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey[400]!,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
          // Milestone badge
          if (photo.isMilestone)
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.star,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingGrid() => GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 1.0,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );

  Widget _buildEmptyState(BuildContext context) => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No photos yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start capturing your precious moments!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      final months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }
}

/// PhotoGridItem
/// Data model for photo grid item
class PhotoGridItem {

  const PhotoGridItem({
    required this.id,
    required this.imageUrl,
    this.thumbnailUrl,
    required this.createdAt,
    this.caption,
    this.isMilestone = false,
  });
  final String id;
  final String imageUrl;
  final String? thumbnailUrl;
  final DateTime createdAt;
  final String? caption;
  final bool isMilestone;
}

/// AdaptivePhotoGrid
/// Grid that adapts columns based on screen width
class AdaptivePhotoGrid extends StatelessWidget {

  const AdaptivePhotoGrid({
    super.key,
    required this.photos,
    this.onPhotoTap,
    this.isLoading = false,
  });
  final List<PhotoGridItem> photos;
  final Function(String)? onPhotoTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        if (constraints.maxWidth < 400) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth < 800) {
          crossAxisCount = 4;
        } else {
          crossAxisCount = 6;
        }

        return PhotoGrid(
          photos: photos,
          crossAxisCount: crossAxisCount,
          onPhotoTap: onPhotoTap,
          isLoading: isLoading,
        );
      },
    );
}

/// PhotoGridHeader
/// Header with filters and view options
class PhotoGridHeader extends StatelessWidget {

  const PhotoGridHeader({
    super.key,
    required this.photoCount,
    required this.showMilestonesOnly,
    required this.onToggleMilestones,
    this.onSort,
    required this.isGridView,
    required this.onToggleView,
  });
  final int photoCount;
  final bool showMilestonesOnly;
  final VoidCallback onToggleMilestones;
  final VoidCallback? onSort;
  final bool isGridView;
  final VoidCallback onToggleView;

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Photo count
          Text(
            '$photoCount ${photoCount == 1 ? 'photo' : 'photos'}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Spacer(),
          // Milestones filter
          FilterChip(
            label: const Text('Milestones'),
            selected: showMilestonesOnly,
            onSelected: (_) => onToggleMilestones(),
            avatar: Icon(
              Icons.star,
              size: 16,
              color: showMilestonesOnly ? Colors.amber : Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          // Sort button
          if (onSort != null)
            IconButton(
              icon: const Icon(Icons.sort),
              onPressed: onSort,
              tooltip: 'Sort',
            ),
          // View toggle
          IconButton(
            icon: Icon(isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: onToggleView,
            tooltip: isGridView ? 'List view' : 'Grid view',
          ),
        ],
      ),
    );
}