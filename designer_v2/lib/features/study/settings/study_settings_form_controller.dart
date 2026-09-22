import 'package:reactive_forms/reactive_forms.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/repositories/study_repository.dart';
import 'package:studyu_designer_v2/utils/performance.dart';

part 'study_settings_form_controller.g.dart';

class StudySettingsFormViewModel({
  required final IStudyRepository studyRepository,
  required Study initialStudy,
}) extends FormViewModel<Study> {
  this : super(formData: initialStudy) {
    // defer registering listeners so that controls can be initialized properly
    runAsync(keepControlsSynced);
  }

  static const defaultPublishedToRegistry = true;
  static const defaultPublishedToRegistryResults = false;

  final FormControl<bool> isPublishedToRegistryControl = FormControl(
    value: defaultPublishedToRegistry,
  );
  final FormControl<bool> isPublishedToRegistryResultsControl = FormControl(
    value: defaultPublishedToRegistryResults,
  );

  @override
  late final FormGroup form = FormGroup({
    'isPublishedToRegistry': isPublishedToRegistryControl,
    'isPublishedToRegistryResults': isPublishedToRegistryResultsControl,
  });

  @override
  void setControlsFrom(Study data) {
    isPublishedToRegistryControl.value = data.publishedToRegistry;
    isPublishedToRegistryResultsControl.value = data.publishedToRegistryResults;
  }

  @override
  Study buildFormData() {
    final study = formData!.exactDuplicate();

    study.registryPublished = isPublishedToRegistryControl.value!;
    study.resultSharing = (isPublishedToRegistryResultsControl.value!)
        ? ResultSharing.public
        : ResultSharing.private;

    return study;
  }

  void keepControlsSynced() {
    // sync controls so that results cannot be published without publishing
    // the study design itself
    isPublishedToRegistryControl.valueChanges.listen((value) {
      if (value == false) {
        isPublishedToRegistryResultsControl.value = false;
      }
    });
    isPublishedToRegistryResultsControl.valueChanges.listen((value) {
      if (value == true) {
        isPublishedToRegistryControl.value = true;
      }
    });
  }

  @override
  Future save() {
    final study = buildFormData();
    return studyRepository.save(study);
  }

  @override
  Map<FormMode, String> get titles => throw UnimplementedError(); // unused

  void setLaunchDefaults() {
    isPublishedToRegistryControl.value = defaultPublishedToRegistry;
    isPublishedToRegistryResultsControl.value =
        defaultPublishedToRegistryResults;
  }
}

/// Provides the [FormViewModel] responsible for managing the study settings.
///
/// Note: This is not safe to use in widgets (or other providers) that are built
/// before the [StudyController]'s [Study] is available (see also: [AsyncValue])
@riverpod
StudySettingsFormViewModel studySettingsFormViewModel(Ref ref, String studyId) {
  final state = ref.watch(studyControllerProvider(studyId));
  final formViewModel = StudySettingsFormViewModel(
    studyRepository: ref.watch(studyRepositoryProvider),
    initialStudy: state.studyValueRequired,
  );
  ref.onDispose(() {
    print("studySettingsFormViewModelProvider.DISPOSE");
  });
  return formViewModel;
}
