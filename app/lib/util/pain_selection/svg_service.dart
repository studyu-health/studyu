import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:studyu_app/util/pain_selection/svg_parser.dart';
import 'package:studyu_core/core.dart';

/// A data class to hold the renderable SVG picture and the extracted interactive paths.
@immutable
class const SvgData(
  final PictureInfo pictureInfo,
  final Map<String, Path> paths,
);

/// A singleton service that loads the SVGs for the body sides.
class SvgService._() {
  this {
    _init();
  }

  static final SvgService _instance = SvgService._();

  /// The singleton instance of [SvgService].
  static SvgService get instance => _instance;

  final ValueNotifier<SvgData?> _front = ValueNotifier(null);
  final ValueNotifier<SvgData?> _back = ValueNotifier(null);

  /// The [ValueNotifier] for the given [side].
  ///
  /// Its value is null until the SVG is loaded.
  ValueNotifier<SvgData?> getSide(BodySide side) =>
      side.map(front: _front, back: _back);

  Future<void> _init() async {
    await Future.wait([
      for (final side in BodySide.values) _loadDrawable(side, getSide(side)),
    ]);
  }

  Future<void> _loadDrawable(
    BodySide side,
    ValueNotifier<SvgData?> notifier,
  ) async {
    final assetPath = side.map(
      front: "assets/images/body_front.svg",
      back: "assets/images/body_back.svg",
    );

    // Load the raw SVG string from assets.
    final svgString = await rootBundle.loadString(assetPath);

    // 1. Pre-process the SVG to extract paths by their ID.
    final paths = parseSvgForPaths(svgString);

    // 2. Load the SVG for efficient rendering.
    final pictureInfo = await vg.loadPicture(SvgStringLoader(svgString), null);

    // Notify listeners with both the picture and the paths.
    notifier.value = SvgData(pictureInfo, paths);
  }
}
