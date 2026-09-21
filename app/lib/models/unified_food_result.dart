import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:studyu_core/core.dart';

/// Unified search result that can hold data from any source
/// This is a View Model for the App UI, not a Core domain model.
class UnifiedFoodResult({
  required final String id,
  required final String name,
  final String? brand,
  final String? imageUrl,
  final double? calories,
  required final FoodSource source,

  /// Holds [Product] (from OpenFoodFacts) or [UsdaFoodItem] (from App)
  required final dynamic originalData,
});
