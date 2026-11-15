@TestOn('browser')
library;

import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/features/design/study_form_controller.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/localization/app_localizations_en.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/repositories/fitbit_credentials_repository.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

const _studyId = 'preview-validation-study';
const _userId = 'preview-validation-owner';

class _SourceForm() extends Mock implements StudyFormViewModel {
  final titleControl = FormControl<String>(
    value: 'Original title',
    validators: [Validators.required],
  );
  late final _form = FormGroup({'title': titleControl});
  int snapshots = 0;

  @override
  FormGroup get form => _form;

  @override
  Study buildFormData() {
    snapshots++;
    return Study.withId(_userId)
      ..id = _studyId
      ..title = titleControl.value ?? '';
  }
}

class _AuthRepository() extends Mock implements AuthRepository {
  @override
  sb.User get currentUser => const sb.User(
    id: _userId,
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    createdAt: '',
  );
}

class _StudyRepository() extends Mock implements StudyRepository;
class _FitbitRepository() extends Mock implements FitbitCredentialsRepository;

void main() {
  setUpAll(() => AppTranslation.setForTesting(AppLocalizationsEn()));

  void withForm(void Function(FakeAsync, ProviderContainer, _SourceForm) body) {
    fakeAsync((async) {
      final source = _SourceForm();
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const SizedBox.shrink(),
          ),
        ],
      );
      final container = ProviderContainer(
        overrides: [
          studyFormViewModelProvider(_studyId).overrideWith((ref) => source),
          routerProvider.overrideWithValue(router),
          authRepositoryProvider.overrideWithValue(_AuthRepository()),
          studyRepositoryProvider.overrideWithValue(_StudyRepository()),
          fitbitCredentialsRepositoryProvider(_studyId)
              .overrideWithValue(_FitbitRepository()),
        ],
      );
      try {
        container.listen(
          studyTestValidatorProvider(_studyId),
          (_, _) {},
          fireImmediately: true,
        );
        async.flushMicrotasks();
        expect(source.snapshots, 1);
        body(async, container, source);
      } finally {
        container.dispose();
        source.form.dispose();
        router.dispose();
        async.flushMicrotasks();
      }
    });
  }

  test('typing rebuilds the preview validator only after a pause', () {
    withForm((async, container, source) {
      for (final text in ['N', 'Ne', 'New title']) {
        source.titleControl.value = text;
        async.flushMicrotasks();
        async.elapse(const Duration(milliseconds: 100));
      }
      expect(source.snapshots, 1);
      async.elapse(const Duration(milliseconds: Config.formAutosaveDebounce));
      async.flushMicrotasks();
      expect(source.snapshots, 2);
      expect(
        container
            .read(studyTestValidatorProvider(_studyId))
            .studyInfoFormViewModel
            .titleControl
            .value,
        'New title',
      );
    });
  });

  test('field validation stays immediate while preview validation waits', () {
    withForm((async, container, source) {
      source.titleControl.value = '';
      async.flushMicrotasks();
      expect(source.titleControl.hasError(ValidationMessage.required), isTrue);
      expect(source.snapshots, 1);
    });
  });

  test('disposing the provider cancels pending preview validation', () {
    withForm((async, container, source) {
      source.titleControl.value = 'Pending edit';
      async.flushMicrotasks();
      container.dispose();
      async.elapse(const Duration(milliseconds: Config.formAutosaveDebounce));
      async.flushMicrotasks();
      expect(source.snapshots, 1);
    });
  });
}
