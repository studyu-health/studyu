import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image/image.dart' as image;
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/daily_recall_entry_view_model.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_screen.dart';
import 'package:studyu_app/screens/study/nutrition/meal_creator_screen.dart';
import 'package:studyu_app/screens/study/nutrition/meal_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_photo_widgets.dart';
import 'package:studyu_app/screens/study/tasks/observation/nutrition_task_widget.dart';
import 'package:studyu_app/services/nutrition_photo_storage.dart';
import 'package:studyu_app/util/nutrition_recall_autosave_manager.dart';
import 'package:studyu_app/util/study_subject_extension.dart';
import 'package:studyu_core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../util/mock_nutrition_draft_storage.dart';
import 'fake_nutrition_food_repository.dart';

Widget nutritionTaskApp(
  NutritionTask task, {
  DailyRecall? existingRecall,
  Locale locale = const Locale('en'),
  DateTime? historicalDate,
  NutritionRecallPersistenceTarget? persistenceTarget,
  bool readOnly = false,
  AppState? appState,
  FakeNutritionFoodRepository? foodRepository,
}) => ChangeNotifierProvider(
  create: (_) => appState ?? AppState(),
  child: MaterialApp(
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    locale: locale,
    home: NutritionTaskWidget(
      existingRecall: existingRecall,
      task: task,
      persistenceTarget: persistenceTarget,
      historicalDate: historicalDate,
      readOnly: readOnly,
      foodRepository: foodRepository ?? FakeNutritionFoodRepository(),
      completionPeriod: CompletionPeriod(
        id: 'period',
        unlockTime: StudyUTimeOfDay(),
        lockTime: StudyUTimeOfDay(hour: 23),
      ),
    ),
  ),
);

class const _NutritionLauncher({
  required final NutritionTask task,
  required final ValueChanged<DailyRecall?> onResult,
  final DailyRecall? existingRecall,
}) extends StatefulWidget {
  @override
  State<_NutritionLauncher> createState() => _NutritionLauncherState();
}

class _NutritionLauncherState() extends State<_NutritionLauncher> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final result = await Navigator.of(context).push<DailyRecall>(
        NutritionTaskWidget.route(
          existingRecall: widget.existingRecall,
          task: widget.task,
          foodRepository: FakeNutritionFoodRepository(),
          completionPeriod: CompletionPeriod(
            id: 'period',
            unlockTime: StudyUTimeOfDay(),
            lockTime: StudyUTimeOfDay(hour: 23),
          ),
        ),
      );
      widget.onResult(result);
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

const nutritionInstructionsShownKey =
    'nutrition_instructions_shown_nutrition-task';
const _photoManagerChannel = MethodChannel('com.fluttercandies/photo_manager');

const _nutritionPhotoScope = (userId: 'participant', subjectId: 'subject');
final _storedNutritionPhotos = <String, Uint8List>{};
bool _nutritionPhotoSupabaseInitialized = false;

NutritionPhotoKey _itemPhotoKey(String foodId) =>
    NutritionPhotoKey(_nutritionPhotoScope, NutritionPhotoKind.item, foodId);

Future<void> _initializeNutritionPhotoSupabase() async {
  if (_nutritionPhotoSupabaseInitialized) return;
  await Supabase.initialize(
    url: 'http://localhost',
    publishableKey: 'test-key',
    httpClient: MockClient((request) async {
      final photo = _storedNutritionPhotos[request.url.path];
      if (request.method == 'GET' && photo != null) {
        return http.Response.bytes(
          photo,
          200,
          headers: {'content-type': 'image/jpeg'},
        );
      }
      return http.Response(
        '{"statusCode":"404","message":"Object not found"}',
        404,
        headers: {'content-type': 'application/json'},
      );
    }),
    authOptions: const FlutterAuthClientOptions(
      autoRefreshToken: false,
      detectSessionInUri: false,
      persistSession: false,
    ),
  );
  await Supabase.instance.client.auth.recoverSession(
    jsonEncode({
      'access_token': 'participant-token',
      'token_type': 'bearer',
      'user': {'id': 'participant', 'app_metadata': <String, dynamic>{}},
    }),
  );
  _nutritionPhotoSupabaseInitialized = true;
}

void _storeItemPhotos(String mealId, int foodCount) {
  _storedNutritionPhotos.clear();
  for (var index = 0; index < foodCount; index++) {
    final key = _itemPhotoKey('$mealId-$index-definition');
    _storedNutritionPhotos['/storage/v1/object/nutrition-photos/${key.path}'] =
        Uint8List.fromList([255, 216]);
  }
}

AppState _photoParticipant() =>
    AppState()
      ..activeSubject = StudySubject('subject', 'study', 'participant', []);

class _CatalogPhotoClient(final Map<Uri, Uint8List> _photos)
    extends Fake
    implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async =>
      _CatalogPhotoRequest(_photos[url]!);
}

class _CatalogPhotoRequest(final Uint8List _bytes)
    extends Fake
    implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async => _CatalogPhotoResponse(_bytes);
}

class _CatalogPhotoResponse(final Uint8List _bytes)
    extends Stream<List<int>>
    with Fake
    implements HttpClientResponse {
  @override
  int get statusCode => HttpStatus.ok;

  @override
  int get contentLength => _bytes.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => Stream<List<int>>.value(_bytes).listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );
}

NutritionTask nutritionTask({
  String? instructions,
  int? minimumMeals,
  List<String>? customMealTypes,
}) => NutritionTask.withId()
  ..id = 'nutrition-task'
  ..title = 'Nutrition'
  ..instructions = instructions
  ..minimumMealsRequired = minimumMeals
  ..customMealTypes = customMealTypes;

NutritionProfile nutrition(double energyKcal) => NutritionProfile(
  energyKcal: energyKcal,
  protein: 0,
  carbs: 0,
  fat: 0,
  sugars: 0,
  fiber: 0,
  saturatedFat: 0,
  transFat: 0,
  cholesterol: 0,
  sodium: 0,
  waterContent: 0,
  micros: {},
);

FoodEntry food(String id, String name, double energyKcal) => FoodEntry(
  id: id,
  foodId: '$id-definition',
  foodVersionId: '$id-version',
  entryType: FoodEntryType.singleIngredient,
  name: name,
  amount: 1,
  unit: 'serving',
  servingSizeGrams: 100,
  portionEstimationMethod: PortionEstimationMethod.standardUnit,
  portionState: PortionState.asServed,
  nutrition: nutrition(energyKcal),
  source: FoodSource.manual,
  confidenceScore: 1,
  createdAt: DateTime(2026, 7, 15),
  originalValues: {},
);

MealLog meal(
  String id,
  MealType type, {
  String? label,
  List<FoodEntry> foods = const [],
  bool isSkipped = false,
  MealOccurrenceTimePrecision timePrecision =
      MealOccurrenceTimePrecision.approximate,
}) => MealLog(
  id: id,
  mealType: type,
  customMealLabel: label,
  mealContext: MealContext.home,
  timestamp: DateTime(2026, 7, 15, 12),
  timePrecision: timePrecision,
  timezone: 'UTC',
  isSkipped: isSkipped,
  skipReason: isSkipped ? 'Not hungry' : null,
  foods: foods,
);

DailyRecall recall(List<MealLog> meals) => DailyRecall(
  id: 'recall',
  date: DateTime(2026, 7, 15),
  recallMode: RecallMode.realtimeRecord,
  entryStartedAt: DateTime(2026, 7, 15, 8),
  meals: meals,
);

FakeNutritionFoodRepository _savedSoupRepository() =>
    FakeNutritionFoodRepository([
      SavedFoodTemplate(
        id: 'saved-soup',
        userId: 'anonymous',
        name: 'Saved soup',
        isPublic: false,
        createdAt: DateTime(2026, 7, 15),
        prototype: food('soup', 'Soup', 100),
      ),
    ]);

Future<void> _selectSavedSoup(WidgetTester tester, {bool settle = true}) async {
  await tester.tap(find.text('Library'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Saved soup'));
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(
      of: find.byKey(const ValueKey('selection-tray')),
      matching: find.byType(FilledButton),
    ),
  );
  await tester.pump();
  if (settle) await tester.pumpAndSettle();
}

({NutritionTask task, StudySubject subject}) historicalNavigationSetup(
  String foodName, {
  int daysAgo = 1,
}) {
  final task = nutritionTask()..id = 'task';
  task.schedule.completionPeriods = [
    CompletionPeriod(
      id: 'period',
      unlockTime: StudyUTimeOfDay(),
      lockTime: StudyUTimeOfDay(hour: 23),
    ),
  ];
  final subject = StudySubject('subject', 'study', 'user', [])
    ..startedAt = DateTime.now().subtract(const Duration(days: 3));
  subject.study = (Study('study', 'user')
    ..schedule = (StudySchedule()..numberOfCycles = 0)
    ..interventions = []);
  final date = DateTime.now().toUtc().subtract(Duration(days: daysAgo));
  final historicalRecall =
      recall([
          meal(
            'meal',
            MealType.breakfast,
            foods: [food('food', foodName, 100)],
          ),
        ])
        ..date = date
        ..entryCompletedAt = date
        ..studyDaySnapshot = subject.getNutritionStudyDayFor(date);
  final progress = SubjectProgress(
    subjectId: subject.id,
    interventionId: 'intervention',
    taskId: task.id,
    resultType: 'DailyRecall',
    result: Result<DailyRecall>.app(
      type: 'DailyRecall',
      periodId: 'period',
      result: historicalRecall,
    ),
  )..completedAt = date;
  subject.progress.add(progress);
  return (task: task, subject: subject);
}

void main() {
  setUp(() => mockNutritionDraftStorage());
  testWidgets('conflicting draft is kept until confirmed discard', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      nutritionInstructionsShownKey: true,
    });
    final l10n = lookupAppLocalizations(const Locale('en'));
    final today = DateTime.now();
    final task = nutritionTask();
    final subject = StudySubject('subject-draft', 'study', 'user', [])
      ..startedAt = today
      ..study = (Study('study', 'user')..schedule.numberOfCycles = 0);
    final saved = DailyRecall.withId(
      date: today,
      recallMode: RecallMode.realtimeRecord,
      meals: [],
      studyDaySnapshot: 0,
      entryCompletedAt: today,
      lastAutoSavedAt: today,
      waterIntakeMl: 100,
    );
    subject.progress.add(
      SubjectProgress(
          subjectId: subject.id,
          interventionId: 'baseline',
          taskId: task.id,
          resultType: 'DailyRecall',
          result: Result<DailyRecall>.app(
            type: 'DailyRecall',
            periodId: 'period',
            result: saved,
          ),
        )
        ..completedAt = today
        ..nutritionRevision = 1,
    );
    final manager = NutritionRecallAutoSaveManager();
    final local = DailyRecall.fromJson(saved.toJson())
      ..lastAutoSavedAt = today.add(const Duration(seconds: 1))
      ..waterIntakeMl = 350;
    await manager.saveRecall(
      recall: local,
      subjectId: subject.id,
      taskId: task.id,
      interventionId: 'baseline',
      periodId: 'period',
      studyDaySnapshot: 0,
      progressCompletedAt: today,
      nutritionRevision: 0,
    );

    await tester.pumpWidget(
      nutritionTaskApp(task, appState: AppState()..activeSubject = subject),
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.nutrition_recall_conflict_title), findsOneWidget);
    expect(find.text(l10n.nutrition_add_diary_entry), findsNothing);
    await tester.tap(find.text(l10n.nutrition_recall_discard_draft));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.cancel));
    await tester.pumpAndSettle();
    expect(
      (await manager.scanPendingRecalls(subject.id))
          .single
          .recall
          .waterIntakeMl,
      350,
    );

    await tester.tap(find.text(l10n.nutrition_recall_discard_draft));
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(FilledButton, l10n.nutrition_recall_discard_draft),
    );
    await tester.pumpAndSettle();
    expect(await manager.scanPendingRecalls(subject.id), isEmpty);
    expect(find.text(l10n.nutrition_recall_conflict_title), findsNothing);
    expect(find.text(l10n.nutrition_add_diary_entry), findsOneWidget);
  });

  testWidgets(
    'timeline shows available energy for a meal with missing values',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        nutritionInstructionsShownKey: true,
      });
      final unknown = food('unknown', 'Unlabelled food', 0);
      unknown.nutrition.unavailableNutrients = {'energyKcal'};
      await tester.pumpWidget(
        nutritionTaskApp(
          nutritionTask(),
          existingRecall: recall([
            meal('first', MealType.breakfast, foods: [unknown]),
            meal(
              'second',
              MealType.lunch,
              foods: [unknown, food('known', 'Rice', 100)],
            ),
          ]),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Nutrition information unavailable'),
        findsOneWidget,
      );
      expect(find.textContaining('100 kcal'), findsOneWidget);
      expect(find.textContaining('(partial)'), findsNothing);
    },
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({
      nutritionInstructionsShownKey: true,
      'nutrition_instructions_shown_task': true,
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          _photoManagerChannel,
          (_) async => PermissionState.denied.index,
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_photoManagerChannel, null);
  });

  testWidgets('timeline photo grid splits one to four item photos', (
    tester,
  ) async {
    await _initializeNutritionPhotoSupabase();
    SharedPreferences.setMockInitialValues({
      nutritionInstructionsShownKey: true,
    });
    const cases = [
      ('one', 1, [Size(48, 48)]),
      ('two', 2, [Size(24, 48), Size(24, 48)]),
      ('three', 3, [Size(16, 48), Size(16, 48), Size(16, 48)]),
      ('four', 4, [Size(24, 24), Size(24, 24), Size(24, 24), Size(24, 24)]),
    ];
    for (final (id, foodCount, expectedSizes) in cases) {
      _storeItemPhotos(id, foodCount);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.pumpWidget(
        nutritionTaskApp(
          nutritionTask(),
          appState: _photoParticipant(),
          existingRecall: recall([
            meal(
              id,
              MealType.breakfast,
              foods: [
                for (var index = 0; index < foodCount; index++)
                  food('$id-$index', '$id $index', 100),
              ],
            ),
          ]),
        ),
      );
      await tester.pumpAndSettle();

      final grid = find.byType(NutritionPhotoGrid);
      for (var index = 0; index < expectedSizes.length; index++) {
        final key = _itemPhotoKey('$id-$index-definition');
        expect(
          tester.getSize(
            find.descendant(of: grid, matching: find.byKey(ValueKey(key.path))),
          ),
          expectedSizes[index],
        );
      }
    }
  });

  testWidgets('timeline photo grid shows the first four available photos', (
    tester,
  ) async {
    await _initializeNutritionPhotoSupabase();
    SharedPreferences.setMockInitialValues({
      nutritionInstructionsShownKey: true,
    });
    _storeItemPhotos('five', 5);
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(),
        appState: _photoParticipant(),
        existingRecall: recall([
          meal(
            'five',
            MealType.breakfast,
            foods: [
              food('missing-photo', 'Food without a photo', 100),
              for (var index = 0; index < 5; index++)
                food('five-$index', 'Food $index', 100),
            ],
          ),
        ]),
      ),
    );
    await tester.pumpAndSettle();

    final grid = find.byType(NutritionPhotoGrid);
    for (var index = 0; index < 4; index++) {
      final key = _itemPhotoKey('five-$index-definition');
      expect(
        tester.getSize(
          find.descendant(of: grid, matching: find.byKey(ValueKey(key.path))),
        ),
        const Size(24, 24),
      );
    }
    expect(
      find.descendant(
        of: grid,
        matching: find.byKey(ValueKey(_itemPhotoKey('five-4-definition').path)),
      ),
      findsNothing,
    );
  });

  testWidgets('diary card shows both catalog photos from a saved entry', (
    tester,
  ) async {
    await _initializeNutritionPhotoSupabase();
    _storedNutritionPhotos.clear();
    SharedPreferences.setMockInitialValues({
      nutritionInstructionsShownKey: true,
    });
    const urls = [
      'https://example.test/apple.png',
      'https://example.test/pear.png',
    ];
    final foods = [
      food('apple', 'Apple', 100)
        ..originalValues['image_front_small_url'] = urls[0],
      food('pear', 'Pear', 100)..originalValues['image_url'] = urls[1],
    ];
    final client = _CatalogPhotoClient({
      Uri.parse(urls[0]): image.encodePng(image.Image(width: 8, height: 8)),
      Uri.parse(urls[1]): image.encodePng(image.Image(width: 16, height: 8)),
    });
    debugNetworkImageHttpClientProvider = () => client;
    try {
      final placeholder = find.byType(SizedBox);
      await tester.pumpWidget(const SizedBox.shrink());
      final context = tester.element(placeholder);
      await tester.runAsync(() async {
        await Future.wait(
          urls.map((url) => precacheImage(NetworkImage(url), context)),
        );
      });
      await tester.pumpWidget(
        nutritionTaskApp(
          nutritionTask(),
          appState: _photoParticipant(),
          existingRecall: recall([
            meal('fruit', MealType.breakfast, foods: foods),
          ]),
        ),
      );
      await tester.pumpAndSettle();

      final renderedPhotos = find.descendant(
        of: find.byType(NutritionPhotoGrid),
        matching: find.byType(RawImage),
      );
      expect(
        tester
            .widgetList<RawImage>(renderedPhotos)
            .map((photo) => photo.image?.width),
        [8, 16],
      );
    } finally {
      debugNetworkImageHttpClientProvider = null;
    }
  });

  testWidgets('photo grid keeps the fallback when item photos are missing', (
    tester,
  ) async {
    await _initializeNutritionPhotoSupabase();
    _storedNutritionPhotos.clear();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NutritionPhotoGrid(
            sources: [(photoKey: _itemPhotoKey('missing'), imageUrl: null)],
            fallback: const Text('Fallback photo'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Fallback photo'), findsOneWidget);
    expect(find.byKey(ValueKey(_itemPhotoKey('missing').path)), findsNothing);
  });

  testWidgets('water logging is hidden when the study has it disabled', (
    tester,
  ) async {
    await tester.pumpWidget(nutritionTaskApp(nutritionTask()));
    await tester.pumpAndSettle();

    expect(find.text('Log meal'), findsOneWidget);
    expect(find.text('Water'), findsNothing);
    expect(find.byTooltip('Add a cup of water'), findsNothing);
  });

  testWidgets('water controls use the saved cup size for future adjustments', (
    tester,
  ) async {
    final task = nutritionTask()..trackWaterIntake = true;
    final addCup = find.byTooltip('Add a cup of water');
    final removeCup = find.byWidgetPredicate(
      (widget) =>
          widget is IconButton && widget.tooltip == 'Remove a cup of water',
    );
    await tester.pumpWidget(nutritionTaskApp(task));
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.text('Water')).dy,
      greaterThan(tester.getBottomLeft(find.text('No meals recorded yet')).dy),
    );
    expect(tester.widget<IconButton>(removeCup).onPressed, isNull);
    await tester.tap(addCup);
    await tester.pumpAndSettle();
    expect(find.text('250 mL'), findsOneWidget);

    await tester.tap(find.byTooltip('Cup size'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '0');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), '400');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('250 mL'), findsOneWidget);
    await tester.tap(addCup);
    await tester.pumpAndSettle();
    expect(find.text('650 mL'), findsOneWidget);
    await tester.tap(removeCup);
    await tester.tap(removeCup);
    await tester.pumpAndSettle();
    expect(find.text('0 mL'), findsOneWidget);
    expect(tester.widget<IconButton>(removeCup).onPressed, isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(nutritionTaskApp(task));
    await tester.pumpAndSettle();
    await tester.tap(addCup);
    await tester.pumpAndSettle();
    expect(find.text('400 mL'), findsOneWidget);
  });

  testWidgets('historical mode shows context and hides workspace navigation', (
    tester,
  ) async {
    final date = DateTime(2026, 7, 15);
    final subject = StudySubject('subject', 'study', 'user', [])
      ..startedAt = DateTime.now().subtract(const Duration(days: 2));
    subject.study = (Study('study', 'user')
      ..schedule = (StudySchedule()..numberOfCycles = 0)
      ..interventions = []);
    final target = NutritionRecallPersistenceTarget(
      taskId: 'task',
      periodId: 'period',
      interventionId: 'intervention',
      completedAt: DateTime.utc(2026, 7, 15, 12),
      studyDaySnapshot: subject.getDayOfStudyFor(DateTime.now()) - 1,
    );

    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(),
        existingRecall: recall([
          meal('meal', MealType.breakfast, foods: [food('food', 'Apple', 100)]),
        ]),
        historicalDate: date,
        persistenceTarget: target,
        appState: AppState()..activeSubject = subject,
      ),
    );
    await tester.pump();

    expect(find.text('Statistics'), findsNothing);
    expect(find.text('My items'), findsNothing);
    expect(find.byIcon(Icons.history_outlined), findsNothing);
    expect(find.byIcon(Icons.help_outline), findsNothing);
  });

  testWidgets(
    'read-only historical record without a target stays in historical shell',
    (tester) async {
      await tester.pumpWidget(
        nutritionTaskApp(
          nutritionTask()..showStatistics = true,
          existingRecall: recall([
            meal(
              'meal',
              MealType.breakfast,
              foods: [food('food', 'Apple', 100)],
            ),
          ])..waterIntakeMl = 600,
          historicalDate: DateTime(2026, 7, 15),
          readOnly: true,
        ),
      );
      await tester.pump();

      expect(find.text('Read-only'), findsOneWidget);
      expect(find.text('Daily summary'), findsOneWidget);
      expect(find.text('Statistics'), findsNothing);
      expect(find.text('My items'), findsNothing);
      expect(find.byIcon(Icons.history_outlined), findsNothing);
      expect(find.byIcon(Icons.help_outline), findsNothing);
      expect(find.text('Log meal'), findsNothing);
      expect(find.byTooltip('More options'), findsNothing);
      expect(find.text('600 mL'), findsOneWidget);
      expect(find.byTooltip('Add a cup of water'), findsNothing);
      expect(find.byTooltip('Remove a cup of water'), findsNothing);

      await tester.tap(find.text('Apple'));
      await tester.pumpAndSettle();
      expect(find.byType(NutritionTaskWidget), findsOneWidget);
      expect(find.byType(MealEntryScreen), findsNothing);
    },
  );

  testWidgets('history opens an older server record in the read-only shell', (
    tester,
  ) async {
    final setup = historicalNavigationSetup('Historical apple', daysAgo: 2);

    await tester.pumpWidget(
      nutritionTaskApp(
        setup.task,
        appState: AppState()..activeSubject = setup.subject,
      ),
    );
    await tester.pump();
    await tester.tap(find.byTooltip('History'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Historical apple'));
    await tester.pumpAndSettle();

    expect(find.text('Read-only'), findsOneWidget);
    expect(find.text('Historical apple'), findsOneWidget);
    expect(find.text('Daily summary'), findsNothing);
    expect(find.text('Statistics'), findsNothing);
    expect(find.text('My items'), findsNothing);
    expect(find.byTooltip('History'), findsNothing);
    expect(find.byTooltip('Help'), findsNothing);
    expect(find.text('Repeat diary entry'), findsNothing);
  });

  testWidgets('history opens a previous-day local draft for editing', (
    tester,
  ) async {
    final setup = historicalNavigationSetup('Draft apple');
    final progress = setup.subject.progress.removeLast();
    final draft = progress.result.result as DailyRecall;
    draft.entryCompletedAt = null;
    final manager = NutritionRecallAutoSaveManager();
    await manager.saveRecall(
      recall: draft,
      subjectId: setup.subject.id,
      taskId: setup.task.id,
      interventionId: progress.interventionId,
      periodId: progress.result.periodId!,
      studyDaySnapshot: draft.studyDaySnapshot!,
    );
    await tester.pumpWidget(
      nutritionTaskApp(
        setup.task,
        appState: AppState()..activeSubject = setup.subject,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('History'));
    await tester.pumpAndSettle();
    expect(find.text('Draft saved on this device'), findsOneWidget);
    await tester.tap(find.text('Draft apple'));
    await tester.pumpAndSettle();

    expect(find.text('Read-only'), findsNothing);
    expect(find.text('Log meal'), findsOneWidget);
    expect(find.text('Draft apple'), findsOneWidget);
  });

  testWidgets(
    'history labels an expired correction and lets users discard it',
    (tester) async {
      final setup = historicalNavigationSetup('Synced apple', daysAgo: 2);
      final progress = setup.subject.progress.single;
      final draft = DailyRecall.fromJson(
        (progress.result.result as DailyRecall).toJson(),
      );
      draft.meals.single.foods.single.name = 'Unsynced apple';
      final manager = NutritionRecallAutoSaveManager();
      await manager.saveRecall(
        recall: draft,
        subjectId: setup.subject.id,
        taskId: setup.task.id,
        interventionId: progress.interventionId,
        periodId: progress.result.periodId!,
        studyDaySnapshot: draft.studyDaySnapshot!,
        progressCompletedAt: progress.completedAt,
        nutritionRevision: progress.nutritionRevision,
      );
      await tester.pumpWidget(
        nutritionTaskApp(
          setup.task,
          appState: AppState()..activeSubject = setup.subject,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('History'));
      await tester.pumpAndSettle();

      expect(find.text('Synced apple'), findsOneWidget);
      expect(find.text('Unsynced apple'), findsOneWidget);
      expect(find.textContaining('Sync window ended'), findsOneWidget);
      await tester.tap(find.byTooltip('Discard draft'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Discard draft'));
      await tester.pumpAndSettle();

      expect(await manager.scanPendingRecalls(setup.subject.id), isEmpty);
      expect(find.text('Synced apple'), findsOneWidget);
      expect(find.text('Unsynced apple'), findsNothing);
    },
  );

  testWidgets('a synced historical meal opens and saves while offline', (
    tester,
  ) async {
    final setup = historicalNavigationSetup('Saved apple');
    final progress = setup.subject.progress.single;
    final period = setup.task.schedule.completionPeriods.single;
    final manager = NutritionRecallAutoSaveManager();
    final repository = _OfflineDefinitionRepository();
    await tester.pumpWidget(
      nutritionTaskApp(
        setup.task,
        foodRepository: repository,
        appState: AppState()..activeSubject = setup.subject,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('History'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saved apple'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saved apple'));
    await tester.pumpAndSettle();

    expect(find.byType(MealEntryScreen), findsOneWidget);
    await tester.tap(find.text('Save diary entry'));
    await tester.pumpAndSettle();
    expect(find.byType(MealEntryScreen), findsNothing);
    final draft = (await manager.scanPendingRecalls(setup.subject.id)).single;
    expect(draft.periodId, period.id);
    expect(draft.progressCompletedAt, progress.completedAt);
    expect(draft.nutritionRevision, progress.nutritionRevision);
  });

  testWidgets('history refreshes after an opened record closes', (
    tester,
  ) async {
    final setup = historicalNavigationSetup('Historical apple', daysAgo: 2);

    final appState = AppState()
      ..activeSubject = setup.subject
      ..selectedStudy = setup.subject.study;
    await tester.pumpWidget(nutritionTaskApp(setup.task, appState: appState));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('History'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Historical apple'));
    await tester.pumpAndSettle();

    final previous = setup.subject.progress.single;
    final correctedRecall =
        recall([
            meal(
              'meal',
              MealType.breakfast,
              foods: [food('food', 'Corrected apple', 100)],
            ),
          ])
          ..studyDaySnapshot =
              (previous.result.result as DailyRecall).studyDaySnapshot
          ..entryCompletedAt = previous.completedAt;
    setup.subject.progress[0] = SubjectProgress(
      subjectId: setup.subject.id,
      interventionId: previous.interventionId,
      taskId: setup.task.id,
      resultType: 'DailyRecall',
      result: Result<DailyRecall>.app(
        type: 'DailyRecall',
        periodId: 'period',
        result: correctedRecall,
      ),
    )..completedAt = previous.completedAt;

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Corrected apple'), findsOneWidget);
    expect(find.text('Historical apple'), findsNothing);
  });

  testWidgets('Library Create opens the food and meal editors', (tester) async {
    final l10n = lookupAppLocalizations(const Locale('en'));
    await tester.pumpWidget(nutritionTaskApp(nutritionTask()));
    await tester.pumpAndSettle();

    final navigation = find.byType(NavigationBar);
    final create = find.descendant(
      of: find.byType(AppBar),
      matching: find.text(l10n.nutrition_create_library_item),
    );
    expect(create, findsNothing);
    await tester.tap(
      find.descendant(of: navigation, matching: find.text(l10n.food_library)),
    );
    await tester.pumpAndSettle();

    await tester.tap(create);
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.add_food_action));
    await tester.pumpAndSettle();
    expect(find.byType(FoodEntryScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(create);
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.create_meal));
    await tester.pumpAndSettle();
    expect(find.byType(MealCreatorScreen), findsOneWidget);
  });

  testWidgets('returning from history refreshes the mounted food library', (
    tester,
  ) async {
    final setup = historicalNavigationSetup('Historical apple', daysAgo: 2);
    final repository = FakeNutritionFoodRepository();

    await tester.pumpWidget(
      nutritionTaskApp(
        setup.task,
        appState: AppState()..activeSubject = setup.subject,
        foodRepository: repository,
      ),
    );
    await tester.pumpAndSettle();
    expect(repository.loadCalls, 1);

    await tester.tap(find.byTooltip('History'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Historical apple'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(repository.loadCalls, 2);
  });

  testWidgets('disposing during history does not refresh the food library', (
    tester,
  ) async {
    final setup = historicalNavigationSetup('Historical apple', daysAgo: 2);
    final repository = FakeNutritionFoodRepository();

    await tester.pumpWidget(
      nutritionTaskApp(
        setup.task,
        appState: AppState()..activeSubject = setup.subject,
        foodRepository: repository,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('History'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Historical apple'));
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    expect(repository.loadCalls, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('expired historical edit returns to History on app resume', (
    tester,
  ) async {
    final setup = historicalNavigationSetup('Editable apple');

    await tester.pumpWidget(
      nutritionTaskApp(
        setup.task,
        appState: AppState()..activeSubject = setup.subject,
      ),
    );
    await tester.pump();
    await tester.tap(find.byTooltip('History'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editable apple'));
    await tester.pumpAndSettle();
    setup.subject.startedAt = setup.subject.startedAt!.subtract(
      const Duration(days: 1),
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('History')),
      findsOneWidget,
    );
    expect(find.text('Editable apple'), findsOneWidget);
    expect(find.text('This study day is no longer editable.'), findsOneWidget);
  });

  testWidgets('never renders manual completion controls', (tester) async {
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(),
        existingRecall: recall([meal('meal', MealType.breakfast)]),
      ),
    );
    await tester.pump();

    expect(find.text('Finish today’s nutrition log'), findsNothing);
    expect(
      find.text('This submits your current nutrition log for today.'),
      findsNothing,
    );
  });

  testWidgets(
    'moves the daily summary to statistics and retains the period selection',
    (tester) async {
      await tester.pumpWidget(
        nutritionTaskApp(
          nutritionTask()..showStatistics = true,
          existingRecall: recall([
            meal(
              'meal',
              MealType.breakfast,
              foods: [food('apple', 'Apple', 100)],
            ),
          ])..date = DateTime.now(),
        ),
      );
      await tester.pump();
      expect(find.text('Daily summary'), findsNothing);

      final navigation = find.byType(NavigationBar);
      final statistics = find.descendant(
        of: navigation,
        matching: find.text('Statistics'),
      );
      await tester.tap(statistics);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Statistics'),
        ),
        findsOneWidget,
      );
      expect(find.byTooltip('History'), findsNothing);
      expect(find.text('Daily summary'), findsOneWidget);
      expect(find.text('100 kcal'), findsOneWidget);

      await tester.tap(find.byTooltip('Help'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Averages include only completed study days'),
        findsOneWidget,
      );
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Week'));
      await tester.pumpAndSettle();
      expect(find.text('Energy by study day'), findsOneWidget);
      await tester.tap(
        find.descendant(of: navigation, matching: find.text('Diary')),
      );
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Food diary'),
        ),
        findsOneWidget,
      );
      expect(find.text('Daily summary'), findsNothing);

      await tester.tap(statistics);
      await tester.pumpAndSettle();
      expect(find.text('Energy by study day'), findsOneWidget);
    },
  );

  testWidgets('disabling statistics returns to the diary and keeps Library', (
    tester,
  ) async {
    final task = nutritionTask()..showStatistics = true;
    final existingRecall = recall([
      meal('meal', MealType.breakfast, foods: [food('apple', 'Apple', 100)]),
    ])..date = DateTime.now();
    await tester.pumpWidget(
      nutritionTaskApp(task, existingRecall: existingRecall),
    );
    await tester.pumpAndSettle();

    final navigation = find.byType(NavigationBar);
    final statistics = find.descendant(
      of: navigation,
      matching: find.text('Statistics'),
    );
    await tester.tap(statistics);
    await tester.pumpAndSettle();
    expect(find.text('Daily summary'), findsOneWidget);

    task.showStatistics = false;
    await tester.pumpWidget(
      nutritionTaskApp(task, existingRecall: existingRecall),
    );
    await tester.pumpAndSettle();
    expect(statistics, findsNothing);
    expect(find.text('Daily summary'), findsNothing);
    expect(find.text('Log meal'), findsOneWidget);

    await tester.tap(
      find.descendant(of: navigation, matching: find.text('Library')),
    );
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Library')),
      findsOneWidget,
    );
  });

  for (final tab in ['Diary', 'Statistics', 'Library']) {
    testWidgets('Exit closes $tab without returning a completion result', (
      tester,
    ) async {
      var didReturn = false;
      DailyRecall? result;
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AppState(),
          child: MaterialApp(
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            locale: const Locale('en'),
            home: _NutritionLauncher(
              task: nutritionTask()..showStatistics = tab == 'Statistics',
              existingRecall: recall([meal('meal', MealType.breakfast)]),
              onResult: (value) {
                didReturn = true;
                result = value;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final navigation = find.byType(NavigationBar);
      await tester.tap(
        find.descendant(of: navigation, matching: find.text(tab)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BackButton), findsNothing);
      await tester.tap(
        find.descendant(of: navigation, matching: find.text('Exit')),
      );
      await tester.pumpAndSettle();

      expect(didReturn, isTrue);
      expect(result, isNull);
      expect(find.byType(NutritionTaskWidget), findsNothing);
    });
  }

  testWidgets('repeated Exit requests leave the parent route open', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(title: const Text('Parent route')),
                    body: _NutritionLauncher(
                      task: nutritionTask(),
                      onResult: (_) {},
                    ),
                  ),
                ),
              ),
              child: const Text('Open diary'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open diary'));
    await tester.pumpAndSettle();

    final navigationBar = tester.widget<NavigationBar>(
      find.byType(NavigationBar),
    );
    final exit = navigationBar.destinations.indexWhere(
      (destination) =>
          destination is NavigationDestination && destination.label == 'Exit',
    );
    expect(exit, isNonNegative);
    navigationBar.onDestinationSelected!(exit);
    navigationBar.onDestinationSelected!(exit);
    await tester.pumpAndSettle();

    expect(find.byType(NutritionTaskWidget), findsNothing);
    expect(find.text('Parent route'), findsOneWidget);
  });

  testWidgets('Exit asks before leaving below the advisory meal target', (
    tester,
  ) async {
    var didReturn = false;
    DailyRecall? result;
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          locale: const Locale('en'),
          home: _NutritionLauncher(
            task: nutritionTask(minimumMeals: 1),
            existingRecall: recall([]),
            onResult: (value) {
              didReturn = true;
              result = value;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Exit'));
    await tester.pumpAndSettle();

    expect(didReturn, isFalse);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(didReturn, isFalse);
    await tester.tap(find.text('Exit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Leave anyway'));
    await tester.pumpAndSettle();

    expect(didReturn, isTrue);
    expect(result, isNull);
  });

  testWidgets('shows the recall date as non-interactive header text', (
    tester,
  ) async {
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(instructions: '   '),
        existingRecall: recall([]),
      ),
    );
    await tester.pump();

    final expectedDate = MaterialLocalizations.of(
      tester.element(find.byType(NutritionTaskWidget)),
    ).formatMediumDate(DateTime(2026, 7, 15));
    final date = find.text(expectedDate);

    expect(find.text('Instructions'), findsNothing);
    expect(date, findsOneWidget);
    expect(
      find.ancestor(of: date, matching: find.byType(InkWell)),
      findsNothing,
    );
    expect(
      find.ancestor(of: date, matching: find.byType(IconButton)),
      findsNothing,
    );
  });

  testWidgets('Log meal opens search before the new meal editor', (
    tester,
  ) async {
    await tester.pumpWidget(
      nutritionTaskApp(nutritionTask(), foodRepository: _savedSoupRepository()),
    );
    await tester.pump();

    expect(find.text('No meals recorded yet'), findsOneWidget);
    expect(find.text('Breakfast'), findsNothing);
    expect(find.text('Log meal'), findsOneWidget);
    expect(find.text('Repeat diary entry'), findsNothing);

    await tester.tap(find.text('Log meal'));
    await tester.pumpAndSettle();
    expect(find.byType(FoodSearchScreen), findsOneWidget);
    expect(find.byType(MealEntryScreen, skipOffstage: false), findsNothing);

    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();
    expect(find.text('No meals recorded yet'), findsOneWidget);

    await tester.tap(find.text('Log meal'));
    await tester.pumpAndSettle();
    await _selectSavedSoup(tester, settle: false);
    expect(find.byType(MealEntryScreen, skipOffstage: false), findsNothing);
    await tester.pumpAndSettle();
    final route = ModalRoute.of(tester.element(find.byType(MealEntryScreen)))!;
    expect(route.transitionDuration, Duration.zero);

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Add entry'),
      ),
      findsOneWidget,
    );
    expect(find.text('Soup'), findsOneWidget);
    expect(find.byType(FoodSearchScreen), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard changes'));
    await tester.pumpAndSettle();
    expect(find.text('No meals recorded yet'), findsOneWidget);
  });

  testWidgets(
    'saved diary food is available before sync and stays out after Library deletion',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        nutritionInstructionsShownKey: true,
      });
      final subject = StudySubject('subject', 'study', 'user', []);
      final repository = FakeNutritionFoodRepository();
      await tester.pumpWidget(
        nutritionTaskApp(
          nutritionTask(),
          appState: AppState()..activeSubject = subject,
          foodRepository: repository,
        ),
      );
      await tester.pumpAndSettle();
      final logMeal = find.text('Log meal');
      await tester.tap(logMeal);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create item'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create food'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).first, 'Draft apricot');
      await tester.tap(find.text('Save and add to entry'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add 1 item to entry'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Select a time'));
      await tester.pumpAndSettle();
      await tester.tap(find.text("I don't remember"));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save diary entry'));
      await tester.pumpAndSettle();

      final draftFood = find.text('Draft apricot');
      expect(draftFood, findsOneWidget);
      expect(subject.progress, isEmpty);
      expect(await repository.loadTemplates(subject.id), isEmpty);
      await tester.tap(logMeal);
      await tester.pumpAndSettle();
      expect(draftFood, findsOneWidget);
      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();

      Finder tab(String label) => find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(label),
      );
      await tester.tap(tab('Library'));
      await tester.pumpAndSettle();
      expect(draftFood, findsOneWidget);
      await tester.tap(find.byTooltip('More options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();
      expect(draftFood, findsNothing);

      await tester.tap(tab('Diary'));
      await tester.pumpAndSettle();
      expect(draftFood, findsOneWidget);
      await tester.tap(logMeal);
      await tester.pumpAndSettle();
      expect(draftFood, findsNothing);
    },
  );

  testWidgets(
    'Repeat diary entry saves an editable copy of a prior meal to Today',
    (tester) async {
      final setup = historicalNavigationSetup('Breakfast apple');
      setup.task.customMealTypes = ['Usual breakfast'];
      final priorRecall =
          setup.subject.progress.single.result.result as DailyRecall;
      final source = priorRecall.meals.single
        ..mealType = MealType.other
        ..customMealLabel = 'Usual breakfast';
      final sourceFood = source.foods.single..amount = 2;

      await tester.pumpWidget(
        nutritionTaskApp(
          setup.task,
          appState: AppState()..activeSubject = setup.subject,
        ),
      );
      await tester.pumpAndSettle();

      final repeat = find.text('Repeat diary entry');
      final model = tester.element(repeat).read<DailyRecallEntryViewModel>();
      await tester.ensureVisible(repeat);
      await tester.tap(repeat);
      await tester.pumpAndSettle();
      expect(find.text('Choose a recent meal'), findsOneWidget);
      await tester.tap(find.text('Usual breakfast'));
      await tester.pumpAndSettle();

      expect(find.byType(FoodSearchScreen), findsNothing);
      expect(find.text('Usual breakfast'), findsOneWidget);
      expect(find.text('Select a time'), findsOneWidget);
      expect(model.recall.meals, isEmpty);
      final initialFood = tester
          .widget<MealEntryScreen>(find.byType(MealEntryScreen))
          .initialFoods
          .single;
      expect(initialFood.amount, 2);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard changes'));
      await tester.pumpAndSettle();
      expect(model.recall.meals, isEmpty);

      await tester.tap(repeat);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Usual breakfast'));
      await tester.pumpAndSettle();

      final item = find.text('Breakfast apple');
      await tester.ensureVisible(item);
      await tester.tap(item);
      await tester.pumpAndSettle();
      final servings = find.widgetWithText(TextFormField, 'Servings *');
      await tester.ensureVisible(servings);
      await tester.enterText(servings, '3');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select a time'));
      await tester.pumpAndSettle();
      await tester.tap(find.text("I don't remember"));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save diary entry'));
      await tester.pumpAndSettle();

      final saved = model.recall.meals.single;
      final savedFood = saved.foods.single;
      expect(saved.id, isNot(source.id));
      expect(saved.customMealLabel, 'Usual breakfast');
      expect(saved.mealContext, isNull);
      expect(saved.timePrecision, MealOccurrenceTimePrecision.unknown);
      expect(saved.timestamp, isNull);
      expect(savedFood.id, isNot(sourceFood.id));
      expect(savedFood.foodId, sourceFood.foodId);
      expect(savedFood.foodVersionId, sourceFood.foodVersionId);
      expect(savedFood.amount, 3);
      expect(priorRecall.meals.single, same(source));
      expect(priorRecall.meals.single.foods.single.amount, 2);
    },
  );

  testWidgets(
    'Repeat diary entry hides meals that contain a disallowed saved meal',
    (tester) async {
      final setup = historicalNavigationSetup('Breakfast apple');
      setup.task.allowMeals = false;
      final priorRecall =
          setup.subject.progress.single.result.result as DailyRecall;
      priorRecall.meals.single.foods.add(
        food('porridge', 'Saved porridge', 160)..entryType = FoodEntryType.meal,
      );
      priorRecall.meals.addAll([
        meal('empty', MealType.lunch),
        meal('skipped', MealType.dinner, isSkipped: true),
      ]);

      await tester.pumpWidget(
        nutritionTaskApp(
          setup.task,
          appState: AppState()..activeSubject = setup.subject,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Log meal'), findsOneWidget);
      expect(find.text('Repeat diary entry'), findsNothing);
    },
  );

  testWidgets(
    'assisted logging shows the day gallery and saves reviewed food',
    (tester) async {
      const photoId = 'lunch-photo';
      final photoTime = DateTime(2026, 7, 15, 12, 30);
      var galleryQueries = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_photoManagerChannel, (call) async {
            if (call.method == 'getAssetPathList') galleryQueries++;
            return switch (call.method) {
              'getPermissionState' => PermissionState.authorized.index,
              'getAssetPathList' => {
                'data': [
                  {'id': 'all', 'name': 'All photos', 'isAll': true},
                ],
              },
              'getAssetCountFromPath' => 1,
              'getAssetListPaged' => {
                'data': [
                  {
                    'id': photoId,
                    'type': 1,
                    'width': 300,
                    'height': 300,
                    'createDt': photoTime.millisecondsSinceEpoch ~/ 1000,
                  },
                ],
              },
              _ => null,
            };
          });

      final today = recall([
        meal(
          'breakfast',
          MealType.breakfast,
          foods: [food('toast', 'Toast', 80)],
        ),
      ]);
      await tester.pumpWidget(
        nutritionTaskApp(
          nutritionTask(),
          existingRecall: today,
          foodRepository: _savedSoupRepository(),
        ),
      );
      await tester.pumpAndSettle();

      final assisted = find.text('Assisted meal logging');
      expect(galleryQueries, 0);
      expect(
        tester.getBottomLeft(assisted).dy,
        lessThan(tester.getTopLeft(find.text('Meals')).dy),
      );
      await tester.tap(assisted);
      await tester.pumpAndSettle();

      expect(galleryQueries, greaterThan(0));
      expect(find.byKey(const ValueKey(photoId)), findsOneWidget);
      await tester.tap(find.text('Continue without photos'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField),
        'I ate 75 g of potato salad.',
      );
      await tester.pump();
      await tester.tap(find.text('Generate meal suggestions'));
      await tester.pumpAndSettle();

      expect(find.text('Review meals'), findsOneWidget);
      expect(find.text('Potato salad'), findsOneWidget);
      expect(find.textContaining('75 g'), findsOneWidget);
      expect(today.meals.map((meal) => meal.foods.single.name), ['Toast']);

      await tester.tap(find.text('Save 1 diary entry'));
      await tester.pumpAndSettle();
      expect(find.text('Review meals'), findsNothing);
      expect(find.text('Toast'), findsOneWidget);
      expect(find.text('Potato salad'), findsOneWidget);
    },
  );

  testWidgets('German nutrition timeline uses participant translations', (
    tester,
  ) async {
    await tester.pumpWidget(
      nutritionTaskApp(nutritionTask(), locale: const Locale('de')),
    );
    await tester.pump();

    expect(find.text('Mahlzeiten'), findsOneWidget);
    expect(find.text('Mahlzeit erfassen'), findsOneWidget);
    expect(find.text('Meals'), findsNothing);

    await tester.tap(find.text('Mahlzeit erfassen'));
    await tester.pumpAndSettle();

    final search = tester.widget<FoodSearchScreen>(
      find.byType(FoodSearchScreen),
    );
    final l10n = AppLocalizations.of(
      tester.element(find.byType(FoodSearchScreen)),
    )!;
    expect(search.mealLabel, l10n.meal_neutral_label);
    expect(find.text('Lunch'), findsNothing);
  });

  testWidgets('configured custom labels remain available in the editor', (
    tester,
  ) async {
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(customMealTypes: ['Morning meal', 'Late meal']),
        foodRepository: _savedSoupRepository(),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Log meal'));
    await tester.pumpAndSettle();
    await _selectSavedSoup(tester);
    await tester.tap(find.text('Meal details'));
    await tester.pumpAndSettle();

    expect(find.text('Morning meal'), findsOneWidget);
    expect(find.text('Late meal'), findsOneWidget);
  });

  testWidgets('custom tasks keep unmatched legacy meals under Other meals', (
    tester,
  ) async {
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(customMealTypes: ['Morning meal']),
        existingRecall: recall([
          meal(
            'configured',
            MealType.other,
            label: 'Morning meal',
            foods: [food('apple', 'Apple', 52)],
          ),
          meal(
            'unmatched',
            MealType.other,
            label: 'Late bite',
            foods: [food('toast', 'Toast', 80)],
          ),
          meal(
            'legacy',
            MealType.breakfast,
            foods: [food('eggs', 'Eggs', 140)],
          ),
        ]),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Morning meal'), findsOneWidget);
    expect(find.textContaining('Other'), findsNothing);
    expect(find.textContaining('Late bite'), findsOneWidget);
    expect(find.textContaining('Breakfast'), findsOneWidget);
    expect(find.text('Lunch'), findsNothing);
    expect(find.text('Toast'), findsOneWidget);
    expect(find.text('Eggs'), findsOneWidget);
  });

  testWidgets('keeps multiple and custom meals separate with previews', (
    tester,
  ) async {
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(),
        existingRecall: recall([
          meal('snack-1', MealType.snack, foods: [food('apple', 'Apple', 52)]),
          meal(
            'snack-2',
            MealType.snack,
            foods: [food('yogurt', 'Yogurt', 90)],
          ),
          meal('brunch', MealType.brunch, foods: [food('eggs', 'Eggs', 140)]),
          meal(
            'custom',
            MealType.other,
            label: 'Late bite',
            foods: [food('toast', 'Toast', 80)],
          ),
          meal('skipped', MealType.breakfast, isSkipped: true),
        ]),
      ),
    );
    await tester.pump();

    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Yogurt'), findsOneWidget);
    expect(find.textContaining('Brunch'), findsOneWidget);
    expect(find.textContaining('Late bite'), findsOneWidget);
    expect(find.textContaining('Not hungry'), findsOneWidget);
    expect(find.textContaining('52 kcal'), findsOneWidget);
    expect(find.textContaining('90 kcal'), findsOneWidget);
  });

  testWidgets('timeline deletion asks for confirmation', (tester) async {
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(),
        existingRecall: recall([
          meal(
            'breakfast',
            MealType.breakfast,
            foods: [food('apple', 'Apple', 52)],
          ),
        ]),
      ),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    final deleteAction = find.text('Delete');
    expect(
      tester.getTopLeft(find.text('Edit')).dy,
      closeTo(
        tester.getBottomLeft(find.byTooltip('More options')).dy,
        kMinInteractiveDimension,
      ),
    );
    await tester.tap(deleteAction);
    await tester.pumpAndSettle();

    expect(find.text('Delete this entry?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Apple'), findsOneWidget);

    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    await tester.tap(deleteAction);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Apple'), findsNothing);
  });

  testWidgets('deleted editor result removes only the selected meal', (
    tester,
  ) async {
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(),
        existingRecall: recall([
          meal(
            'breakfast',
            MealType.breakfast,
            foods: [food('apple', 'Apple', 52)],
          ),
          meal('lunch', MealType.lunch, foods: [food('yogurt', 'Yogurt', 90)]),
        ]),
      ),
    );
    await tester.pump();

    expect(find.byTooltip('More options'), findsNWidgets(2));
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('meal-breakfast')),
        matching: find.byTooltip('More options'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Delete entry'));
    await tester.tap(find.text('Delete entry'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.byType(NutritionTaskWidget), findsOneWidget);
    expect(find.text('Apple'), findsNothing);
    expect(find.text('Yogurt'), findsOneWidget);
  });

  testWidgets('shows instructions on first open and keeps them in help', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final task = nutritionTask(instructions: 'Record every meal.');

    await tester.pumpWidget(nutritionTaskApp(task));
    await tester.pumpAndSettle();

    expect(find.text('Instructions'), findsOneWidget);
    expect(find.text('Record every meal.'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Help'));
    await tester.pumpAndSettle();

    expect(find.text('Instructions'), findsOneWidget);
    expect(find.text('Record every meal.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pumpWidget(nutritionTaskApp(task));
    await tester.pumpAndSettle();

    expect(find.text('Close'), findsNothing);
  });

  testWidgets('uses the default instructions and configured meal target', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(nutritionTaskApp(nutritionTask(minimumMeals: 2)));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Please record all the foods and beverages you consumed today. '
        'For each meal or snack, provide as much detail as possible including '
        'portion sizes and preparation methods.',
      ),
      findsOneWidget,
    );
    final l10n = AppLocalizations.of(
      tester.element(find.byType(NutritionTaskWidget)),
    )!;
    expect(find.text(l10n.min_meals_required(2)), findsOneWidget);
  });

  testWidgets('groups unknown-time entries at the end', (tester) async {
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(),
        existingRecall: recall([
          meal(
            'unknown',
            MealType.other,
            timePrecision: MealOccurrenceTimePrecision.unknown,
            foods: [food('tea', 'Tea', 5)],
          ),
          meal(
            'early',
            MealType.breakfast,
            foods: [food('cereal', 'Cereal', 200)],
          ),
        ]),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Time not remembered'), findsNWidgets(2));
    expect(find.text('Tea'), findsOneWidget);
    expect(find.text('Cereal'), findsOneWidget);
    final cerealY = tester.getTopLeft(find.text('Cereal')).dy;
    final teaY = tester.getTopLeft(find.text('Tea')).dy;
    expect(cerealY, lessThan(teaY));
  });

  testWidgets('timestamp does not make unknown precision chronological', (
    tester,
  ) async {
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(),
        existingRecall: recall([
          meal(
            'unknown',
            MealType.other,
            timePrecision: MealOccurrenceTimePrecision.unknown,
            foods: [food('tea', 'Tea', 5)],
          )..timestamp = DateTime(2026, 7, 15, 6),
          meal('later', MealType.dinner, foods: [food('bread', 'Bread', 100)]),
        ]),
      ),
    );
    await tester.pump();

    expect(
      tester.getTopLeft(find.text('Bread')).dy,
      lessThan(tester.getTopLeft(find.text('Tea')).dy),
    );
  });

  testWidgets('adjacent category entries share one icon header', (
    tester,
  ) async {
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(),
        existingRecall: recall([
          meal(
            'first',
            MealType.breakfast,
            foods: [food('cereal', 'Cereal', 200)],
          )..timestamp = DateTime(2026, 7, 15, 8),
          meal(
            'second',
            MealType.breakfast,
            foods: [food('toast', 'Toast', 150)],
          )..timestamp = DateTime(2026, 7, 15, 9),
        ]),
      ),
    );
    await tester.pump();

    expect(find.text('Breakfast'), findsOneWidget);
    expect(find.text('Cereal'), findsOneWidget);
    expect(find.text('Toast'), findsOneWidget);
    expect(find.textContaining('Breakfast •'), findsNothing);
  });

  testWidgets('interleaved categories stay chronological', (tester) async {
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(),
        existingRecall: recall([
          meal(
            'first',
            MealType.breakfast,
            foods: [food('cereal', 'Cereal', 200)],
          )..timestamp = DateTime(2026, 7, 15, 8),
          meal('lunch', MealType.lunch, foods: [food('pasta', 'Pasta', 500)])
            ..timestamp = DateTime(2026, 7, 15, 12),
          meal(
            'second',
            MealType.breakfast,
            foods: [food('toast', 'Toast', 150)],
          )..timestamp = DateTime(2026, 7, 15, 13),
        ]),
      ),
    );
    await tester.pump();

    final breakfastHeaders = find.text('Breakfast');
    expect(breakfastHeaders, findsNWidgets(2));
    expect(
      tester.getTopLeft(breakfastHeaders.at(0)).dy,
      lessThan(tester.getTopLeft(find.text('Lunch')).dy),
    );
    expect(
      tester.getTopLeft(find.text('Lunch')).dy,
      lessThan(tester.getTopLeft(breakfastHeaders.at(1)).dy),
    );
  });

  testWidgets('historical neutral and skipped labels remain visible', (
    tester,
  ) async {
    await tester.pumpWidget(
      nutritionTaskApp(
        nutritionTask(),
        existingRecall: recall([
          meal('other', MealType.other, foods: [food('tea', 'Tea', 5)]),
          meal(
            'skipped',
            MealType.other,
            label: 'Early breakfast',
            isSkipped: true,
          ),
        ]),
      ),
    );
    await tester.pump();

    expect(find.text('Meal'), findsOneWidget);
    expect(find.textContaining('Early breakfast'), findsOneWidget);
  });
}

class _OfflineDefinitionRepository() extends FakeNutritionFoodRepository {
  @override
  Future<void> ensureDefinitions({
    required String subjectId,
    required Iterable<FoodEntry> foods,
  }) async => throw const SocketException('offline');
}
