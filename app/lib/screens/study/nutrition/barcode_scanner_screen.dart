import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:studyu_app/models/usda_models.dart';
import 'package:studyu_app/screens/study/nutrition/food_entry_screen.dart';
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
  String _guidanceMessage = 'Point camera at barcode';

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
  void initState() {
    super.initState();
    // Configure OpenFoodFacts User-Agent
    OpenFoodAPIConfiguration.userAgent = UserAgent(
      name: 'StudyU',
      version: '1.0',
      system: 'Flutter',
      url: 'https://studyu.health',
    );
    OpenFoodAPIConfiguration.globalLanguages = [OpenFoodFactsLanguage.ENGLISH];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onBarcodeDetected(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;

    if (barcodes.isEmpty) {
      setState(() {
        _guidanceMessage = 'No barcode detected - adjust position';
      });
      return;
    }

    // Update guidance based on detection
    setState(() {
      _guidanceMessage = 'Barcode detected! Processing...';
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
        _guidanceMessage = 'Invalid barcode - try different angle';
      });
      return;
    }

    setState(() {
      _guidanceMessage = '✓ Valid barcode! Looking up...';
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

    try {
      // Try OpenFoodFacts first
      final productConfig = ProductQueryConfiguration(
        code,
        language: OpenFoodFactsLanguage.ENGLISH,
        fields: [
          ProductField.NAME,
          ProductField.BRANDS,
          ProductField.BARCODE,
          ProductField.NUTRIMENTS,
          ProductField.SERVING_SIZE,
          ProductField.QUANTITY,
          ProductField.IMAGE_FRONT_SMALL_URL,
        ],
        version: ProductQueryVersion.v3,
      );

      final result = await OpenFoodAPIClient.getProductV3(productConfig);

      if (!mounted) return;

      if (result.status == ProductResultV3.statusSuccess &&
          result.product != null) {
        // Product found in OpenFoodFacts!
        final foodEntry = _convertToFoodEntry(result.product!);

        // Navigate to food entry screen for editing
        final editedFood = await Navigator.push(
          context,
          FoodEntryScreen.route(existingFood: foodEntry),
        );

        if (editedFood != null && mounted) {
          // Return the food entry
          Navigator.pop(context, editedFood);
        } else {
          // User cancelled, resume scanning
          if (mounted) {
            setState(() {
              _isProcessing = false;
              _lastScannedCode = null;
              _lastScanTime = null;
              _detectedCode = null;
            });
            try {
              await _controller.start();
            } catch (e) {
              // Ignore restart errors
            }
          }
        }
        return; // Success, exit early
      }

      // Not found in OpenFoodFacts, try USDA

      try {
        final usdaResult = await UsdaApiService.searchByBarcode(code);

        if (!mounted) return;

        if (usdaResult.foods.isNotEmpty) {
          final usdaFood = usdaResult.foods.first;

          // Product found in USDA!
          final foodEntry = _convertUsdaToFoodEntry(usdaFood);

          // Navigate to food entry screen for editing
          final editedFood = await Navigator.push(
            context,
            FoodEntryScreen.route(existingFood: foodEntry),
          );

          if (editedFood != null && mounted) {
            // Return the food entry
            Navigator.pop(context, editedFood);
          } else {
            // User cancelled, resume scanning
            if (mounted) {
              setState(() {
                _isProcessing = false;
                _lastScannedCode = null;
                _lastScanTime = null;
                _detectedCode = null;
              });
              try {
                await _controller.start();
              } catch (e) {
                // Ignore restart errors
              }
            }
          }
          return; // Success, exit early
        }
      } catch (usdaError) {
        // Continue to show "not found" dialog
      }

      // Not found in either database
      if (mounted) {
        _showProductNotFoundDialog(code);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error fetching product: $e');
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
        energyKcal: energyKcal,
        protein: protein,
        carbs: carbs,
        fat: fat,
        sugars: sugars,
        fiber: fiber,
        saturatedFat: saturatedFat,
        transFat: 0,
        cholesterol: 0,
        sodium: sodium,
        waterContent: 0,
        micros: {},
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
      ),
      foodCode: food.gtinUpc, // Barcode from USDA
      externalId: food.fdcId.toString(),
      source: studyu.FoodSource.usda,
      confidenceScore: 1.0,
      originalValues: {
        'fdcId': food.fdcId,
        'dataType': food.dataType,
        'description': food.description,
      },
    );
  }

  void _showProductNotFoundDialog(String barcode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.search_off, color: Colors.orange),
            SizedBox(width: 8),
            Text('Product Not Found'),
          ],
        ),
        content: Text(
          'No product found for barcode: $barcode\n\n'
          'This product might not be in the OpenFoodFacts or USDA database yet. '
          "We searched both databases but couldn't find a match. "
          'You can add it manually or try scanning another product.',
        ),
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
            child: const Text('Scan Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to previous screen
            },
            child: const Text('Add Manually'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(message),
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
            child: const Text('Try Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
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
            tooltip: 'Toggle Flash',
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => _controller.switchCamera(),
            tooltip: 'Switch Camera',
          ),
        ],
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
                    _guidanceMessage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '📦 Large barcode? Move back 15-30cm\n📏 Small barcode? Move closer',
                    style: TextStyle(
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
                          const Text(
                            '✓ DETECTED',
                            style: TextStyle(
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
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Looking up product...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
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
