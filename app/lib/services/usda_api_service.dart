import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:studyu_app/models/usda_models.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

/// Service for interacting with USDA FoodData Central API
/// Documentation: https://fdc.nal.usda.gov/api-guide.html
class UsdaApiService() {
  static const String _baseUrl = 'https://api.nal.usda.gov/fdc/v1';

  /// Get USDA API key from environment
  static String? get _apiKey {
    // Try to get from environment file first
    final envKey = getEnv('USDA_API_KEY', optional: true);
    if (envKey != null && envKey.isNotEmpty) {
      return envKey;
    }
    // Fallback to dart-define
    try {
      const dartDefineKey = String.fromEnvironment('USDA_API_KEY');
      if (dartDefineKey.isNotEmpty) {
        return dartDefineKey;
      }
    } catch (e) {
      // Ignore
    }
    return null;
  }

  /// Search for foods in USDA database by barcode/GTIN
  ///
  /// [barcode] - Barcode/GTIN/UPC code (e.g., "041303016022")
  ///
  /// Returns a list of food items matching the barcode
  static Future<UsdaSearchResponse> searchByBarcode(String barcode) async {
    final apiKey = _apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
        'USDA API key not configured. Please set USDA_API_KEY in environment.',
      );
    }

    // USDA API supports searching by GTIN/UPC
    final url = Uri.parse('$_baseUrl/foods/search').replace(
      queryParameters: {
        'api_key': apiKey,
        'query': barcode,
        'pageSize': '10',
        'dataType': 'Foundation,SR Legacy,Branded', // Include Branded products for barcodes
      },
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final searchResponse = UsdaSearchResponse.fromJson(jsonData);

        // Filter to exact barcode matches
        final exactMatches = searchResponse.foods.where((food) {
          return food.gtinUpc != null &&
              food.gtinUpc!.replaceAll(RegExp('[^0-9]'), '') ==
                  barcode.replaceAll(RegExp('[^0-9]'), '');
        }).toList();

        return UsdaSearchResponse(
          totalHits: exactMatches.length,
          currentPage: 1,
          totalPages: 1,
          foods: exactMatches,
        );
      } else if (response.statusCode == 403) {
        throw Exception(
          'USDA API key is invalid or expired. Please check your API key.',
        );
      } else if (response.statusCode == 429) {
        throw Exception(
          'USDA API rate limit exceeded. Please try again later.',
        );
      } else {
        throw Exception(
          'USDA API error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to search USDA database by barcode: $e');
    }
  }

  /// Search for foods in USDA database
  ///
  /// [query] - Search term (e.g., "apple", "chicken breast")
  /// [pageSize] - Number of results per page (default: 50, max: 200)
  /// [pageNumber] - Page number (default: 1)
  ///
  /// Returns a list of food items matching the search query
  static Future<UsdaSearchResponse> searchFoods({
    required String query,
    int pageSize = 50,
    int pageNumber = 1,
  }) async {
    final apiKey = _apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
        'USDA API key not configured. Please set USDA_API_KEY in environment.',
      );
    }

    final url = Uri.parse('$_baseUrl/foods/search').replace(
      queryParameters: {
        'api_key': apiKey,
        'query': query,
        'pageSize': pageSize.toString(),
        'pageNumber': pageNumber.toString(),
        'dataType': 'Foundation,SR Legacy', // Foundation foods + Standard Reference Legacy
      },
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return UsdaSearchResponse.fromJson(jsonData);
      } else if (response.statusCode == 403) {
        throw Exception(
          'USDA API key is invalid or expired. Please check your API key.',
        );
      } else if (response.statusCode == 429) {
        throw Exception(
          'USDA API rate limit exceeded. Please try again later.',
        );
      } else {
        throw Exception(
          'USDA API error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to search USDA database: $e');
    }
  }

  /// Get detailed food information by FDC ID
  ///
  /// [fdcId] - FoodData Central ID
  /// [nutrients] - Optional list of nutrient IDs to include (default: all)
  static Future<UsdaFoodItem> getFoodDetails(
    int fdcId, {
    List<int>? nutrients,
  }) async {
    final apiKey = _apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
        'USDA API key not configured. Please set USDA_API_KEY in environment.',
      );
    }

    final url = Uri.parse('$_baseUrl/food/$fdcId').replace(
      queryParameters: {
        'api_key': apiKey,
        if (nutrients != null && nutrients.isNotEmpty)
          'nutrients': nutrients.join(','),
      },
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return UsdaFoodItem.fromJson(jsonData);
      } else if (response.statusCode == 403) {
        throw Exception('USDA API key is invalid or expired.');
      } else if (response.statusCode == 404) {
        throw Exception('Food not found in USDA database.');
      } else {
        throw Exception(
          'USDA API error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to fetch food details: $e');
    }
  }
}
