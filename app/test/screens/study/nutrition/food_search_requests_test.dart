import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/nutrition/barcode_scanner_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
import 'package:studyu_app/screens/study/nutrition/food_library.dart';
import 'package:studyu_app/screens/study/nutrition/food_search/food_search_requests.dart';
import 'package:studyu_app/screens/study/nutrition/food_search_screen.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_food_repository.dart';
import 'package:studyu_app/screens/study/nutrition/template_view_model.dart';
import 'package:studyu_app/services/usda_api_service.dart';
import 'package:studyu_core/core.dart' as studyu;

void main() {
  late _FoodFactsHttpHelper transport;
  setUp(() {
    final original = HttpHelper.instance;
    final originalAgent = OpenFoodAPIConfiguration.userAgent;
    transport = _FoodFactsHttpHelper();
    HttpHelper.instance = transport;
    OpenFoodAPIConfiguration.userAgent = UserAgent(name: 'search-test');
    addTearDown(() {
      HttpHelper.instance = original;
      OpenFoodAPIConfiguration.userAgent = originalAgent;
    });
  });

  for (final code in ['de', 'en', 'unsupported']) {
    test('text and barcode requests use $code with English fallback', () async {
      final model = FoodSearchViewModel(
        languageCode: code,
        usdaConfigured: false,
      );
      addTearDown(model.dispose);
      await model.retry('apple');
      final barcode = await fetchOpenFoodFactsBarcode(
        '0123456789012',
        languageCode: code,
      );
      expect(transport.requests, hasLength(2));
      expect(transport.requests.first['api_version'], '3.5');
      expect(transport.paths.last, '/api/v3.5/product/0123456789012');
      for (final request in transport.requests) {
        expect(request['lc'], code == 'de' ? 'de,en' : 'en');
        expect(request['tags_lc'], code == 'de' ? 'de' : 'en');
        final fields = request['fields']!.split(',');
        expect(
          fields,
          containsAll(['product_name', 'product_name_en', 'nutrition']),
        );
        expect(fields, isNot(contains('nutriments')));
        if (code == 'de') expect(fields, contains('product_name_de'));
      }
      final name = code == 'de' ? 'Apfel' : 'Apple';
      expect(model.results.single.name, name);
      expect(convertFoodResultToFoodEntry(model.results.single).name, name);
      expect(barcode.product!.productName, name);
    });
  }

  test(
    'absent or empty localized name uses English without another request',
    () async {
      transport.product = {
        'code': '0123456789012',
        'product_name': 'Default',
        'product_name_de': '',
        'product_name_en': 'Apple',
      };
      final model = FoodSearchViewModel(
        languageCode: 'de',
        usdaConfigured: false,
      );
      addTearDown(model.dispose);
      await model.retry('apple');
      final barcode = await fetchOpenFoodFactsBarcode(
        '0123456789012',
        languageCode: 'de',
      );
      expect(model.results.single.name, 'Apple');
      expect(convertFoodResultToFoodEntry(model.results.single).name, 'Apple');
      expect(barcode.product!.productName, 'Apple');
      expect(transport.requests, hasLength(2));
      transport.product = {'code': '0123456789012', 'product_name_en': 'Apple'};
      await model.retry('apple');
      final absentName = await fetchOpenFoodFactsBarcode(
        '0123456789012',
        languageCode: 'de',
      );
      expect(model.results.single.name, 'Apple');
      expect(absentName.product!.productName, 'Apple');
      expect(transport.requests, hasLength(4));
      transport.product = {'code': '0123456789012', 'product_name': 'Default'};
      await model.retry('apple');
      expect(model.results.single.name, 'Default');
    },
  );

  testWidgets('locale change invalidates pending request and uses new locale', (
    tester,
  ) async {
    final pending = Completer<http.Response>();
    transport.pending = pending.future;
    final model = FoodSearchViewModel(usdaConfigured: false);
    addTearDown(model.dispose);
    unawaited(model.retry('apple'));
    await tester.pump();
    transport.pending = null;
    model.setLanguageCode('de');
    await tester.pump(const Duration(milliseconds: 400));
    expect(transport.requests.map((request) => request['lc']), ['en', 'de,en']);
    expect(model.results.single.name, 'Apfel');
    pending.complete(
      http.Response(
        jsonEncode({
          'products': [
            {'product_name': 'Stale'},
          ],
        }),
        200,
      ),
    );
    await tester.pump();
    expect(model.results.single.name, 'Apfel');
    expect(model.hasError, isFalse);
  });

  for (final library in [false, true]) {
    testWidgets(
      '${library ? 'FoodLibrary' : 'FoodSearchScreen'} supplies UI locale',
      (tester) async {
        final templates = TemplateViewModel(
          userId: 'test',
          repository: _EmptyRepository(),
        );
        final appState = AppState();
        addTearDown(templates.dispose);
        addTearDown(appState.dispose);
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: templates),
              ChangeNotifierProvider.value(value: appState),
            ],
            child: _app(
              locale: const Locale('de'),
              home: library
                  ? const Scaffold(
                      body: FoodLibrary(includeExternalLibrary: true),
                    )
                  : FoodSearchScreen(templateViewModel: templates),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).first, 'apple');
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle();
        expect(transport.requests.single['lc'], 'de,en');
        expect(find.text('Apfel'), findsOneWidget);
      },
    );
  }

  testWidgets(
    'My items filter rejects pending external results and restarts on All',
    (tester) async {
      final templates = TemplateViewModel(
        userId: 'test',
        repository: _EmptyRepository(),
      );
      final appState = AppState();
      addTearDown(templates.dispose);
      addTearDown(appState.dispose);
      final pending = Completer<http.Response>();
      transport.pending = pending.future;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: templates),
            ChangeNotifierProvider.value(value: appState),
          ],
          child: _app(home: FoodSearchScreen(templateViewModel: templates)),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'apple');
      await tester.pump(const Duration(milliseconds: 400));
      final l10n = lookupAppLocalizations(const Locale('en'));
      await tester.tap(find.widgetWithText(FilterChip, l10n.my_saved_items));
      await tester.pump();
      pending.complete(
        http.Response(
          jsonEncode({
            'products': [transport.product],
          }),
          200,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Apple'), findsNothing);
      expect(find.text(l10n.no_results_for_query('apple')), findsWidgets);
      expect(find.text(l10n.cant_find_it).hitTestable(), findsOneWidget);
      transport.pending = null;
      await tester.tap(find.widgetWithText(FilterChip, l10n.filter_all));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(transport.requests, hasLength(2));
      expect(find.text('Apple'), findsOneWidget);
    },
  );

  for (final failures in [1, 3]) {
    testWidgets('search handles $failures HTTP 503 responses', (tester) async {
      transport.unavailableResponses = failures;
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AppState(),
          child: _app(home: FoodSearchScreen(repository: _EmptyRepository())),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'apple');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();

      final l10n = lookupAppLocalizations(const Locale('en'));
      expect(find.text(l10n.no_results_for_query('apple')), findsNothing);
      expect(find.text(l10n.cant_find_it), findsNothing);
      expect(find.text(l10n.try_again), findsNothing);
      expect(transport.requests, hasLength(1));

      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
      if (failures == 3) {
        expect(find.text(l10n.no_results_for_query('apple')), findsNothing);
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
        expect(transport.requests, hasLength(3));
        expect(find.text(l10n.no_results_for_query('apple')), findsNothing);
        expect(find.text(l10n.food_search_error), findsOneWidget);
        expect(find.text(l10n.cant_find_it), findsNothing);
        await tester.tap(find.text(l10n.try_again));
      }
      await tester.pumpAndSettle();
      expect(find.text('Apple'), findsOneWidget);
      expect(transport.requests, hasLength(failures + 1));
    });
  }

  testWidgets('scanner ignores QR codes and nonnumeric product codes', (
    tester,
  ) async {
    final original = MobileScannerPlatform.instance;
    MobileScannerPlatform.instance = _ScannerPlatform();
    addTearDown(() => MobileScannerPlatform.instance = original);
    await tester.pumpWidget(_app(home: const BarcodeScannerScreen()));
    await tester.pumpAndSettle();

    tester.widget<MobileScanner>(find.byType(MobileScanner)).onDetect!(
      const BarcodeCapture(
        barcodes: [
          Barcode(format: BarcodeFormat.qrCode, rawValue: '0123456789012'),
          Barcode(format: BarcodeFormat.ean13, rawValue: 'A123456789012'),
        ],
      ),
    );
    await tester.pump();

    expect(transport.requests, isEmpty);
  });

  for (final library in [false, true]) {
    testWidgets(
      'barcode manual action opens the food editor (library: $library)',
      (tester) async {
        final original = MobileScannerPlatform.instance;
        MobileScannerPlatform.instance = _ScannerPlatform();
        addTearDown(() => MobileScannerPlatform.instance = original);
        transport.product = {};
        final templates = TemplateViewModel(
          userId: 'subject',
          repository: _EmptyRepository(),
        );
        addTearDown(templates.dispose);
        final l10n = lookupAppLocalizations(const Locale('en'));

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => AppState()),
              ChangeNotifierProvider.value(value: templates),
            ],
            child: _app(
              home: library
                  ? const Scaffold(
                      body: FoodLibrary(includeExternalLibrary: true),
                    )
                  : const FoodSearchScreen(mealLabel: 'Dinner'),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip(l10n.scan_barcode));
        await tester.pumpAndSettle();
        await http.runWithClient(
          () async {
            tester.widget<MobileScanner>(find.byType(MobileScanner)).onDetect!(
              const BarcodeCapture(
                barcodes: [
                  Barcode(
                    format: BarcodeFormat.ean13,
                    rawValue: '0123456789012',
                  ),
                ],
              ),
            );
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 300));
          },
          () => MockClient(
            (_) async => http.Response(
              '{"totalHits":0,"currentPage":1,"totalPages":0,"foods":[]}',
              200,
            ),
          ),
        );

        await tester.tap(find.text(l10n.add_manually));
        await tester.pumpAndSettle();
        expect(find.byType(FoodEntryScreen), findsOneWidget);
        expect(find.byType(BarcodeScannerScreen), findsNothing);
        expect(
          tester
              .widget<FoodEntryScreen>(find.byType(FoodEntryScreen))
              .mealLabel,
          library ? isNull : 'Dinner',
        );
      },
    );
  }

  for (final (per, serving, grams, calories, portion) in [
    ('100g', '50 g', 50.0, 62.5, '50 g'),
    ('100g', '1 cup (200 mL)', 100.0, 125.0, null),
    ('100ml', '1 cup (200 mL)', 0.0, 250.0, '1 cup (200 mL)'),
  ]) {
    testWidgets(
      'barcode retains its nutrition basis across selection ($per, $serving)',
      (tester) async {
        final original = MobileScannerPlatform.instance;
        MobileScannerPlatform.instance = _ScannerPlatform();
        addTearDown(() => MobileScannerPlatform.instance = original);
        transport.product = {
          'code': '0123456789012',
          'product_name_en': 'Test drink',
          'serving_size': serving,
          'nutrition': {
            'aggregated_set': {
              'preparation': 'as_sold',
              'per': per,
              'nutrients': {
                'energy-kcal': {'unit': 'kcal', 'value': 125},
              },
            },
          },
        };
        final l10n = lookupAppLocalizations(const Locale('en'));
        var foods = <studyu.FoodEntry>[];
        await tester.pumpWidget(
          ChangeNotifierProvider(
            create: (_) => AppState(),
            child: _app(
              home: Builder(
                builder: (context) => Scaffold(
                  body: TextButton(
                    onPressed: () async {
                      final selection = await FoodSearchScreen.show(
                        context,
                        mealLabel: 'Meal',
                        initialFoods: foods,
                        repository: _EmptyRepository(),
                      );
                      if (selection != null) {
                        foods = selection.foods
                            .map(
                              (food) =>
                                  studyu.FoodEntry.fromJson(food.toJson()),
                            )
                            .toList();
                      }
                    },
                    child: const Text('Open search'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Open search'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip(l10n.scan_barcode));
        await tester.pumpAndSettle();

        tester.widget<MobileScanner>(find.byType(MobileScanner)).onDetect!(
          const BarcodeCapture(
            barcodes: [
              Barcode(format: BarcodeFormat.ean13, rawValue: '0123456789012'),
            ],
          ),
        );
        await tester.pumpAndSettle();

        final metadata = grams > 0
            ? '${grams.toInt()} g · ${calories.round()} kcal'
            : '$portion · ${calories.round()} kcal';
        expect(find.text('Test drink'), findsOneWidget);
        expect(find.text(metadata), findsOneWidget);

        await tester.tap(
          find.widgetWithText(FilledButton, 'Add 1 item to entry'),
        );
        await tester.pumpAndSettle();
        expect(foods.single.servingSizeGrams, grams);
        expect(foods.single.portionReference, portion);
        expect(foods.single.nutrition.energyKcal, calories);

        await tester.tap(find.text('Open search'));
        await tester.pumpAndSettle();
        expect(find.text(metadata), findsOneWidget);
      },
    );
  }

  testWidgets('barcode timeout uses neutral error and ignores late success', (
    tester,
  ) async {
    final platform = _ScannerPlatform();
    final original = MobileScannerPlatform.instance;
    MobileScannerPlatform.instance = platform;
    addTearDown(() => MobileScannerPlatform.instance = original);
    final pending = Completer<http.Response>();
    transport.pending = pending.future;
    await tester.pumpWidget(
      _app(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () =>
                  Navigator.push(context, BarcodeScannerScreen.route()),
              child: const Text('Open scanner'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open scanner'));
    await tester.pumpAndSettle();
    final scanner = tester.widget<MobileScanner>(find.byType(MobileScanner));
    const capture = BarcodeCapture(
      barcodes: [
        Barcode(format: BarcodeFormat.ean13, rawValue: '0123456789012'),
      ],
    );
    scanner.onDetect!(capture);
    await tester.pump();
    expect(transport.requests, hasLength(1));
    await tester.pump(const Duration(seconds: 9));
    expect(find.byType(AlertDialog), findsNothing);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 300));
    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(find.text(l10n.external_library_error), findsOneWidget);
    pending.complete(
      http.Response(
        jsonEncode({'status': 'success', 'product': transport.product}),
        200,
      ),
    );
    await tester.pump();
    expect(find.byType(BarcodeScannerScreen), findsOneWidget);
    expect(find.text(l10n.external_library_error), findsOneWidget);

    await tester.tapAt(const Offset(4, 4));
    await tester.pump();
    expect(find.text(l10n.external_library_error), findsOneWidget);

    await tester.tap(find.text(l10n.try_again));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(AlertDialog), findsNothing);

    transport.pending = Completer<http.Response>().future;
    scanner.onDetect!(capture);
    await tester.pump();
    expect(transport.requests, hasLength(2));
    await tester.pump(const Duration(seconds: 10));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text(l10n.cancel));
    await tester.pumpAndSettle();
    expect(find.byType(BarcodeScannerScreen), findsNothing);
    expect(find.text('Open scanner'), findsOneWidget);
  });

  testWidgets(
    'USDA barcode timeout keeps scan-again behavior and ignores late success',
    (tester) async {
      final original = MobileScannerPlatform.instance;
      MobileScannerPlatform.instance = _ScannerPlatform();
      addTearDown(() => MobileScannerPlatform.instance = original);
      transport.product = {};
      final pending = Completer<http.Response>();
      var usdaRequests = 0;
      Uri? usdaRequest;
      await http.runWithClient(
        () async {
          await tester.pumpWidget(_app(home: const BarcodeScannerScreen()));
          await tester.pumpAndSettle();
          tester.widget<MobileScanner>(find.byType(MobileScanner)).onDetect!(
            const BarcodeCapture(
              barcodes: [
                Barcode(format: BarcodeFormat.ean13, rawValue: '0123456789012'),
              ],
            ),
          );
          await tester.pump();
          expect(usdaRequests, 1);
          expect(usdaRequest!.queryParameters['query'], '0123456789012');
          await tester.pump(const Duration(seconds: 9));
          expect(find.byType(AlertDialog), findsNothing);
          await tester.pump(const Duration(seconds: 1));
          await tester.pump(const Duration(milliseconds: 300));
          final l10n = lookupAppLocalizations(const Locale('en'));
          expect(
            find.text(l10n.barcode_scanner_not_found_title),
            findsOneWidget,
          );
          pending.complete(
            http.Response(
              jsonEncode({
                'totalHits': 1,
                'currentPage': 1,
                'totalPages': 1,
                'foods': [
                  {
                    'fdcId': 1,
                    'description': 'Late Apple',
                    'gtinUpc': '0123456789012',
                  },
                ],
              }),
              200,
            ),
          );
          await tester.pump();
          expect(
            find.text(l10n.barcode_scanner_not_found_title),
            findsOneWidget,
          );
          await tester.tap(find.text(l10n.barcode_scanner_scan_again));
          await tester.pumpAndSettle();
          expect(find.byType(AlertDialog), findsNothing);
          expect(find.byType(BarcodeScannerScreen), findsOneWidget);
        },
        () => MockClient((request) {
          usdaRequests++;
          usdaRequest = request.url;
          return pending.future;
        }),
      );
    },
    skip: !UsdaApiService.isConfigured,
  );

  testWidgets(
    'disposed barcode scanner ignores pending success and further detection',
    (tester) async {
      final platform = _ScannerPlatform();
      final original = MobileScannerPlatform.instance;
      MobileScannerPlatform.instance = platform;
      addTearDown(() => MobileScannerPlatform.instance = original);
      final pending = Completer<http.Response>();
      transport.pending = pending.future;
      await tester.pumpWidget(
        _app(locale: const Locale('de'), home: const BarcodeScannerScreen()),
      );
      await tester.pumpAndSettle();
      final scanner = tester.widget<MobileScanner>(find.byType(MobileScanner));
      const capture = BarcodeCapture(
        barcodes: [
          Barcode(format: BarcodeFormat.ean13, rawValue: '0123456789012'),
        ],
      );
      scanner.onDetect!(capture);
      await tester.pump();
      expect(transport.requests.single['lc'], 'de,en');
      await tester.pumpWidget(_app(home: const Text('Replacement')));
      pending.complete(
        http.Response(
          jsonEncode({'status': 'success', 'product': transport.product}),
          200,
        ),
      );
      scanner.onDetect!(capture);
      await tester.pumpAndSettle();
      expect(find.text('Replacement'), findsOneWidget);
      expect(transport.requests, hasLength(1));
      expect(tester.takeException(), isNull);
    },
  );
}

Widget _app({required Widget home, Locale locale = const Locale('en')}) =>
    MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: locale,
      home: home,
    );

class _EmptyRepository() extends NutritionFoodRepository {
  @override
  Future<List<studyu.SavedFoodTemplate>> loadTemplates(
    String subjectId,
  ) async => [];
}

class _FoodFactsHttpHelper() extends HttpHelper {
  this : super.internal();
  final List<Map<String, String>> requests = [];
  final List<String> paths = [];
  int unavailableResponses = 0;
  Future<http.Response>? pending;
  Map<String, dynamic> product = {
    'code': '0123456789012',
    'product_name': 'Default',
    'product_name_de': 'Apfel',
    'product_name_en': 'Apple',
  };

  Future<http.Response> respond(Uri uri, Map<String, String> parameters) {
    requests.add(Map.of(parameters));
    paths.add(uri.path);
    if (unavailableResponses > 0) {
      unavailableResponses--;
      return Future.value(http.Response('', 503));
    }
    return pending ??
        Future.value(
          http.Response(
            jsonEncode(
              uri.path.contains('/product/')
                  ? {
                      'status': product.isEmpty ? 'failure' : 'success',
                      'product': product.isEmpty ? null : product,
                    }
                  : {
                      'products': [product],
                    },
            ),
            200,
          ),
        );
  }

  @override
  Future<http.Response> doGetRequest(
    Uri uri, {
    User? user,
    required UriHelper uriHelper,
    String? bearerToken,
    bool addCookiesToHeader = false,
    bool addCredentialsToHeader = false,
  }) => respond(uri, uri.queryParameters);

  @override
  Future<http.Response> doPostRequest(
    Uri uri,
    Map<String, String> body,
    User? user, {
    required UriHelper uriHelper,
    required bool addCredentialsToBody,
    bool addCredentialsToHeader = false,
  }) => respond(uri, body);
}

class _ScannerPlatform() extends MobileScannerPlatform {
  @override
  Stream<BarcodeCapture?> get barcodesStream => const Stream.empty();
  @override
  Stream<TorchState> get torchStateStream => const Stream.empty();
  @override
  Stream<double> get zoomScaleStateStream => const Stream.empty();
  @override
  Widget buildCameraView() => const SizedBox.shrink();
  @override
  Future<MobileScannerViewAttributes> start(StartOptions options) async =>
      const MobileScannerViewAttributes(
        cameraDirection: CameraFacing.back,
        currentTorchMode: TorchState.off,
        size: Size(640, 480),
      );
  @override
  Future<void> stop() async {}
  @override
  Future<void> dispose() async {}
  @override
  Future<void> updateScanWindow(Rect? window) async {}
}
