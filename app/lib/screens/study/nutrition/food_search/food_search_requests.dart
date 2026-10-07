import 'package:openfoodfacts/openfoodfacts.dart';

const foodProviderTimeout = Duration(seconds: 10);

List<OpenFoodFactsLanguage> openFoodFactsLanguages(String languageCode) {
  final language = LanguageHelper.fromJson(languageCode);
  return [
    if (language != OpenFoodFactsLanguage.UNDEFINED &&
        language != OpenFoodFactsLanguage.ENGLISH)
      language,
    OpenFoodFactsLanguage.ENGLISH,
  ];
}

const openFoodFactsSearchFields = [
  ProductField.NAME,
  ProductField.NAME_IN_LANGUAGES,
  ProductField.BRANDS,
  ProductField.BARCODE,
  ProductField.NUTRIMENTS,
  ProductField.SERVING_SIZE,
  ProductField.QUANTITY,
  ProductField.IMAGE_FRONT_SMALL_URL,
];

// Request localized names and English in one request. Do not retry by language.
String? openFoodFactsProductName(Product product, String languageCode) {
  for (final language in openFoodFactsLanguages(languageCode)) {
    final name = product.productNameInLanguages?[language];
    if (name != null && name.trim().isNotEmpty) return name;
  }
  return product.productName;
}

Future<ProductResultV3> fetchOpenFoodFactsBarcode(
  String barcode, {
  required String languageCode,
}) async {
  final result = await OpenFoodAPIClient.getProductV3(
    ProductQueryConfiguration(
      barcode,
      languages: openFoodFactsLanguages(languageCode),
      fields: openFoodFactsSearchFields,
      version: ProductQueryVersion.v3,
    ),
  ).timeout(foodProviderTimeout);
  final product = result.product;
  if (product != null) {
    product.productName = openFoodFactsProductName(product, languageCode);
  }
  return result;
}
