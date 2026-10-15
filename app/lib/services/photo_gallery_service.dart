import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:studyu_app/models/photo_reference.dart';

/// Service for querying device photo gallery.
class PhotoGalleryService() {
  /// Time window around meal time to search for photos (in hours).
  static const int _defaultTimeWindowHours = 2;

  /// Maximum number of photos to return.
  static const int _maxPhotos = 20;

  /// Check if photo gallery permission is granted.
  Future<bool> hasPermission() async {
    // On Android, check the specific permission based on API level
    if (Platform.isAndroid) {
      final photosStatus = await Permission.photos.status;
      if (photosStatus.isGranted || photosStatus.isLimited) return true;
      final storageStatus = await Permission.storage.status;
      return storageStatus.isGranted || storageStatus.isLimited;
    }
    // On iOS, use PhotoManager's check
    final state = await PhotoManager.getPermissionState(
      requestOption: const PermissionRequestOption(),
    );
    return state.isAuth || state == PermissionState.limited;
  }

  /// Request photo gallery permission.
  Future<bool> requestPermission() async {
    // On Android, request the specific permission
    if (Platform.isAndroid) {
      final photosStatus = await Permission.photos.request();
      if (photosStatus.isGranted || photosStatus.isLimited) return true;
      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted || storageStatus.isLimited;
    }
    // On iOS, use PhotoManager's request
    final state = await PhotoManager.requestPermissionExtend();
    return state.isAuth || state == PermissionState.limited;
  }

  /// Get photos taken within a time window around the specified time.
  Future<List<PhotoReference>> getPhotosAroundTime(
    DateTime centerTime, {
    int windowHours = _defaultTimeWindowHours,
  }) async {
    final hasAccess = await hasPermission();
    if (!hasAccess) {
      return [];
    }

    final startTime = centerTime.subtract(Duration(hours: windowHours));
    final endTime = centerTime.add(Duration(hours: windowHours));

    // Configure filter options for time range
    final filterOption = FilterOptionGroup(
      createTimeCond: DateTimeCond(min: startTime, max: endTime),
      orders: [const OrderOption()],
    );

    // Query only images
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: filterOption,
    );

    if (albums.isEmpty) {
      return [];
    }

    // Get assets from the first album (typically "Recent" or "All Photos")
    final assets = await albums.first.getAssetListPaged(
      page: 0,
      size: _maxPhotos,
    );

    // Convert to PhotoReference objects
    return assets
        .map(
          (asset) => PhotoReference(
            id: asset.id,
            createDateTime: asset.createDateTime,
          ),
        )
        .toList();
  }

  /// Get an AssetEntity by ID for displaying the photo.
  Future<AssetEntity?> getAsset(String photoId) {
    return AssetEntity.fromId(photoId);
  }
}
