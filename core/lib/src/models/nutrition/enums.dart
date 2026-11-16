// Enums for Nutrition Models

enum RecallMode() {
  realtimeRecord,
  yesterdayRecall;

  String toJson() => name;
  static RecallMode fromJson(String json) => values.byName(json);
}

enum MealType() {
  breakfast,
  brunch,
  lunch,
  dinner,
  snack,
  other;

  String toJson() => name;
  static MealType fromJson(String json) => values.byName(json);
}

enum MealContext() {
  home,
  restaurant,
  takeout,
  vending,
  other;

  String toJson() => name;
  static MealContext fromJson(String json) => values.byName(json);
}

enum CompanyContext() {
  alone,
  family,
  friends,
  colleagues,
  other;

  String toJson() => name;
  static CompanyContext fromJson(String json) => values.byName(json);
}

enum DistractionContext() {
  none,
  tv,
  phone,
  work,
  other;

  String toJson() => name;
  static DistractionContext fromJson(String json) => values.byName(json);
}

enum FoodEntryType() {
  singleIngredient,
  recipe,
  brandedProduct,
  manualCustom;

  String toJson() => name;
  static FoodEntryType fromJson(String json) => values.byName(json);
}

enum PortionEstimationMethod() {
  householdMeasure,
  photograph,
  standardUnit,
  userWeighted,
  unknown;

  String toJson() => name;
  static PortionEstimationMethod fromJson(String json) => values.byName(json);
}

enum PortionState() {
  raw,
  cooked,
  asServed;

  String toJson() => name;
  static PortionState fromJson(String json) => values.byName(json);
}

enum FoodSource() {
  openfoodfacts,
  usda,
  mealdb,
  manual;

  String toJson() => name;
  static FoodSource fromJson(String json) => values.byName(json);
}
