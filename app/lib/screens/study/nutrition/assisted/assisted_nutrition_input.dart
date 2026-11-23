import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/photo_reference.dart';
import 'package:studyu_app/screens/study/nutrition/assisted/assisted_nutrition_voice.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_photo_widgets.dart';
import 'package:studyu_app/services/photo_gallery_service.dart';
import 'package:uuid/uuid.dart';

const _selectedPhotoSize = 96.0;
const _selectedPhotoSpacing = 20.0;
final _numberedPhotoReference = RegExp(
  r'((?:\bphotos?|\bfotos?|사진)\s*#?\s*)(\d+)\b',
  caseSensitive: false,
);

class AssistedNutritionPhoto({
  required final String id,
  required Uint8List bytes,
  final PhotoReference? galleryReference,
}) {
  final Uint8List _bytes = bytes.asUnmodifiableView();
}

class AssistedNutritionInput({
  required final String description,
  required Iterable<AssistedNutritionPhoto> photos,
}) {
  final List<AssistedNutritionPhoto> photos = List.unmodifiable(photos);
}

Future<T?> showAssistedNutritionInput<T extends Object>(
  BuildContext context, {
  required DateTime diaryDay,
  required Future<T> Function(AssistedNutritionInput input) onGenerate,
  AssistedNutritionInput? initialInput,
}) => showAssistedNutritionSheet<T>(
  context,
  builder: (_) => _AssistedInputSheet(
    diaryDay: diaryDay,
    onGenerate: onGenerate,
    initialInput: initialInput,
  ),
);

enum _PhotoAccess() {
  checking,
  unavailable,
  granted,
  error,
}

enum _PickerError() {
  cameraPermission,
  invalidPhoto,
  gallery,
}

class const _AssistedInputSheet<T extends Object>({
  required final DateTime diaryDay,
  required final Future<T> Function(AssistedNutritionInput) onGenerate,
  required final AssistedNutritionInput? initialInput,
}) extends StatefulWidget {
  @override
  State<_AssistedInputSheet<T>> createState() => _AssistedInputSheetState<T>();
}

class _AssistedInputSheetState<T extends Object>()
    extends State<_AssistedInputSheet<T>> {
  final _voice = AssistedNutritionVoiceCapture();
  final _galleryService = PhotoGalleryService();
  final _picker = ImagePicker();
  final _selectionScroll = ScrollController();
  final _selectedTileKeys = <String, GlobalKey>{};
  final _equivalentDayPhotoIds = <String, String>{};
  late final TextEditingController _description;
  late final List<AssistedNutritionPhoto> _selected;
  late final AppLifecycleListener _lifecycle;
  late bool _showDescription;
  _PhotoAccess _photoAccess = _PhotoAccess.checking;
  _PickerError? _pickerError;
  List<PhotoReference> _dayPhotos = [];
  bool _loadingLibrary = false;
  bool _picking = false;
  bool _reorderingPhotos = false;
  bool _generationFailed = false;
  Object? _generation;
  String? _flyingPhotoId;
  OverlayEntry? _photoFlight;

  bool get _supportsDayGallery =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  @override
  void initState() {
    super.initState();
    final draft = widget.initialInput;
    _showDescription = draft != null;
    _description = TextEditingController(text: draft?.description);
    _selected = [...?draft?.photos];
    _lifecycle = AppLifecycleListener(
      onResume: _refreshPhotos,
      onPause: _voice.cancel,
    );
    unawaited(_refreshPhotos());
  }

  @override
  void dispose() {
    _clearPhotoFlight();
    _selectionScroll.dispose();
    _description.dispose();
    _voice.dispose();
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _refreshPhotos({bool requestPermission = false}) async {
    if (!_supportsDayGallery || _loadingLibrary) return;
    _loadingLibrary = true;
    try {
      final granted = requestPermission
          ? await _galleryService.requestPermission()
          : await _galleryService.hasPermission();
      if (!mounted) return;
      if (!granted) {
        setState(() {
          _dayPhotos = [];
          _photoAccess = _PhotoAccess.unavailable;
        });
        return;
      }
      final photos = await _galleryService.getPhotosForDate(widget.diaryDay);
      if (!mounted) return;
      setState(() {
        _dayPhotos = photos;
        _photoAccess = _PhotoAccess.granted;
      });
    } catch (_) {
      if (mounted) setState(() => _photoAccess = _PhotoAccess.error);
    } finally {
      _loadingLibrary = false;
    }
  }

  static String _libraryId(PhotoReference photo) => 'library:${photo.id}';

  bool _dayPhotoIsSelected(PhotoReference photo) {
    final id = _libraryId(photo);
    return _selected.any(
      (selected) =>
          selected.id == id || selected.id == _equivalentDayPhotoIds[id],
    );
  }

  Future<void> _pick(ImageSource source) async {
    if (_picking) return;
    setState(() {
      _picking = true;
      _pickerError = null;
    });
    try {
      final List<XFile> files;
      if (source == ImageSource.camera) {
        final capture = await _picker.pickImage(
          source: source,
          requestFullMetadata: false,
        );
        files = [?capture];
      } else {
        files = await _picker.pickMultiImage(requestFullMetadata: false);
      }
      for (final file in files) {
        if (!mounted) return;
        try {
          final photo = await _prepare(file, id: 'picked:${const Uuid().v4()}');
          if (!mounted) return;
          await _selectPhoto(photo);
        } catch (_) {
          if (mounted) setState(() => _pickerError = _PickerError.invalidPhoto);
        }
      }
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(() {
        _pickerError = switch (error.code) {
          'camera_access_denied' ||
          'camera_access_restricted' => _PickerError.cameraPermission,
          _ when source == ImageSource.gallery => _PickerError.gallery,
          _ => _PickerError.invalidPhoto,
        };
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _pickerError = source == ImageSource.gallery
              ? _PickerError.gallery
              : _PickerError.invalidPhoto;
        });
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<AssistedNutritionPhoto> _prepare(
    XFile file, {
    required String id,
    PhotoReference? galleryReference,
  }) async {
    if (await file.length() > 30000000) {
      throw const FormatException('The source photo is too large.');
    }
    return AssistedNutritionPhoto(
      id: id,
      bytes: await prepareNutritionPhoto(await file.readAsBytes()),
      galleryReference: galleryReference,
    );
  }

  Future<void> _selectDayPhoto(
    PhotoReference dayPhoto,
    BuildContext tileContext,
  ) async {
    if (_picking) return;
    final origin = _tileRect(tileContext);
    setState(() {
      _picking = true;
      _pickerError = null;
    });
    try {
      final asset = await _galleryService.getAsset(dayPhoto.id);
      final file = await asset?.file;
      if (file == null) throw const FormatException('Photo is unavailable.');
      final photo = await _prepare(
        XFile(file.path),
        id: _libraryId(dayPhoto),
        galleryReference: dayPhoto,
      );
      if (mounted) await _selectPhoto(photo, origin: origin);
    } catch (_) {
      if (mounted) setState(() => _pickerError = _PickerError.invalidPhoto);
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _selectPhoto(
    AssistedNutritionPhoto photo, {
    Rect? origin,
  }) async {
    for (final selected in _selected) {
      if (selected.id == photo.id) return;
      if (listEquals(selected._bytes, photo._bytes)) {
        if (photo.id.startsWith('library:')) {
          setState(() => _equivalentDayPhotoIds[photo.id] = selected.id);
        }
        return;
      }
    }

    final animate = origin != null && !MediaQuery.disableAnimationsOf(context);
    _clearPhotoFlight();
    setState(() {
      _selected.add(photo);
      _selectedTileKeys[photo.id] = GlobalKey();
      _flyingPhotoId = animate ? photo.id : null;
      _generationFailed = false;
    });

    await WidgetsBinding.instance.endOfFrame;
    if (!mounted || !_selectionScroll.hasClients) return;
    _selectionScroll.jumpTo(_selectionScroll.position.maxScrollExtent);
    if (!animate) return;
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;

    final targetContext = _selectedTileKeys[photo.id]?.currentContext;
    final target = targetContext != null && targetContext.mounted
        ? _tileRect(targetContext)
        : null;
    if (target == null) {
      setState(() => _flyingPhotoId = null);
      return;
    }
    _startPhotoFlight(photo, origin, target);
  }

  Rect? _tileRect(BuildContext tileContext) {
    final render = tileContext.findRenderObject();
    final overlay = Overlay.of(context).context.findRenderObject();
    if (render is! RenderBox || overlay is! RenderBox || !render.hasSize) {
      return null;
    }
    return overlay.globalToLocal(render.localToGlobal(Offset.zero)) &
        render.size;
  }

  void _startPhotoFlight(
    AssistedNutritionPhoto photo,
    Rect origin,
    Rect destination,
  ) {
    final flight = OverlayEntry(
      builder: (context) => TweenAnimationBuilder<Rect?>(
        tween: RectTween(begin: origin, end: destination),
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
        onEnd: () {
          if (!mounted || _flyingPhotoId != photo.id) return;
          _clearPhotoFlight();
          setState(() => _flyingPhotoId = null);
        },
        builder: (context, bounds, child) => Positioned.fromRect(
          rect: bounds!,
          child: IgnorePointer(child: ExcludeSemantics(child: child)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(photo._bytes, fit: BoxFit.cover, cacheWidth: 260),
        ),
      ),
    );
    _photoFlight = flight;
    Overlay.of(context).insert(flight);
  }

  void _clearPhotoFlight() {
    _photoFlight?.remove();
    _photoFlight?.dispose();
    _photoFlight = null;
  }

  Future<void> _removePhoto(int index) async {
    final l10n = AppLocalizations.of(context)!;
    final photo = _selected[index];
    final remove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.nutrition_assisted_remove_photo_title(index + 1)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 1.45,
                child: Image.memory(photo._bytes, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.nutrition_assisted_remove_photo_help),
          ],
        ),
        scrollable: true,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.nutrition_assisted_keep_photo),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.nutrition_photo_remove),
          ),
        ],
      ),
    );
    if (!mounted || remove != true) return;
    final currentIndex = _selected.indexOf(photo);
    if (currentIndex == -1) return;

    final remaining = [..._selected]..removeAt(currentIndex);
    _updatePhotoReferences(remaining, l10n);
    setState(() {
      _selected.removeAt(currentIndex);
      _selectedTileKeys.remove(photo.id);
      _equivalentDayPhotoIds.removeWhere(
        (_, selectedId) => selectedId == photo.id,
      );
      _generationFailed = false;
      if (_flyingPhotoId == photo.id) {
        _clearPhotoFlight();
        _flyingPhotoId = null;
      }
    });
  }

  void _updatePhotoReferences(
    List<AssistedNutritionPhoto> newOrder,
    AppLocalizations l10n,
  ) {
    final numbersById = {
      for (final (index, photo) in newOrder.indexed) photo.id: index + 1,
    };
    final description = _description.text;
    final updatedDescription = description.replaceAllMapped(
      _numberedPhotoReference,
      (match) {
        final oldNumber = int.tryParse(match.group(2)!);
        if (oldNumber == null ||
            oldNumber < 1 ||
            oldNumber > _selected.length) {
          return match[0]!;
        }
        final newNumber = numbersById[_selected[oldNumber - 1].id];
        if (newNumber == null) return l10n.nutrition_assisted_removed_photo;
        return newNumber == oldNumber ? match[0]! : '${match[1]}$newNumber';
      },
    );
    if (description != updatedDescription) {
      _description.text = updatedDescription;
    }
  }

  void _openPhotoReorder() {
    FocusScope.of(context).unfocus();
    _clearPhotoFlight();
    setState(() {
      _flyingPhotoId = null;
      _reorderingPhotos = true;
    });
  }

  void _closePhotoReorder() => setState(() => _reorderingPhotos = false);

  void _applyPhotoOrder(List<AssistedNutritionPhoto> newOrder) {
    if (listEquals(_selected, newOrder)) {
      _closePhotoReorder();
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    _updatePhotoReferences(newOrder, l10n);
    setState(() {
      _selected
        ..clear()
        ..addAll(newOrder);
      _generationFailed = false;
      _reorderingPhotos = false;
    });
  }

  void _describe() {
    _clearPhotoFlight();
    setState(() {
      _flyingPhotoId = null;
      _showDescription = true;
    });
  }

  void _back() {
    if (_generation != null) {
      _cancelGeneration();
    } else if (_voice.busy) {
      _voice.cancel();
    } else {
      FocusScope.of(context).unfocus();
      setState(() => _showDescription = false);
    }
  }

  void _stopRecording() {
    final l10n = AppLocalizations.of(context)!;
    final sample = switch (_selected.length) {
      0 => l10n.nutrition_assisted_sample_description,
      1 => l10n.nutrition_assisted_sample_one_photo,
      _ => l10n.nutrition_assisted_sample_two_photos,
    };
    unawaited(
      _voice.stopAndTranscribe(
        sample: sample,
        onTranscript: (transcript) {
          _description.text = transcript;
          if (_generationFailed) setState(() => _generationFailed = false);
        },
      ),
    );
  }

  Future<void> _generate() async {
    if (_voice.busy || _generation != null) return;
    final input = AssistedNutritionInput(
      description: _description.text.trim(),
      photos: _selected,
    );
    if (input.description.isEmpty && input.photos.isEmpty) return;

    FocusScope.of(context).unfocus();
    final request = Object();
    setState(() {
      _generationFailed = false;
      _generation = request;
    });
    try {
      await Future<void>.delayed(const Duration(milliseconds: 650));
      if (!mounted || _generation != request) return;
      final result = await widget.onGenerate(input);
      if (mounted && _generation == request) Navigator.pop(context, result);
    } catch (_) {
      if (!mounted || _generation != request) return;
      setState(() {
        _generation = null;
        _generationFailed = true;
      });
    }
  }

  void _cancelGeneration() => setState(() => _generation = null);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListenableBuilder(
      listenable: Listenable.merge([_voice, _description]),
      builder: (context, _) => PopScope<T>(
        canPop: !_reorderingPhotos && !_showDescription && !_picking,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          if (_reorderingPhotos) {
            _closePhotoReorder();
          } else if (_showDescription) {
            _back();
          }
        },
        child: _reorderingPhotos
            ? _PhotoReorderSheet(
                initialOrder: _selected,
                onCancel: _closePhotoReorder,
                onDone: _applyPhotoOrder,
              )
            : _generation != null
            ? _buildGeneration(l10n)
            : AssistedNutritionSheet(
                title: _showDescription
                    ? l10n.nutrition_assisted_describe_meals
                    : l10n.nutrition_assisted_entry,
                centerTitle: _showDescription ? null : false,
                onBack: _showDescription ? _back : null,
                onClose: () => Navigator.pop(context),
                content: _showDescription
                    ? _buildDescription(l10n)
                    : _buildPhotos(l10n),
                action: _buildAction(l10n),
              ),
      ),
    );
  }

  Widget _buildAction(AppLocalizations l10n) {
    if (!_showDescription) {
      return FilledButton.icon(
        onPressed: _picking ? null : _describe,
        icon: _selected.isEmpty ? const Icon(Icons.skip_next_outlined) : null,
        label: Text(
          _selected.isEmpty
              ? l10n.nutrition_assisted_continue_without_photos
              : l10n.nutrition_assisted_continue_description,
        ),
      );
    }
    return switch (_voice.stage) {
      AssistedNutritionVoiceStage.recording => FilledButton(
        onPressed: _stopRecording,
        child: Text(l10n.nutrition_assisted_stop_transcribe),
      ),
      AssistedNutritionVoiceStage.transcribing => OutlinedButton(
        onPressed: _voice.cancel,
        child: Text(l10n.cancel),
      ),
      _ => FilledButton(
        onPressed:
            !_voice.busy &&
                (_description.text.trim().isNotEmpty || _selected.isNotEmpty)
            ? _generate
            : null,
        child: Text(l10n.nutrition_assisted_generate),
      ),
    };
  }

  Widget _buildGeneration(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return AssistedNutritionSheet(
      title: l10n.nutrition_assisted_generating,
      content: Semantics(
        liveRegion: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.nutrition_assisted_generation_help,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            const LinearProgressIndicator(),
            const SizedBox(height: 18),
          ],
        ),
      ),
      action: OutlinedButton(
        onPressed: _cancelGeneration,
        child: Text(l10n.cancel),
      ),
    );
  }

  Widget _buildDescription(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_selected.isNotEmpty) ...[
          _buildSelectedPhotos(l10n),
          const SizedBox(height: 16),
        ],
        Text(
          l10n.nutrition_assisted_description_help,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        AssistedNutritionVoiceField(
          voice: _voice,
          controller: _description,
          hint: _selected.isEmpty
              ? l10n.nutrition_assisted_description_hint
              : l10n.nutrition_assisted_description_photo_hint,
          onChanged: () {
            if (_generationFailed) setState(() => _generationFailed = false);
          },
        ),
        if (_generationFailed) ...[
          const SizedBox(height: 8),
          AssistedNutritionError(l10n.nutrition_assisted_generation_error),
        ],
      ],
    );
  }

  Widget _buildPhotos(AppLocalizations l10n) {
    final hasDayAccess = _supportsDayGallery;
    final available = _dayPhotos
        .where((photo) => !_dayPhotoIsSelected(photo))
        .toList();
    final error = switch (_pickerError) {
      _PickerError.cameraPermission => l10n.camera_access_denied,
      _PickerError.invalidPhoto => l10n.nutrition_photo_invalid,
      _PickerError.gallery => l10n.nutrition_assisted_gallery_error,
      null => null,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_selected.isNotEmpty) ...[
          _buildSelectedPhotos(l10n),
          const SizedBox(height: 12),
        ],
        if (_dayPhotos.isNotEmpty)
          _sectionHeading(l10n.nutrition_assisted_add_photos),
        LayoutBuilder(
          builder: (context, constraints) {
            final gap = constraints.maxWidth >= 328 ? 20.0 : 12.0;
            final width = math.min(96.0, (constraints.maxWidth - 2 * gap) / 3);
            final textSize = MediaQuery.textScalerOf(context).scale(14);
            final height = math.max(width, 44 + 2.4 * textSize);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: width,
                      height: height,
                      child: _PhotoActionTile(
                        icon: Icons.photo_camera_outlined,
                        label: l10n.nutrition_photo_take,
                        onPressed: _picking || !(kIsWeb || _supportsDayGallery)
                            ? null
                            : () => _pick(ImageSource.camera),
                      ),
                    ),
                    SizedBox(width: gap),
                    SizedBox(
                      width: width,
                      height: height,
                      child: _PhotoActionTile(
                        icon: Icons.photo_outlined,
                        label: l10n.nutrition_assisted_open_gallery,
                        onPressed: _picking
                            ? null
                            : () => _pick(ImageSource.gallery),
                      ),
                    ),
                    SizedBox(width: gap),
                    if (available.isNotEmpty)
                      SizedBox(
                        width: width,
                        height: height,
                        child: _dayPhotoTile(available.first, l10n),
                      ),
                  ],
                ),
                if (available.length > 1) ...[
                  SizedBox(height: gap),
                  SizedBox(
                    width: width * 3 + gap * 2,
                    height: height,
                    child: GridView.builder(
                      primary: false,
                      padding: EdgeInsets.zero,
                      itemCount: available.length - 1,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: gap,
                        mainAxisSpacing: gap,
                        mainAxisExtent: height,
                      ),
                      itemBuilder: (context, index) =>
                          _dayPhotoTile(available[index + 1], l10n),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        if (hasDayAccess && _photoAccess == _PhotoAccess.unavailable) ...[
          const SizedBox(height: 12),
          Text(l10n.nutrition_assisted_photo_permission),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: () => _refreshPhotos(requestPermission: true),
              child: Text(l10n.grantPermission),
            ),
          ),
        ],
        if (hasDayAccess && _photoAccess == _PhotoAccess.error) ...[
          const SizedBox(height: 8),
          AssistedNutritionError(l10n.nutrition_assisted_gallery_error),
        ],
        if (_picking ||
            (hasDayAccess && _photoAccess == _PhotoAccess.checking)) ...[
          const SizedBox(height: 8),
          const LinearProgressIndicator(),
        ],
        if (error != null) ...[
          const SizedBox(height: 8),
          AssistedNutritionError(error),
        ],
      ],
    );
  }

  Widget _dayPhotoTile(PhotoReference photo, AppLocalizations l10n) =>
      _DayPhotoTile(
        key: ValueKey(photo.id),
        photo: photo,
        gallery: _galleryService,
        label: l10n.nutrition_photo_add,
        onTap: _picking ? null : (context) => _selectDayPhoto(photo, context),
      );

  Widget _sectionHeading(String title, {double bottomPadding = 8}) => Padding(
    padding: EdgeInsets.only(bottom: bottomPadding),
    child: Semantics(
      header: true,
      child: Text(title, style: Theme.of(context).textTheme.titleSmall),
    ),
  );

  Widget _buildSelectedPhotos(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selected.length > 1)
          Row(
            children: [
              Expanded(
                child: _sectionHeading(
                  l10n.nutrition_assisted_selected_photos,
                  bottomPadding: 0,
                ),
              ),
              IconButton(
                tooltip: l10n.nutrition_assisted_reorder_photos,
                onPressed: _picking || _voice.busy ? null : _openPhotoReorder,
                color: Theme.of(context).colorScheme.primary,
                icon: const Icon(Icons.swap_horiz_outlined),
              ),
            ],
          )
        else
          _sectionHeading(l10n.nutrition_assisted_selected_photos),
        SingleChildScrollView(
          controller: _selectionScroll,
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: _selectedPhotoSpacing,
            children: [
              for (final (index, photo) in _selected.indexed)
                SizedBox.square(
                  key: _selectedTileKeys.putIfAbsent(photo.id, GlobalKey.new),
                  dimension: _selectedPhotoSize,
                  child: Opacity(
                    opacity: _flyingPhotoId == photo.id ? 0 : 1,
                    child: _SelectedPhotoTile(
                      photo: photo,
                      number: index + 1,
                      label: l10n.nutrition_assisted_photo_number(index + 1),
                      onRemove: _voice.busy || _picking
                          ? null
                          : () => _removePhoto(index),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class const _PhotoReorderSheet({
  required final List<AssistedNutritionPhoto> initialOrder,
  required final VoidCallback onCancel,
  required final ValueChanged<List<AssistedNutritionPhoto>> onDone,
}) extends StatefulWidget {
  @override
  State<_PhotoReorderSheet> createState() => _PhotoReorderSheetState();
}

class _PhotoReorderSheetState() extends State<_PhotoReorderSheet> {
  static const _itemExtent = _selectedPhotoSize + _selectedPhotoSpacing;

  final _scrollController = ScrollController();
  late final _photos = List.of(widget.initialOrder);
  late var _selectedId = _photos.first.id;
  int? _draggingIndex;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _movePhoto(int from, int to) {
    setState(() {
      final photo = _photos.removeAt(from);
      _photos.insert(to, photo);
      _selectedId = photo.id;
      _draggingIndex = null;
    });
  }

  void _moveWithButton(int from, int to) {
    _movePhoto(from, to);
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final start = to * _itemExtent;
    final end = start + _selectedPhotoSize;
    final offset = switch (position.pixels) {
      final pixels when start < pixels => start,
      final pixels when end > pixels + position.viewportDimension =>
        end - position.viewportDimension,
      final pixels => pixels,
    };
    _scrollController.jumpTo(
      offset.clamp(position.minScrollExtent, position.maxScrollExtent),
    );
  }

  void _cancelDrag() {
    if (_draggingIndex != null) setState(() => _draggingIndex = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final selectedIndex = _photos.indexWhere(
      (photo) => photo.id == _selectedId,
    );
    final isDragging = _draggingIndex != null;
    return AssistedNutritionSheet(
      title: l10n.nutrition_assisted_reorder_photos,
      centerTitle: false,
      onClose: widget.onCancel,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Text(
            l10n.nutrition_assisted_reorder_photo_help,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(
            height: _selectedPhotoSize,
            child: Listener(
              onPointerCancel: (_) => _cancelDrag(),
              child: ReorderableListView.builder(
                scrollController: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                buildDefaultDragHandles: false,
                itemExtent: _itemExtent,
                itemCount: _photos.length,
                onReorderStart: (index) => setState(() {
                  _selectedId = _photos[index].id;
                  _draggingIndex = index;
                }),
                onReorderEnd: (index) {
                  final source = _draggingIndex;
                  if (source != null &&
                      (index == source || index == source + 1)) {
                    _cancelDrag();
                  }
                },
                onReorderItem: _movePhoto,
                itemBuilder: (context, index) {
                  final photo = _photos[index];
                  return Padding(
                    key: ValueKey(photo.id),
                    padding: const EdgeInsetsDirectional.only(
                      end: _selectedPhotoSpacing,
                    ),
                    child: ReorderableDelayedDragStartListener(
                      index: index,
                      child: _SelectedPhotoTile(
                        photo: photo,
                        number: index + 1,
                        label: l10n.nutrition_assisted_photo_number(index + 1),
                        selected: photo.id == _selectedId,
                        onSelect: () => setState(() => _selectedId = photo.id),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Semantics(
            liveRegion: true,
            child: Text(
              l10n.nutrition_assisted_photo_selected(selectedIndex + 1),
              style: theme.textTheme.titleSmall,
            ),
          ),
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isDragging || selectedIndex == 0
                      ? null
                      : () => _moveWithButton(selectedIndex, selectedIndex - 1),
                  child: Text(l10n.nutrition_assisted_move_photo_earlier),
                ),
              ),
              Expanded(
                child: OutlinedButton(
                  onPressed: isDragging || selectedIndex == _photos.length - 1
                      ? null
                      : () => _moveWithButton(selectedIndex, selectedIndex + 1),
                  child: Text(l10n.nutrition_assisted_move_photo_later),
                ),
              ),
            ],
          ),
        ],
      ),
      action: FilledButton(
        onPressed: isDragging ? null : () => widget.onDone(_photos),
        child: Text(l10n.done),
      ),
    );
  }
}

class const _PhotoActionTile({
  required final IconData icon,
  required final String label,
  required final VoidCallback? onPressed,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => OutlinedButton(
    style: OutlinedButton.styleFrom(
      backgroundColor: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    onPressed: onPressed,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 22),
        const SizedBox(height: 6),
        Text(label, textAlign: TextAlign.center),
      ],
    ),
  );
}

class const _DayPhotoTile({
  super.key,
  required final PhotoReference photo,
  required final PhotoGalleryService gallery,
  required final String label,
  required final ValueChanged<BuildContext>? onTap,
}) extends StatefulWidget {
  @override
  State<_DayPhotoTile> createState() => _DayPhotoTileState();
}

class _DayPhotoTileState() extends State<_DayPhotoTile> {
  late final Future<Uint8List?> _thumbnail = _loadThumbnail();

  Future<Uint8List?> _loadThumbnail() async {
    try {
      final asset = await widget.gallery.getAsset(widget.photo.id);
      return await asset?.thumbnailDataWithSize(
        const ThumbnailSize.square(240),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Tooltip(
      message: widget.label,
      child: Semantics(
        label: widget.label,
        button: true,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Material(
            color: colors.surfaceContainerHighest,
            child: InkWell(
              onTap: widget.onTap == null ? null : () => widget.onTap!(context),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  FutureBuilder<Uint8List?>(
                    future: _thumbnail,
                    builder: (context, snapshot) => snapshot.data == null
                        ? Icon(
                            Icons.photo_outlined,
                            color: colors.onSurfaceVariant,
                          )
                        : Image.memory(snapshot.data!, fit: BoxFit.cover),
                  ),
                  PositionedDirectional(
                    top: 6,
                    end: 6,
                    child: ExcludeSemantics(
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: colors.surface,
                        foregroundColor: colors.onSurface,
                        child: const Icon(Icons.add, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class const _SelectedPhotoTile({
  required final AssistedNutritionPhoto photo,
  required final int number,
  required final String label,
  final VoidCallback? onRemove,
  final VoidCallback? onSelect,
  final bool selected = false,
}) extends StatelessWidget {
  static const _badgeRadius = 12.0;
  static const _badgeInset = 6.0;
  static const _radius = BorderRadius.all(Radius.circular(12));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final colors = theme.colorScheme;
    return Semantics(
      label: label,
      selected: onSelect == null ? null : selected,
      child: InkWell(
        onTap: onSelect,
        borderRadius: _radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: _radius,
              child: Image.memory(
                photo._bytes,
                fit: BoxFit.cover,
                cacheWidth: 260,
              ),
            ),
            PositionedDirectional(
              top: _badgeInset,
              start: _badgeInset,
              child: ExcludeSemantics(
                child: CircleAvatar(
                  radius: _badgeRadius,
                  backgroundColor: colors.surface,
                  foregroundColor: colors.onSurface,
                  child: Text('$number', style: theme.textTheme.labelSmall),
                ),
              ),
            ),
            if (onRemove != null)
              PositionedDirectional(
                top: 0,
                end: 0,
                child: IconButton(
                  tooltip: l10n.nutrition_photo_remove,
                  onPressed: onRemove,
                  alignment: AlignmentDirectional.topEnd,
                  padding: const EdgeInsets.all(_badgeInset),
                  constraints: const BoxConstraints.tightFor(
                    width: kMinInteractiveDimension,
                    height: kMinInteractiveDimension,
                  ),
                  icon: CircleAvatar(
                    radius: _badgeRadius,
                    backgroundColor: colors.surface,
                    foregroundColor: colors.onSurface,
                    child: const Icon(Icons.close, size: 16),
                  ),
                ),
              ),
            if (selected)
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.primary, width: 2),
                    borderRadius: _radius,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
