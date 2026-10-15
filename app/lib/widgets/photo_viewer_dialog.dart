import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

/// Full-screen dialog for viewing a photo in detail.
class const PhotoViewerDialog({
  /// The ID of the photo to display.
  required final String photoId,

  /// The date the photo was taken.
  required final DateTime photoDate,

  /// Optional callback triggered when the user taps "Analyze Meal".
  /// When provided, an analyze button is shown in the full-screen view.
  final VoidCallback? onAnalyze,
  super.key,
}) extends StatelessWidget {
  /// Creates a new [PhotoViewerDialog].
  this;

  /// Shows the photo viewer dialog.
  static Future<void> show(
    BuildContext context, {
    required String photoId,
    required DateTime photoDate,
    VoidCallback? onAnalyze,
  }) {
    return showDialog(
      context: context,
      builder: (_) => PhotoViewerDialog(
        photoId: photoId,
        photoDate: photoDate,
        onAnalyze: onAnalyze,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final assetEntity = AssetEntity(
      id: photoId,
      typeInt: 1,
      width: 0,
      height: 0,
    );

    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black.withValues(alpha: 0.8),
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            _formatDate(photoDate),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        floatingActionButton: onAnalyze != null
            ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.of(context).pop();
                  onAnalyze!();
                },
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Analyze Meal'),
              )
            : null,
        body: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Center(
            child: FutureBuilder<File?>(
              future: assetEntity.file,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(color: Colors.white);
                }

                if (snapshot.hasData && snapshot.data != null) {
                  return Image.file(
                    snapshot.data!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.error,
                        color: Colors.white,
                        size: 48,
                      );
                    },
                  );
                }

                // Fallback to thumbnail if file is not available
                return FutureBuilder<Uint8List?>(
                  future: assetEntity.thumbnailDataWithSize(
                    const ThumbnailSize(1024, 1024),
                    quality: 90,
                  ),
                  builder: (context, thumbSnapshot) {
                    if (thumbSnapshot.hasData && thumbSnapshot.data != null) {
                      return Image.memory(
                        thumbSnapshot.data!,
                        fit: BoxFit.contain,
                      );
                    }

                    return const Icon(
                      Icons.image_not_supported,
                      color: Colors.white,
                      size: 48,
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute';
  }
}
