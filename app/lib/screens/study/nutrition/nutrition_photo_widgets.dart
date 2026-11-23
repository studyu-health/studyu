import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image;
import 'package:image_picker/image_picker.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/services/nutrition_photo_storage.dart';
import 'package:studyu_core/core.dart';

NutritionPhotoScope? nutritionPhotoScope(AppState? state) {
  final subject = state?.activeSubject;
  if (state == null ||
      state.isPreview ||
      subject == null ||
      subject.isDeleted) {
    return null;
  }
  final scope = (userId: subject.userId, subjectId: subject.id);
  return NutritionPhotoStorage.current?.owns(scope) == true ? scope : null;
}

NutritionPhotoKey? nutritionPhotoKey(
  NutritionPhotoScope? scope,
  NutritionPhotoKind kind,
  String? id,
) => scope == null || id == null ? null : NutritionPhotoKey(scope, kind, id);

Future<void> saveNutritionPhoto(
  BuildContext context,
  NutritionPhotoKey? key,
  NutritionPhotoChange? change,
) async {
  final storage = NutritionPhotoStorage.current;
  if (key == null ||
      change == null ||
      storage == null ||
      !storage.owns(key.scope)) {
    return;
  }
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context)!;
  Future<void> save() async {
    try {
      await storage.apply(key, change);
    } catch (_, stackTrace) {
      StudyULogger.warning(
        'Could not save a nutrition photo.',
        stackTrace: stackTrace,
      );
      if (!messenger.mounted || !storage.canRetry(key, change)) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.nutrition_photo_save_failed),
          action: SnackBarAction(
            label: l10n.nutrition_photo_retry,
            onPressed: save,
          ),
        ),
      );
    }
  }

  storage.stage(key, change);
  await save();
}

Future<void> retryNutritionPhotoDeletes(NutritionPhotoScope? scope) async {
  if (scope == null) return;
  try {
    await NutritionPhotoStorage.current?.retryDeletes(scope);
  } catch (_, stackTrace) {
    StudyULogger.warning(
      'Could not retry nutrition photo cleanup.',
      stackTrace: stackTrace,
    );
  }
}

Future<void> deleteNutritionPhoto(NutritionPhotoKey? key) async {
  if (key == null) return;
  try {
    await NutritionPhotoStorage.current?.deleteWithRetry(key);
  } catch (_, stackTrace) {
    StudyULogger.warning(
      'Could not queue nutrition photo cleanup.',
      stackTrace: stackTrace,
    );
  }
}

class const NutritionPhotoThumbnail({
  super.key,
  required final NutritionPhotoKey? photoKey,
  required final Widget fallback,
  final double? size,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final key = photoKey;
    if (key == null) return fallback;
    return _StoredPhoto(
      key: ValueKey(key.path),
      photoKey: key,
      builder: (context, bytes) => bytes == null
          ? fallback
          : Padding(
              padding: EdgeInsets.only(right: size == null ? 0 : 12),
              child: SizedBox(
                width: size,
                height: size,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _PhotoImage(bytes: bytes),
                ),
              ),
            ),
    );
  }
}

typedef NutritionPhotoSource = ({
  NutritionPhotoKey? photoKey,
  String? imageUrl,
});

class const NutritionPhotoGrid({
  super.key,
  required final List<NutritionPhotoSource> sources,
  required final Widget fallback,
  final double size = 48,
  final double spacing = 12,
}) extends StatefulWidget {
  @override
  State<NutritionPhotoGrid> createState() => _NutritionPhotoGridState();
}

class _NutritionPhotoGridState() extends State<NutritionPhotoGrid> {
  static const _photoLimit = 4;
  final _storage = NutritionPhotoStorage.current;
  Future<List<Widget>>? _photos;
  int _revision = 0;

  @override
  void initState() {
    super.initState();
    _storage?.changedPath.addListener(_onPhotoChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _photos ??= _loadPhotos();
  }

  @override
  void didUpdateWidget(NutritionPhotoGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    final previous = oldWidget.sources;
    final current = widget.sources;
    if (previous.length != current.length ||
        Iterable<int>.generate(current.length).any(
          (index) =>
              previous[index].photoKey?.path != current[index].photoKey?.path ||
              previous[index].imageUrl != current[index].imageUrl,
        )) {
      _reloadPhotos();
    }
  }

  @override
  void dispose() {
    _storage?.changedPath.removeListener(_onPhotoChanged);
    super.dispose();
  }

  Future<List<Widget>> _loadPhotos() async {
    final revision = _revision;
    final photos = <Widget>[];
    final remaining = widget.sources
        .where((source) => source.photoKey != null || source.imageUrl != null)
        .iterator;
    while (mounted && revision == _revision && photos.length < _photoLimit) {
      final batch = <Future<Widget?>>[
        for (
          var index = photos.length;
          index < _photoLimit && remaining.moveNext();
          index++
        )
          _loadPhoto(remaining.current, revision),
      ];
      if (batch.isEmpty) break;
      photos.addAll((await Future.wait(batch)).whereType<Widget>());
    }
    return photos;
  }

  Future<Widget?> _loadPhoto(NutritionPhotoSource source, int revision) async {
    if (source.photoKey case final key?) {
      try {
        final bytes = await _storage?.download(key);
        if (bytes != null) {
          return SizedBox.expand(
            key: ValueKey(key.path),
            child: _PhotoImage(bytes: bytes),
          );
        }
      } on Exception {
        // Use the catalog photo if the private download fails.
      }
    }
    final url = source.imageUrl;
    if (url == null || !mounted || revision != _revision) return null;
    final image = NetworkImage(url);
    var failed = false;
    await precacheImage(image, context, onError: (_, _) => failed = true);
    if (failed) return null;
    return SizedBox.expand(
      child: Image(
        image: image,
        fit: BoxFit.cover,
        excludeFromSemantics: true,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      ),
    );
  }

  void _onPhotoChanged() {
    final changedPath = _storage?.changedPath.value?.path;
    if (changedPath == null ||
        widget.sources.any((source) => source.photoKey?.path == changedPath)) {
      setState(_reloadPhotos);
    }
  }

  void _reloadPhotos() {
    _revision++;
    _photos = _loadPhotos();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Widget>>(
    key: ValueKey(_revision),
    future: _photos,
    builder: (context, snapshot) {
      final photos = snapshot.data;
      if (photos == null || photos.isEmpty) return widget.fallback;
      return Padding(
        padding: EdgeInsets.only(right: widget.spacing),
        child: SizedBox.square(
          dimension: widget.size,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _NutritionPhotoGridCells(photos: photos),
          ),
        ),
      );
    },
  );
}

class const _NutritionPhotoGridCells({required final List<Widget> photos})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (photos.length == 1) {
      return photos.single;
    }
    if (photos.length == 2 || photos.length == 3) {
      return Row(
        children: [for (final photo in photos) Expanded(child: photo)],
      );
    }
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: photos[0]),
              Expanded(child: photos[1]),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(child: photos[2]),
              Expanded(child: photos[3]),
            ],
          ),
        ),
      ],
    );
  }
}

class const NutritionPhotoEditor({
  super.key,
  final NutritionPhotoKey? photoKey,
  required final NutritionPhotoChange? change,
  required final ValueChanged<NutritionPhotoChange?> onChanged,
  required final bool enabled,
}) extends StatefulWidget {
  @override
  State<NutritionPhotoEditor> createState() => _NutritionPhotoEditorState();
}

class _NutritionPhotoEditorState() extends State<NutritionPhotoEditor> {
  bool _picking = false;

  Future<void> _pick() async {
    setState(() => _picking = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      final mobile =
          !kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.android);
      final source = mobile
          ? await showModalBottomSheet<ImageSource>(
              context: context,
              builder: (context) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.photo_camera_outlined),
                      title: Text(l10n.nutrition_photo_take),
                      onTap: () => Navigator.pop(context, ImageSource.camera),
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo_library_outlined),
                      title: Text(l10n.nutrition_photo_choose),
                      onTap: () => Navigator.pop(context, ImageSource.gallery),
                    ),
                  ],
                ),
              ),
            )
          : ImageSource.gallery;
      if (source == null || !mounted || !widget.enabled) return;
      final initialKey = widget.photoKey?.path;
      final file = await ImagePicker().pickImage(
        source: source,
        requestFullMetadata: false,
      );
      if (file == null || !mounted || !widget.enabled) return;
      if (await file.length() > 30000000) {
        throw const FormatException('The source photo is too large.');
      }
      final bytes = await prepareNutritionPhoto(await file.readAsBytes());
      if (mounted && widget.enabled && initialKey == widget.photoKey?.path) {
        widget.onChanged(NutritionPhotoChange.replace(bytes));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.nutrition_photo_invalid)));
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Widget _controls(BuildContext context, Uint8List? stored) {
    final l10n = AppLocalizations.of(context)!;
    final key = widget.photoKey;
    final pending = key == null
        ? null
        : NutritionPhotoStorage.current?.pendingChange(key);
    final change = widget.change ?? pending;
    final bytes = change == null ? stored : change.bytes;
    final enabled = widget.enabled && !_picking;
    final actionChildren = <Widget>[
      if (bytes != null) ...[
        TextButton.icon(
          onPressed: enabled ? _pick : null,
          icon: const Icon(Icons.add_a_photo_outlined),
          label: Text(l10n.nutrition_photo_replace),
        ),
        TextButton(
          onPressed: enabled
              ? () => widget.onChanged(
                  stored == null && pending == null
                      ? null
                      : const NutritionPhotoChange.remove(),
                )
              : null,
          child: Text(l10n.nutrition_photo_remove),
        ),
      ],
      if (pending != null && widget.change == null)
        TextButton(
          onPressed: enabled
              ? () => saveNutritionPhoto(context, key, pending)
              : null,
          child: Text(l10n.nutrition_photo_retry),
        ),
      if (_picking)
        const SizedBox.square(
          dimension: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
    ];
    final actions = actionChildren.isEmpty
        ? null
        : Wrap(
            alignment: bytes == null
                ? WrapAlignment.start
                : WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            children: actionChildren,
          );
    if (bytes == null) {
      return _NutritionPhotoFrame(
        photo: _EmptyPhotoPlaceholder(
          onPressed: enabled ? _pick : null,
          label: l10n.nutrition_photo_add,
        ),
        actions: actions,
      );
    }

    return _NutritionPhotoFrame(
      photo: _PhotoImage(bytes: bytes),
      actions: actions,
    );
  }

  @override
  Widget build(BuildContext context) {
    final key = widget.photoKey;
    return key == null
        ? _controls(context, null)
        : _StoredPhoto(
            key: ValueKey(key.path),
            photoKey: key,
            builder: _controls,
          );
  }
}

class const NutritionPhotoPreview({
  final NutritionPhotoKey? photoKey,
  final String? imageUrl,
  final String? semanticLabel,
  final EdgeInsets padding = EdgeInsets.zero,
}) extends StatelessWidget {
  Widget _preview(BuildContext context, Uint8List? bytes) {
    if (bytes != null) {
      return Padding(
        padding: padding,
        child: _NutritionPhotoFrame(photo: _PhotoImage(bytes: bytes)),
      );
    }
    final url = imageUrl;
    if (url == null) return const SizedBox.shrink();
    return Image.network(
      url,
      fit: BoxFit.cover,
      semanticLabel: semanticLabel,
      frameBuilder: (_, child, frame, _) => frame == null
          ? const SizedBox.shrink()
          : Padding(
              padding: padding,
              child: _NutritionPhotoFrame(photo: child),
            ),
      errorBuilder: (_, _, _) => const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final key = photoKey;
    return key == null
        ? _preview(context, null)
        : _StoredPhoto(
            key: ValueKey(key.path),
            photoKey: key,
            builder: _preview,
          );
  }
}

class const _EmptyPhotoPlaceholder({
  required final VoidCallback? onPressed,
  required final String label,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: onPressed,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_a_photo_outlined,
                size: 34,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class const _NutritionPhotoFrame({
  required final Widget photo,
  final Widget? actions,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 224),
      child: Card.outlined(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.fromLTRB(8, 8, 8, actions == null ? 8 : 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              SizedBox(
                width: double.infinity,
                height: 132,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: photo,
                ),
              ),
              ?actions,
            ],
          ),
        ),
      ),
    ),
  );
}

class const _StoredPhoto({
  super.key,
  required final NutritionPhotoKey photoKey,
  required final Widget Function(BuildContext, Uint8List?) builder,
}) extends StatefulWidget {
  @override
  State<_StoredPhoto> createState() => _StoredPhotoState();
}

class _StoredPhotoState() extends State<_StoredPhoto> {
  final _storage = NutritionPhotoStorage.current;
  Future<Uint8List?>? _bytes;
  int _revision = 0;

  @override
  void initState() {
    super.initState();
    _bytes = _storage?.download(widget.photoKey);
    _storage?.changedPath.addListener(_onChange);
  }

  void _onChange() {
    final changed = _storage?.changedPath.value?.path;
    if (changed == null || changed == widget.photoKey.path) {
      setState(() {
        _revision++;
        _bytes = _storage?.download(widget.photoKey);
      });
    }
  }

  @override
  void dispose() {
    _storage?.changedPath.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List?>(
    key: ValueKey(_revision),
    future: _bytes,
    builder: (context, snapshot) => widget.builder(context, snapshot.data),
  );
}

/// Keep private images out of Flutter's shared ImageCache.
class const _PhotoImage({required final Uint8List bytes})
    extends StatefulWidget {
  @override
  State<_PhotoImage> createState() => _PhotoImageState();
}

class _PhotoImageState() extends State<_PhotoImage> {
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  @override
  void didUpdateWidget(_PhotoImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bytes != widget.bytes) _decode();
  }

  Future<void> _decode() async {
    final bytes = widget.bytes;
    _image?.dispose();
    _image = null;
    try {
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: 320,
        allowUpscaling: false,
      );
      try {
        final frame = await codec.getNextFrame();
        if (!mounted || widget.bytes != bytes) {
          frame.image.dispose();
          return;
        }
        setState(() => _image = frame.image);
      } finally {
        codec.dispose();
      }
    } catch (_) {
      // A corrupt image leaves the preview empty.
    }
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: RawImage(image: _image, fit: BoxFit.cover),
  );
}

const _maxPhotoDimension = 1600;

Future<Uint8List> prepareNutritionPhoto(Uint8List bytes) async {
  if (bytes.length > 30000000) {
    throw const FormatException('The source photo is too large.');
  }
  final normalized = await compute(_normalizePhoto, bytes);
  if (normalized != null) return normalized;

  // The engine can decode additional formats on platforms that support them.
  final codec = await ui.instantiateImageCodecWithSize(
    await ui.ImmutableBuffer.fromUint8List(bytes),
    getTargetSize: (width, height) {
      final scale = math.min(1.0, _maxPhotoDimension / math.max(width, height));
      return ui.TargetImageSize(
        width: math.max(1, (width * scale).round()),
        height: math.max(1, (height * scale).round()),
      );
    },
  );
  try {
    final frame = await codec.getNextFrame();
    try {
      final decoded = frame.image;
      final pixels = await decoded.toByteData(
        format: ui.ImageByteFormat.rawStraightRgba,
      );
      if (pixels == null) {
        throw const FormatException('Could not decode the photo.');
      }
      return await compute(_encodePixels, (
        decoded.width,
        decoded.height,
        pixels.buffer,
      ));
    } finally {
      frame.image.dispose();
    }
  } finally {
    codec.dispose();
  }
}

Uint8List? _normalizePhoto(Uint8List bytes) {
  final decoded = image.decodeImage(bytes);
  if (decoded == null) return null;
  final oriented = image.bakeOrientation(decoded);
  final longest = math.max(oriented.width, oriented.height);
  final resized = longest <= _maxPhotoDimension
      ? oriented
      : image.copyResize(
          oriented,
          width: math.max(
            1,
            (oriented.width * _maxPhotoDimension / longest).round(),
          ),
          height: math.max(
            1,
            (oriented.height * _maxPhotoDimension / longest).round(),
          ),
          interpolation: image.Interpolation.average,
        );
  return _encodePixels((
    resized.width,
    resized.height,
    resized.getBytes(order: image.ChannelOrder.rgba).buffer,
  ));
}

Uint8List _encodePixels((int, int, ByteBuffer) pixels) {
  final jpeg = image.encodeJpg(
    image.Image.fromBytes(
      width: pixels.$1,
      height: pixels.$2,
      bytes: pixels.$3,
      numChannels: 4,
    ),
    quality: 85,
  );
  if (jpeg.length > NutritionPhotoStorage.maxBytes) {
    throw const FormatException('Photo exceeds the upload limit.');
  }
  return jpeg;
}
