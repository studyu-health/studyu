// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filter_draft_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FilterDraftController)
final filterDraftControllerProvider = FilterDraftControllerProvider._();

final class FilterDraftControllerProvider
    extends $NotifierProvider<FilterDraftController, FilterDraft> {
  FilterDraftControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filterDraftControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filterDraftControllerHash();

  @$internal
  @override
  FilterDraftController create() => FilterDraftController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FilterDraft value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FilterDraft>(value),
    );
  }
}

String _$filterDraftControllerHash() =>
    r'3ac71b6b0a389436930677aeb240c0013d490ea3';

abstract class _$FilterDraftController extends $Notifier<FilterDraft> {
  FilterDraft build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<FilterDraft, FilterDraft>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FilterDraft, FilterDraft>,
              FilterDraft,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
