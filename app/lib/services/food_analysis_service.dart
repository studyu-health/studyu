import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:studyu_core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Result of a food image analysis containing detected food items.
class const FoodAnalysisResult({
  /// List of detected food items.
  required final List<AnalyzedFoodItem> items,

  /// Overall confidence score (0.0 to 1.0) for the analysis.
  required final double overallConfidence,

  /// Optional notes about the analysis (e.g., "appears to be homemade").
  final String? notes,

  /// Whether the analysis was successful.
  required final bool success,

  /// Error message if analysis failed.
  final String? errorMessage,
}) {
  /// Creates a new [FoodAnalysisResult].
  this;

  /// Creates a failed result with the given error message.
  factory failure(String errorMessage) {
    return FoodAnalysisResult(
      items: const [],
      overallConfidence: 0,
      success: false,
      errorMessage: errorMessage,
    );
  }
}

/// A single food item detected in an image analysis.
class const AnalyzedFoodItem({
  /// The food entry with estimated nutrition data.
  required final FoodEntry foodEntry,

  /// Confidence score (0.0 to 1.0) for this specific item.
  required final double confidenceScore,
}) {
  /// Creates a new [AnalyzedFoodItem].
  this;
}

/// Service for analyzing food images using LLM via Supabase Edge Function.
class FoodAnalysisService() {
  /// Analyzes a food image and returns detected food items with estimated
  /// nutrition data.
  ///
  /// [imageBytes] - The image data as bytes (JPEG or PNG).
  /// [mealTime] - Optional meal time for context.
  /// [mealType] - Optional meal type for context.
  ///
  /// Returns a [FoodAnalysisResult] containing the detected items or an error.
  static Future<FoodAnalysisResult> analyzeImage({
    required Uint8List imageBytes,
    DateTime? mealTime,
    MealType? mealType,
  }) async {
    try {
      // Get Supabase client
      SupabaseClient supabase;
      try {
        supabase = Supabase.instance.client;
      } catch (e) {
        developer.log(
          'Supabase not initialized',
          name: 'FoodAnalysisService',
          error: e,
        );
        return FoodAnalysisResult.failure(
          'Service unavailable: Database connection not initialized.',
        );
      }

      // Convert image to base64
      final base64Image = base64Encode(imageBytes);

      // Prepare context
      final mealTypeString = mealType?.name;
      final mealTimeString = mealTime != null
          ? '${mealTime.hour.toString().padLeft(2, '0')}:${mealTime.minute.toString().padLeft(2, '0')}'
          : null;

      developer.log(
        'Analyzing food image: ${imageBytes.length} bytes, '
        'mealType: $mealTypeString, mealTime: $mealTimeString',
        name: 'FoodAnalysisService',
      );

      // Call the Edge Function
      final response = await supabase.functions.invoke(
        'analyze-food-image',
        body: {
          'imageBase64': base64Image,
          'mealType': ?mealTypeString,
          'mealTime': ?mealTimeString,
        },
      );

      // Check for function errors
      if (response.status != 200) {
        final errorData = response.data as Map<String, dynamic>?;
        final errorMessage =
            errorData?['error'] as String? ??
            'Analysis failed with status ${response.status}';
        developer.log(
          'Edge function error: $errorMessage',
          name: 'FoodAnalysisService',
          level: 1000, // SEVERE
        );
        return FoodAnalysisResult.failure(errorMessage);
      }

      // Parse response
      final data = response.data as Map<String, dynamic>;

      if (data['success'] != true) {
        final errorMessage =
            data['error'] as String? ?? 'Unknown analysis error';
        developer.log(
          'Analysis error: $errorMessage',
          name: 'FoodAnalysisService',
          level: 1000,
        );
        return FoodAnalysisResult.failure(errorMessage);
      }

      final analysisData = data['data'] as Map<String, dynamic>;

      // Parse items
      final itemsData = analysisData['items'] as List<dynamic>?;
      if (itemsData == null || itemsData.isEmpty) {
        return FoodAnalysisResult.failure('No food items detected in image');
      }

      final items = itemsData.map((itemData) {
        return _parseAnalyzedFoodItem(itemData as Map<String, dynamic>);
      }).toList();

      developer.log(
        'Analysis successful: ${items.length} items detected',
        name: 'FoodAnalysisService',
      );

      return FoodAnalysisResult(
        items: items,
        overallConfidence:
            (analysisData['overallConfidence'] as num?)?.toDouble() ?? 0.5,
        notes: analysisData['notes'] as String?,
        success: true,
      );
    } on FunctionException catch (e) {
      developer.log(
        'Supabase function exception: ${e.details}',
        name: 'FoodAnalysisService',
        level: 1000,
        error: e,
      );
      return FoodAnalysisResult.failure(
        'Could not connect to analysis service. Please try again.',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected error during analysis',
        name: 'FoodAnalysisService',
        level: 1000,
        error: e,
        stackTrace: stackTrace,
      );
      return FoodAnalysisResult.failure(
        'An unexpected error occurred. Please try manual entry.',
      );
    }
  }

  /// Parses a single analyzed food item from the API response.
  static AnalyzedFoodItem _parseAnalyzedFoodItem(Map<String, dynamic> data) {
    final nutritionData = data['nutrition'] as Map<String, dynamic>? ?? {};

    final nutrition = NutritionProfile(
      energyKcal: (nutritionData['energyKcal'] as num?)?.toDouble() ?? 0,
      protein: (nutritionData['protein'] as num?)?.toDouble() ?? 0,
      carbs: (nutritionData['carbs'] as num?)?.toDouble() ?? 0,
      fat: (nutritionData['fat'] as num?)?.toDouble() ?? 0,
      sugars: (nutritionData['sugars'] as num?)?.toDouble() ?? 0,
      fiber: (nutritionData['fiber'] as num?)?.toDouble() ?? 0,
      saturatedFat: (nutritionData['saturatedFat'] as num?)?.toDouble() ?? 0,
      transFat: 0,
      cholesterol: 0,
      sodium: (nutritionData['sodium'] as num?)?.toDouble() ?? 0,
      waterContent: 0,
      micros: const {},
    );

    final foodEntry = FoodEntry.withId(
      entryType: FoodEntryType.manualCustom,
      name: data['name'] as String? ?? 'Unknown Food',
      description: data['description'] as String?,
      amount: (data['amount'] as num?)?.toDouble() ?? 1,
      unit: data['unit'] as String? ?? 'serving',
      servingSizeGrams: (data['servingSizeGrams'] as num?)?.toDouble() ?? 100,
      portionReference: data['portionReference'] as String?,
      portionEstimationMethod: PortionEstimationMethod.photograph,
      portionState: PortionState.asServed,
      nutrition: nutrition,
      source: FoodSource.manual,
      confidenceScore: (data['confidenceScore'] as num?)?.toDouble() ?? 0.5,
      originalValues: const {},
    );

    return AnalyzedFoodItem(
      foodEntry: foodEntry,
      confidenceScore: (data['confidenceScore'] as num?)?.toDouble() ?? 0.5,
    );
  }
}
