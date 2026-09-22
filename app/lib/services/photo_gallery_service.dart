import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:studyu_app/models/photo_reference.dart';

/// Service for querying device photo gallery.
class PhotoGalleryService() {
  /// Local midnight boundaries for the calendar date containing [date].
  static ({DateTime start, DateTime end}) localDayRange(DateTime date) => (
    start: DateTime(date.year, date.month, date.day),
    end: DateTime(date.year, date.month, date.day + 1),
  );

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

  /// Get all photos taken on the local calendar date.
  Future<List<PhotoReference>> getPhotosForDate(DateTime date) async {
    final hasAccess = await hasPermission();
    if (!hasAccess) return [];

    final range = localDayRange(date);
    final filterOption = FilterOptionGroup(
      createTimeCond: DateTimeCond(min: range.start, max: range.end),
      orders: [const OrderOption()],
    );
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: filterOption,
    );
    if (albums.isEmpty) return [];

    final album = albums.firstWhere(
      (album) => album.isAll,
      orElse: () => albums.first,
    );
    final count = await album.assetCountAsync;
    if (count == 0) return [];
    final assets = await album.getAssetListPaged(page: 0, size: count);

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
