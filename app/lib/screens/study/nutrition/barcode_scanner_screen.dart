import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/usda_models.dart';
import 'package:studyu_app/screens/study/nutrition/food_search/food_search_requests.dart';
import 'package:studyu_app/screens/study/nutrition/open_food_facts_attribution.dart';
import 'package:studyu_app/services/usda_api_service.dart';
import 'package:studyu_core/core.dart' as studyu;

class const BarcodeScannerScreen({super.key}) extends StatefulWidget {
  static MaterialPageRoute<studyu.FoodEntry> route() =>
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen());

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState() extends State<BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.unrestricted, // Fastest detection!
    // No format restrictions - detects ALL barcode types!
  );

  bool _isProcessing = false;
  String? _lastScannedCode;
  DateTime? _lastScanTime;
  String? _detectedCode;
  String? _guidanceMessage;

  bool _isValidBarcode(String code) {
    // Remove any non-digit characters
    final cleanCode = code.replaceAll(RegExp('[^0-9]'), '');

    // Valid barcodes are usually 8, 12, or 13 digits
    if (cleanCode.length < 8 || cleanCode.length > 13) {
      return false;
    }

    // Check if it's all zeros or all the same digit (usually invalid)
    if (RegExp(r'^(.)\1+$').hasMatch(cleanCode)) {
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onBarcodeDetected(BarcodeCapture capture) async {
    if (!mounted) return;
    final languageCode = Localizations.localeOf(context).languageCode;
    final List<Barcode> barcodes = capture.barcodes;
    final l10n = AppLocalizations.of(context)!;

    if (barcodes.isEmpty) {
      setState(() {
        _guidanceMessage = l10n.barcode_scanner_no_barcode;
      });
      return;
    }

    // Update guidance based on detection
    setState(() {
      _guidanceMessage = l10n.barcode_scanner_processing;
    });

    if (_isProcessing) {
      return;
    }

    final barcode = barcodes.first;
    final code = barcode.rawValue;

    if (code == null || code.isEmpty) {
      return;
    }

    // Validate barcode before processing
    if (!_isValidBarcode(code)) {
      setState(() {
        _guidanceMessage = l10n.barcode_scanner_invalid;
      });
      return;
    }

    setState(() {
      _guidanceMessage = l10n.barcode_scanner_lookup;
    });

    // Prevent duplicate scans within 2 seconds (reduced from 3 for faster scanning)
    final now = DateTime.now();
    if (_lastScannedCode == code &&
        _lastScanTime != null &&
        now.difference(_lastScanTime!).inSeconds < 2) {
      return;
    }

    // Show detected barcode prominently
    setState(() {
      _detectedCode = code;
    });

    setState(() {
      _isProcessing = true;
      _lastScannedCode = code;
      _lastScanTime = now;
    });

    // Stop scanner while processing
    try {
      await _controller.stop();
    } catch (e) {
      // Controller might already be stopped, ignore
    }

    if (!mounted) return;
    try {
      // Try OpenFoodFacts first.
      final result = await fetchOpenFoodFactsBarcode(
        code,
        languageCode: languageCode,
      );

      if (!mounted) return;

      if (result.status == ProductResultV3.statusSuccess &&
          result.product != null) {
        Navigator.pop(context, _convertToFoodEntry(result.product!));
        return;
      }

      // Not found in OpenFoodFacts, try USDA when configured.
      if (UsdaApiService.isConfigured) {
        try {
          final usdaResult = await UsdaApiService.searchByBarcode(code)
              .timeout(foodProviderTimeout);

          if (!mounted) return;

          if (usdaResult.foods.isNotEmpty) {
            final usdaFood = usdaResult.foods.first;

            Navigator.pop(context, _convertUsdaToFoodEntry(usdaFood));
            return;
          }
        } catch (usdaError) {
          // Continue to show "not found" dialog
        }
      }

      // Not found in either database
      if (mounted) {
        _showProductNotFoundDialog(code);
      }
    } catch (e) {
      studyu.StudyULogger.error('Error fetching barcode product: $e');
      if (mounted) {
        _showErrorDialog();
      }
    }
  }

  studyu.FoodEntry _convertToFoodEntry(Product product) {
    final nutriments = product.nutriments;

    // Extract nutrition info with fallbacks
    final energyKcal =
        nutriments?.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams) ?? 0;
    final protein =
        nutriments?.getValue(Nutrient.proteins, PerSize.oneHundredGrams) ?? 0;
    final carbs =
        nutriments?.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams) ??
        0;
    final fat =
        nutriments?.getValue(Nutrient.fat, PerSize.oneHundredGrams) ?? 0;
    final sugars =
        nutriments?.getValue(Nutrient.sugars, PerSize.oneHundredGrams) ?? 0;
    final fiber =
        nutriments?.getValue(Nutrient.fiber, PerSize.oneHundredGrams) ?? 0;
    final saturatedFat =
        nutriments?.getValue(Nutrient.saturatedFat, PerSize.oneHundredGrams) ??
        0;
    final sodium =
        (nutriments?.getValue(Nutrient.sodium, PerSize.oneHundredGrams) ?? 0) *
        1000;
    bool isUnavailable(Nutrient nutrient) =>
        nutriments?.getValue(nutrient, PerSize.oneHundredGrams) == null;
    final unavailableNutrients = {
      if (isUnavailable(Nutrient.energyKCal)) 'energyKcal',
      if (isUnavailable(Nutrient.proteins)) 'protein',
      if (isUnavailable(Nutrient.carbohydrates)) 'carbs',
      if (isUnavailable(Nutrient.fat)) 'fat',
    };

    // Parse serving size
    double servingSizeGrams = 100.0;
    if (product.servingSize != null) {
      final match = RegExp(r'(\d+(?:\.\d+)?)\s*g')
          .firstMatch(product.servingSize!);
      if (match != null) {
        servingSizeGrams = double.tryParse(match.group(1)!) ?? 100.0;
      }
    }

    return studyu.FoodEntry.withId(
      entryType: studyu.FoodEntryType.brandedProduct,
      name: product.productName ?? 'Unknown Product',
      brandName: product.brands,
      description: product.genericName,
      amount: 1,
      unit: 'serving',
      servingSizeGrams: servingSizeGrams,
      portionReference: product.servingSize,
      portionEstimationMethod: studyu.PortionEstimationMethod.standardUnit,
      portionState: studyu.PortionState.asServed,
      yieldFactor: 1.0,
      nutrition: studyu.NutritionProfile(
        energyKcal: energyKcal * servingSizeGrams / 100,
        protein: protein * servingSizeGrams / 100,
        carbs: carbs * servingSizeGrams / 100,
        fat: fat * servingSizeGrams / 100,
        sugars: sugars * servingSizeGrams / 100,
        fiber: fiber * servingSizeGrams / 100,
        saturatedFat: saturatedFat * servingSizeGrams / 100,
        transFat: 0,
        cholesterol: 0,
        sodium: sodium * servingSizeGrams / 100,
        waterContent: 0,
        micros: {},
        unavailableNutrients: unavailableNutrients,
      ),
      foodCode: product.barcode,
      externalId: product.barcode,
      source: studyu.FoodSource.openfoodfacts,
      confidenceScore: 1.0,
      originalValues: product.toJson(),
    );
  }

  studyu.FoodEntry _convertUsdaToFoodEntry(UsdaFoodItem food) {
    // USDA provides nutrients per 100g by default
    final servingSizeGrams = food.servingSize ?? 100.0;
    final servingSizeUnit = food.servingSizeUnit ?? 'g';

    // Scale nutrients to serving size
    final scale = servingSizeGrams / 100.0;

    return studyu.FoodEntry.withId(
      entryType: studyu.FoodEntryType.brandedProduct,
      name: food.description ?? 'Unknown Food',
      brandName: food.brandOwner ?? food.brandName,
      description: food.ingredients,
      amount: 1,
      unit: servingSizeUnit,
      servingSizeGrams: servingSizeGrams,
      portionReference: food.householdServingFullText,
      portionEstimationMethod: studyu.PortionEstimationMethod.standardUnit,
      portionState: studyu.PortionState.asServed,
      yieldFactor: 1.0,
      nutrition: studyu.NutritionProfile(
        energyKcal: (food.energyKcal100g * scale).roundToDouble(),
        protein: food.protein100g * scale,
        carbs: food.carbohydrates100g * scale,
        fat: food.fat100g * scale,
        sugars: food.sugars100g * scale,
        fiber: food.fiber100g * scale,
        saturatedFat: food.saturatedFat100g * scale,
        transFat: 0,
        cholesterol: 0,
        sodium: food.sodium100g * scale, // Already in mg
        waterContent: 0,
        micros: {},
        unavailableNutrients: {
          if (food.getNutrientValue(1008) == null) 'energyKcal',
          if (food.getNutrientValue(1003) == null) 'protein',
          if (food.getNutrientValue(1005) == null) 'carbs',
          if (food.getNutrientValue(1004) == null) 'fat',
        },
      ),
      foodCode: food.gtinUpc, // Barcode from USDA
      externalId: food.fdcId.toString(),
      source: studyu.FoodSource.usda,
      confidenceScore: 1.0,
      originalValues: food.toJson(),
    );
  }

  void _showProductNotFoundDialog(String barcode) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.search_off, color: Colors.orange),
            const SizedBox(width: 8),
            Text(l10n.barcode_scanner_not_found_title),
          ],
        ),
        content: Text(l10n.barcode_scanner_not_found_message(barcode)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isProcessing = false;
                _lastScannedCode = null;
                _lastScanTime = null;
              });
              try {
                _controller.start();
              } catch (e) {
                // Ignore restart errors
              }
            },
            child: Text(l10n.barcode_scanner_scan_again),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to previous screen
            },
            child: Text(l10n.add_manually),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Text(l10n.barcode_scanner_error_title),
          ],
        ),
        content: Text(l10n.external_library_error),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isProcessing = false;
                _lastScannedCode = null;
                _lastScanTime = null;
              });
              try {
                _controller.start();
              } catch (e) {
                // Ignore restart errors
              }
            },
            child: Text(l10n.try_again),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scan_barcode),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, child) {
                return Icon(
                  state.torchState == TorchState.on
                      ? Icons.flash_on
                      : Icons.flash_off,
                );
              },
            ),
            onPressed: () => _controller.toggleTorch(),
            tooltip: l10n.barcode_scanner_toggle_flash,
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => _controller.switchCamera(),
            tooltip: l10n.barcode_scanner_switch_camera,
          ),
        ],
      ),
      bottomNavigationBar: const SafeArea(
        top: false,
        child: OpenFoodFactsAttribution(),
      ),
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(controller: _controller, onDetect: _onBarcodeDetected),

          // Scanning overlay
          CustomPaint(painter: ScannerOverlayPainter(), child: Container()),

          // Instructions at the top
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _guidanceMessage ?? l10n.barcode_scanner_guidance_initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.barcode_scanner_distance_guidance,
                    style: const TextStyle(
                      color: Colors.yellowAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_detectedCode != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            l10n.barcode_scanner_detected,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _detectedCode!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Loading indicator
          if (_isProcessing)
            ColoredBox(
              color: Colors.black.withValues(alpha: 0.7),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      l10n.barcode_scanner_lookup_progress,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ScannerOverlayPainter() extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    // EXTRA LARGE scan area for both small and large barcodes!
    final scanAreaWidth = size.width * 0.92;
    final scanAreaHeight = size.height * 0.65;
    final scanAreaLeft = (size.width - scanAreaWidth) / 2;
    final scanAreaTop = (size.height - scanAreaHeight) / 2;

    // Draw semi-transparent overlay
    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Cut out the scan area
    final scanRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(scanAreaLeft, scanAreaTop, scanAreaWidth, scanAreaHeight),
      const Radius.circular(12),
    );
    path.addRRect(scanRect);
    path.fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw scan area border
    final borderPaint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(scanRect, borderPaint);

    // Draw corner indicators
    const cornerLength = 30.0;
    final cornerPaint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    // Top-left corner
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop),
      Offset(scanAreaLeft + cornerLength, scanAreaTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop),
      Offset(scanAreaLeft, scanAreaTop + cornerLength),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaWidth, scanAreaTop),
      Offset(scanAreaLeft + scanAreaWidth - cornerLength, scanAreaTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaWidth, scanAreaTop),
      Offset(scanAreaLeft + scanAreaWidth, scanAreaTop + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop + scanAreaHeight),
      Offset(scanAreaLeft + cornerLength, scanAreaTop + scanAreaHeight),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop + scanAreaHeight),
      Offset(scanAreaLeft, scanAreaTop + scanAreaHeight - cornerLength),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaWidth, scanAreaTop + scanAreaHeight),
      Offset(
        scanAreaLeft + scanAreaWidth - cornerLength,
        scanAreaTop + scanAreaHeight,
      ),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaWidth, scanAreaTop + scanAreaHeight),
      Offset(
        scanAreaLeft + scanAreaWidth,
        scanAreaTop + scanAreaHeight - cornerLength,
      ),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
