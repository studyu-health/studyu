import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:web/web.dart' as web;

class QrCodeDownloader._() {
  /// Generates a QR code widget for display in the UI
  static Future<Widget> generateQrWidget({
    required String data,
    double size = 200,
  }) async {
    final qrCode = QrCode.fromData(
      data: data,
      errorCorrectLevel: QrErrorCorrectLevel.H,
    );

    final logoBytes = await rootBundle.load('assets/icon/icon.png');
    final logoData = logoBytes.buffer.asUint8List();

    return SizedBox(
      width: size,
      height: size,
      child: PrettyQrView(
        qrImage: QrImage(qrCode),
        decoration: _getDefaultDecoration(logoData),
      ),
    );
  }

  /// Downloads a QR code as a PNG file
  static Future<void> downloadQrCode({
    required String data,
    required String filename,
    int size = 512,
  }) async {
    final qrCode = QrCode.fromData(
      data: data,
      errorCorrectLevel: QrErrorCorrectLevel.H,
    );

    final qrImage = QrImage(qrCode);

    final logoBytes = await rootBundle.load('assets/icon/icon.png');
    final logoData = logoBytes.buffer.asUint8List();

    final qrImageBytes = await qrImage.toImageAsBytes(
      size: size,
      decoration: _getDefaultDecoration(logoData),
    );

    if (qrImageBytes == null) {
      throw Exception('Failed to generate QR code image');
    }

    final blob = web.Blob(
      [qrImageBytes.buffer.asUint8List().toJS].toJS,
      web.BlobPropertyBag(type: 'image/png'),
    );
    final url = web.URL.createObjectURL(blob);
    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = '$filename.png';
    anchor.click();
    web.URL.revokeObjectURL(url);
  }

  /// Returns default QR decoration with logo overlay
  /// Uses standard black-on-white style for maximum scanning compatibility
  static PrettyQrDecoration _getDefaultDecoration(Uint8List logoData) {
    return PrettyQrDecoration(
      background: Colors.white,
      image: PrettyQrDecorationImage(image: MemoryImage(logoData)),
      // ignore: experimental_member_use
      shape: const PrettyQrShape.custom(
        PrettyQrSquaresSymbol(),
        finderPattern: PrettyQrSmoothSymbol(),
        alignmentPatterns: PrettyQrDotsSymbol(),
      ),
    );
  }
}
