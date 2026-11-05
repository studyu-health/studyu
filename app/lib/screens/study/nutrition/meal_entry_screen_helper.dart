import 'package:studyu_core/core.dart';

String getEntryTypeLabel(FoodEntryType type) {
  switch (type) {
    case FoodEntryType.singleIngredient:
      return 'Single Ingredient';
    case FoodEntryType.recipe:
      return 'Recipe';
    case FoodEntryType.brandedProduct:
      return 'Branded Product';
    case FoodEntryType.manualCustom:
      return 'Manual Entry';
  }
}
