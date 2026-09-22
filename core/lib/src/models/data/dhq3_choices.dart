import 'package:studyu_core/core.dart';

/// DHQ3 Past Year with Serving Sizes – shared choice sets (exact FFQ wording).
class Dhq3Choices() {
  static List<Choice> get sex => [
    Choice.withText(text: 'Male', id: 'male'),
    Choice.withText(text: 'Female', id: 'female'),
    Choice.withText(text: 'Other', id: 'other'),
  ];

  /// Frequency: 1 time per month or less … 6+ per day (with NEVER first for skip)
  static List<Choice> get frequencyWithNever => [
    Choice.withText(text: 'NEVER', id: 'never'),
    Choice.withText(
      text: '1 time per month or less',
      id: '1_per_month_or_less',
    ),
    Choice.withText(text: '2-3 times per month', id: '2_3_per_month'),
    Choice.withText(text: '1-2 times per week', id: '1_2_per_week'),
    Choice.withText(text: '3-4 times per week', id: '3_4_per_week'),
    Choice.withText(text: '5-6 times per week', id: '5_6_per_week'),
    Choice.withText(text: '1 time per day', id: '1_per_day'),
    Choice.withText(text: '2-3 times per day', id: '2_3_per_day'),
    Choice.withText(text: '4-5 times per day', id: '4_5_per_day'),
    Choice.withText(text: '6 or more times per day', id: '6_plus_per_day'),
  ];

  /// Frequency for foods: 1-11 per year … 2+ per day
  /// Note: "1-6 per year" and "7-11 per year" are merged into one option
  /// so that frequencyFoodWithNever stays at 10 (designer limit).
  static List<Choice> get frequencyFood => [
    Choice.withText(text: '1-11 times per year', id: '1_11_per_year'),
    Choice.withText(text: '1 time per month', id: '1_per_month'),
    Choice.withText(text: '2-3 times per month', id: '2_3_per_month'),
    Choice.withText(text: '1 time per week', id: '1_per_week'),
    Choice.withText(text: '2 times per week', id: '2_per_week'),
    Choice.withText(text: '3-4 times per week', id: '3_4_per_week'),
    Choice.withText(text: '5-6 times per week', id: '5_6_per_week'),
    Choice.withText(text: '1 time per day', id: '1_per_day'),
    Choice.withText(text: '2 or more times per day', id: '2_plus_per_day'),
  ];

  static List<Choice> get frequencyFoodWithNever => [
    Choice.withText(text: 'NEVER', id: 'never'),
    ...frequencyFood,
  ];

  /// Seasonal frequency (when in season)
  static List<Choice> get frequencySeason => [
    Choice.withText(text: 'NEVER', id: 'never'),
    Choice.withText(text: '1-6 times per season', id: '1_6_per_season'),
    Choice.withText(text: '7-11 times per season', id: '7_11_per_season'),
    Choice.withText(text: '1 time per month', id: '1_per_month'),
    Choice.withText(text: '2-3 times per month', id: '2_3_per_month'),
    Choice.withText(text: '1 time per week', id: '1_per_week'),
    Choice.withText(text: '2 times per week', id: '2_per_week'),
    Choice.withText(text: '3-4 times per week', id: '3_4_per_week'),
    Choice.withText(text: '5-6 times per week', id: '5_6_per_week'),
    Choice.withText(text: '1 time per day', id: '1_per_day'),
  ];

  /// Almost never to almost always
  static List<Choice> get almostNeverToAlways => [
    Choice.withText(text: 'Almost never or never', id: 'almost_never'),
    Choice.withText(text: 'About 1/4 of the time', id: '1_4'),
    Choice.withText(text: 'About 1/2 of the time', id: '1_2'),
    Choice.withText(text: 'About 3/4 of the time', id: '3_4'),
    Choice.withText(text: 'Almost always or always', id: 'almost_always'),
  ];

  static List<Choice> get yesNo => [
    Choice.withText(text: 'Yes', id: 'yes'),
    Choice.withText(text: 'No', id: 'no'),
  ];

  static List<Choice> get yesNoDontKnow => [
    Choice.withText(text: 'Yes', id: 'yes'),
    Choice.withText(text: 'No', id: 'no'),
    Choice.withText(text: "Don't know", id: 'dont_know'),
  ];

  /// Portion: small / medium / large (generic)
  static List<Choice> portionCups(String small, String medium, String large) =>
      [
        Choice.withText(text: small, id: 'less'),
        Choice.withText(text: medium, id: 'medium'),
        Choice.withText(text: large, id: 'more'),
      ];

  /// Milk type (9 options)
  static List<Choice> get milkType => [
    Choice.withText(text: 'Whole milk', id: 'whole'),
    Choice.withText(text: '2% fat milk', id: '2percent'),
    Choice.withText(text: '1% fat milk', id: '1percent'),
    Choice.withText(text: 'Skim, nonfat, or 1/2% fat milk', id: 'skim'),
    Choice.withText(text: 'Soy milk', id: 'soy'),
    Choice.withText(text: 'Rice milk', id: 'rice'),
    Choice.withText(text: 'Almond milk', id: 'almond'),
    Choice.withText(text: 'Coconut milk', id: 'coconut'),
    Choice.withText(text: 'Other', id: 'other'),
  ];

  /// Milk type for cereal (10 options)
  static List<Choice> get milkTypeCereal => [
    Choice.withText(text: 'Whole milk', id: 'whole'),
    Choice.withText(text: '2% fat milk', id: '2percent'),
    Choice.withText(text: '1% fat milk', id: '1percent'),
    Choice.withText(text: 'Skim, nonfat, or 1/2% fat milk', id: 'skim'),
    Choice.withText(text: 'Soy milk', id: 'soy'),
    Choice.withText(text: 'Rice milk', id: 'rice'),
    Choice.withText(text: 'Almond milk', id: 'almond'),
    Choice.withText(text: 'Coconut milk', id: 'coconut'),
    Choice.withText(text: 'Condensed or evaporated milk', id: 'condensed'),
    Choice.withText(text: 'Other', id: 'other'),
  ];

  /// Water portion
  static List<Choice> get portionWater => [
    Choice.withText(text: 'Less than 1 cup (8 ounces)', id: 'less'),
    Choice.withText(text: '1 to 3 cups (8 to 24 ounces)', id: 'medium'),
    Choice.withText(text: 'More than 3 cups (24 ounces)', id: 'more'),
  ];

  /// Soda portion
  static List<Choice> get portionSoda => [
    Choice.withText(text: 'Less than 1 can or bottle (12 ounces)', id: 'less'),
    Choice.withText(text: '1 can or bottle (12 to 16 ounces)', id: 'medium'),
    Choice.withText(text: 'More than 1 can or bottle (16 ounces)', id: 'more'),
  ];

  /// Sports drinks portion (bottles)
  static List<Choice> get portionSportsBottles => [
    Choice.withText(text: 'Less than 1 bottle (12 ounces)', id: 'less'),
    Choice.withText(text: '1 to 2 bottles (12 to 24 ounces)', id: 'medium'),
    Choice.withText(text: 'More than 2 bottles (24 ounces)', id: 'more'),
  ];

  /// Vitamin water portion (bottles)
  static List<Choice> get portionVitaminWater => [
    Choice.withText(text: 'Less than 1 bottle (12 ounces)', id: 'less'),
    Choice.withText(text: '1 to 2 bottles (12 to 20 ounces)', id: 'medium'),
    Choice.withText(text: 'More than 2 bottles (20 ounces)', id: 'more'),
  ];

  /// Beer portion
  static List<Choice> get portionBeer => [
    Choice.withText(text: 'Less than a 12-ounce can or bottle', id: 'less'),
    Choice.withText(text: '1 to 3 12-ounce cans or bottles', id: 'medium'),
    Choice.withText(text: 'More than 3 12-ounce cans or bottles', id: 'more'),
  ];

  /// Wine portion
  static List<Choice> get portionWine => [
    Choice.withText(text: 'Less than 1 glass (5 ounces)', id: 'less'),
    Choice.withText(text: '1 to 2 glasses (5 to 10 ounces)', id: 'medium'),
    Choice.withText(text: 'More than 2 glasses (10 ounces)', id: 'more'),
  ];

  /// Liquor portion
  static List<Choice> get portionLiquor => [
    Choice.withText(text: 'Less than 1 shot of liquor', id: 'less'),
    Choice.withText(text: '1 to 4 shots of liquor', id: 'medium'),
    Choice.withText(text: 'More than 4 shots of liquor', id: 'more'),
  ];

  /// Espresso drinks portion
  static List<Choice> get portionEspresso => [
    Choice.withText(text: 'Less than a small drink (12 ounces)', id: 'less'),
    Choice.withText(
      text: 'Small to medium drink (12 to 16 ounces)',
      id: 'medium',
    ),
    Choice.withText(text: 'More than a large drink (20 ounces)', id: 'more'),
  ];

  /// Teaspoons portion
  static List<Choice> get portionTeaspoons => [
    Choice.withText(text: 'Less than 1 teaspoon', id: 'less'),
    Choice.withText(text: '1 to 3 teaspoons', id: 'medium'),
    Choice.withText(text: 'More than 3 teaspoons', id: 'more'),
  ];

  /// Artificial sweetener type
  static List<Choice> get sweetenerType => [
    Choice.withText(text: 'Equal or aspartame', id: 'equal'),
    Choice.withText(text: "Sweet'N Low or saccharin", id: 'saccharin'),
    Choice.withText(text: 'Splenda or sucralose', id: 'splenda'),
    Choice.withText(text: 'Stevia', id: 'stevia'),
    Choice.withText(text: 'Herbal extracts or other kind', id: 'other'),
  ];

  /// Artificial sweetener portion
  static List<Choice> get portionSweetenerPackets => [
    Choice.withText(
      text: 'Less than 1 packet or less than 1 teaspoon',
      id: 'less',
    ),
    Choice.withText(text: '1 packet or 1 teaspoon', id: 'medium'),
    Choice.withText(
      text: 'More than 1 packet or more than 1 teaspoon',
      id: 'more',
    ),
  ];

  /// Non-dairy creamer type
  static List<Choice> get creamerType => [
    Choice.withText(text: 'Regular powdered', id: 'regular_powder'),
    Choice.withText(text: 'Regular liquid', id: 'regular_liquid'),
    Choice.withText(text: 'Low-fat or fat-free liquid', id: 'lowfat_liquid'),
    Choice.withText(text: 'Low-fat or fat-free powdered', id: 'lowfat_powder'),
  ];

  /// Cream type
  static List<Choice> get creamType => [
    Choice.withText(text: 'Regular', id: 'regular'),
    Choice.withText(text: 'Low-fat', id: 'lowfat'),
  ];

  /// Cold tea sweetener type
  static List<Choice> get teaSweetenerType => [
    Choice.withText(text: 'Sugar or honey', id: 'sugar'),
    Choice.withText(
      text: "Artificial sweeteners (such as Splenda, Equal, Sweet'N Low or others)",
      id: 'artificial',
    ),
  ];

  /// Cooking fats for vegetables
  static List<Choice> get cookingFats => [
    Choice.withText(text: 'Margarine (including low-fat)', id: 'margarine'),
    Choice.withText(text: 'Butter (including low-fat)', id: 'butter'),
    Choice.withText(text: 'Olive oil', id: 'olive_oil'),
    Choice.withText(
      text: 'Other kinds of oils (corn, canola, or rapeseed oil, etc.)',
      id: 'other_oil',
    ),
  ];

  /// After cooking fats
  static List<Choice> get afterCookingFats => [
    Choice.withText(text: 'Margarine (including low-fat)', id: 'margarine'),
    Choice.withText(text: 'Butter (including low-fat)', id: 'butter'),
    Choice.withText(
      text: 'Salad dressing (including low-fat or fat-free)',
      id: 'dressing',
    ),
    Choice.withText(text: 'Other', id: 'other'),
  ];

  /// Chicken cooking method
  static List<Choice> get chickenDoneness => [
    Choice.withText(text: 'Just until done', id: 'just_done'),
    Choice.withText(text: 'Well-done', id: 'well_done'),
    Choice.withText(text: 'Very well-done', id: 'very_well_done'),
    Choice.withText(text: "Don't know", id: 'dont_know'),
  ];

  /// Beef/steak doneness
  static List<Choice> get beefDoneness => [
    Choice.withText(text: 'Rare', id: 'rare'),
    Choice.withText(text: 'Medium', id: 'medium'),
    Choice.withText(text: 'Well-done', id: 'well_done'),
    Choice.withText(text: 'Very well-done', id: 'very_well_done'),
    Choice.withText(text: "Don't Know", id: 'dont_know'),
  ];

  /// Bacon doneness
  static List<Choice> get baconDoneness => [
    Choice.withText(text: 'Just until done', id: 'just_done'),
    Choice.withText(text: 'Well-done/crisp', id: 'well_done'),
    Choice.withText(text: 'Charred', id: 'charred'),
    Choice.withText(text: "Don't know", id: 'dont_know'),
  ];

  /// Supplement frequency
  static List<Choice> get supplementFreq => [
    Choice.withText(text: 'Less than 1 day per month', id: 'lt1_month'),
    Choice.withText(text: '1-3 days per month', id: '1_3_month'),
    Choice.withText(text: '1-3 days per week', id: '1_3_week'),
    Choice.withText(text: '4-6 days per week', id: '4_6_week'),
    Choice.withText(text: 'Everyday', id: 'everyday'),
  ];

  /// Supplement years taken
  static List<Choice> get supplementYears => [
    Choice.withText(text: 'Less than 1 year', id: 'lt1'),
    Choice.withText(text: '1-4 years', id: '1_4'),
    Choice.withText(text: '5-9 years', id: '5_9'),
    Choice.withText(text: '10 or more years', id: '10_plus'),
  ];

  /// Multivitamin type
  static List<Choice> get multivitaminType => [
    Choice.withText(text: 'Multivitamin', id: 'regular'),
    Choice.withText(
      text: 'Multivitamin for people 50 years of age or older',
      id: '50_plus',
    ),
    Choice.withText(text: 'Prenatal multivitamin', id: 'prenatal'),
    Choice.withText(text: "Don't know", id: 'dont_know'),
  ];

  /// Gummy count
  static List<Choice> get gummyCount => [
    Choice.withText(text: 'Less than 1', id: 'lt1'),
    Choice.withText(text: '1', id: '1'),
    Choice.withText(text: '2', id: '2'),
    Choice.withText(text: '3', id: '3'),
    Choice.withText(text: '4 or more', id: '4_plus'),
    Choice.withText(text: "Don't know", id: 'dont_know'),
  ];
}
