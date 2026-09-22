// This code is taken from the package by Tim Lehmann (timcreatedit)
// Source: https://github.com/timcreatedit/body_part_selector
// Licensed under the MIT License.
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/util/pain_selection/svg_service.dart';
import 'package:studyu_core/core.dart';
import 'package:touchable/touchable.dart';

typedef PainEditResult = ({
  String parentPartId,
  String childPartId,
  BodyPain pain,
});

/// A widget that allows for selecting body parts and displays their pain level.
/// When a body part is tapped, a dialog is shown to select the pain level, type, and specific location.
class const BodyPartSelector({
  required final Body body,
  required final BodySide side,
  final void Function(
    String parentPartId,
    String childPartId,
    BodyPain newPain,
  )?
  onPainChanged,
  final PainScale scale = PainScale.english,
  final Color? unselectedColor,
  final Color? unselectedOutlineColor,
  super.key,
}) extends StatelessWidget {
  Future<void> _showPainSelectorDialog(
    BuildContext context,
    String partId,
  ) async {
    final part = body.allPartsById[partId];
    if (part == null) {
      return;
    }

    final result = await showDialog<PainEditResult>(
      context: context,
      builder: (context) => PainEditDialog(tappedPart: part, scale: scale),
    );

    if (result != null && context.mounted) {
      onPainChanged?.call(result.parentPartId, result.childPartId, result.pain);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = SvgService.instance.getSide(side);
    return ValueListenableBuilder<SvgData?>(
      valueListenable: notifier,
      builder: (context, svgData, _) {
        if (svgData == null) {
          return const Center(child: CircularProgressIndicator.adaptive());
        } else {
          return _buildBody(context, svgData);
        }
      },
    );
  }

  Widget _buildBody(BuildContext context, SvgData svgData) {
    return AnimatedSwitcher(
      duration: kThemeAnimationDuration,
      child: LayoutBuilder(
        key: ValueKey(Object.hash(body, side)),
        builder: (context, constraints) {
          final size = Size.square(
            min(
              constraints.maxWidth,
              constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : constraints.maxWidth,
            ),
          );

          return SizedBox(
            width: size.width,
            height: size.height,
            child: CanvasTouchDetector(
              gesturesToOverride: const [GestureType.onTapDown],
              builder: (context) => CustomPaint(
                size: size,
                painter: _BodyPainter(
                  pictureInfo: svgData.pictureInfo,
                  bodyPartPaths: svgData.paths,
                  body: body,
                  onTap: (id) => _showPainSelectorDialog(context, id),
                  context: context,
                  scale: scale,
                  unselectedColor:
                      unselectedColor ??
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  unselectedOutlineColor:
                      unselectedOutlineColor ??
                      Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BodyPainter({
  required final PictureInfo pictureInfo,
  required final Map<String, ui.Path> bodyPartPaths,
  required final Body body,
  required final void Function(String) onTap,
  required final BuildContext context,
  required final PainScale scale,
  required final Color unselectedColor,
  required final Color unselectedOutlineColor,
}) extends CustomPainter {
  int getPainLevel(String key) => body.allPartsById[key]?.pain.painLevel ?? 0;

  ({Color fill, Color stroke}) _getPainColors(int painLevel) {
    if (painLevel == 0) {
      return (fill: unselectedColor, stroke: unselectedOutlineColor);
    }

    final scalePoints = scale.levels.keys.where((p) => p > 0).toList()..sort();
    if (scalePoints.isEmpty) {
      return (fill: Colors.red, stroke: Colors.white);
    }

    final firstPainPoint = scalePoints.first;
    if (painLevel >= scalePoints.last) {
      final style = scale.levels[scalePoints.last]!;
      return (fill: style.color, stroke: style.textColor);
    }

    final lowerBound = scalePoints.lastWhere(
      (p) => p <= painLevel,
      orElse: () => firstPainPoint,
    );
    final upperBound = scalePoints.firstWhere(
      (p) => p >= painLevel,
      orElse: () => lowerBound,
    );

    if (lowerBound == upperBound) {
      final style = scale.levels[lowerBound]!;
      return (fill: style.color, stroke: style.textColor);
    }

    final lowerStyle = scale.levels[lowerBound]!;
    final upperStyle = scale.levels[upperBound]!;
    final t = (painLevel - lowerBound) / (upperBound - lowerBound);

    final fillColor = Color.lerp(lowerStyle.color, upperStyle.color, t)!;
    final strokeColor = Color.lerp(
      lowerStyle.textColor,
      upperStyle.textColor,
      t,
    )!;

    return (fill: fillColor, stroke: strokeColor);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final viewBox = pictureInfo.size;
    final double scaleFactor = min(
      size.width / viewBox.width,
      size.height / viewBox.height,
    );
    final scaledHalfViewBoxSize = viewBox * scaleFactor / 2.0;
    final halfDesiredSize = size / 2.0;
    final shift = Offset(
      halfDesiredSize.width - scaledHalfViewBoxSize.width,
      halfDesiredSize.height - scaledHalfViewBoxSize.height,
    );
    final fittingMatrix = Matrix4.identity()
      ..translateByDouble(shift.dx, shift.dy, 0.0, 1.0)
      ..scaleByDouble(scaleFactor, scaleFactor, scaleFactor, 1.0);

    canvas.save();
    canvas.transform(fittingMatrix.storage);
    canvas.clipRect(Rect.fromLTWH(0, 0, viewBox.width, viewBox.height));
    canvas.drawPicture(pictureInfo.picture);
    canvas.restore();

    final touchyCanvas = TouchyCanvas(context, canvas);

    for (final entry in bodyPartPaths.entries) {
      final id = entry.key;
      final path = entry.value;

      final painLevel = getPainLevel(id);
      final colors = _getPainColors(painLevel);
      final bodyPartPath = path.transform(fittingMatrix.storage);

      touchyCanvas.drawPath(
        bodyPartPath,
        Paint()
          ..color = colors.fill
          ..style = PaintingStyle.fill,
        onTapDown: (_) => onTap(id),
      );

      canvas.drawPath(
        bodyPartPath,
        Paint()
          ..color = colors.stroke
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class const PainEditDialog({
  required final BodyPart tappedPart,
  required final PainScale scale,
  super.key,
}) extends StatefulWidget {
  @override
  State<PainEditDialog> createState() => _PainEditDialogState();
}

class _PainEditDialogState() extends State<PainEditDialog> {
  late int _currentPain;
  PainType? _selectedPainType;
  late String _selectedPartId;
  late List<BodyPart> _selectableParts;

  @override
  void initState() {
    super.initState();
    final mostSpecificPainfulPart = _findMostSpecificPain(widget.tappedPart);
    _currentPain = mostSpecificPainfulPart.pain.painLevel;
    _selectedPainType = mostSpecificPainfulPart.pain.type;
    _selectedPartId = mostSpecificPainfulPart.id;
    _selectableParts = _flattenHierarchy(widget.tappedPart);
    WidgetsBinding.instance.addPostFrameCallback((_) => _showBodyAreaDialog());
  }

  BodyPart _findMostSpecificPain(BodyPart part) {
    for (final child in part.children) {
      final result = _findMostSpecificPain(child);
      if (result.pain.painLevel > 0) {
        return result;
      }
    }
    return part;
  }

  List<BodyPart> _flattenHierarchy(BodyPart part) {
    final list = [part];
    for (final child in part.children) {
      list.addAll(_flattenHierarchy(child));
    }
    return list;
  }

  Future<void> _showPainLevelDialog() async {
    final scalePoints = widget.scale.levels.keys.toList()..sort();
    int? selectedLevel = _currentPain;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(widget.scale.dialogTitle),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: scalePoints.map((level) {
                        final style = widget.scale.levels[level]!;
                        return GestureDetector(
                          onTap: () {
                            setStateDialog(() => selectedLevel = level);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 90,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: selectedLevel == level
                                  ? style.color
                                  : style.color.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(12),
                              border: selectedLevel == level
                                  ? Border.all(width: 2)
                                  : null,
                              boxShadow: selectedLevel == level
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.08,
                                        ),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  style.face,
                                  style: const TextStyle(fontSize: 36),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  style.description,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: style.textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => context.pop(false),
                  child: Text(AppLocalizations.of(context)!.cancelButton),
                ),
                TextButton(
                  onPressed: selectedLevel != null
                      ? () {
                          _currentPain = selectedLevel!;
                          context.pop(true);
                        }
                      : null,
                  child: Text(AppLocalizations.of(context)!.done),
                ),
              ],
            );
          },
        );
      },
    );
    if (result == true) {
      if (_currentPain == 0) {
        _finish();
        return;
      }
      await _showPainTypeDialog();
    } else if (result == false) {
      if (!mounted) return;
      context.pop();
    }
  }

  Future<void> _showPainTypeDialog() async {
    final loc = AppLocalizations.of(context)!;
    final painTypeOptions = _generatePainTypes(context);
    PainType? selectedType = _selectedPainType ?? painTypeOptions.first;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(false),
                    tooltip: loc.back,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(loc.painTypeLabel)),
                ],
              ),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Flexible(
                      child: SizedBox(
                        width: 320,
                        child: ListView.separated(
                          shrinkWrap: true,
                          separatorBuilder: (_, _) => const Divider(),
                          itemCount: painTypeOptions.length,
                          itemBuilder: (context, index) {
                            final type = painTypeOptions[index];
                            return ListTile(
                              leading: _painTypeIcon(type.name),
                              title: Text(type.name),
                              selected: selectedType?.name == type.name,
                              onTap: () {
                                setStateDialog(() => selectedType = type);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _selectedPainType = selectedType;
                    context.pop(true);
                  },
                  child: Text(loc.done),
                ),
              ],
            );
          },
        );
      },
    );
    if (result == true) {
      _finish();
    } else if (result == false) {
      await _showPainLevelDialog();
    }
  }

  Future<void> _showBodyAreaDialog() async {
    final loc = AppLocalizations.of(context)!;
    if (_selectableParts.length <= 1) {
      await _showPainLevelDialog();
      return;
    }
    String? selectedId = _selectedPartId;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(loc.bodyPartLabel),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Flexible(
                      child: SizedBox(
                        width: 320,
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: _selectableParts.length,
                          separatorBuilder: (_, _) => const Divider(),
                          itemBuilder: (context, index) {
                            final part = _selectableParts[index];
                            return ListTile(
                              title: Text(part.name),
                              selected: selectedId == part.id,
                              onTap: () {
                                setStateDialog(() => selectedId = part.id);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => context.pop(false),
                  child: Text(AppLocalizations.of(context)!.cancelButton),
                ),
                TextButton(
                  onPressed: () {
                    _selectedPartId = selectedId ?? _selectedPartId;
                    context.pop(true);
                  },
                  child: Text(loc.done),
                ),
              ],
            );
          },
        );
      },
    );
    if (result == true) {
      await _showPainLevelDialog();
    } else {
      if (!mounted) return;
      context.pop();
    }
  }

  void _finish() {
    context.pop((
      parentPartId: widget.tappedPart.id,
      childPartId: _selectedPartId,
      pain: BodyPain(painLevel: _currentPain, type: _selectedPainType),
    ));
  }

  List<PainType> _generatePainTypes(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return [
      PainType(loc.painTypeUnspecified),
      PainType(loc.painTypeBurning),
      PainType(loc.painTypeStabbing),
      PainType(loc.painTypeAching),
      PainType(loc.painTypeThrobbing),
      PainType(loc.painTypeSharp),
      PainType(loc.painTypeDull),
      PainType(loc.painTypeCramping),
      PainType(loc.painTypeRadiating),
      PainType(loc.painTypeTingling),
      PainType(loc.painTypeShooting),
      PainType(loc.painTypePulsing),
      PainType(loc.painTypePressure),
      PainType(loc.painTypeTightness),
      PainType(loc.painTypeSoreness),
      PainType(loc.painTypeStiffness),
    ];
  }

  Widget _painTypeIcon(String name) {
    return const Icon(Icons.local_hospital);
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

@immutable
class const PainLevelStyle({
  required final String face,
  required final String description,
  required final Color color,
  final Color textColor = Colors.white,
});

@immutable
class const PainScale({
  required final String dialogTitle,
  required final String painIndicatorText,
  required final Map<int, PainLevelStyle> levels,
}) {
  static const PainScale english = PainScale(
    dialogTitle: 'Select Pain Details',
    painIndicatorText: 'Pain',
    levels: {
      0: PainLevelStyle(
        face: '😄',
        description: 'No Hurt',
        color: Color(0xFF4CAF50),
      ),
      2: PainLevelStyle(
        face: '😊',
        description: 'Hurts Little Bit',
        color: Color(0xFFFFCC80),
        textColor: Colors.black87,
      ),
      4: PainLevelStyle(
        face: '😐',
        description: 'Hurts Little More',
        color: Color(0xFFFFA726),
        textColor: Colors.black87,
      ),
      6: PainLevelStyle(
        face: '😕',
        description: 'Hurts Even More',
        color: Color(0xFFFF7043),
      ),
      8: PainLevelStyle(
        face: '😢',
        description: 'Hurts Whole Lot',
        color: Color(0xFFF44336),
      ),
      10: PainLevelStyle(
        face: '😭',
        description: 'Hurts Worst',
        color: Color(0xFFB71C1C),
      ),
    },
  );
}
