import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/photo_reference.dart';
import 'package:studyu_app/services/photo_gallery_service.dart';

/// A section that displays photos from the device gallery
/// taken around the specified meal time to help with recall.
class const PhotoRecallSection({
  /// The meal time to search for photos around.
  required final DateTime mealTime,

  /// Callback when a photo is tapped.
  final ValueChanged<PhotoReference>? onPhotoTap,

  /// Callback when the analyze button is tapped on a photo.
  final ValueChanged<PhotoReference>? onAnalyzePhoto,

  /// ID of the photo currently being analyzed (for loading state).
  final String? analyzingPhotoId,
  super.key,
}) extends StatefulWidget {
  /// Creates a new [PhotoRecallSection].
  this;

  @override
  State<PhotoRecallSection> createState() => _PhotoRecallSectionState();
}

class _PhotoRecallSectionState() extends State<PhotoRecallSection> {
  final PhotoGalleryService _photoService = PhotoGalleryService();
  List<PhotoReference>? _photos;
  bool _isLoading = false;
  bool _isExpanded = false;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndLoad();
  }

  @override
  void didUpdateWidget(covariant PhotoRecallSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload photos if meal time changes and we have permission
    if (oldWidget.mealTime != widget.mealTime && _hasPermission) {
      _loadPhotos();
    }
  }

  Future<void> _checkPermissionAndLoad() async {
    final hasPermission = await _photoService.hasPermission();
    if (mounted) {
      setState(() => _hasPermission = hasPermission);
    }
    if (hasPermission) {
      await _loadPhotos();
    }
  }

  Future<void> _loadPhotos() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final photos = await _photoService.getPhotosAroundTime(widget.mealTime);
      if (mounted) {
        setState(() {
          _photos = photos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _requestPermission() async {
    final granted = await _photoService.requestPermission();
    if (granted && mounted) {
      setState(() => _hasPermission = true);
      await _loadPhotos();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Collapsed state - show summary card
    if (!_isExpanded) {
      return _buildCollapsedCard(theme, l10n);
    }

    // Expanded state - show photo grid
    return _buildExpandedCard(theme, l10n);
  }

  Widget _buildCollapsedCard(ThemeData theme, AppLocalizations l10n) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: InkWell(
        onTap: () => setState(() => _isExpanded = true),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.photo_library_outlined,
                  size: 20,
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.photoRecallTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _hasPermission
                          ? l10n.photoRecallSubtitle
                          : l10n.photoRecallPermissionNeeded,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedCard(ThemeData theme, AppLocalizations l10n) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with collapse button
          InkWell(
            onTap: () => setState(() => _isExpanded = false),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer.withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.photo_library_outlined,
                      size: 20,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.photoRecallTitle,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.photoRecallTapToEnlarge,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.expand_less,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),

          // Content area
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _buildContent(theme, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme, AppLocalizations l10n) {
    // Permission not granted state
    if (!_hasPermission) {
      return _buildPermissionRequest(theme, l10n);
    }

    // Loading state
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // No photos found
    if (_photos == null || _photos!.isEmpty) {
      return _buildEmptyState(theme, l10n);
    }

    // Photo grid
    return _buildPhotoGrid(theme, l10n);
  }

  Widget _buildPermissionRequest(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.photoRecallPermissionTitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.photoRecallPermissionDescription,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _requestPermission,
            child: Text(l10n.grantPermission),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.hide_image_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.photoRecallNoPhotos,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.photoRecallNoPhotosSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(ThemeData theme, AppLocalizations l10n) {
    final timeString =
        '${widget.mealTime.hour.toString().padLeft(2, '0')}:${widget.mealTime.minute.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time info banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.photoRecallTimeInfo(timeString),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _photos!.length,
          itemBuilder: (context, index) {
            final photo = _photos![index];
            return _PhotoThumbnail(
              photo: photo,
              onTap: () => widget.onPhotoTap?.call(photo),
              onAnalyze: widget.onAnalyzePhoto != null
                  ? () => widget.onAnalyzePhoto!.call(photo)
                  : null,
              isAnalyzing: widget.analyzingPhotoId == photo.id,
            );
          },
        ),
      ],
    );
  }
}

class const _PhotoThumbnail({
  required final PhotoReference photo,
  final VoidCallback? onTap,
  final VoidCallback? onAnalyze,
  final bool isAnalyzing = false,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo thumbnail
            FutureBuilder<Uint8List?>(
              future: AssetEntity(id: photo.id, typeInt: 1, width: 0, height: 0)
                  .thumbnailDataWithSize(
                    const ThumbnailSize(300, 300),
                    quality: 80,
                  ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ColoredBox(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasData && snapshot.data != null) {
                  return Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return ColoredBox(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.error),
                      );
                    },
                  );
                }

                return ColoredBox(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.image_not_supported),
                );
              },
            ),

            // Analyze button overlay
            if (onAnalyze != null)
              Positioned(
                top: 4,
                right: 4,
                child: _AnalyzeButton(
                  onTap: onAnalyze!,
                  isAnalyzing: isAnalyzing,
                  tooltip: l10n.analyzePhotoTooltip,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class const _AnalyzeButton({
  required final VoidCallback onTap,
  required final String tooltip,
  final bool isAnalyzing = false,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: isAnalyzing ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isAnalyzing
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: isAnalyzing
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: theme.colorScheme.onPrimary,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
