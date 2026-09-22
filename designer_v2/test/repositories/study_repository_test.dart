@TestOn('browser')
library;

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/services/notification_service.dart';
import 'package:studyu_designer_v2/services/notifications.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'study_repository_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<StudyUApiClient>(),
  MockSpec<AuthRepository>(),
  MockSpec<GoRouter>(),
  MockSpec<GoRouteInformationProvider>(),
  MockSpec<NotificationService>(),
  MockSpec<User>(),
])
void main() {
  setUpAll(() => AppTranslation.setForTesting(AppLocalizationsEn()));

  group('StudyRepository deletion routing', () {
    late MockStudyUApiClient apiClient;
    late MockAuthRepository authRepository;
    late MockGoRouter router;
    late MockGoRouteInformationProvider routeInformationProvider;
    late MockNotificationService notificationService;
    late StudyRepository repository;
    late Study study;

    setUp(() {
      apiClient = MockStudyUApiClient();
      authRepository = MockAuthRepository();
      router = MockGoRouter();
      routeInformationProvider = MockGoRouteInformationProvider();
      notificationService = MockNotificationService();
      final user = MockUser();
      when(user.id).thenReturn('me');
      when(authRepository.currentUser).thenReturn(user);
      when(router.routeInformationProvider)
          .thenReturn(routeInformationProvider);
      final container = ProviderContainer(
        overrides: [
          apiClientProvider.overrideWithValue(apiClient),
          authRepositoryProvider.overrideWithValue(authRepository),
          routerProvider.overrideWithValue(router),
          notificationServiceProvider.overrideWithValue(notificationService),
        ],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        studyRepositoryProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      repository = subscription.read();
      study = Study('study', 'me')..title = 'Study';
      repository.upsertLocally(study).markAsFetched();
    });

    ModelAction deleteAction() => repository
        .availableActions(study)
        .singleWhere((action) => action.type == StudyActionType.delete);

    void setRoute(String path) {
      when(routeInformationProvider.value)
          .thenReturn(RouteInformation(uri: Uri.parse(path)));
    }

    void verifyNoRedirect() {
      verifyNever(
        router.goNamed(
          RoutingIntents.studies.routeName,
          pathParameters: anyNamed('pathParameters'),
          queryParameters: anyNamed('queryParameters'),
          extra: anyNamed('extra'),
        ),
      );
    }

    test('dashboard deletion does not redirect', () async {
      setRoute(RoutingIntents.studies.route.path);
      when(apiClient.deleteStudy(study)).thenAnswer((_) => Future.value());

      await deleteAction().onExecute();

      verifyNoRedirect();
      verify(notificationService.show(Notifications.studyDeleted)).called(1);
    });

    test('detail deletion redirects only after persistence succeeds', () async {
      setRoute('/studies/study/edit');
      final persistence = Completer<void>();
      when(apiClient.deleteStudy(study)).thenAnswer((_) => persistence.future);

      final deletion = deleteAction().onExecute();
      await Future<void>.delayed(Duration.zero);
      verifyNoRedirect();

      persistence.complete();
      await deletion;

      verify(router.goNamed(RoutingIntents.studies.routeName)).called(1);
      verify(notificationService.show(Notifications.studyDeleted)).called(1);
    });

    test('failed detail deletion does not redirect or show success', () async {
      setRoute('/studies/study/edit');
      when(apiClient.deleteStudy(study)).thenThrow(StateError('delete failed'));

      await deleteAction().onExecute();

      verifyNoRedirect();
      verifyNever(notificationService.show(Notifications.studyDeleted));
      verify(notificationService.showMessage(tr.sync_failed)).called(1);
    });

    test('failed dashboard deletion still propagates', () async {
      setRoute(RoutingIntents.studies.route.path);
      when(apiClient.deleteStudy(study)).thenThrow(StateError('delete failed'));

      await expectLater(deleteAction().onExecute(), throwsA(isA<StateError>()));

      verifyNoRedirect();
      verifyNever(notificationService.show(Notifications.studyDeleted));
      verifyNever(notificationService.showMessage(any));
    });

    test(
      'redirect decision uses the route after persistence completes',
      () async {
        setRoute('/studies/study/edit');
        final persistence = Completer<void>();
        when(apiClient.deleteStudy(study))
            .thenAnswer((_) => persistence.future);

        final deletion = deleteAction().onExecute();
        await Future<void>.delayed(Duration.zero);
        setRoute(RoutingIntents.studies.route.path);
        persistence.complete();
        await deletion;

        verifyNoRedirect();
        verify(notificationService.show(Notifications.studyDeleted)).called(1);
      },
    );
  });

  group('StudyRepository.close', () {
    late MockStudyUApiClient apiClient;
    late StudyRepository repository;
    late Study study;

    setUp(() {
      apiClient = MockStudyUApiClient();
      final container = ProviderContainer(
        overrides: [
          apiClientProvider.overrideWithValue(apiClient),
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        ],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        studyRepositoryProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      repository = subscription.read();
      study = Study('study', 'me')
        ..title = 'Study'
        ..status = StudyStatus.running;
      repository.upsertLocally(study).markAsFetched();
    });

    test('waits for persistence before updating the cached study', () async {
      final persistence = Completer<Study>();
      late Study persistedStudy;
      when(apiClient.saveStudy(any)).thenAnswer((invocation) {
        persistedStudy = invocation.positionalArguments.single as Study;
        return persistence.future;
      });

      final closing = repository.close(study);
      await Future<void>.delayed(Duration.zero);

      expect(persistedStudy.status, StudyStatus.closed);
      expect(study.status, StudyStatus.running);
      expect(repository.get(study.id)!.model.status, StudyStatus.running);

      persistence.complete(persistedStudy);
      await closing;

      expect(repository.get(study.id)!.model.status, StudyStatus.closed);
    });

    test('failed persistence leaves the cached study unchanged', () async {
      when(apiClient.saveStudy(any)).thenThrow(StateError('save failed'));

      await expectLater(repository.close(study), throwsA(isA<StateError>()));

      expect(study.status, StudyStatus.running);
      expect(repository.get(study.id)!.model.status, StudyStatus.running);
    });
  });
}
