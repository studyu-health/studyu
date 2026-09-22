import 'package:flutter/widgets.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

/// Helper shim that preserves the [MdiIcons.fromString] and [MdiIcons.getNames]
/// API from the original `material_design_icons_flutter` package.
///
/// The FaFre `flutter_material_design_icons` package provides [MdiIcons.values]
/// and [MdiIcons.maybeMetadataOf] but does not include `fromString`/`getNames`.
/// This shim builds a name-to-IconData map from the metadata at runtime.
///
/// Note: [MdiMetadata.name] returns kebab-case (e.g. `'account-heart'`)
/// whereas the old package used camelCase (e.g. `'accountHeart'`).
/// This helper converts keys back to camelCase for backwards compatibility.
class MdiIconsHelper._() {
  static Map<String, IconData>? _iconMap;

  static Map<String, IconData> get _map {
    _iconMap ??= {
      for (final icon in MdiIcons.values)
        _toCamelCase(MdiIcons.maybeMetadataOf(icon)?.name ?? ''): icon,
    };
    return _iconMap!;
  }

  /// Converts kebab-case (MDI metadata name) to camelCase (Dart constant name).
  /// e.g. `'ab-testing'` → `'abTesting'`, `'account-alert-outline'` → `'accountAlertOutline'`
  static String _toCamelCase(String kebab) {
    if (kebab.isEmpty) return kebab;
    final parts = kebab.split('-');
    return parts.first +
        parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
  }

  /// Returns the [IconData] for the given camelCase icon name,
  /// or `null` if not found.
  static IconData? fromString(String name) {
    return _map[name];
  }

  /// Returns all available icon names in camelCase format.
  static List<String> getNames() => _map.keys.toList();
}
