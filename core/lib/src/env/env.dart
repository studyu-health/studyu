import 'package:supabase/supabase.dart';

late final SupabaseClient client;
late final String supabaseUrl;
late final String supabaseAnonKey;
late final String? appUrl;
late final String? designerUrl;
late final String? projectGeneratorUrl;
late final String? androidPackageName;
late final String? iosAppStoreId;
late final String? developerEmail;
String? appDeepLinkScheme;

String get appScheme {
  if (appDeepLinkScheme != null) {
    try {
      final scheme = Uri.parse(appDeepLinkScheme!).scheme;
      if (scheme.isNotEmpty && scheme != 'http' && scheme != 'https') {
        return scheme;
      }
    } catch (_) {}
  }
  return 'studyu-app';
}

String generateAppSchemeLink(String path) {
  return '$appScheme://${path.startsWith('/') ? path.substring(1) : path}';
}

String generateAppDeepLink(String path) {
  final baseUrl = appUrl ?? 'https://app.studyu.health';
  return '$baseUrl/${path.startsWith('/') ? path.substring(1) : path}';
}

void setEnv(
  String envSupabaseUrl,
  String envSupabaseAnonKey, {
  required SupabaseClient supabaseClient,
  String? envAppUrl,
  String? envDesignerUrl,
  String? envProjectGeneratorUrl,
  String? envAndroidPackageName,
  String? envIosAppStoreId,
  String? envDeveloperEmail,
  String? envAppDeepLinkScheme,
}) {
  supabaseUrl = envSupabaseUrl;
  supabaseAnonKey = envSupabaseAnonKey;
  client = supabaseClient;
  // Remove trailing slashes to prevent double slashes when concatenating path
  if (envAppUrl != null && envAppUrl.endsWith('/')) {
    appUrl = envAppUrl.substring(0, envAppUrl.length - 1);
  } else {
    appUrl = envAppUrl;
  }
  if (envDesignerUrl != null && envDesignerUrl.endsWith('/')) {
    designerUrl = envDesignerUrl.substring(0, envDesignerUrl.length - 1);
  } else {
    designerUrl = envDesignerUrl;
  }
  if (envProjectGeneratorUrl != null && envProjectGeneratorUrl.endsWith('/')) {
    projectGeneratorUrl = envProjectGeneratorUrl.substring(
      0,
      envProjectGeneratorUrl.length - 1,
    );
  } else {
    projectGeneratorUrl = envProjectGeneratorUrl;
  }

  androidPackageName = envAndroidPackageName;
  iosAppStoreId = envIosAppStoreId;
  developerEmail = envDeveloperEmail;
  // Remove trailing slashes from deep link scheme
  if (envAppDeepLinkScheme != null && envAppDeepLinkScheme.endsWith('/')) {
    appDeepLinkScheme = envAppDeepLinkScheme.substring(
      0,
      envAppDeepLinkScheme.length - 1,
    );
  } else {
    appDeepLinkScheme = envAppDeepLinkScheme;
  }
}
