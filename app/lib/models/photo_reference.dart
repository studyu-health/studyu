/// A reference to a photo from the device gallery.
class const PhotoReference({
  /// Unique identifier from photo_manager.
  required final String id,

  /// Time the photo was taken.
  required final DateTime createDateTime,

  /// Local thumbnail path for display.
  final String? thumbnailPath,

  /// Whether this photo is selected by the user.
  final bool isSelected = false,
}) {
  /// Creates a new [PhotoReference].
  this;

  /// Creates a copy of this [PhotoReference] with the given fields replaced.
  PhotoReference copyWith({
    String? id,
    DateTime? createDateTime,
    String? thumbnailPath,
    bool? isSelected,
  }) {
    return PhotoReference(
      id: id ?? this.id,
      createDateTime: createDateTime ?? this.createDateTime,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
