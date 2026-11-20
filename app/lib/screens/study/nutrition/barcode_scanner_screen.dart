import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/unified_food_result.dart';
import 'package:studyu_app/screens/study/nutrition/food_search/food_search_requests.dart';
import 'package:studyu_app/screens/study/nutrition/food_search/food_search_view_model.dart';
import 'package:studyu_app/screens/study/nutrition/open_food_facts_attribution.dart';
import 'package:studyu_app/services/usda_api_service.dart';
import 'package:studyu_core/core.dart' as studyu;

sealed class const BarcodeScanResult();

final class const BarcodeFoodFound(final UnifiedFoodResult food)
    extends BarcodeScanResult;

final class const BarcodeManualEntryRequested() extends BarcodeScanResult;

class const BarcodeScannerScreen({super.key}) extends StatefulWidget {
  static MaterialPageRoute<BarcodeScanResult> route() =>
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen());

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState() extends State<BarcodeScannerScreen> {
  static const _foodBarcodeFormats = [
    BarcodeFormat.ean8,
    BarcodeFormat.ean13,
    BarcodeFormat.upcA,
    BarcodeFormat.upcE,
    BarcodeFormat.itf14,
  ];

  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.unrestricted,
    formats: _foodBarcodeFormats,
  );

  bool _isProcessing = false;
  String? _lastScannedCode;
  DateTime? _lastScanTime;
  String? _detectedCode;
  String? _guidanceMessage;

  String? _productCode(Barcode barcode) {
    final code = barcode.rawValue;
    final length = switch (barcode.format) {
      BarcodeFormat.ean8 || BarcodeFormat.upcE => 8,
      BarcodeFormat.upcA => 12,
      BarcodeFormat.ean13 => 13,
      BarcodeFormat.itf14 => 14,
      _ => 0,
    };
    if (code == null ||
        length == 0 ||
        code.length != length ||
        code.contains(RegExp('[^0-9]')) ||
        RegExp(r'^(.)\1+$').hasMatch(code)) {
      return null;
    }
    return code;
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

    if (_isProcessing) return;

    final code = barcodes.map(_productCode).nonNulls.firstOrNull;
    if (code == null) {
      setState(() {
        _guidanceMessage = l10n.barcode_scanner_invalid;
      });
      return;
    }

    // Prevent duplicate scans within 2 seconds (reduced from 3 for faster scanning)
    final now = DateTime.now();
    if (_lastScannedCode == code &&
        _lastScanTime != null &&
        now.difference(_lastScanTime!).inSeconds < 2) {
      return;
    }

    setState(() {
      _guidanceMessage = l10n.barcode_scanner_lookup;
      _detectedCode = code;
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
        Navigator.pop(
          context,
          BarcodeFoodFound(openFoodFactsSearchResult(result.product!)),
        );
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

            Navigator.pop(
              context,
              BarcodeFoodFound(usdaFoodSearchResult(usdaFood)),
            );
            return;
          }
        } catch (usdaError) {
          // Continue to show "not found" dialog
        }
      }

      // Not found in either database
      if (mounted) {
        await _showProductNotFoundDialog(code);
      }
    } catch (e) {
      studyu.StudyULogger.error('Error fetching barcode product: $e');
      if (mounted) {
        await _showErrorDialog();
      }
    }
  }

  Future<void> _showProductNotFoundDialog(String barcode) {
    final l10n = AppLocalizations.of(context)!;
    return _showLookupDialog(
      title: l10n.barcode_scanner_not_found_title,
      message: l10n.barcode_scanner_not_found_message(barcode),
      retryLabel: l10n.barcode_scanner_scan_again,
      exitLabel: l10n.add_manually,
      exitResult: const BarcodeManualEntryRequested(),
    );
  }

  Future<void> _showErrorDialog() {
    final l10n = AppLocalizations.of(context)!;
    return _showLookupDialog(
      title: l10n.barcode_scanner_error_title,
      message: l10n.external_library_error,
      retryLabel: l10n.try_again,
      exitLabel: l10n.cancel,
    );
  }

  Future<void> _showLookupDialog({
    required String title,
    required String message,
    required String retryLabel,
    required String exitLabel,
    BarcodeScanResult? exitResult,
  }) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(retryLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(exitLabel),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (shouldExit == true) {
      Navigator.pop(context, exitResult);
      return;
    }
    setState(() {
      _isProcessing = false;
      _lastScannedCode = null;
      _lastScanTime = null;
    });
    try {
      await _controller.start();
    } catch (_) {
      // The controller can fail to restart.
    }
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
