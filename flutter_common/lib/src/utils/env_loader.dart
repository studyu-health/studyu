import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:studyu_core/env.dart' as env;
import 'package:studyu_flutter_common/src/utils/storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const envsAssetPath = 'packages/studyu_flutter_common/lib/envs';

// load env from envs/.env or from the filename specified in the STUDYU_ENV runtime-variable
String envFilePath() {
  const env = String.fromEnvironment('STUDYU_ENV');
  return env.isNotEmpty ? '$envsAssetPath/$env' : '$envsAssetPath/.env';
}

String? getEnv(String name, {bool optional = false}) {
  final value = dotenv.env[name];
  if (value != null && value.isNotEmpty) {
    // print('Loaded env $name=$value');
    return value;
  }

  try {
    final fallback = String.fromEnvironment(name);
    if (fallback.isNotEmpty) {
      print('Loaded $name from --dart-define: $fallback');
      return fallback;
    }
  } catch (e) {
    if (!optional) {
      // todo handle environment error in the UI
      print('No environment value for $name');
      // rethrow;
    }
  }

  return null;
}

Future<void> loadEnv() async {
  await dotenv.load(fileName: envFilePath());
  final supabaseUrls = loadSupabaseUrls();

  final supabaseAnonKey = getEnv('STUDYU_SUPABASE_PUBLIC_ANON_KEY');
  final envAppUrl = getEnv('STUDYU_APP_URL');
  final envDesignerUrl = getEnv('STUDYU_DESIGNER_URL');
  final envProjectGeneratorUrl = getEnv(
    'STUDYU_PROJECT_GENERATOR_URL',
    optional: true,
  );
  final envAndroidPackageName = getEnv(
    'STUDYU_ANDROID_PACKAGE_ID',
    optional: true,
  );
  final envIosAppStoreId = getEnv('STUDYU_IOS_APP_STORE_ID', optional: true);
  final envDeveloperEmail = getEnv('STUDYU_DEVELOPER_EMAIL', optional: true);
  final envAppDeepLinkScheme = getEnv(
    'STUDYU_APP_DEEP_LINK_SCHEME',
    optional: true,
  );

  // await SecureStorage.migrateSharedPreferencesToSecureStorage();

  // Test if supabaseUrls has multiple entries and try them in order until one works
  final workingSupabaseUrl = await findWorkingSupabaseUrl(
    supabaseUrls,
    supabaseAnonKey!,
  );

  await Supabase.initialize(
    url: workingSupabaseUrl,
    publishableKey: supabaseAnonKey,
    authOptions: FlutterAuthClientOptions(localStorage: SupabaseStorage()),
    debug: true,
  );

  env.setEnv(
    workingSupabaseUrl,
    supabaseAnonKey,
    envAppUrl: envAppUrl,
    envDesignerUrl: envDesignerUrl,
    envProjectGeneratorUrl: envProjectGeneratorUrl,
    envAndroidPackageName: envAndroidPackageName,
    envIosAppStoreId: envIosAppStoreId,
    envDeveloperEmail: envDeveloperEmail,
    envAppDeepLinkScheme: envAppDeepLinkScheme,
    supabaseClient: Supabase.instance.client,
  );
}

List<String> loadSupabaseUrls() {
  final urlsEnv = getEnv('STUDYU_SUPABASE_URLS');
  // Deprecated: Use STUDYU_SUPABASE_URLS instead
  // Will be removed in future versions
  final urlEnv = getEnv('STUDYU_SUPABASE_URL', optional: true);

  List<String> urls = [];

  if (urlsEnv != null && urlsEnv.isNotEmpty) {
    urls = urlsEnv
        .split(',')
        .map((u) => u.trim())
        .where((u) => u.isNotEmpty)
        .toList();
  }

  if (urls.isEmpty) {
    if (urlEnv == null || urlEnv.isEmpty) {
      throw Exception(
        'No STUDYU_SUPABASE_URLS or STUDYU_SUPABASE_URL environment variable found',
      );
    }
    debugPrint(
      '⚠️ Warning: Using deprecated STUDYU_SUPABASE_URL environment variable. Please migrate to STUDYU_SUPABASE_URLS.',
    );
    urls = [urlEnv.trim()];
  } else if (urlEnv != null && urlEnv.isNotEmpty) {
    // include STUDYU_SUPABASE_URL if it's not already in STUDYU_SUPABASE_URLS
    final trimmed = urlEnv.trim();
    if (!urls.contains(trimmed)) {
      urls.add(trimmed);
    }
  }

  return urls;
}

Future<String> findWorkingSupabaseUrl(
  List<String> supabaseUrls,
  String supabaseAnonKey,
) async {
  for (final url in supabaseUrls) {
    final client = SupabaseClient(url, supabaseAnonKey);
    try {
      await client
          .from('app_config')
          .select()
          .eq('id', 'eq.prod')
          .limit(1)
          .maybeSingle()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () =>
                throw TimeoutException('Connection timeout after 5 seconds'),
          );
      debugPrint("✅ Connected to Supabase at $url");
      return url;
    } catch (e) {
      debugPrint("⚠️ Failed to connect to $url: $e");
    }
  }

  throw Exception("No Supabase URL worked!");
}
