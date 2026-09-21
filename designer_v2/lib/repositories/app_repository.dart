import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';

part 'app_repository.g.dart';

abstract class IAppRepository() {
  Future<AppConfig> fetchAppConfig();
  void dispose();
}

class AppRepository(final StudyUApi apiClient) implements IAppRepository {
  @override
  Future<AppConfig> fetchAppConfig() async {
    final appConfig = await apiClient.fetchAppConfig();
    return appConfig;
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }
}

@riverpod
Future<AppConfig> appConfig(Ref ref) async {
  final apiClient = ref.watch(apiClientProvider);
  return await AppRepository(apiClient).fetchAppConfig();
}
