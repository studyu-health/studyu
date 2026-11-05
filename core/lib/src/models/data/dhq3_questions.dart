import 'package:studyu_core/core.dart';

import 'package:studyu_core/src/models/data/dhq3_choices.dart';

/// 14 named DHQ3 surveys – each is a separate entity with a meaningful title.
/// Order defines scheduling: survey 1 = day 1, etc.
/// Skip logic: frequency/portion only when item is selected (checklists) or when frequency != NEVER.
class Dhq3Questions() {
  static const int surveyCount = 14;

  /// Ordered list of survey titles (day 1 = index 0, etc.). Balanced cluster sizes (~16–34 questions each).
  static const List<String> surveyTitles = [
    'About you & coffee/tea',
    'Beverages – Juices & milk',
    'Beverages – Soda, alcohol & tea',
    'Fruits',
    'Vegetables – Greens, carrots & beans',
    'Vegetables – Broccoli, peppers & salads',
    'Vegetables – Potatoes & other',
    'Soups, rice, pasta & pizza',
    'Cereal, breads & spreads',
    'Cold cuts, eggs & snacks',
    'Meat & poultry – Part 1',
    'Meat & poultry & fish – Part 2',
    'Dairy & sweets',
    'Spreads, diet summary & supplements',
  ];

  static const String _introText =
      'FOR INFORMATIONAL USE ONLY. This survey asks about the past 12 months. Select "NEVER" when you did not consume an item.';

  static QuestionnaireTask createTaskForDay(int dayIndex) {
    final i = dayIndex.clamp(0, surveyCount - 1);
    final task = QuestionnaireTask.withId()
      ..title = surveyTitles[i]
      ..header = _introText
      ..footer = 'Thank you for completing this survey.'
      ..questions.questions = _questionsForSection(i);
    task.schedule = Schedule()
      ..completionPeriods = [
        CompletionPeriod.noId(
          unlockTime: StudyUTimeOfDay(),
          lockTime: StudyUTimeOfDay(hour: 23, minute: 59),
        ),
      ]
      ..reminders = [StudyUTimeOfDay(hour: 9)];
    return task;
  }

  static int? dayIndexForTitle(String? title) {
    if (title == null) return null;
    final i = surveyTitles.indexOf(title);
    return i >= 0 ? i + 1 : null; // 1-based day number
  }

  static bool isNamedSurvey(String? title) =>
      title != null && surveyTitles.contains(title);

  static List<Question> _questionsForSection(int section) {
    switch (section) {
      case 0:
        return _aboutYouAndCoffeeTea();
      case 1:
        return _beveragesPart(0, 12);
      case 2:
        return _beveragesPart(12, 24);
      case 3:
        return _fruits();
      case 4:
        return _vegetablesPart(0, 9);
      case 5:
        return _vegetablesPart(9, 18);
      case 6:
        return _vegetablesPart(18, 27);
      case 7:
        return _soupsAndRicePastaPizza();
      case 8:
        return _cerealPancakesBreads();
      case 9:
        return _coldCutsAndEggsAndSnacks();
      case 10:
        return _meatPoultryFishPart(0, 12);
      case 11:
        return _meatPoultryFishPart(12, 24);
      case 12:
        return _yogurtCheeseSweets();
      case 13:
        return _spreadsSummaryVitamins();
      default:
        return [];
    }
  }

  static ChoiceQuestion _q(
    String id,
    String prompt, {
    List<Choice>? choices,
    bool multiple = false,
  }) {
    final c = ChoiceQuestion.withId()
      ..id = id
      ..prompt = prompt
      ..multiple = multiple
      ..choices = choices ?? Dhq3Choices.frequencyWithNever;
    return c;
  }

  /// Show this question only when [checklistQuestionId] has [choiceId] selected (for checklists).
  static QuestionConditional<List<String>> _showWhenChoiceSelected(
    String checklistQuestionId,
    String choiceId,
  ) {
    final ce = ChoiceExpression()
      ..target = checklistQuestionId
      ..choices = {choiceId};
    return QuestionConditional<List<String>>.withCondition(
      CompositeExpression(logicType: LogicType.and, expressions: [ce]),
    );
  }

  /// Show this question only when [frequencyQuestionId] answer is not NEVER (for portion follow-ups).
  static QuestionConditional<List<String>> _showWhenNotNever(
    String frequencyQuestionId,
  ) {
    final ce = ChoiceExpression()
      ..target = frequencyQuestionId
      ..choices = {'never'};
    final notExpr = NotExpression()..expression = ce;
    return QuestionConditional<List<String>>.withCondition(
      CompositeExpression(logicType: LogicType.and, expressions: [notExpr]),
    );
  }

  /// About you – exact FFQ wording.
  static List<Question> _aboutYou() {
    final q = <Question>[];

    final dob = DateQuestion()
      ..id = 'dhq_dob'
      ..prompt = 'What is your date of birth?';
    q.add(dob);

    q.add(
      _q(
        'dhq_sex',
        'Are you male or female?',
        choices: [
          Choice.withText(text: 'Male', id: 'male'),
          Choice.withText(text: 'Female', id: 'female'),
          Choice.withText(text: 'Other', id: 'other'),
        ],
      ),
    );
    return q;
  }

  static List<Question> _aboutYouAndCoffeeTea() {
    final q = <Question>[];
    q.addAll(_aboutYou());
    q.addAll(_coffeeTeaAdditions());
    return q;
  }

  /// Beverage list – exact wording from DHQ3 FFQ (Past Year With Serving Sizes).
  static const List<String> _allBev = [
    'Tomato juice or vegetable juice',
    'Orange juice or grapefruit juice',
    'Grape juice',
    'Other 100% fruit juices or 100% fruit juice mixtures (such as apple, pineapple, or others)',
    'Fruit or vegetable smoothies',
    'Other fruit drinks, regular or diet (such as Hi-C, fruit punch, lemonade, or cranberry cocktail)',
    'Milkshakes',
    'Soda or pop',
    'Milk as a beverage (NOT in coffee, tea, or cereal; including soy, rice, almond, and coconut milk; NOT including chocolate milk, hot chocolate, and milkshake)',
    'Chocolate milk or hot chocolate',
    'Meal replacement or high-protein beverages (such as Ensure, Boost, Muscle Milk, Slimfast, Instant Breakfast, or others; NOT including any added protein powder)',
    'Sports drinks (such as Gatorade, Powerade, or Propel)',
    'Energy drinks (such as Red Bull or Jolt)',
    'Water (including tap, bottled, and carbonated water; NOT including vitamin water)',
    'Vitamin water (such as SoBe, Propel Zero, or Glaceau Water)',
    'Beer',
    'Wine or wine cooler',
    'Liquor or mixed drinks',
    'Coffee, caffeinated or decaffeinated (including brewed coffee, instant coffee, or espresso shots; NOT including espresso drinks such as latte, mocha, etc.)',
    'Espresso drink mixtures, caffeinated or decaffeinated (including latte, mocha, cappuccino, etc.)',
    'COLD or ICED tea, caffeinated or decaffeinated (NOT including herbal or green tea)',
    'HOT tea, caffeinated or decaffeinated (NOT including herbal or green tea)',
    'Green tea',
    'Herbal or fruit tea (including hibiscus, chamomile, licorice, sassafras, etc.)',
  ];

  /// Beverages for indices [start, end). Uses prefix for checklist ids (e.g. p0, p1).
  static List<Question> _beveragesPart(int start, int end) {
    final q = <Question>[];
    final prefix = start == 0 ? 'p0' : 'p1';
    final count = end - start;
    const maxPerChecklist = 8;
    final numChecklists = (count + maxPerChecklist - 1) ~/ maxPerChecklist;
    for (var part = 0; part < numChecklists; part++) {
      final pStart = start + part * maxPerChecklist;
      final pEnd = (pStart + maxPerChecklist).clamp(0, end);
      if (pStart >= end) break;
      final opts = _allBev
          .sublist(pStart, pEnd)
          .asMap()
          .entries
          .map(
            (e) => Choice.withText(
              text: e.value,
              id: 'bev_${prefix}_${part}_${e.key}',
            ),
          )
          .toList();
      q.add(
        _q(
          'dhq_beverages_${prefix}_$part',
          'What beverages did you drink? Please check the box next to each beverage that you drank at least once in the past 12 months. (Part ${part + 1} of $numChecklists.)',
          multiple: true,
          choices: opts,
        ),
      );
    }
    final summerRestIndices = {
      7,
      11,
      13,
      15,
    }; // soda, sports drinks, water, beer
    for (var i = start; i < end; i++) {
      final localIndex = i - start;
      final part = localIndex ~/ maxPerChecklist;
      final offset = localIndex % maxPerChecklist;
      final checklistId = 'dhq_beverages_${prefix}_$part';
      final choiceId = 'bev_${prefix}_${part}_$offset';
      final cond = _showWhenChoiceSelected(checklistId, choiceId);
      final name = _allBev[i];
      final nameLower = name.toLowerCase();

      if (summerRestIndices.contains(i)) {
        final freqSummer = _q(
          'dhq_bev_${i}_freq_summer',
          'How often did you drink $nameLower IN THE SUMMER?',
        );
        freqSummer.conditional = cond;
        q.add(freqSummer);
        final freqRest = _q(
          'dhq_bev_${i}_freq_rest',
          'How often did you drink $nameLower DURING THE REST OF THE YEAR?',
        );
        freqRest.conditional = cond;
        q.add(freqRest);
      } else {
        final freqQ = _q(
          'dhq_bev_${i}_freq',
          'Over the past 12 months, how often did you drink $nameLower?',
        );
        freqQ.conditional = cond;
        q.add(freqQ);
      }

      // Portion sizes based on beverage type
      List<Choice> portionChoices;
      if (i == 13) {
        portionChoices = Dhq3Choices.portionWater;
      } else if (i == 7) {
        portionChoices = Dhq3Choices.portionSoda;
      } else if (i == 11) {
        portionChoices = Dhq3Choices.portionSportsBottles;
      } else if (i == 14) {
        portionChoices = Dhq3Choices.portionVitaminWater;
      } else if (i == 15) {
        portionChoices = Dhq3Choices.portionBeer;
      } else if (i == 16) {
        portionChoices = Dhq3Choices.portionWine;
      } else if (i == 17) {
        portionChoices = Dhq3Choices.portionLiquor;
      } else if (i == 19) {
        portionChoices = Dhq3Choices.portionEspresso;
      } else {
        portionChoices = Dhq3Choices.portionCups(
          'Less than 3/4 cup (6 ounces)',
          '3/4 to 1 1/2 cups (6 to 12 ounces)',
          'More than 1 1/2 cups (12 ounces)',
        );
      }
      final portionQ = _q(
        'dhq_bev_${i}_portion',
        'Each time you drank $nameLower, how much did you usually drink?',
        choices: portionChoices,
      );
      portionQ.conditional = cond;
      q.add(portionQ);

      // Follow-ups from FFQ (exact wording)
      if (i == 1) {
        // Orange juice calcium-fortified
        final ojCalcium = _q(
          'dhq_bev_1_oj_calcium',
          'How often was the orange juice or grapefruit juice you drank calcium-fortified?',
          choices: Dhq3Choices.almostNeverToAlways,
        );
        ojCalcium.conditional = cond;
        q.add(ojCalcium);
      } else if (i == 5) {
        // Other fruit drinks - diet
        final fruitDiet = _q(
          'dhq_bev_5_diet',
          'How often were your other fruit drinks diet or sugar-free?',
          choices: Dhq3Choices.almostNeverToAlways,
        );
        fruitDiet.conditional = cond;
        q.add(fruitDiet);
      } else if (i == 7) {
        // Soda - diet and caffeine-free
        final sodaDiet = _q(
          'dhq_bev_7_diet',
          'How often were these sodas or pops diet or sugar-free?',
          choices: Dhq3Choices.almostNeverToAlways,
        );
        sodaDiet.conditional = cond;
        q.add(sodaDiet);
        final sodaCaff = _q(
          'dhq_bev_7_caffeine',
          'How often were these sodas or pops caffeine-free?',
          choices: Dhq3Choices.almostNeverToAlways,
        );
        sodaCaff.conditional = cond;
        q.add(sodaCaff);
      } else if (i == 8) {
        // Milk - type
        final milkKind = _q(
          'dhq_bev_8_milk_type',
          'What kind of milk did you usually drink?',
          choices: Dhq3Choices.milkType,
        );
        milkKind.conditional = cond;
        q.add(milkKind);
      } else if (i == 9) {
        // Chocolate milk - reduced fat
        final chocReduced = _q(
          'dhq_bev_9_reduced_fat',
          'How often was the chocolate milk or hot chocolate reduced-fat or fat-free?',
          choices: Dhq3Choices.almostNeverToAlways,
        );
        chocReduced.conditional = cond;
        q.add(chocReduced);
      } else if (i == 11) {
        // Sports drinks - diet/sugar-free
        final sportsDiet = _q(
          'dhq_bev_11_diet',
          'How often were the sports drinks you drank diet or sugar-free?',
          choices: Dhq3Choices.almostNeverToAlways,
        );
        sportsDiet.conditional = cond;
        q.add(sportsDiet);
      } else if (i == 13) {
        // Water - tap, bottled sweetened, bottled unsweetened
        final tap = _q(
          'dhq_bev_13_tap',
          'How often was the water you drank tap water?',
          choices: Dhq3Choices.almostNeverToAlways,
        );
        tap.conditional = cond;
        q.add(tap);
        final bottledSweet = _q(
          'dhq_bev_13_bottled_sweetened',
          'How often was the water you drank bottled, sweetened water, regular or diet (including carbonated water)?',
          choices: Dhq3Choices.almostNeverToAlways,
        );
        bottledSweet.conditional = cond;
        q.add(bottledSweet);
        final bottledUnsw = _q(
          'dhq_bev_13_bottled_unsweetened',
          'How often was the water you drank bottled, unsweetened water (including carbonated water)?',
          choices: Dhq3Choices.almostNeverToAlways,
        );
        bottledUnsw.conditional = cond;
        q.add(bottledUnsw);
      } else if (i == 15) {
        // Beer - light beer
        final lightBeer = _q(
          'dhq_bev_15_light',
          'How often was the beer you drank light beer?',
          choices: Dhq3Choices.almostNeverToAlways,
        );
        lightBeer.conditional = cond;
        q.add(lightBeer);
      } else if (i == 16) {
        // Wine - red wine
        final redWine = _q(
          'dhq_bev_16_red',
          'How often was the wine you drank red wine?',
          choices: Dhq3Choices.almostNeverToAlways,
        );
        redWine.conditional = cond;
        q.add(redWine);
      } else if (i == 18) {
        // Coffee - decaf, iced coffee
        final coffeeDecaf = _q(
          'dhq_bev_18_decaf',
          'How often was the coffee you drank decaffeinated?',
          choices: Dhq3Choices.almostNeverToAlways,
        );
        coffeeDecaf.conditional = cond;
        q.add(coffeeDecaf);
        final coffeeIced = _q(
          'dhq_bev_18_iced',
          'How often was the coffee you drank iced coffee?',
          choices: Dhq3Choices.almostNeverToAlways,
        );
        coffeeIced.conditional = cond;
        q.add(coffeeIced);
      } else if (i == 19) {
        // Espresso drinks - decaf, soy/nonfat milk, flavor shot
        final espressoDecaf = _q(
          'dhq_bev_19_decaf',
          'How often were the espresso drinks you drank decaffeinated?',
          choices: Dhq3Choices.almostNeverToAlways,
        );
        espressoDecaf.conditional = cond;
        q.add(espressoDecaf);
        final espressoNonfat = _q(
          'dhq_bev_19_nonfat',
          'How often were the espresso drinks made with soy or nonfat milk?',
          choices: Dhq3Choices.almostNeverToAlways,
        );
        espressoNonfat.conditional = cond;
        q.add(espressoNonfat);
        final espressoFlavor = _q(
          'dhq_bev_19_flavor',
          'How often did you have a flavor shot added to the espresso drinks?',
          choices: Dhq3Choices.almostNeverToAlways,
        );
        espressoFlavor.conditional = cond;
        q.add(espressoFlavor);
      } else if (i == 20) {
        // Cold/iced tea - sweetened, sugar/honey
        final coldTeaSweetened = _q(
          'dhq_bev_20_sweetened',
          'How often was the cold or iced tea you drank sweetened (with sugar, honey, or an artificial sweetener)?',
          choices: Dhq3Choices.almostNeverToAlways,
        );
        coldTeaSweetened.conditional = cond;
        q.add(coldTeaSweetened);
        final coldTeaSweetener = _q(
          'dhq_bev_20_sweetener_type',
          'Was your cold or iced tea usually sweetened with sugar or honey, or with an artificial sweetener?',
          choices: Dhq3Choices.teaSweetenerType,
        );
        coldTeaSweetener.conditional = cond;
        q.add(coldTeaSweetener);
        final coldTeaDecaf = _q(
          'dhq_bev_20_decaf',
          'How often was the cold or iced tea you drank decaffeinated?',
          choices: Dhq3Choices.almostNeverToAlways,
        );
        coldTeaDecaf.conditional = cond;
        q.add(coldTeaDecaf);
      } else if (i == 21) {
        // Hot tea - decaf
        final hotTeaDecaf = _q(
          'dhq_bev_21_decaf',
          'How often was the hot tea you drank decaffeinated?',
          choices: Dhq3Choices.almostNeverToAlways,
        );
        hotTeaDecaf.conditional = cond;
        q.add(hotTeaDecaf);
      } else if (i == 22) {
        // Green tea - decaf
        final greenTeaDecaf = _q(
          'dhq_bev_22_decaf',
          'How often was the green tea you drank decaffeinated?',
          choices: Dhq3Choices.almostNeverToAlways,
        );
        greenTeaDecaf.conditional = cond;
        q.add(greenTeaDecaf);
      }
    }
    return q;
  }

  /// Additions to coffee and tea – exact FFQ wording with all follow-ups.
  static List<Question> _coffeeTeaAdditions() {
    final q = <Question>[];
    // Checklist
    q.add(
      _q(
        'dhq_coffee_additions',
        'What did you add to your coffee and tea? Please check the box next to each item you added to your coffee or tea at least once in the past 12 months.',
        multiple: true,
        choices: [
          Choice.withText(
            text: 'Sugar, honey, or other sweeteners',
            id: 'sugar',
          ),
          Choice.withText(
            text: 'Cream, milk (including soy, rice, almond, and coconut), or non-dairy creamer',
            id: 'cream',
          ),
        ],
      ),
    );

    // Sugar/honey follow-ups
    final sugarCond = _showWhenChoiceSelected('dhq_coffee_additions', 'sugar');
    final sugarFreq = _q(
      'dhq_sugar_freq',
      'How often did you add sugar, honey, or other sweeteners to your coffee or tea, iced or hot (including green and herbal tea)?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    sugarFreq.conditional = sugarCond;
    q.add(sugarFreq);

    final sugarPortion = _q(
      'dhq_sugar_portion',
      'Each time you added sugar or honey to your coffee or tea, how much did you usually add in total?',
      choices: Dhq3Choices.portionTeaspoons,
    );
    sugarPortion.conditional = sugarCond;
    q.add(sugarPortion);

    final artSweetFreq = _q(
      'dhq_artificial_sweetener_freq',
      'How often did you add an artificial or no-calorie sweetener to your coffee or tea?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    artSweetFreq.conditional = sugarCond;
    q.add(artSweetFreq);

    final artSweetType = _q(
      'dhq_artificial_sweetener_type',
      'What kind of artificial or no-calorie sweetener did you usually use?',
      choices: Dhq3Choices.sweetenerType,
    );
    artSweetType.conditional = sugarCond;
    q.add(artSweetType);

    final artSweetPortion = _q(
      'dhq_artificial_sweetener_portion',
      'Each time you added artificial sweetener, how much did you usually add in total?',
      choices: Dhq3Choices.portionSweetenerPackets,
    );
    artSweetPortion.conditional = sugarCond;
    q.add(artSweetPortion);

    // Cream/milk follow-ups
    final creamCond = _showWhenChoiceSelected('dhq_coffee_additions', 'cream');

    // Non-dairy creamer
    final ndCreamerFreq = _q(
      'dhq_nondairy_creamer_freq',
      'How often was non-dairy creamer added to your coffee or tea (including green and herbal tea)?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    ndCreamerFreq.conditional = creamCond;
    q.add(ndCreamerFreq);

    final ndCreamerPortion = _q(
      'dhq_nondairy_creamer_portion',
      'Each time you added non-dairy creamer, how much did you usually add in total?',
      choices: Dhq3Choices.portionTeaspoons,
    );
    ndCreamerPortion.conditional = creamCond;
    q.add(ndCreamerPortion);

    final ndCreamerType = _q(
      'dhq_nondairy_creamer_type',
      'What kind of non-dairy creamer did you usually use?',
      choices: Dhq3Choices.creamerType,
    );
    ndCreamerType.conditional = creamCond;
    q.add(ndCreamerType);

    // Cream or half-and-half
    final creamFreq = _q(
      'dhq_cream_freq',
      'How often was cream or half-and-half added to your coffee or tea?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    creamFreq.conditional = creamCond;
    q.add(creamFreq);

    final creamPortion = _q(
      'dhq_cream_portion',
      'Each time you added cream or half-and-half, how much did you usually add in total?',
      choices: [
        Choice.withText(text: 'Less than 1 tablespoon', id: 'less'),
        Choice.withText(text: '1 to 3 tablespoons', id: 'medium'),
        Choice.withText(text: 'More than 3 tablespoons', id: 'more'),
      ],
    );
    creamPortion.conditional = creamCond;
    q.add(creamPortion);

    final creamType = _q(
      'dhq_cream_type',
      'What kind of cream or half-and-half did you usually use?',
      choices: Dhq3Choices.creamType,
    );
    creamType.conditional = creamCond;
    q.add(creamType);

    // Milk in coffee/tea
    final milkFreq = _q(
      'dhq_milk_in_coffee_freq',
      'How often was milk (including soy, rice, almond, and coconut) added to your coffee or tea?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    milkFreq.conditional = creamCond;
    q.add(milkFreq);

    final milkPortion = _q(
      'dhq_milk_in_coffee_portion',
      'Each time you added milk to your coffee or tea, how much did you usually add in total?',
      choices: [
        Choice.withText(text: 'Less than 1/4 cup (2 ounces)', id: 'less'),
        Choice.withText(text: '1/4 to 1/2 cup (2 to 4 ounces)', id: 'medium'),
        Choice.withText(text: 'More than 1/2 cup (4 ounces)', id: 'more'),
      ],
    );
    milkPortion.conditional = creamCond;
    q.add(milkPortion);

    final milkType = _q(
      'dhq_milk_in_coffee_type',
      'What kind of milk did you usually add to your coffee or tea?',
      choices: Dhq3Choices.milkType,
    );
    milkType.conditional = creamCond;
    q.add(milkType);

    return q;
  }

  static List<Question> _fruits() {
    final q = <Question>[];
    const fruits = [
      'Applesauce',
      'Apples',
      'Bananas',
      'Peaches, nectarines, or plums',
      'Dried fruit (such as prunes or raisins)',
      'Pineapple (fresh, canned, or frozen)',
      'Pears (fresh, canned, or frozen)',
      'Grapes',
      'Cantaloupe',
      'Melons, other than cantaloupe (such as watermelon or honeydew)',
      'Strawberries',
      'Blueberries',
      'Oranges, tangerines, or clementines',
      'Grapefruit',
      'Avocado or guacamole',
      'Other kinds of fruit (not listed above)',
    ];
    // Seasonal fruits indices: peaches(3), cantaloupe(8), strawberries(10), blueberries(11), oranges(12), grapefruit(13)
    const seasonalFruits = {3, 8, 10, 11, 12, 13};

    for (var part = 0; part < 2; part++) {
      final start = part * 8;
      final end = (start + 8).clamp(0, fruits.length);
      if (start >= fruits.length) break;
      final opts = fruits
          .sublist(start, end)
          .asMap()
          .entries
          .map((e) => Choice.withText(text: e.value, id: 'f_${part}_${e.key}'))
          .toList();
      q.add(
        _q(
          'dhq_fruits_$part',
          'What fruits have you eaten? Please check the box next to each food that you ate at least once in the past 12 months. (Part ${part + 1} of 2.)',
          multiple: true,
          choices: opts,
        ),
      );
    }
    for (var i = 0; i < fruits.length; i++) {
      final part = i ~/ 8;
      final offset = i % 8;
      final checklistId = 'dhq_fruits_$part';
      final choiceId = 'f_${part}_$offset';
      final cond = _showWhenChoiceSelected(checklistId, choiceId);
      final name = fruits[i];

      // Seasonal fruits get IN SEASON / REST OF YEAR questions
      if (seasonalFruits.contains(i)) {
        final freqSeason = _q(
          'dhq_fruit_${i}_freq_season',
          'How often did you eat ${name.toLowerCase()} WHEN IN SEASON?',
          choices: Dhq3Choices.frequencySeason,
        );
        freqSeason.conditional = cond;
        q.add(freqSeason);
        final freqRest = _q(
          'dhq_fruit_${i}_freq_rest',
          'How often did you eat ${name.toLowerCase()} DURING THE REST OF THE YEAR?',
          choices: Dhq3Choices.frequencyFoodWithNever,
        );
        freqRest.conditional = cond;
        q.add(freqRest);
      } else {
        final freqQ = _q(
          'dhq_fruit_${i}_freq',
          'Over the past 12 months, how often did you eat ${name.toLowerCase()}?',
        );
        freqQ.conditional = cond;
        q.add(freqQ);
      }

      // Portion sizes - specific for each fruit
      List<Choice> portionChoices;
      if (i == 0) {
        // Applesauce
        portionChoices = Dhq3Choices.portionCups(
          'Less than 1/2 cup',
          '1/2 to 1 cup',
          'More than 1 cup',
        );
      } else if (i == 1) {
        // Apples
        portionChoices = [
          Choice.withText(text: 'Less than 1 apple', id: 'less'),
          Choice.withText(text: '1 apple', id: 'medium'),
          Choice.withText(text: 'More than 1 apple', id: 'more'),
        ];
      } else if (i == 2) {
        // Bananas
        portionChoices = [
          Choice.withText(text: 'Less than 1 banana', id: 'less'),
          Choice.withText(text: '1 banana', id: 'medium'),
          Choice.withText(text: 'More than 1 banana', id: 'more'),
        ];
      } else if (i == 3) {
        // Peaches
        portionChoices = [
          Choice.withText(
            text: 'Less than 1 peach, nectarine, or plum',
            id: 'less',
          ),
          Choice.withText(text: '1 to 2', id: 'medium'),
          Choice.withText(text: 'More than 2', id: 'more'),
        ];
      } else if (i == 4) {
        // Dried fruit
        portionChoices = [
          Choice.withText(text: 'Less than 2 tablespoons', id: 'less'),
          Choice.withText(text: '2 to 5 tablespoons', id: 'medium'),
          Choice.withText(text: 'More than 5 tablespoons', id: 'more'),
        ];
      } else if (i == 14) {
        // Avocado
        portionChoices = [
          Choice.withText(
            text: 'Less than 1/4 avocado or 2 tablespoons guacamole',
            id: 'less',
          ),
          Choice.withText(
            text: '1/4 to 1/2 avocado or 2 to 5 tablespoons guacamole',
            id: 'medium',
          ),
          Choice.withText(
            text: 'More than 1/2 avocado or more than 5 tablespoons guacamole',
            id: 'more',
          ),
        ];
      } else {
        portionChoices = Dhq3Choices.portionCups(
          'Less than 1/2 cup',
          '1/2 to 1 cup',
          'More than 1 cup',
        );
      }

      final portionQ = _q(
        'dhq_fruit_${i}_portion',
        'Each time you ate ${name.toLowerCase()}, how much did you usually eat?',
        choices: portionChoices,
      );
      portionQ.conditional = cond;
      q.add(portionQ);
    }
    return q;
  }

  /// Vegetables, potatoes, beans – exact FFQ wording.
  static const List<String> _veg = [
    'COOKED greens (such as spinach, turnip, collard, mustard, chard, or kale)',
    'RAW greens (such as spinach, turnip, collard, chard, kale, watercress, seaweed, mustard greens, beet greens, or dandelion greens)',
    'Coleslaw',
    'Sauerkraut or cabbage (other than coleslaw)',
    'COOKED carrots (including frozen, fresh, or canned)',
    'RAW carrots',
    'String beans or green beans (fresh, canned, or frozen)',
    'Peas (fresh, canned, or frozen)',
    'Corn (fresh, canned, or frozen)',
    'Broccoli (fresh or frozen)',
    'Cauliflower or Brussels sprouts (fresh or frozen)',
    'Sweet peppers (green, red, or yellow)',
    'Onions',
    'Garlic',
    'Mixed vegetables',
    'Lettuce salads (with or without other vegetables)',
    'Salad dressing on salads (including low-fat or fat-free)',
    'Mayonnaise on salads (including low-fat, diet, or light)',
    'Fresh tomatoes (including those in salads)',
    'Salsa',
    'Catsup or ketchup',
    'Sweet potatoes or yams',
    'French fries, home fries, hash browned potatoes, or Tater Tots',
    'Potato salad',
    'Baked, boiled, or mashed potatoes',
    'Cooked dried or canned beans (such as baked beans, pintos, kidney, black-eyed peas, lima, lentils, soybeans, or refried beans; NOT including bean soups or chili)',
    'Other kinds of vegetables (not listed above)',
  ];

  /// Vegetables for indices [start, end). Prefix p0, p1, p2 for the three sections.
  static List<Question> _vegetablesPart(int start, int end) {
    final q = <Question>[];
    final prefix = 'p${start ~/ 9}';
    const maxPerChecklist = 9;
    // Seasonal vegetables: corn(8), fresh tomatoes(18)
    const seasonalVeg = {8, 18};

    for (var part = 0; part < 1; part++) {
      final pStart = start + part * maxPerChecklist;
      final pEnd = (pStart + maxPerChecklist).clamp(0, end);
      if (pStart >= end) break;
      final opts = _veg
          .sublist(pStart, pEnd)
          .asMap()
          .entries
          .map(
            (e) => Choice.withText(text: e.value, id: 'v_${prefix}_${e.key}'),
          )
          .toList();
      q.add(
        _q(
          'dhq_vegetables_$prefix',
          'What vegetables, potatoes, and beans did you eat? Please check the box next to each food that you ate at least once in the past 12 months.',
          multiple: true,
          choices: opts,
        ),
      );
    }
    for (var i = start; i < end; i++) {
      final localIndex = i - start;
      final checklistId = 'dhq_vegetables_$prefix';
      final choiceId = 'v_${prefix}_$localIndex';
      final cond = _showWhenChoiceSelected(checklistId, choiceId);

      // Seasonal vegetables get IN SEASON / REST OF YEAR questions
      if (seasonalVeg.contains(i)) {
        final freqSeason = _q(
          'dhq_veg_${i}_freq_season',
          'How often did you eat ${_veg[i].toLowerCase()} WHEN IN SEASON?',
          choices: Dhq3Choices.frequencySeason,
        );
        freqSeason.conditional = cond;
        q.add(freqSeason);
        final freqRest = _q(
          'dhq_veg_${i}_freq_rest',
          'How often did you eat ${_veg[i].toLowerCase()} DURING THE REST OF THE YEAR?',
          choices: Dhq3Choices.frequencyFoodWithNever,
        );
        freqRest.conditional = cond;
        q.add(freqRest);
      } else {
        final freqQ = _q(
          'dhq_veg_${i}_freq',
          'Over the past 12 months, how often did you eat ${_veg[i].toLowerCase()}?',
        );
        freqQ.conditional = cond;
        q.add(freqQ);
      }

      // Portion sizes - specific for certain items
      List<Choice> portionChoices;
      if (i == 15) {
        // Lettuce salads
        portionChoices = Dhq3Choices.portionCups(
          'Less than 1 cup',
          '1 to 2 cups',
          'More than 2 cups',
        );
      } else if (i == 22 || i == 23 || i == 24) {
        // Fries, potato salad, mashed potatoes
        portionChoices = Dhq3Choices.portionCups(
          'Less than 1/2 cup or less than 10 fries',
          '1/2 to 1 cup or 10 to 25 fries',
          'More than 1 cup or more than 25 fries',
        );
      } else {
        portionChoices = Dhq3Choices.portionCups(
          'Less than 1/2 cup',
          '1/2 to 1 cup',
          'More than 1 cup',
        );
      }

      final portionQ = _q(
        'dhq_veg_${i}_portion',
        'Each time you ate ${_veg[i].toLowerCase()}, how much did you usually eat?',
        choices: portionChoices,
      );
      portionQ.conditional = cond;
      q.add(portionQ);

      // Follow-ups for specific vegetables
      if (i == 15) {
        // Lettuce salads - dark green lettuce follow-up
        final darkGreen = _q(
          'dhq_veg_15_dark_green',
          'How often was the lettuce in your salads dark green or leafy (such as romaine, mesclun, or spinach)?',
          choices: Dhq3Choices.almostNeverToAlways,
        );
        darkGreen.conditional = cond;
        q.add(darkGreen);
      } else if (i == 24) {
        // Baked, boiled, or mashed potatoes - many follow-ups
        final mashed = _q(
          'dhq_veg_24_mashed',
          'How often were the potatoes you ate mashed potatoes?',
          choices: Dhq3Choices.almostNeverToAlways,
        );
        mashed.conditional = cond;
        q.add(mashed);
        final sourCream = _q(
          'dhq_veg_24_sour_cream',
          'How often did you add sour cream to your baked, boiled, or mashed potatoes?',
          choices: Dhq3Choices.almostNeverToAlways,
        );
        sourCream.conditional = cond;
        q.add(sourCream);
        final margarine = _q(
          'dhq_veg_24_margarine',
          'How often did you add margarine to your baked, boiled, or mashed potatoes?',
          choices: Dhq3Choices.almostNeverToAlways,
        );
        margarine.conditional = cond;
        q.add(margarine);
        final margarinePortion = _q(
          'dhq_veg_24_margarine_portion',
          'Each time you added margarine, how much did you usually add?',
          choices: Dhq3Choices.portionTeaspoons,
        );
        margarinePortion.conditional = cond;
        q.add(margarinePortion);
        final butter = _q(
          'dhq_veg_24_butter',
          'How often did you add butter to your baked, boiled, or mashed potatoes?',
          choices: Dhq3Choices.almostNeverToAlways,
        );
        butter.conditional = cond;
        q.add(butter);
        final butterPortion = _q(
          'dhq_veg_24_butter_portion',
          'Each time you added butter, how much did you usually add?',
          choices: Dhq3Choices.portionTeaspoons,
        );
        butterPortion.conditional = cond;
        q.add(butterPortion);
      } else if (i == 25) {
        // Cooked beans - refried beans follow-up
        final refried = _q(
          'dhq_veg_25_refried',
          'How often were the beans you ate refried beans?',
          choices: Dhq3Choices.almostNeverToAlways,
        );
        refried.conditional = cond;
        q.add(refried);
      }
    }

    // Add "Additions to cooked vegetables" section at the end of the last vegetable part (p2)
    if (start == 18) {
      q.addAll(_additionsToVegetables());
    }

    return q;
  }

  /// Additions to cooked vegetables - fats during and after cooking
  static List<Question> _additionsToVegetables() {
    final q = <Question>[];

    // Fats DURING cooking
    q.add(
      _q(
        'dhq_veg_fat_during',
        'Which fats were added to your vegetables DURING cooking? Check all that apply.',
        multiple: true,
        choices: Dhq3Choices.cookingFats,
      ),
    );

    // Margarine during cooking follow-ups
    final margDuringCond = _showWhenChoiceSelected(
      'dhq_veg_fat_during',
      'margarine',
    );
    final margDuringFreq = _q(
      'dhq_veg_marg_during_freq',
      'How often was margarine (including low-fat) added to your vegetables during cooking?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    margDuringFreq.conditional = margDuringCond;
    q.add(margDuringFreq);
    final margDuringPortion = _q(
      'dhq_veg_marg_during_portion',
      'Each time margarine was added during cooking, how much was usually added?',
      choices: Dhq3Choices.portionTeaspoons,
    );
    margDuringPortion.conditional = margDuringCond;
    q.add(margDuringPortion);

    // Butter during cooking follow-ups
    final butterDuringCond = _showWhenChoiceSelected(
      'dhq_veg_fat_during',
      'butter',
    );
    final butterDuringFreq = _q(
      'dhq_veg_butter_during_freq',
      'How often was butter (including low-fat) added to your vegetables during cooking?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    butterDuringFreq.conditional = butterDuringCond;
    q.add(butterDuringFreq);
    final butterDuringPortion = _q(
      'dhq_veg_butter_during_portion',
      'Each time butter was added during cooking, how much was usually added?',
      choices: Dhq3Choices.portionTeaspoons,
    );
    butterDuringPortion.conditional = butterDuringCond;
    q.add(butterDuringPortion);

    // Olive oil during cooking follow-ups
    final oliveDuringCond = _showWhenChoiceSelected(
      'dhq_veg_fat_during',
      'olive_oil',
    );
    final oliveDuringFreq = _q(
      'dhq_veg_olive_during_freq',
      'How often was olive oil added to your vegetables during cooking?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    oliveDuringFreq.conditional = oliveDuringCond;
    q.add(oliveDuringFreq);
    final oliveDuringPortion = _q(
      'dhq_veg_olive_during_portion',
      'Each time olive oil was added during cooking, how much was usually added?',
      choices: Dhq3Choices.portionTeaspoons,
    );
    oliveDuringPortion.conditional = oliveDuringCond;
    q.add(oliveDuringPortion);

    // Other oils during cooking follow-ups
    final otherOilDuringCond = _showWhenChoiceSelected(
      'dhq_veg_fat_during',
      'other_oil',
    );
    final otherOilDuringFreq = _q(
      'dhq_veg_other_oil_during_freq',
      'How often were other kinds of oils added to your vegetables during cooking?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    otherOilDuringFreq.conditional = otherOilDuringCond;
    q.add(otherOilDuringFreq);
    final otherOilDuringPortion = _q(
      'dhq_veg_other_oil_during_portion',
      'Each time other oils were added during cooking, how much was usually added?',
      choices: Dhq3Choices.portionTeaspoons,
    );
    otherOilDuringPortion.conditional = otherOilDuringCond;
    q.add(otherOilDuringPortion);

    // Fats AFTER cooking
    q.add(
      _q(
        'dhq_veg_fat_after',
        'Which fats were added to your vegetables AFTER cooking? Check all that apply.',
        multiple: true,
        choices: Dhq3Choices.afterCookingFats,
      ),
    );

    // Margarine after cooking follow-ups
    final margAfterCond = _showWhenChoiceSelected(
      'dhq_veg_fat_after',
      'margarine',
    );
    final margAfterFreq = _q(
      'dhq_veg_marg_after_freq',
      'How often was margarine (including low-fat) added to your vegetables after cooking?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    margAfterFreq.conditional = margAfterCond;
    q.add(margAfterFreq);
    final margAfterPortion = _q(
      'dhq_veg_marg_after_portion',
      'Each time margarine was added after cooking, how much was usually added?',
      choices: Dhq3Choices.portionTeaspoons,
    );
    margAfterPortion.conditional = margAfterCond;
    q.add(margAfterPortion);

    // Butter after cooking follow-ups
    final butterAfterCond = _showWhenChoiceSelected(
      'dhq_veg_fat_after',
      'butter',
    );
    final butterAfterFreq = _q(
      'dhq_veg_butter_after_freq',
      'How often was butter (including low-fat) added to your vegetables after cooking?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    butterAfterFreq.conditional = butterAfterCond;
    q.add(butterAfterFreq);
    final butterAfterPortion = _q(
      'dhq_veg_butter_after_portion',
      'Each time butter was added after cooking, how much was usually added?',
      choices: Dhq3Choices.portionTeaspoons,
    );
    butterAfterPortion.conditional = butterAfterCond;
    q.add(butterAfterPortion);

    // Salad dressing after cooking follow-ups
    final dressingAfterCond = _showWhenChoiceSelected(
      'dhq_veg_fat_after',
      'dressing',
    );
    final dressingAfterFreq = _q(
      'dhq_veg_dressing_after_freq',
      'How often was salad dressing added to your vegetables after cooking?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    dressingAfterFreq.conditional = dressingAfterCond;
    q.add(dressingAfterFreq);
    final dressingAfterPortion = _q(
      'dhq_veg_dressing_after_portion',
      'Each time salad dressing was added after cooking, how much was usually added?',
      choices: [
        Choice.withText(text: 'Less than 1 tablespoon', id: 'less'),
        Choice.withText(text: '1 to 2 tablespoons', id: 'medium'),
        Choice.withText(text: 'More than 2 tablespoons', id: 'more'),
      ],
    );
    dressingAfterPortion.conditional = dressingAfterCond;
    q.add(dressingAfterPortion);

    return q;
  }

  static List<Question> _soupsChiliTacos() {
    final q = <Question>[];

    // Soups - seasonal frequency
    q.add(
      _q('dhq_soups_freq_winter', 'How often did you eat soups IN THE WINTER?'),
    );
    q.add(
      _q(
        'dhq_soups_freq_rest',
        'How often did you eat soups DURING THE REST OF THE YEAR?',
      ),
    );

    final soupsCond = _showWhenNotNever('dhq_soups_freq_winter');
    final soupsPortion = _q(
      'dhq_soups_portion',
      'Each time you ate soups, how much did you usually eat?',
      choices: Dhq3Choices.portionCups(
        'Less than 1 cup (8 ounces)',
        '1 to 2 cups (8 to 16 ounces)',
        'More than 2 cups (16 ounces)',
      ),
    );
    soupsPortion.conditional = soupsCond;
    q.add(soupsPortion);

    // Soup types
    final beanSoup = _q(
      'dhq_soups_bean',
      'How often were the soups you ate bean soups?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    beanSoup.conditional = soupsCond;
    q.add(beanSoup);

    final tomatoSoup = _q(
      'dhq_soups_tomato',
      'How often were the soups you ate tomato or vegetable soups?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    tomatoSoup.conditional = soupsCond;
    q.add(tomatoSoup);

    final brothSoup = _q(
      'dhq_soups_broth',
      'How often were the soups you ate broth soups (with or without noodles, rice, or vegetables)?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    brothSoup.conditional = soupsCond;
    q.add(brothSoup);

    final creamSoup = _q(
      'dhq_soups_cream',
      'How often were the soups you ate cream soups (including chowder)?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    creamSoup.conditional = soupsCond;
    q.add(creamSoup);

    // Chili
    q.add(
      _q(
        'dhq_chili_freq',
        'Over the past 12 months, how often did you eat chili?',
      ),
    );
    final chiliPortion = _q(
      'dhq_chili_portion',
      'Each time you ate chili, how much did you usually eat?',
      choices: Dhq3Choices.portionCups(
        'Less than 1/2 cup',
        '1/2 to 1 cup',
        'More than 1 cup',
      ),
    );
    chiliPortion.conditional = _showWhenNotNever('dhq_chili_freq');
    q.add(chiliPortion);

    // Tacos/Burritos
    q.add(
      _q(
        'dhq_tacos_freq',
        'Over the past 12 months, how often did you eat tacos, burritos, enchiladas, tamales, or stuffed peppers (chile relleno)?',
      ),
    );
    final tacosCond = _showWhenNotNever('dhq_tacos_freq');
    final tacosPortion = _q(
      'dhq_tacos_portion',
      'Each time you ate tacos, burritos, etc., how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 1 taco or burrito', id: 'less'),
        Choice.withText(text: '1 to 2 tacos or burritos', id: 'medium'),
        Choice.withText(text: 'More than 2 tacos or burritos', id: 'more'),
      ],
    );
    tacosPortion.conditional = tacosCond;
    q.add(tacosPortion);

    final tacosBurritos = _q(
      'dhq_tacos_type',
      'How often were these foods burritos, soft tacos, or fajitas (made with flour tortillas) rather than hard-shell tacos?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    tacosBurritos.conditional = tacosCond;
    q.add(tacosBurritos);

    // Tortillas
    q.add(
      _q(
        'dhq_tortillas_freq',
        'Over the past 12 months, how often did you eat corn or flour tortillas (NOT in tacos, burritos, or other Mexican foods)?',
      ),
    );
    final tortillasCond = _showWhenNotNever('dhq_tortillas_freq');
    final tortillasPortion = _q(
      'dhq_tortillas_portion',
      'Each time you ate tortillas, how many did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 1 tortilla', id: 'less'),
        Choice.withText(text: '1 to 2 tortillas', id: 'medium'),
        Choice.withText(text: 'More than 2 tortillas', id: 'more'),
      ],
    );
    tortillasPortion.conditional = tortillasCond;
    q.add(tortillasPortion);

    final tortillasType = _q(
      'dhq_tortillas_type',
      'How often were the tortillas you ate flour tortillas rather than corn?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    tortillasType.conditional = tortillasCond;
    q.add(tortillasType);

    return q;
  }

  static List<Question> _soupsAndRicePastaPizza() {
    final q = <Question>[];
    q.addAll(_soupsChiliTacos());
    q.addAll(_ricePastaPizza());
    return q;
  }

  static List<Question> _ricePastaPizza() {
    final q = <Question>[];

    // Rice or other grains
    q.add(
      _q(
        'dhq_rice_freq',
        'Over the past 12 months, how often did you eat rice or other cooked grains (such as bulgur, cracked wheat, or millet)?',
      ),
    );
    final riceCond = _showWhenNotNever('dhq_rice_freq');
    final ricePortion = _q(
      'dhq_rice_portion',
      'Each time you ate rice or other cooked grains, how much did you usually eat?',
      choices: Dhq3Choices.portionCups(
        'Less than 1/2 cup',
        '1/2 to 1 1/2 cups',
        'More than 1 1/2 cups',
      ),
    );
    ricePortion.conditional = riceCond;
    q.add(ricePortion);
    final riceWhole = _q(
      'dhq_rice_whole_grain',
      'How often was the rice you ate whole grain (such as brown rice)?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    riceWhole.conditional = riceCond;
    q.add(riceWhole);

    // Sushi
    q.add(
      _q(
        'dhq_sushi_freq',
        'Over the past 12 months, how often did you eat sushi?',
      ),
    );
    final sushiPortion = _q(
      'dhq_sushi_portion',
      'Each time you ate sushi, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 5 pieces', id: 'less'),
        Choice.withText(text: '5 to 10 pieces', id: 'medium'),
        Choice.withText(text: 'More than 10 pieces', id: 'more'),
      ],
    );
    sushiPortion.conditional = _showWhenNotNever('dhq_sushi_freq');
    q.add(sushiPortion);

    // Lasagna/ravioli/tortellini
    q.add(
      _q(
        'dhq_lasagna_freq',
        'Over the past 12 months, how often did you eat lasagna, stuffed shells, stuffed manicotti, ravioli, or tortellini?',
      ),
    );
    final lasagnaPortion = _q(
      'dhq_lasagna_portion',
      'Each time you ate these foods, how much did you usually eat?',
      choices: Dhq3Choices.portionCups(
        'Less than 1 cup',
        '1 to 2 cups',
        'More than 2 cups',
      ),
    );
    lasagnaPortion.conditional = _showWhenNotNever('dhq_lasagna_freq');
    q.add(lasagnaPortion);

    // Macaroni and cheese
    q.add(
      _q(
        'dhq_mac_cheese_freq',
        'Over the past 12 months, how often did you eat macaroni and cheese?',
      ),
    );
    final macCheesePortion = _q(
      'dhq_mac_cheese_portion',
      'Each time you ate macaroni and cheese, how much did you usually eat?',
      choices: Dhq3Choices.portionCups(
        'Less than 1/2 cup',
        '1/2 to 1 cup',
        'More than 1 cup',
      ),
    );
    macCheesePortion.conditional = _showWhenNotNever('dhq_mac_cheese_freq');
    q.add(macCheesePortion);

    // Pasta salad
    q.add(
      _q(
        'dhq_pasta_salad_freq',
        'Over the past 12 months, how often did you eat pasta salad or macaroni salad?',
      ),
    );
    final pastaSaladPortion = _q(
      'dhq_pasta_salad_portion',
      'Each time you ate pasta salad, how much did you usually eat?',
      choices: Dhq3Choices.portionCups(
        'Less than 1/2 cup',
        '1/2 to 1 cup',
        'More than 1 cup',
      ),
    );
    pastaSaladPortion.conditional = _showWhenNotNever('dhq_pasta_salad_freq');
    q.add(pastaSaladPortion);

    // Pasta/spaghetti/noodles
    q.add(
      _q(
        'dhq_pasta_freq',
        'Over the past 12 months, how often did you eat pasta, spaghetti, or other noodles (NOT including macaroni and cheese, lasagna, or Asian noodle dishes)?',
      ),
    );
    final pastaCond = _showWhenNotNever('dhq_pasta_freq');
    final pastaPortion = _q(
      'dhq_pasta_portion',
      'Each time you ate pasta, spaghetti, or noodles, how much did you usually eat?',
      choices: Dhq3Choices.portionCups(
        'Less than 1 cup',
        '1 to 2 cups',
        'More than 2 cups',
      ),
    );
    pastaPortion.conditional = pastaCond;
    q.add(pastaPortion);

    final pastaWhole = _q(
      'dhq_pasta_whole_grain',
      'How often was the pasta you ate whole grain or whole wheat pasta?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    pastaWhole.conditional = pastaCond;
    q.add(pastaWhole);

    final pastaSauceMeat = _q(
      'dhq_pasta_sauce_meat',
      'How often was the pasta you ate with a tomato sauce containing meat?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    pastaSauceMeat.conditional = pastaCond;
    q.add(pastaSauceMeat);

    final pastaSauceNoMeat = _q(
      'dhq_pasta_sauce_no_meat',
      'How often was the pasta you ate with a tomato sauce without meat?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    pastaSauceNoMeat.conditional = pastaCond;
    q.add(pastaSauceNoMeat);

    final pastaSauceCream = _q(
      'dhq_pasta_sauce_cream',
      'How often was the pasta you ate with a cream sauce (such as Alfredo)?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    pastaSauceCream.conditional = pastaCond;
    q.add(pastaSauceCream);

    final pastaButter = _q(
      'dhq_pasta_butter',
      'How often did you add butter or margarine to your pasta?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    pastaButter.conditional = pastaCond;
    q.add(pastaButter);

    final pastaButterPortion = _q(
      'dhq_pasta_butter_portion',
      'Each time you added butter or margarine to pasta, how much did you usually add?',
      choices: Dhq3Choices.portionTeaspoons,
    );
    pastaButterPortion.conditional = pastaCond;
    q.add(pastaButterPortion);

    // Pizza
    q.add(
      _q(
        'dhq_pizza_freq',
        'Over the past 12 months, how often did you eat pizza (including frozen pizza)?',
      ),
    );
    final pizzaCond = _showWhenNotNever('dhq_pizza_freq');
    final pizzaPortion = _q(
      'dhq_pizza_portion',
      'Each time you ate pizza, how much did you usually eat?',
      choices: [
        Choice.withText(
          text: 'Less than 2 slices or less than 1 mini pizza',
          id: 'less',
        ),
        Choice.withText(text: '2 to 3 slices or 1 mini pizza', id: 'medium'),
        Choice.withText(
          text: 'More than 3 slices or more than 1 mini pizza',
          id: 'more',
        ),
      ],
    );
    pizzaPortion.conditional = pizzaCond;
    q.add(pizzaPortion);

    final pizzaMeat = _q(
      'dhq_pizza_meat',
      'How often did the pizza you ate have meat toppings (such as pepperoni, sausage, or hamburger)?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    pizzaMeat.conditional = pizzaCond;
    q.add(pizzaMeat);

    return q;
  }

  static List<Question> _cerealPancakesBreads() {
    final q = <Question>[];

    // Oatmeal/grits/cooked cereal - seasonal
    q.add(
      _q(
        'dhq_oatmeal_freq_winter',
        'How often did you eat oatmeal, grits, or other cooked cereal IN THE WINTER?',
      ),
    );
    q.add(
      _q(
        'dhq_oatmeal_freq_rest',
        'How often did you eat oatmeal, grits, or other cooked cereal DURING THE REST OF THE YEAR?',
      ),
    );
    final oatmealCond = _showWhenNotNever('dhq_oatmeal_freq_winter');
    final oatmealPortion = _q(
      'dhq_oatmeal_portion',
      'Each time you ate oatmeal, grits, or other cooked cereal, how much did you usually eat?',
      choices: Dhq3Choices.portionCups(
        'Less than 3/4 cup',
        '3/4 to 1 1/2 cups',
        'More than 1 1/2 cups',
      ),
    );
    oatmealPortion.conditional = oatmealCond;
    q.add(oatmealPortion);

    // Cold cereal - with extensive follow-ups
    q.add(
      _q(
        'dhq_cold_cereal_freq',
        'Over the past 12 months, how often did you eat cold cereal?',
      ),
    );
    final coldCerealCond = _showWhenNotNever('dhq_cold_cereal_freq');
    final coldCerealPortion = _q(
      'dhq_cold_cereal_portion',
      'Each time you ate cold cereal, how much did you usually eat?',
      choices: Dhq3Choices.portionCups(
        'Less than 1 cup',
        '1 to 2 cups',
        'More than 2 cups',
      ),
    );
    coldCerealPortion.conditional = coldCerealCond;
    q.add(coldCerealPortion);

    final cerealWholeGrain = _q(
      'dhq_cold_cereal_whole_grain',
      'How often was the cold cereal you ate a whole grain cereal (such as Cheerios, Raisin Bran, Shredded Wheat, Total, or others)?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    cerealWholeGrain.conditional = coldCerealCond;
    q.add(cerealWholeGrain);

    final cerealFortified = _q(
      'dhq_cold_cereal_fortified',
      'How often was the cold cereal you ate a fortified cereal (such as Total, Product 19, or Special K)?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    cerealFortified.conditional = coldCerealCond;
    q.add(cerealFortified);

    final cerealGranola = _q(
      'dhq_cold_cereal_granola',
      'How often was the cold cereal you ate granola or muesli?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    cerealGranola.conditional = coldCerealCond;
    q.add(cerealGranola);

    final cerealMilkType = _q(
      'dhq_cold_cereal_milk_type',
      'What kind of milk did you usually eat on your cold cereal?',
      choices: Dhq3Choices.milkTypeCereal,
    );
    cerealMilkType.conditional = coldCerealCond;
    q.add(cerealMilkType);

    final cerealMilkAmount = _q(
      'dhq_cold_cereal_milk_amount',
      'How much milk did you usually add to your cold cereal?',
      choices: [
        Choice.withText(text: 'Less than 1/4 cup', id: 'less'),
        Choice.withText(text: '1/4 to 1/2 cup', id: 'medium'),
        Choice.withText(text: 'More than 1/2 cup', id: 'more'),
      ],
    );
    cerealMilkAmount.conditional = coldCerealCond;
    q.add(cerealMilkAmount);

    // Pancakes/waffles/French toast - extensive follow-ups
    q.add(
      _q(
        'dhq_pancakes_freq',
        'Over the past 12 months, how often did you eat pancakes, waffles, or French toast?',
      ),
    );
    final pancakesCond = _showWhenNotNever('dhq_pancakes_freq');
    final pancakesPortion = _q(
      'dhq_pancakes_portion',
      'Each time you ate pancakes, waffles, or French toast, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 2 pieces', id: 'less'),
        Choice.withText(text: '2 to 3 pieces', id: 'medium'),
        Choice.withText(text: 'More than 3 pieces', id: 'more'),
      ],
    );
    pancakesPortion.conditional = pancakesCond;
    q.add(pancakesPortion);

    final pancakesMargarine = _q(
      'dhq_pancakes_margarine',
      'How often did you add margarine to your pancakes, waffles, or French toast?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    pancakesMargarine.conditional = pancakesCond;
    q.add(pancakesMargarine);

    final pancakesMargarinePortion = _q(
      'dhq_pancakes_margarine_portion',
      'Each time you added margarine, how much did you usually add?',
      choices: Dhq3Choices.portionTeaspoons,
    );
    pancakesMargarinePortion.conditional = pancakesCond;
    q.add(pancakesMargarinePortion);

    final pancakesButter = _q(
      'dhq_pancakes_butter',
      'How often did you add butter to your pancakes, waffles, or French toast?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    pancakesButter.conditional = pancakesCond;
    q.add(pancakesButter);

    final pancakesButterPortion = _q(
      'dhq_pancakes_butter_portion',
      'Each time you added butter, how much did you usually add?',
      choices: Dhq3Choices.portionTeaspoons,
    );
    pancakesButterPortion.conditional = pancakesCond;
    q.add(pancakesButterPortion);

    final pancakesSyrup = _q(
      'dhq_pancakes_syrup',
      'How often did you add syrup to your pancakes, waffles, or French toast?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    pancakesSyrup.conditional = pancakesCond;
    q.add(pancakesSyrup);

    final pancakesSyrupPortion = _q(
      'dhq_pancakes_syrup_portion',
      'Each time you added syrup, how much did you usually add?',
      choices: [
        Choice.withText(text: 'Less than 2 tablespoons', id: 'less'),
        Choice.withText(text: '2 to 4 tablespoons', id: 'medium'),
        Choice.withText(text: 'More than 4 tablespoons', id: 'more'),
      ],
    );
    pancakesSyrupPortion.conditional = pancakesCond;
    q.add(pancakesSyrupPortion);

    final pancakesSyrupDiet = _q(
      'dhq_pancakes_syrup_diet',
      'How often was the syrup you used diet, lite, or sugar-free?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    pancakesSyrupDiet.conditional = pancakesCond;
    q.add(pancakesSyrupDiet);

    // Bagels or English muffins - with follow-ups
    q.add(
      _q(
        'dhq_bagels_freq',
        'Over the past 12 months, how often did you eat bagels or English muffins?',
      ),
    );
    final bagelsCond = _showWhenNotNever('dhq_bagels_freq');
    final bagelsPortion = _q(
      'dhq_bagels_portion',
      'Each time you ate bagels or English muffins, how much did you usually eat?',
      choices: [
        Choice.withText(
          text: 'Less than 1 bagel or English muffin',
          id: 'less',
        ),
        Choice.withText(text: '1 bagel or English muffin', id: 'medium'),
        Choice.withText(
          text: 'More than 1 bagel or English muffin',
          id: 'more',
        ),
      ],
    );
    bagelsPortion.conditional = bagelsCond;
    q.add(bagelsPortion);

    final bagelsWholeGrain = _q(
      'dhq_bagels_whole_grain',
      'How often were the bagels or English muffins you ate whole grain or whole wheat?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    bagelsWholeGrain.conditional = bagelsCond;
    q.add(bagelsWholeGrain);

    final bagelsCreamCheese = _q(
      'dhq_bagels_cream_cheese',
      'How often did you add cream cheese to your bagels or English muffins?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    bagelsCreamCheese.conditional = bagelsCond;
    q.add(bagelsCreamCheese);

    final bagelsCreamCheesePortion = _q(
      'dhq_bagels_cream_cheese_portion',
      'Each time you added cream cheese, how much did you usually add?',
      choices: [
        Choice.withText(text: 'Less than 1 tablespoon', id: 'less'),
        Choice.withText(text: '1 to 2 tablespoons', id: 'medium'),
        Choice.withText(text: 'More than 2 tablespoons', id: 'more'),
      ],
    );
    bagelsCreamCheesePortion.conditional = bagelsCond;
    q.add(bagelsCreamCheesePortion);

    final bagelsCreamCheeseLowfat = _q(
      'dhq_bagels_cream_cheese_lowfat',
      'How often was the cream cheese you used low-fat or fat-free?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    bagelsCreamCheeseLowfat.conditional = bagelsCond;
    q.add(bagelsCreamCheeseLowfat);

    // Bread as part of sandwiches
    q.add(
      _q(
        'dhq_bread_sandwich_freq',
        'Over the past 12 months, how often did you eat bread as part of sandwiches (including burger and hot dog buns)?',
      ),
    );
    final breadSandCond = _showWhenNotNever('dhq_bread_sandwich_freq');
    final breadSandPortion = _q(
      'dhq_bread_sandwich_portion',
      'Each time you ate bread as part of sandwiches, how much did you usually eat?',
      choices: [
        Choice.withText(
          text: 'Less than 2 slices or less than 1 roll',
          id: 'less',
        ),
        Choice.withText(text: '2 slices or 1 roll', id: 'medium'),
        Choice.withText(
          text: 'More than 2 slices or more than 1 roll',
          id: 'more',
        ),
      ],
    );
    breadSandPortion.conditional = breadSandCond;
    q.add(breadSandPortion);

    final breadSandWholeGrain = _q(
      'dhq_bread_sandwich_whole_grain',
      'How often was the bread you ate whole grain or whole wheat?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    breadSandWholeGrain.conditional = breadSandCond;
    q.add(breadSandWholeGrain);

    final breadSandMayo = _q(
      'dhq_bread_sandwich_mayo',
      'How often did you add mayonnaise or mayonnaise-type dressing to your sandwiches?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    breadSandMayo.conditional = breadSandCond;
    q.add(breadSandMayo);

    final breadSandMayoPortion = _q(
      'dhq_bread_sandwich_mayo_portion',
      'Each time you added mayonnaise, how much did you usually add?',
      choices: [
        Choice.withText(text: 'Less than 1 tablespoon', id: 'less'),
        Choice.withText(text: '1 to 2 tablespoons', id: 'medium'),
        Choice.withText(text: 'More than 2 tablespoons', id: 'more'),
      ],
    );
    breadSandMayoPortion.conditional = breadSandCond;
    q.add(breadSandMayoPortion);

    // Bread or rolls NOT in sandwiches
    q.add(
      _q(
        'dhq_bread_roll_freq',
        'Over the past 12 months, how often did you eat bread or dinner rolls (NOT in sandwiches)?',
      ),
    );
    final breadRollCond = _showWhenNotNever('dhq_bread_roll_freq');
    final breadRollPortion = _q(
      'dhq_bread_roll_portion',
      'Each time you ate bread or dinner rolls, how much did you usually eat?',
      choices: [
        Choice.withText(
          text: 'Less than 1 slice or less than 1 roll',
          id: 'less',
        ),
        Choice.withText(text: '1 to 2 slices or 1 to 2 rolls', id: 'medium'),
        Choice.withText(
          text: 'More than 2 slices or more than 2 rolls',
          id: 'more',
        ),
      ],
    );
    breadRollPortion.conditional = breadRollCond;
    q.add(breadRollPortion);

    final breadRollMargarine = _q(
      'dhq_bread_roll_margarine',
      'How often did you add margarine to your bread or rolls?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    breadRollMargarine.conditional = breadRollCond;
    q.add(breadRollMargarine);

    final breadRollMargarinePortion = _q(
      'dhq_bread_roll_margarine_portion',
      'Each time you added margarine, how much did you usually add?',
      choices: Dhq3Choices.portionTeaspoons,
    );
    breadRollMargarinePortion.conditional = breadRollCond;
    q.add(breadRollMargarinePortion);

    final breadRollButter = _q(
      'dhq_bread_roll_butter',
      'How often did you add butter to your bread or rolls?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    breadRollButter.conditional = breadRollCond;
    q.add(breadRollButter);

    final breadRollButterPortion = _q(
      'dhq_bread_roll_butter_portion',
      'Each time you added butter, how much did you usually add?',
      choices: Dhq3Choices.portionTeaspoons,
    );
    breadRollButterPortion.conditional = breadRollCond;
    q.add(breadRollButterPortion);

    // Cornbread or corn muffins
    q.add(
      _q(
        'dhq_cornbread_freq',
        'Over the past 12 months, how often did you eat cornbread or corn muffins?',
      ),
    );
    final cornbreadPortion = _q(
      'dhq_cornbread_portion',
      'Each time you ate cornbread or corn muffins, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 1 piece', id: 'less'),
        Choice.withText(text: '1 to 2 pieces', id: 'medium'),
        Choice.withText(text: 'More than 2 pieces', id: 'more'),
      ],
    );
    cornbreadPortion.conditional = _showWhenNotNever('dhq_cornbread_freq');
    q.add(cornbreadPortion);

    // Biscuits
    q.add(
      _q(
        'dhq_biscuits_freq',
        'Over the past 12 months, how often did you eat biscuits?',
      ),
    );
    final biscuitsPortion = _q(
      'dhq_biscuits_portion',
      'Each time you ate biscuits, how many did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 1 biscuit', id: 'less'),
        Choice.withText(text: '1 to 2 biscuits', id: 'medium'),
        Choice.withText(text: 'More than 2 biscuits', id: 'more'),
      ],
    );
    biscuitsPortion.conditional = _showWhenNotNever('dhq_biscuits_freq');
    q.add(biscuitsPortion);

    // Jam, jelly, or honey on bread or rolls
    q.add(
      _q(
        'dhq_jam_freq',
        'Over the past 12 months, how often did you eat jam, jelly, preserves, or honey on bread or rolls?',
      ),
    );
    final jamPortion = _q(
      'dhq_jam_portion',
      'Each time you ate jam, jelly, preserves, or honey, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 1 tablespoon', id: 'less'),
        Choice.withText(text: '1 to 2 tablespoons', id: 'medium'),
        Choice.withText(text: 'More than 2 tablespoons', id: 'more'),
      ],
    );
    jamPortion.conditional = _showWhenNotNever('dhq_jam_freq');
    q.add(jamPortion);

    // Peanut butter or other nut butters
    q.add(
      _q(
        'dhq_peanut_butter_freq',
        'Over the past 12 months, how often did you eat peanut butter or other nut butters?',
      ),
    );
    final pbPortion = _q(
      'dhq_peanut_butter_portion',
      'Each time you ate peanut butter or other nut butters, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 1 tablespoon', id: 'less'),
        Choice.withText(text: '1 to 2 tablespoons', id: 'medium'),
        Choice.withText(text: 'More than 2 tablespoons', id: 'more'),
      ],
    );
    pbPortion.conditional = _showWhenNotNever('dhq_peanut_butter_freq');
    q.add(pbPortion);

    // Hummus
    q.add(
      _q(
        'dhq_hummus_freq',
        'Over the past 12 months, how often did you eat hummus?',
      ),
    );
    final hummusPortion = _q(
      'dhq_hummus_portion',
      'Each time you ate hummus, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 2 tablespoons', id: 'less'),
        Choice.withText(text: '2 to 5 tablespoons', id: 'medium'),
        Choice.withText(text: 'More than 5 tablespoons', id: 'more'),
      ],
    );
    hummusPortion.conditional = _showWhenNotNever('dhq_hummus_freq');
    q.add(hummusPortion);

    return q;
  }

  static List<Question> _coldCuts() {
    final q = <Question>[];

    // Roast beef or steak in sandwiches
    q.add(
      _q(
        'dhq_roast_beef_sandwich_freq',
        'Over the past 12 months, how often did you eat roast beef or steak in sandwiches?',
      ),
    );
    final roastBeefPortion = _q(
      'dhq_roast_beef_sandwich_portion',
      'Each time you ate roast beef or steak in sandwiches, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 2 ounces', id: 'less'),
        Choice.withText(text: '2 to 4 ounces', id: 'medium'),
        Choice.withText(text: 'More than 4 ounces', id: 'more'),
      ],
    );
    roastBeefPortion.conditional = _showWhenNotNever(
      'dhq_roast_beef_sandwich_freq',
    );
    q.add(roastBeefPortion);

    // Luncheon or deli ham
    q.add(
      _q(
        'dhq_deli_ham_freq',
        'Over the past 12 months, how often did you eat luncheon or deli-style ham?',
      ),
    );
    final deliHamPortion = _q(
      'dhq_deli_ham_portion',
      'Each time you ate luncheon or deli-style ham, how much did you usually eat?',
      choices: [
        Choice.withText(
          text: 'Less than 1 ounce or less than 2 slices',
          id: 'less',
        ),
        Choice.withText(text: '1 to 3 ounces or 2 to 6 slices', id: 'medium'),
        Choice.withText(
          text: 'More than 3 ounces or more than 6 slices',
          id: 'more',
        ),
      ],
    );
    deliHamPortion.conditional = _showWhenNotNever('dhq_deli_ham_freq');
    q.add(deliHamPortion);

    // Turkey or chicken cold cuts
    q.add(
      _q(
        'dhq_turkey_coldcuts_freq',
        'Over the past 12 months, how often did you eat turkey or chicken cold cuts?',
      ),
    );
    final turkeyColdcutsPortion = _q(
      'dhq_turkey_coldcuts_portion',
      'Each time you ate turkey or chicken cold cuts, how much did you usually eat?',
      choices: [
        Choice.withText(
          text: 'Less than 1 ounce or less than 2 slices',
          id: 'less',
        ),
        Choice.withText(text: '1 to 3 ounces or 2 to 6 slices', id: 'medium'),
        Choice.withText(
          text: 'More than 3 ounces or more than 6 slices',
          id: 'more',
        ),
      ],
    );
    turkeyColdcutsPortion.conditional = _showWhenNotNever(
      'dhq_turkey_coldcuts_freq',
    );
    q.add(turkeyColdcutsPortion);

    // Bologna, salami, or other processed meat cold cuts
    q.add(
      _q(
        'dhq_bologna_freq',
        'Over the past 12 months, how often did you eat bologna, salami, or other processed meat cold cuts?',
      ),
    );
    final bolognaPortion = _q(
      'dhq_bologna_portion',
      'Each time you ate bologna, salami, or other processed meat cold cuts, how much did you usually eat?',
      choices: [
        Choice.withText(
          text: 'Less than 1 ounce or less than 2 slices',
          id: 'less',
        ),
        Choice.withText(text: '1 to 3 ounces or 2 to 6 slices', id: 'medium'),
        Choice.withText(
          text: 'More than 3 ounces or more than 6 slices',
          id: 'more',
        ),
      ],
    );
    bolognaPortion.conditional = _showWhenNotNever('dhq_bologna_freq');
    q.add(bolognaPortion);

    // Hot dogs or frankfurters - with follow-ups
    q.add(
      _q(
        'dhq_hotdogs_freq',
        'Over the past 12 months, how often did you eat hot dogs or frankfurters?',
      ),
    );
    final hotdogsCond = _showWhenNotNever('dhq_hotdogs_freq');
    final hotdogsPortion = _q(
      'dhq_hotdogs_portion',
      'Each time you ate hot dogs, how many did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 1 hot dog', id: 'less'),
        Choice.withText(text: '1 to 2 hot dogs', id: 'medium'),
        Choice.withText(text: 'More than 2 hot dogs', id: 'more'),
      ],
    );
    hotdogsPortion.conditional = hotdogsCond;
    q.add(hotdogsPortion);

    final hotdogsChicken = _q(
      'dhq_hotdogs_chicken',
      'How often were the hot dogs you ate made of chicken or turkey?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    hotdogsChicken.conditional = hotdogsCond;
    q.add(hotdogsChicken);

    final hotdogsBun = _q(
      'dhq_hotdogs_bun',
      'How often did you eat the hot dogs with a bun?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    hotdogsBun.conditional = hotdogsCond;
    q.add(hotdogsBun);

    return q;
  }

  static List<Question> _coldCutsAndEggsAndSnacks() {
    final q = <Question>[];
    q.addAll(_coldCuts());
    q.addAll(_eggsMeatAlternatives());
    q.addAll(_chipsSnacks());
    return q;
  }

  /// Meat, poultry, fish section with detailed follow-ups
  static List<Question> _meatPoultryFishPart(int start, int end) {
    final q = <Question>[];

    // Items to process in this range
    if (start == 0) {
      // Part 1: Ground chicken/turkey, chicken, turkey, beef burgers, ground beef
      q.addAll(_groundChickenTurkey());
      q.addAll(_bakedBroiledFriedChicken());
      q.addAll(_chickenMixedDishes());
      q.addAll(_turkey());
      q.addAll(_beefBurgersFastFood());
      q.addAll(_beefBurgersNotFastFood());
      q.addAll(_groundBeefMixtures());
      q.addAll(_beefMixtures());
      q.addAll(_roastBeefPotRoast());
      q.addAll(_beefSteak());
      q.addAll(_spareribs());
      q.addAll(_bakedHam());
    } else {
      // Part 2: Pork, gravy, liver, bacon, sausage, fish
      q.addAll(_porkChops());
      q.addAll(_gravy());
      q.addAll(_liver());
      q.addAll(_bacon());
      q.addAll(_sausage());
      q.addAll(_cannedTuna());
      q.addAll(_freshTunaOthers());
      q.addAll(_salmon());
      q.addAll(_friedShellfish());
      q.addAll(_shellfishNotFried());
      q.addAll(_fishSticksOrFried());
      q.addAll(_otherFishNotFried());
    }
    return q;
  }

  static List<Question> _groundChickenTurkey() {
    final q = <Question>[];
    q.add(
      _q(
        'dhq_ground_poultry_freq',
        'Over the past 12 months, how often did you eat ground chicken or ground turkey?',
      ),
    );
    final portion = _q(
      'dhq_ground_poultry_portion',
      'Each time you ate ground chicken or ground turkey, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 2 ounces', id: 'less'),
        Choice.withText(text: '2 to 4 ounces', id: 'medium'),
        Choice.withText(text: 'More than 4 ounces', id: 'more'),
      ],
    );
    portion.conditional = _showWhenNotNever('dhq_ground_poultry_freq');
    q.add(portion);
    return q;
  }

  static List<Question> _bakedBroiledFriedChicken() {
    final q = <Question>[];
    q.add(
      _q(
        'dhq_chicken_freq',
        'Over the past 12 months, how often did you eat chicken (NOT in sandwiches, salads, or mixed dishes like stews)?',
      ),
    );
    final cond = _showWhenNotNever('dhq_chicken_freq');
    final portion = _q(
      'dhq_chicken_portion',
      'Each time you ate chicken, how much did you usually eat?',
      choices: [
        Choice.withText(
          text: 'Less than 2 ounces or 1 small piece',
          id: 'less',
        ),
        Choice.withText(
          text: '2 to 5 ounces or 1 small to medium piece',
          id: 'medium',
        ),
        Choice.withText(
          text: 'More than 5 ounces or more than 1 medium piece',
          id: 'more',
        ),
      ],
    );
    portion.conditional = cond;
    q.add(portion);

    final fried = _q(
      'dhq_chicken_fried',
      'How often was the chicken you ate fried (including deep fried and pan-fried)?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    fried.conditional = cond;
    q.add(fried);

    final grilled = _q(
      'dhq_chicken_grilled',
      'How often was the chicken you ate grilled, baked, or broiled?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    grilled.conditional = cond;
    q.add(grilled);

    final whiteMeat = _q(
      'dhq_chicken_white_meat',
      'How often was the chicken you ate white meat (breast)?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    whiteMeat.conditional = cond;
    q.add(whiteMeat);

    final skin = _q(
      'dhq_chicken_skin',
      'How often did you eat the skin on your chicken?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    skin.conditional = cond;
    q.add(skin);

    final doneness = _q(
      'dhq_chicken_doneness',
      'When you ate chicken, how was it usually done?',
      choices: Dhq3Choices.chickenDoneness,
    );
    doneness.conditional = cond;
    q.add(doneness);

    return q;
  }

  static List<Question> _chickenMixedDishes() {
    final q = <Question>[];
    q.add(
      _q(
        'dhq_chicken_mixed_freq',
        'Over the past 12 months, how often did you eat chicken in stews, pot pies, casseroles, or other mixed dishes?',
      ),
    );
    final portion = _q(
      'dhq_chicken_mixed_portion',
      'Each time you ate chicken in mixed dishes, how much did you usually eat?',
      choices: Dhq3Choices.portionCups(
        'Less than 1/2 cup',
        '1/2 to 1 cup',
        'More than 1 cup',
      ),
    );
    portion.conditional = _showWhenNotNever('dhq_chicken_mixed_freq');
    q.add(portion);
    return q;
  }

  static List<Question> _turkey() {
    final q = <Question>[];
    q.add(
      _q(
        'dhq_turkey_freq',
        'Over the past 12 months, how often did you eat turkey (NOT in sandwiches)?',
      ),
    );
    final portion = _q(
      'dhq_turkey_portion',
      'Each time you ate turkey, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 2 slices or 2 ounces', id: 'less'),
        Choice.withText(text: '2 to 4 slices or 2 to 4 ounces', id: 'medium'),
        Choice.withText(
          text: 'More than 4 slices or more than 4 ounces',
          id: 'more',
        ),
      ],
    );
    portion.conditional = _showWhenNotNever('dhq_turkey_freq');
    q.add(portion);
    return q;
  }

  static List<Question> _beefBurgersFastFood() {
    final q = <Question>[];
    q.add(
      _q(
        'dhq_burger_fast_freq',
        'Over the past 12 months, how often did you eat beef hamburgers or cheeseburgers FROM A FAST FOOD or other restaurant?',
      ),
    );
    final cond = _showWhenNotNever('dhq_burger_fast_freq');
    final portion = _q(
      'dhq_burger_fast_portion',
      'Each time you ate beef hamburgers or cheeseburgers from a fast food or other restaurant, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than a 1/4 pound burger', id: 'less'),
        Choice.withText(text: '1/4 to 1/2 pound burger', id: 'medium'),
        Choice.withText(text: 'More than a 1/2 pound burger', id: 'more'),
      ],
    );
    portion.conditional = cond;
    q.add(portion);
    return q;
  }

  static List<Question> _beefBurgersNotFastFood() {
    final q = <Question>[];
    q.add(
      _q(
        'dhq_burger_home_freq',
        'Over the past 12 months, how often did you eat beef hamburgers or cheeseburgers that were NOT from a fast food or other restaurant?',
      ),
    );
    final cond = _showWhenNotNever('dhq_burger_home_freq');
    final portion = _q(
      'dhq_burger_home_portion',
      'Each time you ate beef hamburgers or cheeseburgers not from a restaurant, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 1/4 pound', id: 'less'),
        Choice.withText(text: '1/4 to 1/2 pound', id: 'medium'),
        Choice.withText(text: 'More than 1/2 pound', id: 'more'),
      ],
    );
    portion.conditional = cond;
    q.add(portion);

    final lean = _q(
      'dhq_burger_home_lean',
      'How often was the ground beef you used to make the burgers at home lean or extra lean?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    lean.conditional = cond;
    q.add(lean);

    final doneness = _q(
      'dhq_burger_home_doneness',
      'When you ate these hamburgers, how were they usually done on the inside?',
      choices: Dhq3Choices.beefDoneness,
    );
    doneness.conditional = cond;
    q.add(doneness);

    return q;
  }

  static List<Question> _groundBeefMixtures() {
    final q = <Question>[];
    q.add(
      _q(
        'dhq_ground_beef_mix_freq',
        'Over the past 12 months, how often did you eat ground beef in mixtures (such as tacos, burritos, meatballs, casseroles, chili, or meatloaf)?',
      ),
    );
    final cond = _showWhenNotNever('dhq_ground_beef_mix_freq');
    final portion = _q(
      'dhq_ground_beef_mix_portion',
      'Each time you ate ground beef in mixtures, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 2 ounces', id: 'less'),
        Choice.withText(text: '2 to 4 ounces', id: 'medium'),
        Choice.withText(text: 'More than 4 ounces', id: 'more'),
      ],
    );
    portion.conditional = cond;
    q.add(portion);

    final lean = _q(
      'dhq_ground_beef_mix_lean',
      'How often was the ground beef used in these mixtures lean or extra lean?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    lean.conditional = cond;
    q.add(lean);

    return q;
  }

  static List<Question> _beefMixtures() {
    final q = <Question>[];
    q.add(
      _q(
        'dhq_beef_mix_freq',
        'Over the past 12 months, how often did you eat beef (NOT ground) in stews, pot pies, casseroles, or other mixtures?',
      ),
    );
    final portion = _q(
      'dhq_beef_mix_portion',
      'Each time you ate beef (not ground) in mixtures, how much did you usually eat?',
      choices: Dhq3Choices.portionCups(
        'Less than 1/2 cup',
        '1/2 to 1 cup',
        'More than 1 cup',
      ),
    );
    portion.conditional = _showWhenNotNever('dhq_beef_mix_freq');
    q.add(portion);
    return q;
  }

  static List<Question> _roastBeefPotRoast() {
    final q = <Question>[];
    q.add(
      _q(
        'dhq_roast_freq',
        'Over the past 12 months, how often did you eat roast beef or pot roast (NOT in sandwiches)?',
      ),
    );
    final cond = _showWhenNotNever('dhq_roast_freq');
    final portion = _q(
      'dhq_roast_portion',
      'Each time you ate roast beef or pot roast, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 2 ounces', id: 'less'),
        Choice.withText(text: '2 to 5 ounces', id: 'medium'),
        Choice.withText(text: 'More than 5 ounces', id: 'more'),
      ],
    );
    portion.conditional = cond;
    q.add(portion);

    final doneness = _q(
      'dhq_roast_doneness',
      'When you ate roast beef or pot roast, how was it usually done on the inside?',
      choices: Dhq3Choices.beefDoneness,
    );
    doneness.conditional = cond;
    q.add(doneness);

    return q;
  }

  static List<Question> _beefSteak() {
    final q = <Question>[];
    q.add(
      _q(
        'dhq_steak_freq',
        'Over the past 12 months, how often did you eat beef steaks (NOT in sandwiches)?',
      ),
    );
    final cond = _showWhenNotNever('dhq_steak_freq');
    final portion = _q(
      'dhq_steak_portion',
      'Each time you ate beef steaks, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 3 ounces', id: 'less'),
        Choice.withText(text: '3 to 7 ounces', id: 'medium'),
        Choice.withText(text: 'More than 7 ounces', id: 'more'),
      ],
    );
    portion.conditional = cond;
    q.add(portion);

    final lean = _q(
      'dhq_steak_lean',
      'How often did you eat the fat on your beef steaks?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    lean.conditional = cond;
    q.add(lean);

    final doneness = _q(
      'dhq_steak_doneness',
      'When you ate beef steaks, how were they usually done on the inside?',
      choices: Dhq3Choices.beefDoneness,
    );
    doneness.conditional = cond;
    q.add(doneness);

    return q;
  }

  static List<Question> _spareribs() {
    final q = <Question>[];
    q.add(
      _q(
        'dhq_ribs_freq',
        'Over the past 12 months, how often did you eat beef spare ribs or short ribs?',
      ),
    );
    final portion = _q(
      'dhq_ribs_portion',
      'Each time you ate beef spare ribs or short ribs, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 4 ounces', id: 'less'),
        Choice.withText(text: '4 to 8 ounces', id: 'medium'),
        Choice.withText(text: 'More than 8 ounces', id: 'more'),
      ],
    );
    portion.conditional = _showWhenNotNever('dhq_ribs_freq');
    q.add(portion);
    return q;
  }

  static List<Question> _bakedHam() {
    final q = <Question>[];
    q.add(
      _q(
        'dhq_ham_freq',
        'Over the past 12 months, how often did you eat baked ham or ham steak (NOT in sandwiches)?',
      ),
    );
    final portion = _q(
      'dhq_ham_portion',
      'Each time you ate baked ham or ham steak, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 2 ounces', id: 'less'),
        Choice.withText(text: '2 to 4 ounces', id: 'medium'),
        Choice.withText(text: 'More than 4 ounces', id: 'more'),
      ],
    );
    portion.conditional = _showWhenNotNever('dhq_ham_freq');
    q.add(portion);
    return q;
  }

  static List<Question> _porkChops() {
    final q = <Question>[];
    q.add(
      _q(
        'dhq_pork_freq',
        'Over the past 12 months, how often did you eat pork chops or pork roast (NOT in sandwiches)?',
      ),
    );
    final cond = _showWhenNotNever('dhq_pork_freq');
    final portion = _q(
      'dhq_pork_portion',
      'Each time you ate pork chops or pork roast, how much did you usually eat?',
      choices: [
        Choice.withText(
          text: 'Less than 2 ounces or less than 1 small chop',
          id: 'less',
        ),
        Choice.withText(
          text: '2 to 6 ounces or 1 to 2 medium chops',
          id: 'medium',
        ),
        Choice.withText(
          text: 'More than 6 ounces or more than 2 medium chops',
          id: 'more',
        ),
      ],
    );
    portion.conditional = cond;
    q.add(portion);

    final doneness = _q(
      'dhq_pork_doneness',
      'When you ate pork chops, how were they usually done on the inside?',
      choices: [
        Choice.withText(text: 'Just until done', id: 'just_done'),
        Choice.withText(text: 'Well-done', id: 'well_done'),
        Choice.withText(text: 'Very well-done', id: 'very_well_done'),
        Choice.withText(text: "Don't know", id: 'dont_know'),
      ],
    );
    doneness.conditional = cond;
    q.add(doneness);

    return q;
  }

  static List<Question> _gravy() {
    final q = <Question>[];
    q.add(
      _q(
        'dhq_gravy_freq',
        'Over the past 12 months, how often did you eat gravy on meat, poultry, or potatoes?',
      ),
    );
    final portion = _q(
      'dhq_gravy_portion',
      'Each time you ate gravy, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 2 tablespoons', id: 'less'),
        Choice.withText(text: '2 to 4 tablespoons', id: 'medium'),
        Choice.withText(text: 'More than 4 tablespoons', id: 'more'),
      ],
    );
    portion.conditional = _showWhenNotNever('dhq_gravy_freq');
    q.add(portion);
    return q;
  }

  static List<Question> _liver() {
    final q = <Question>[];
    q.add(
      _q(
        'dhq_liver_freq',
        'Over the past 12 months, how often did you eat liver (including chicken liver) or liverwurst?',
      ),
    );
    final portion = _q(
      'dhq_liver_portion',
      'Each time you ate liver or liverwurst, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 2 ounces', id: 'less'),
        Choice.withText(text: '2 to 4 ounces', id: 'medium'),
        Choice.withText(text: 'More than 4 ounces', id: 'more'),
      ],
    );
    portion.conditional = _showWhenNotNever('dhq_liver_freq');
    q.add(portion);
    return q;
  }

  static List<Question> _bacon() {
    final q = <Question>[];
    q.add(
      _q(
        'dhq_bacon_freq',
        'Over the past 12 months, how often did you eat bacon (including turkey bacon)?',
      ),
    );
    final cond = _showWhenNotNever('dhq_bacon_freq');
    final portion = _q(
      'dhq_bacon_portion',
      'Each time you ate bacon, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 2 slices', id: 'less'),
        Choice.withText(text: '2 to 4 slices', id: 'medium'),
        Choice.withText(text: 'More than 4 slices', id: 'more'),
      ],
    );
    portion.conditional = cond;
    q.add(portion);

    final doneness = _q(
      'dhq_bacon_doneness',
      'When you ate bacon, how was it usually done?',
      choices: Dhq3Choices.baconDoneness,
    );
    doneness.conditional = cond;
    q.add(doneness);

    return q;
  }

  static List<Question> _sausage() {
    final q = <Question>[];
    q.add(
      _q(
        'dhq_sausage_freq',
        'Over the past 12 months, how often did you eat sausage (including turkey sausage)?',
      ),
    );
    final portion = _q(
      'dhq_sausage_portion',
      'Each time you ate sausage, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 1 patty or 2 links', id: 'less'),
        Choice.withText(text: '1 to 2 patties or 2 to 4 links', id: 'medium'),
        Choice.withText(text: 'More than 2 patties or 4 links', id: 'more'),
      ],
    );
    portion.conditional = _showWhenNotNever('dhq_sausage_freq');
    q.add(portion);
    return q;
  }

  static List<Question> _cannedTuna() {
    final q = <Question>[];
    q.add(
      _q(
        'dhq_canned_tuna_freq',
        'Over the past 12 months, how often did you eat canned tuna?',
      ),
    );
    final portion = _q(
      'dhq_canned_tuna_portion',
      'Each time you ate canned tuna, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 2 ounces', id: 'less'),
        Choice.withText(text: '2 to 4 ounces', id: 'medium'),
        Choice.withText(text: 'More than 4 ounces', id: 'more'),
      ],
    );
    portion.conditional = _showWhenNotNever('dhq_canned_tuna_freq');
    q.add(portion);
    return q;
  }

  static List<Question> _freshTunaOthers() {
    final q = <Question>[];
    q.add(
      _q(
        'dhq_fresh_tuna_freq',
        'Over the past 12 months, how often did you eat fresh tuna steaks, trout, mackerel, or sardines (NOT canned)?',
      ),
    );
    final portion = _q(
      'dhq_fresh_tuna_portion',
      'Each time you ate fresh tuna steaks, trout, mackerel, or sardines, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 2 ounces', id: 'less'),
        Choice.withText(text: '2 to 5 ounces', id: 'medium'),
        Choice.withText(text: 'More than 5 ounces', id: 'more'),
      ],
    );
    portion.conditional = _showWhenNotNever('dhq_fresh_tuna_freq');
    q.add(portion);
    return q;
  }

  static List<Question> _salmon() {
    final q = <Question>[];
    q.add(
      _q(
        'dhq_salmon_freq',
        'Over the past 12 months, how often did you eat salmon (fresh, frozen, or canned)?',
      ),
    );
    final portion = _q(
      'dhq_salmon_portion',
      'Each time you ate salmon, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 2 ounces', id: 'less'),
        Choice.withText(text: '2 to 5 ounces', id: 'medium'),
        Choice.withText(text: 'More than 5 ounces', id: 'more'),
      ],
    );
    portion.conditional = _showWhenNotNever('dhq_salmon_freq');
    q.add(portion);
    return q;
  }

  static List<Question> _friedShellfish() {
    final q = <Question>[];
    q.add(
      _q(
        'dhq_fried_shellfish_freq',
        'Over the past 12 months, how often did you eat fried shellfish (such as shrimp, crab, or lobster)?',
      ),
    );
    final portion = _q(
      'dhq_fried_shellfish_portion',
      'Each time you ate fried shellfish, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 3 ounces', id: 'less'),
        Choice.withText(text: '3 to 6 ounces', id: 'medium'),
        Choice.withText(text: 'More than 6 ounces', id: 'more'),
      ],
    );
    portion.conditional = _showWhenNotNever('dhq_fried_shellfish_freq');
    q.add(portion);
    return q;
  }

  static List<Question> _shellfishNotFried() {
    final q = <Question>[];
    q.add(
      _q(
        'dhq_shellfish_freq',
        'Over the past 12 months, how often did you eat shellfish that was NOT fried (such as steamed or boiled shrimp, crab, or lobster)?',
      ),
    );
    final portion = _q(
      'dhq_shellfish_portion',
      'Each time you ate shellfish that was not fried, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 3 ounces', id: 'less'),
        Choice.withText(text: '3 to 6 ounces', id: 'medium'),
        Choice.withText(text: 'More than 6 ounces', id: 'more'),
      ],
    );
    portion.conditional = _showWhenNotNever('dhq_shellfish_freq');
    q.add(portion);
    return q;
  }

  static List<Question> _fishSticksOrFried() {
    final q = <Question>[];
    q.add(
      _q(
        'dhq_fish_sticks_freq',
        'Over the past 12 months, how often did you eat fish sticks or fried fish (including fast food fish sandwiches)?',
      ),
    );
    final portion = _q(
      'dhq_fish_sticks_portion',
      'Each time you ate fish sticks or fried fish, how much did you usually eat?',
      choices: [
        Choice.withText(
          text: 'Less than 2 ounces or less than 2 fish sticks',
          id: 'less',
        ),
        Choice.withText(
          text: '2 to 4 ounces or 2 to 4 fish sticks',
          id: 'medium',
        ),
        Choice.withText(
          text: 'More than 4 ounces or more than 4 fish sticks',
          id: 'more',
        ),
      ],
    );
    portion.conditional = _showWhenNotNever('dhq_fish_sticks_freq');
    q.add(portion);
    return q;
  }

  static List<Question> _otherFishNotFried() {
    final q = <Question>[];
    q.add(
      _q(
        'dhq_other_fish_freq',
        'Over the past 12 months, how often did you eat other kinds of fish that were NOT fried (NOT including shellfish)?',
      ),
    );
    final portion = _q(
      'dhq_other_fish_portion',
      'Each time you ate other kinds of fish that were not fried, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 2 ounces', id: 'less'),
        Choice.withText(text: '2 to 5 ounces', id: 'medium'),
        Choice.withText(text: 'More than 5 ounces', id: 'more'),
      ],
    );
    portion.conditional = _showWhenNotNever('dhq_other_fish_freq');
    q.add(portion);
    return q;
  }

  static List<Question> _eggsMeatAlternatives() {
    final q = <Question>[];

    // Tofu, soy burgers, or soy meat substitutes
    q.add(
      _q(
        'dhq_tofu_freq',
        'Over the past 12 months, how often did you eat tofu, soy burgers, or soy meat-substitutes?',
      ),
    );
    final tofuPortion = _q(
      'dhq_tofu_portion',
      'Each time you ate tofu, soy burgers, or soy meat-substitutes, how much did you usually eat?',
      choices: [
        Choice.withText(
          text: 'Less than 1/4 cup or less than 1 patty',
          id: 'less',
        ),
        Choice.withText(text: '1/4 to 1/2 cup or 1 patty', id: 'medium'),
        Choice.withText(
          text: 'More than 1/2 cup or more than 1 patty',
          id: 'more',
        ),
      ],
    );
    tofuPortion.conditional = _showWhenNotNever('dhq_tofu_freq');
    q.add(tofuPortion);

    // Eggs - with extensive follow-ups
    q.add(
      _q(
        'dhq_eggs_freq',
        'Over the past 12 months, how often did you eat eggs, egg whites, or egg substitutes (NOT counting eggs in baked goods and desserts)?',
      ),
    );
    final eggsCond = _showWhenNotNever('dhq_eggs_freq');
    final eggsPortion = _q(
      'dhq_eggs_portion',
      'Each time you ate eggs, egg whites, or egg substitutes, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 1 egg', id: 'less'),
        Choice.withText(text: '1 to 2 eggs', id: 'medium'),
        Choice.withText(text: 'More than 2 eggs', id: 'more'),
      ],
    );
    eggsPortion.conditional = eggsCond;
    q.add(eggsPortion);

    final eggsRegular = _q(
      'dhq_eggs_regular',
      'How often were the eggs you ate regular whole eggs (not egg whites, egg substitutes, or low-cholesterol eggs)?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    eggsRegular.conditional = eggsCond;
    q.add(eggsRegular);

    final eggsOmega = _q(
      'dhq_eggs_omega3',
      'How often were the eggs you ate omega-3 fortified eggs?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    eggsOmega.conditional = eggsCond;
    q.add(eggsOmega);

    final eggsCheeseMeat = _q(
      'dhq_eggs_cheese_meat',
      'How often were the eggs you ate cooked with cheese or meat?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    eggsCheeseMeat.conditional = eggsCond;
    q.add(eggsCheeseMeat);

    final eggsSubstitutes = _q(
      'dhq_eggs_substitutes',
      'How often were the eggs you ate egg substitutes or egg whites only?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    eggsSubstitutes.conditional = eggsCond;
    q.add(eggsSubstitutes);

    return q;
  }

  static List<Question> _chipsSnacks() {
    final q = <Question>[];

    // Crackers
    q.add(
      _q(
        'dhq_crackers_freq',
        'Over the past 12 months, how often did you eat crackers?',
      ),
    );
    final crackersPortion = _q(
      'dhq_crackers_portion',
      'Each time you ate crackers, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 5 crackers', id: 'less'),
        Choice.withText(text: '5 to 15 crackers', id: 'medium'),
        Choice.withText(text: 'More than 15 crackers', id: 'more'),
      ],
    );
    crackersPortion.conditional = _showWhenNotNever('dhq_crackers_freq');
    q.add(crackersPortion);

    // Potato chips
    q.add(
      _q(
        'dhq_potato_chips_freq',
        'Over the past 12 months, how often did you eat potato chips (including low-fat, fat-free, and light)?',
      ),
    );
    final potatoChipsPortion = _q(
      'dhq_potato_chips_portion',
      'Each time you ate potato chips, how much did you usually eat?',
      choices: [
        Choice.withText(
          text: 'Less than 1/2 cup or less than 1/2 ounce',
          id: 'less',
        ),
        Choice.withText(
          text: '1/2 to 1 1/2 cups or 1/2 to 1 1/2 ounces',
          id: 'medium',
        ),
        Choice.withText(
          text: 'More than 1 1/2 cups or more than 1 1/2 ounces',
          id: 'more',
        ),
      ],
    );
    potatoChipsPortion.conditional = _showWhenNotNever('dhq_potato_chips_freq');
    q.add(potatoChipsPortion);

    // Corn or tortilla chips
    q.add(
      _q(
        'dhq_tortilla_chips_freq',
        'Over the past 12 months, how often did you eat corn chips or tortilla chips (including low-fat, fat-free, and light)?',
      ),
    );
    final tortillaChipsPortion = _q(
      'dhq_tortilla_chips_portion',
      'Each time you ate corn chips or tortilla chips, how much did you usually eat?',
      choices: [
        Choice.withText(
          text: 'Less than 1/2 cup or less than 1/2 ounce',
          id: 'less',
        ),
        Choice.withText(
          text: '1/2 to 1 1/2 cups or 1/2 to 1 1/2 ounces',
          id: 'medium',
        ),
        Choice.withText(
          text: 'More than 1 1/2 cups or more than 1 1/2 ounces',
          id: 'more',
        ),
      ],
    );
    tortillaChipsPortion.conditional = _showWhenNotNever(
      'dhq_tortilla_chips_freq',
    );
    q.add(tortillaChipsPortion);

    // Popcorn
    q.add(
      _q(
        'dhq_popcorn_freq',
        'Over the past 12 months, how often did you eat popcorn (including low-fat)?',
      ),
    );
    final popcornPortion = _q(
      'dhq_popcorn_portion',
      'Each time you ate popcorn, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 2 cups', id: 'less'),
        Choice.withText(text: '2 to 5 cups', id: 'medium'),
        Choice.withText(text: 'More than 5 cups', id: 'more'),
      ],
    );
    popcornPortion.conditional = _showWhenNotNever('dhq_popcorn_freq');
    q.add(popcornPortion);

    // Pretzels
    q.add(
      _q(
        'dhq_pretzels_freq',
        'Over the past 12 months, how often did you eat pretzels?',
      ),
    );
    final pretzelsPortion = _q(
      'dhq_pretzels_portion',
      'Each time you ate pretzels, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 1/2 ounce', id: 'less'),
        Choice.withText(text: '1/2 to 1 1/2 ounces', id: 'medium'),
        Choice.withText(text: 'More than 1 1/2 ounces', id: 'more'),
      ],
    );
    pretzelsPortion.conditional = _showWhenNotNever('dhq_pretzels_freq');
    q.add(pretzelsPortion);

    // Whole nuts - with follow-ups for almond and peanuts
    q.add(
      _q(
        'dhq_nuts_freq',
        'Over the past 12 months, how often did you eat peanuts, walnuts, almonds, or other nuts?',
      ),
    );
    final nutsCond = _showWhenNotNever('dhq_nuts_freq');
    final nutsPortion = _q(
      'dhq_nuts_portion',
      'Each time you ate nuts, how much did you usually eat?',
      choices: [
        Choice.withText(
          text: 'Less than 1/4 cup or less than 1/2 ounce',
          id: 'less',
        ),
        Choice.withText(text: '1/4 to 1/2 cup or 1/2 to 1 ounce', id: 'medium'),
        Choice.withText(
          text: 'More than 1/2 cup or more than 1 ounce',
          id: 'more',
        ),
      ],
    );
    nutsPortion.conditional = nutsCond;
    q.add(nutsPortion);

    final nutsAlmonds = _q(
      'dhq_nuts_almonds',
      'How often were the nuts you ate almonds?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    nutsAlmonds.conditional = nutsCond;
    q.add(nutsAlmonds);

    final nutsPeanuts = _q(
      'dhq_nuts_peanuts',
      'How often were the nuts you ate peanuts?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    nutsPeanuts.conditional = nutsCond;
    q.add(nutsPeanuts);

    // High-protein or breakfast bars
    q.add(
      _q(
        'dhq_protein_bars_freq',
        'Over the past 12 months, how often did you eat high-protein bars or breakfast bars (such as Luna, Clif, PowerBar, Special K, or others)?',
      ),
    );
    final proteinBarsPortion = _q(
      'dhq_protein_bars_portion',
      'Each time you ate high-protein bars or breakfast bars, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 1 bar', id: 'less'),
        Choice.withText(text: '1 bar', id: 'medium'),
        Choice.withText(text: 'More than 1 bar', id: 'more'),
      ],
    );
    proteinBarsPortion.conditional = _showWhenNotNever('dhq_protein_bars_freq');
    q.add(proteinBarsPortion);

    // Protein powder
    q.add(
      _q(
        'dhq_protein_powder_freq',
        'Over the past 12 months, how often did you use protein powder or add it to food or drinks?',
      ),
    );
    final proteinPowderPortion = _q(
      'dhq_protein_powder_portion',
      'Each time you used protein powder, how much did you usually use?',
      choices: [
        Choice.withText(text: 'Less than 1 scoop', id: 'less'),
        Choice.withText(text: '1 to 2 scoops', id: 'medium'),
        Choice.withText(text: 'More than 2 scoops', id: 'more'),
      ],
    );
    proteinPowderPortion.conditional = _showWhenNotNever(
      'dhq_protein_powder_freq',
    );
    q.add(proteinPowderPortion);

    // Granola bars
    q.add(
      _q(
        'dhq_granola_bars_freq',
        'Over the past 12 months, how often did you eat granola bars (regular or lowfat)?',
      ),
    );
    final granolaBarsPortion = _q(
      'dhq_granola_bars_portion',
      'Each time you ate granola bars, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 1 bar', id: 'less'),
        Choice.withText(text: '1 to 2 bars', id: 'medium'),
        Choice.withText(text: 'More than 2 bars', id: 'more'),
      ],
    );
    granolaBarsPortion.conditional = _showWhenNotNever('dhq_granola_bars_freq');
    q.add(granolaBarsPortion);

    return q;
  }

  static List<Question> _yogurtCheeseSweets() {
    final q = <Question>[];

    // Yogurt (not frozen) - with follow-ups
    q.add(
      _q(
        'dhq_yogurt_freq',
        'Over the past 12 months, how often did you eat yogurt (NOT including frozen yogurt)?',
      ),
    );
    final yogurtCond = _showWhenNotNever('dhq_yogurt_freq');
    final yogurtPortion = _q(
      'dhq_yogurt_portion',
      'Each time you ate yogurt, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 4 ounces', id: 'less'),
        Choice.withText(text: '4 to 8 ounces', id: 'medium'),
        Choice.withText(text: 'More than 8 ounces', id: 'more'),
      ],
    );
    yogurtPortion.conditional = yogurtCond;
    q.add(yogurtPortion);

    final yogurtGreek = _q(
      'dhq_yogurt_greek',
      'How often was the yogurt you ate Greek yogurt?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    yogurtGreek.conditional = yogurtCond;
    q.add(yogurtGreek);

    final yogurtLowfat = _q(
      'dhq_yogurt_lowfat',
      'How often was the yogurt you ate lowfat or fat-free?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    yogurtLowfat.conditional = yogurtCond;
    q.add(yogurtLowfat);

    // Cottage cheese or ricotta
    q.add(
      _q(
        'dhq_cottage_cheese_freq',
        'Over the past 12 months, how often did you eat cottage cheese or ricotta cheese?',
      ),
    );
    final cottageCheesePortion = _q(
      'dhq_cottage_cheese_portion',
      'Each time you ate cottage cheese or ricotta, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 1/4 cup', id: 'less'),
        Choice.withText(text: '1/4 to 3/4 cup', id: 'medium'),
        Choice.withText(text: 'More than 3/4 cup', id: 'more'),
      ],
    );
    cottageCheesePortion.conditional = _showWhenNotNever(
      'dhq_cottage_cheese_freq',
    );
    q.add(cottageCheesePortion);

    // Cheese - with follow-ups
    q.add(
      _q(
        'dhq_cheese_freq',
        'Over the past 12 months, how often did you eat cheese (including American, cheddar, Swiss, cream cheese, and other kinds)?',
      ),
    );
    final cheeseCond = _showWhenNotNever('dhq_cheese_freq');
    final cheesePortion = _q(
      'dhq_cheese_portion',
      'Each time you ate cheese, how much did you usually eat?',
      choices: [
        Choice.withText(
          text: 'Less than 1 ounce or less than 1 slice',
          id: 'less',
        ),
        Choice.withText(text: '1 to 2 ounces or 1 to 2 slices', id: 'medium'),
        Choice.withText(
          text: 'More than 2 ounces or more than 2 slices',
          id: 'more',
        ),
      ],
    );
    cheesePortion.conditional = cheeseCond;
    q.add(cheesePortion);

    final cheeseLowfat = _q(
      'dhq_cheese_lowfat',
      'How often was the cheese you ate low-fat or fat-free?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    cheeseLowfat.conditional = cheeseCond;
    q.add(cheeseLowfat);

    // Whipped cream - with follow-ups
    q.add(
      _q(
        'dhq_whipped_cream_freq',
        'Over the past 12 months, how often did you eat whipped cream (including non-dairy)?',
      ),
    );
    final whippedCreamCond = _showWhenNotNever('dhq_whipped_cream_freq');
    final whippedCreamPortion = _q(
      'dhq_whipped_cream_portion',
      'Each time you ate whipped cream, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 1 tablespoon', id: 'less'),
        Choice.withText(text: '1 to 3 tablespoons', id: 'medium'),
        Choice.withText(text: 'More than 3 tablespoons', id: 'more'),
      ],
    );
    whippedCreamPortion.conditional = whippedCreamCond;
    q.add(whippedCreamPortion);

    final whippedCreamNondairy = _q(
      'dhq_whipped_cream_nondairy',
      'How often was the whipped cream you ate non-dairy whipped topping (such as Cool Whip)?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    whippedCreamNondairy.conditional = whippedCreamCond;
    q.add(whippedCreamNondairy);

    // Frozen yogurt/sorbet/ices
    q.add(
      _q(
        'dhq_frozen_yogurt_freq',
        'Over the past 12 months, how often did you eat frozen yogurt, sorbet, or ices (including Italian ice)?',
      ),
    );
    final frozenYogurtPortion = _q(
      'dhq_frozen_yogurt_portion',
      'Each time you ate frozen yogurt, sorbet, or ices, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 1/2 cup', id: 'less'),
        Choice.withText(text: '1/2 to 1 cup', id: 'medium'),
        Choice.withText(text: 'More than 1 cup', id: 'more'),
      ],
    );
    frozenYogurtPortion.conditional = _showWhenNotNever(
      'dhq_frozen_yogurt_freq',
    );
    q.add(frozenYogurtPortion);

    // Ice cream - with follow-ups
    q.add(
      _q(
        'dhq_ice_cream_freq',
        'Over the past 12 months, how often did you eat ice cream, ice cream bars, or sherbet?',
      ),
    );
    final iceCreamCond = _showWhenNotNever('dhq_ice_cream_freq');
    final iceCreamPortion = _q(
      'dhq_ice_cream_portion',
      'Each time you ate ice cream, ice cream bars, or sherbet, how much did you usually eat?',
      choices: [
        Choice.withText(
          text: 'Less than 1/2 cup or less than 1 ice cream bar',
          id: 'less',
        ),
        Choice.withText(
          text: '1/2 to 1 cup or 1 to 2 ice cream bars',
          id: 'medium',
        ),
        Choice.withText(
          text: 'More than 1 cup or more than 2 ice cream bars',
          id: 'more',
        ),
      ],
    );
    iceCreamPortion.conditional = iceCreamCond;
    q.add(iceCreamPortion);

    final iceCreamLight = _q(
      'dhq_ice_cream_light',
      'How often was the ice cream you ate light, low-fat, or fat-free?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    iceCreamLight.conditional = iceCreamCond;
    q.add(iceCreamLight);

    // Cake
    q.add(
      _q(
        'dhq_cake_freq',
        'Over the past 12 months, how often did you eat cake (with or without frosting)?',
      ),
    );
    final cakePortion = _q(
      'dhq_cake_portion',
      'Each time you ate cake, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 1 medium piece', id: 'less'),
        Choice.withText(text: '1 medium piece', id: 'medium'),
        Choice.withText(text: 'More than 1 medium piece', id: 'more'),
      ],
    );
    cakePortion.conditional = _showWhenNotNever('dhq_cake_freq');
    q.add(cakePortion);

    // Pie - with follow-ups
    q.add(
      _q('dhq_pie_freq', 'Over the past 12 months, how often did you eat pie?'),
    );
    final pieCond = _showWhenNotNever('dhq_pie_freq');
    final piePortion = _q(
      'dhq_pie_portion',
      'Each time you ate pie, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 1/8 of a 9-inch pie', id: 'less'),
        Choice.withText(text: '1/8 to 1/4 of a 9-inch pie', id: 'medium'),
        Choice.withText(text: 'More than 1/4 of a 9-inch pie', id: 'more'),
      ],
    );
    piePortion.conditional = pieCond;
    q.add(piePortion);

    final pieFruit = _q(
      'dhq_pie_fruit',
      'How often was the pie you ate fruit pie (such as apple, cherry, or blueberry)?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    pieFruit.conditional = pieCond;
    q.add(pieFruit);

    final piePumpkin = _q(
      'dhq_pie_pumpkin',
      'How often was the pie you ate pumpkin or sweet potato pie?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    piePumpkin.conditional = pieCond;
    q.add(piePumpkin);

    final piePecan = _q(
      'dhq_pie_pecan',
      'How often was the pie you ate pecan pie?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    piePecan.conditional = pieCond;
    q.add(piePecan);

    // Cookies
    q.add(
      _q(
        'dhq_cookies_freq',
        'Over the past 12 months, how often did you eat cookies or brownies (NOT including low-fat)?',
      ),
    );
    final cookiesPortion = _q(
      'dhq_cookies_portion',
      'Each time you ate cookies or brownies, how much did you usually eat?',
      choices: [
        Choice.withText(
          text: 'Less than 2 cookies or less than 1 small brownie',
          id: 'less',
        ),
        Choice.withText(
          text: '2 to 4 cookies or 1 to 2 small brownies',
          id: 'medium',
        ),
        Choice.withText(
          text: 'More than 4 cookies or more than 2 brownies',
          id: 'more',
        ),
      ],
    );
    cookiesPortion.conditional = _showWhenNotNever('dhq_cookies_freq');
    q.add(cookiesPortion);

    // Doughnuts, sweet rolls, Danish, Pop-Tarts
    q.add(
      _q(
        'dhq_doughnuts_freq',
        'Over the past 12 months, how often did you eat doughnuts, sweet rolls, Danish, Pop-Tarts, or toaster pastries?',
      ),
    );
    final doughnutsPortion = _q(
      'dhq_doughnuts_portion',
      'Each time you ate doughnuts, sweet rolls, Danish, or toaster pastries, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 1 piece', id: 'less'),
        Choice.withText(text: '1 to 2 pieces', id: 'medium'),
        Choice.withText(text: 'More than 2 pieces', id: 'more'),
      ],
    );
    doughnutsPortion.conditional = _showWhenNotNever('dhq_doughnuts_freq');
    q.add(doughnutsPortion);

    // Sweet muffins or dessert breads
    q.add(
      _q(
        'dhq_sweet_muffins_freq',
        'Over the past 12 months, how often did you eat sweet muffins or dessert breads (such as banana bread or pumpkin bread)?',
      ),
    );
    final sweetMuffinsPortion = _q(
      'dhq_sweet_muffins_portion',
      'Each time you ate sweet muffins or dessert breads, how much did you usually eat?',
      choices: [
        Choice.withText(
          text: 'Less than 1 medium muffin or 1 medium slice',
          id: 'less',
        ),
        Choice.withText(
          text: '1 medium muffin or 1 medium slice',
          id: 'medium',
        ),
        Choice.withText(text: 'More than 1 medium muffin or slice', id: 'more'),
      ],
    );
    sweetMuffinsPortion.conditional = _showWhenNotNever(
      'dhq_sweet_muffins_freq',
    );
    q.add(sweetMuffinsPortion);

    // Pudding or custard
    q.add(
      _q(
        'dhq_pudding_freq',
        'Over the past 12 months, how often did you eat pudding, custard, or flan?',
      ),
    );
    final puddingPortion = _q(
      'dhq_pudding_portion',
      'Each time you ate pudding, custard, or flan, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 1/2 cup', id: 'less'),
        Choice.withText(text: '1/2 to 1 cup', id: 'medium'),
        Choice.withText(text: 'More than 1 cup', id: 'more'),
      ],
    );
    puddingPortion.conditional = _showWhenNotNever('dhq_pudding_freq');
    q.add(puddingPortion);

    // Chocolate candy
    q.add(
      _q(
        'dhq_chocolate_freq',
        'Over the past 12 months, how often did you eat chocolate candy (including candy bars)?',
      ),
    );
    final chocolatePortion = _q(
      'dhq_chocolate_portion',
      'Each time you ate chocolate candy, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 1 small bar', id: 'less'),
        Choice.withText(text: '1 to 2 small bars', id: 'medium'),
        Choice.withText(text: 'More than 2 small bars', id: 'more'),
      ],
    );
    chocolatePortion.conditional = _showWhenNotNever('dhq_chocolate_freq');
    q.add(chocolatePortion);

    // Other candy
    q.add(
      _q(
        'dhq_other_candy_freq',
        'Over the past 12 months, how often did you eat other candy (NOT including chocolate)?',
      ),
    );
    final otherCandyPortion = _q(
      'dhq_other_candy_portion',
      'Each time you ate other candy, how much did you usually eat?',
      choices: [
        Choice.withText(text: 'Less than 5 pieces', id: 'less'),
        Choice.withText(text: '5 to 15 pieces', id: 'medium'),
        Choice.withText(text: 'More than 15 pieces', id: 'more'),
      ],
    );
    otherCandyPortion.conditional = _showWhenNotNever('dhq_other_candy_freq');
    q.add(otherCandyPortion);

    return q;
  }

  static List<Question> _spreadsSummaryVitamins() {
    final q = <Question>[];

    // Spreads checklist
    q.add(
      _q(
        'dhq_spreads_checklist',
        'Which of the following spreads did you use at least once in the past 12 months? Check all that apply.',
        multiple: true,
        choices: [
          Choice.withText(text: 'Margarine (stick or tub)', id: 'margarine'),
          Choice.withText(text: 'Butter', id: 'butter'),
          Choice.withText(text: 'Mayonnaise', id: 'mayo'),
          Choice.withText(text: 'Salad dressing', id: 'dressing'),
        ],
      ),
    );

    // Margarine follow-ups
    final margCond = _showWhenChoiceSelected(
      'dhq_spreads_checklist',
      'margarine',
    );
    final margarine = _q(
      'dhq_margarine',
      'How often was the margarine you ate light, low-fat, or fat-free (stick or tub)?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    margarine.conditional = margCond;
    q.add(margarine);

    final margarineOmega = _q(
      'dhq_margarine_omega',
      'How often was the margarine you ate omega-3 fortified (such as Smart Balance)?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    margarineOmega.conditional = margCond;
    q.add(margarineOmega);

    // Butter follow-ups
    final butterCond = _showWhenChoiceSelected(
      'dhq_spreads_checklist',
      'butter',
    );
    final butterLight = _q(
      'dhq_butter_light',
      'How often was the butter you ate light or reduced fat?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    butterLight.conditional = butterCond;
    q.add(butterLight);

    // Mayonnaise follow-ups
    final mayoCond = _showWhenChoiceSelected('dhq_spreads_checklist', 'mayo');
    final mayo = _q(
      'dhq_mayo',
      'How often was the mayonnaise you ate light, low-fat, or fat-free?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    mayo.conditional = mayoCond;
    q.add(mayo);

    // Salad dressing follow-ups
    final dressingCond = _showWhenChoiceSelected(
      'dhq_spreads_checklist',
      'dressing',
    );
    final saladDressing = _q(
      'dhq_salad_dressing',
      'How often was the salad dressing you ate light, low-fat, or fat-free?',
      choices: Dhq3Choices.almostNeverToAlways,
    );
    saladDressing.conditional = dressingCond;
    q.add(saladDressing);

    // Diet summary
    q.add(
      _q(
        'dhq_vegetarian',
        'For ALL of the past 12 months, have you followed any type of vegetarian diet?',
        choices: Dhq3Choices.yesNo,
      ),
    );

    q.add(
      _q(
        'dhq_excluded',
        'Which of the following foods did you TOTALLY EXCLUDE from your diet? Mark all that apply.',
        multiple: true,
        choices: [
          Choice.withText(text: 'Meat (beef, pork, lamb, etc.)', id: 'meat'),
          Choice.withText(
            text: 'Poultry (chicken, turkey, duck)',
            id: 'poultry',
          ),
          Choice.withText(text: 'Fish and seafood', id: 'fish'),
          Choice.withText(text: 'Eggs', id: 'eggs'),
          Choice.withText(
            text: 'Dairy products (milk, cheese, etc.)',
            id: 'dairy',
          ),
        ],
      ),
    );

    // SUPPLEMENTS - with detailed follow-ups for each
    q.add(
      _q(
        'dhq_supps_intro',
        'The following questions are about dietary supplements you may have taken during the past 12 months. Have you taken any dietary supplements in the past 12 months?',
        choices: Dhq3Choices.yesNo,
      ),
    );

    // Multivitamin - with extensive follow-ups
    q.add(
      _q(
        'dhq_multi_freq',
        'Over the past 12 months, did you take any multivitamins?',
        choices: Dhq3Choices.yesNo,
      ),
    );
    final multiCond = _showWhenChoiceSelected('dhq_multi_freq', 'yes');

    final multiType = _q(
      'dhq_multi_type',
      'What type of multivitamin did you usually take?',
      choices: Dhq3Choices.multivitaminType,
    );
    multiType.conditional = multiCond;
    q.add(multiType);

    final multiMinerals = _q(
      'dhq_multi_minerals',
      'Did your multivitamin contain minerals?',
      choices: Dhq3Choices.yesNoDontKnow,
    );
    multiMinerals.conditional = multiCond;
    q.add(multiMinerals);

    final multiGummy = _q(
      'dhq_multi_gummy',
      'Was your multivitamin a gummy vitamin?',
      choices: Dhq3Choices.yesNo,
    );
    multiGummy.conditional = multiCond;
    q.add(multiGummy);

    final multiGummyCount = _q(
      'dhq_multi_gummy_count',
      'How many gummy vitamins did you usually take each day?',
      choices: Dhq3Choices.gummyCount,
    );
    multiGummyCount.conditional = multiCond;
    q.add(multiGummyCount);

    final multiFrequency = _q(
      'dhq_multi_frequency',
      'How often did you take multivitamins?',
      choices: Dhq3Choices.supplementFreq,
    );
    multiFrequency.conditional = multiCond;
    q.add(multiFrequency);

    final multiYears = _q(
      'dhq_multi_years',
      'For how many years have you been taking multivitamins?',
      choices: Dhq3Choices.supplementYears,
    );
    multiYears.conditional = multiCond;
    q.add(multiYears);

    // Individual supplements with dosage and years
    final suppList = [
      {
        'name': 'eye health supplement (such as Ocuvite, PreserVision, ICaps, or others)',
        'id': 'eye',
      },
      {'name': 'B-complex vitamins', 'id': 'bcomplex'},
      {
        'name': 'antacids containing calcium (such as Tums, Rolaids)',
        'id': 'antacids',
      },
      {'name': 'vitamin B-12', 'id': 'b12'},
      {'name': 'vitamin B-6', 'id': 'b6'},
      {'name': 'biotin', 'id': 'biotin'},
      {'name': 'calcium (NOT calcium-containing antacids)', 'id': 'calcium'},
      {'name': 'coenzyme Q10', 'id': 'coq10'},
      {
        'name': 'fiber supplements (such as Metamucil, Citrucel, or Benefiber)',
        'id': 'fiber',
      },
      {'name': 'folate or folic acid', 'id': 'folate'},
      {'name': 'garlic supplements', 'id': 'garlic'},
    ];

    for (final supp in suppList) {
      q.add(
        _q(
          'dhq_supp_${supp['id']}_freq',
          'Over the past 12 months, did you take ${supp['name']}?',
          choices: Dhq3Choices.yesNo,
        ),
      );
      final suppCond = _showWhenChoiceSelected(
        'dhq_supp_${supp['id']}_freq',
        'yes',
      );
      final suppFreq = _q(
        'dhq_supp_${supp['id']}_how_often',
        'How often did you take ${supp['name']}?',
        choices: Dhq3Choices.supplementFreq,
      );
      suppFreq.conditional = suppCond;
      q.add(suppFreq);
      final suppYears = _q(
        'dhq_supp_${supp['id']}_years',
        'For how many years have you been taking ${supp['name']}?',
        choices: Dhq3Choices.supplementYears,
      );
      suppYears.conditional = suppCond;
      q.add(suppYears);
    }

    // Second batch of supplements
    final suppList2 = [
      {
        'name': 'joint health supplements (such as glucosamine or chondroitin)',
        'id': 'joint',
      },
      {'name': 'iron', 'id': 'iron'},
      {'name': 'magnesium', 'id': 'magnesium'},
      {'name': 'melatonin', 'id': 'melatonin'},
      {'name': 'niacin or nicotinic acid', 'id': 'niacin'},
      {'name': 'omega-3 fatty acids or fish oil', 'id': 'omega3'},
      {'name': 'potassium', 'id': 'potassium'},
      {
        'name':
            'probiotics (such as Lactobacillus acidophilus, Align, or others)',
        'id': 'probiotics',
      },
      {'name': 'saw palmetto', 'id': 'sawpalmetto'},
      {'name': 'vitamin C', 'id': 'vitc'},
      {'name': 'vitamin D', 'id': 'vitd'},
      {'name': 'vitamin E', 'id': 'vite'},
      {'name': 'zinc', 'id': 'zinc'},
    ];

    for (final supp in suppList2) {
      q.add(
        _q(
          'dhq_supp_${supp['id']}_freq',
          'Over the past 12 months, did you take ${supp['name']}?',
          choices: Dhq3Choices.yesNo,
        ),
      );
      final suppCond = _showWhenChoiceSelected(
        'dhq_supp_${supp['id']}_freq',
        'yes',
      );
      final suppFreq = _q(
        'dhq_supp_${supp['id']}_how_often',
        'How often did you take ${supp['name']}?',
        choices: Dhq3Choices.supplementFreq,
      );
      suppFreq.conditional = suppCond;
      q.add(suppFreq);
      final suppYears = _q(
        'dhq_supp_${supp['id']}_years',
        'For how many years have you been taking ${supp['name']}?',
        choices: Dhq3Choices.supplementYears,
      );
      suppYears.conditional = suppCond;
      q.add(suppYears);
    }

    // Other supplements checklist
    q.add(
      _q(
        'dhq_other_supps_checklist',
        'Have you taken any of the following supplements in the past 12 months? Check all that apply.',
        multiple: true,
        choices: [
          Choice.withText(text: 'Cinnamon', id: 'cinnamon'),
          Choice.withText(
            text: 'Cranberry supplements or pills',
            id: 'cranberry',
          ),
          Choice.withText(text: 'Evening primrose oil', id: 'primrose'),
          Choice.withText(
            text: 'Flaxseed oil or flaxseed supplements',
            id: 'flaxseed',
          ),
          Choice.withText(text: 'Ginkgo biloba', id: 'ginkgo'),
          Choice.withText(text: 'Ginseng', id: 'ginseng'),
          Choice.withText(text: 'Selenium', id: 'selenium'),
          Choice.withText(text: "St. John's wort", id: 'stjohn'),
          Choice.withText(text: 'Turmeric or curcumin', id: 'turmeric'),
          Choice.withText(text: 'Valerian', id: 'valerian'),
        ],
      ),
    );

    // Final question about other supplements
    q.add(
      _q(
        'dhq_any_other_supps',
        'Have you taken any OTHER dietary supplements in the past 12 months that were not already asked about?',
        choices: Dhq3Choices.yesNo,
      ),
    );

    return q;
  }
}
