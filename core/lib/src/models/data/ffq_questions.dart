import 'package:studyu_core/core.dart';

/// Food Frequency Questionnaire (FFQ) – test/single survey (26 questions).
/// Use createFFQTask() for the normal one-off FFQ.
/// Use createFFQTaskForDay(0..13) for 14-day cluster surveys (DHQ3 split into 14).
class FFQQuestions() {
  /// Standard frequency options for FFQ questions
  static List<Choice> get frequencyChoices => [
    Choice.withText(
      text: 'Less than once per month',
      id: 'less_than_once_per_month',
    ),
    Choice.withText(text: '2-3 times per month', id: '2_3_times_per_month'),
    Choice.withText(text: '1-2 times per week', id: '1_2_times_per_week'),
    Choice.withText(text: '3-4 times per week', id: '3_4_times_per_week'),
    Choice.withText(
      text: 'At least 5 times per week',
      id: 'at_least_5_times_per_week',
    ),
  ];

  static const String introText =
      'Think about what you ate over the last year. Consider breakfast, lunch, dinner, and when you ate out.';

  /// Creates the normal (test) FFQ questions – 26 questions.
  static List<Question> createQuestions() {
    final questions = <Question>[];

    questions.add(
      _createFrequencyQuestion(
        id: 'ffq_ground_meat',
        prompt: 'Ground meat, e.g. from beef or lamb, in burgers, Bolognese sauce, etc.',
      ),
    );
    questions.add(
      _createFrequencyQuestion(
        id: 'ffq_pork_beef',
        prompt: 'Pork or beef in the form of steaks, ribs, roasts or as sandwich meat/on sandwiches',
      ),
    );
    questions.add(
      _createFrequencyQuestion(
        id: 'ffq_fried_chicken',
        prompt: 'Fried chicken (such as in chicken burgers, nuggets, etc.)',
      ),
    );
    questions.add(
      _createFrequencyQuestion(
        id: 'ffq_sausages',
        prompt: 'Sausages, cured meats, e.g. wiener or salami',
      ),
    );
    questions.add(
      _createFrequencyQuestion(
        id: 'ffq_bacon',
        prompt: 'Bacon/breakfast bacon',
      ),
    );
    questions.add(
      _createFrequencyQuestion(
        id: 'ffq_salad_dressings',
        prompt: 'Salad dressings (not low-fat)',
      ),
    );
    questions.add(
      _createFrequencyQuestion(
        id: 'ffq_butter_margarine',
        prompt: 'Margarine, butter or oil when cooking',
      ),
    );
    questions.add(
      _createFrequencyQuestion(
        id: 'ffq_eggs',
        prompt: 'Eggs (not when only egg whites were used)',
      ),
    );
    questions.add(_createFrequencyQuestion(id: 'ffq_pizza', prompt: 'Pizza'));
    questions.add(
      _createFrequencyQuestion(
        id: 'ffq_cheese',
        prompt: 'Cheese or cheese spread (not low-fat)',
      ),
    );
    questions.add(
      _createFrequencyQuestion(
        id: 'ffq_french_fries',
        prompt: 'French fries, potato pancakes, etc.',
      ),
    );
    questions.add(
      _createFrequencyQuestion(
        id: 'ffq_chips',
        prompt: 'Corn chips (e.g. nachos/tortilla chips), potato chips',
      ),
    );
    questions.add(
      _createFrequencyQuestion(
        id: 'ffq_pastries',
        prompt: 'Pancakes/donuts, croissants, sweet baked goods (e.g. plum cake, streusel cake, etc.)',
      ),
    );
    questions.add(
      _createFrequencyQuestion(
        id: 'ffq_cakes_cookies',
        prompt: 'Cakes, cookies',
      ),
    );
    questions.add(
      _createFrequencyQuestion(
        id: 'ffq_ice_cream',
        prompt: 'Ice cream (not low-fat or sorbet)',
      ),
    );
    questions.add(
      _createFrequencyQuestion(id: 'ffq_chocolate', prompt: 'Chocolate'),
    );
    questions.add(
      _createFrequencyQuestion(
        id: 'ffq_candy',
        prompt: 'Lollipops/hard candy/bonbons (with sugar)',
      ),
    );
    questions.add(
      _createFrequencyQuestion(
        id: 'ffq_spreads',
        prompt: 'Spreads, such as peanut butter, marmalade, honey, Nutella',
      ),
    );
    questions.add(
      _createFrequencyQuestion(
        id: 'ffq_american_pancakes',
        prompt: 'American pancakes or French toast',
      ),
    );
    questions.add(
      _createFrequencyQuestion(
        id: 'ffq_sports_drinks',
        prompt: 'Sports drinks or energy drinks (e.g. Red Bull)',
      ),
    );
    questions.add(
      _createFrequencyQuestion(
        id: 'ffq_soft_drinks',
        prompt: 'Soft drinks, lemonade (not "light" versions)',
      ),
    );
    questions.add(
      _createFrequencyQuestion(
        id: 'ffq_whole_milk',
        prompt: 'Whole milk, also in cappuccinos, hot chocolates, shakes, etc.',
      ),
    );
    questions.add(
      _createFrequencyQuestion(
        id: 'ffq_sweetened_beverages',
        prompt: 'Other sweetened beverages (such as juice with added sugar, syrup, iced tea, etc.)',
      ),
    );
    questions.add(
      _createFrequencyQuestion(id: 'ffq_white_bread', prompt: 'White bread'),
    );
    questions.add(
      _createFrequencyQuestion(
        id: 'ffq_fast_food',
        prompt: 'How often have you eaten at a fast food restaurant or had food delivered in the last year? (e.g. McDonalds, Pizza, Asian, etc.)',
        choices: [
          Choice.withText(text: 'None', id: 'none'),
          Choice.withText(text: '1-2', id: '1_2'),
          Choice.withText(text: '3-4', id: '3_4'),
          Choice.withText(text: '5-6', id: '5_6'),
          Choice.withText(text: '7 or more', id: '7_or_more'),
        ],
      ),
    );
    questions.add(
      _createFrequencyQuestion(
        id: 'ffq_added_sugar',
        prompt: 'How many teaspoons of sugar have you added to drinks, muesli, or other foods in the last week?',
        choices: [
          Choice.withText(text: 'None', id: 'none'),
          Choice.withText(text: '1-2', id: '1_2'),
          Choice.withText(text: '3-4', id: '3_4'),
          Choice.withText(text: '5-6', id: '5_6'),
          Choice.withText(text: '7 or more', id: '7_or_more'),
        ],
      ),
    );

    return questions;
  }

  static ChoiceQuestion _createFrequencyQuestion({
    required String id,
    required String prompt,
    List<Choice>? choices,
  }) {
    final question = ChoiceQuestion.withId()
      ..id = id
      ..prompt = prompt
      ..multiple = false
      ..choices = choices ?? frequencyChoices;
    return question;
  }

  /// Normal (test) FFQ – one survey, 26 questions.
  static QuestionnaireTask createFFQTask() {
    final task = QuestionnaireTask.withId()
      ..title = 'Food Frequency Questionnaire (FFQ)'
      ..header = introText
      ..footer = 'Thank you for completing the Food Frequency Questionnaire!'
      ..questions.questions = createQuestions();

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

  /// 14-day FFQ: returns the survey for day index 0..13 (Day 1..14). Each has one cluster of DHQ3 questions.
  static QuestionnaireTask createFFQTaskForDay(int dayIndex) {
    return Dhq3Questions.createTaskForDay(dayIndex);
  }

  static bool isFFQTask(String taskTitle) {
    return taskTitle.contains('Food Frequency Questionnaire') ||
        taskTitle.contains('FFQ');
  }

  /// True if this is one of the 14 named DHQ3 surveys (e.g. "About you", "Beverages", "Fruits").
  static bool isFFQDayTask(String? taskTitle) {
    return Dhq3Questions.isNamedSurvey(taskTitle);
  }

  /// Day number 1..14 for the 14 named surveys. Returns null if not one of them.
  static int? getFFQDayNumber(String? taskTitle) {
    return Dhq3Questions.dayIndexForTitle(taskTitle);
  }

  /// Titles for the 14 DHQ3 surveys (one per day/topic). Use with createFFQTaskForDay(index).
  static List<String> get ffqDaySurveyTitles => Dhq3Questions.surveyTitles;
}
