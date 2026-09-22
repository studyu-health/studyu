// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AuthFormController)
final authFormControllerProvider = AuthFormControllerFamily._();

final class AuthFormControllerProvider
    extends $NotifierProvider<AuthFormController, AsyncValue<void>> {
  AuthFormControllerProvider._({
    required AuthFormControllerFamily super.from,
    required AuthFormKey super.argument,
  }) : super(
         retry: null,
         name: r'authFormControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$authFormControllerHash();

  @override
  String toString() {
    return r'authFormControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AuthFormController create() => AuthFormController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AuthFormControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$authFormControllerHash() =>
    r'3e5ce90cda126c544cd08be2ae2af7914b552b38';

final class AuthFormControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          AuthFormController,
          AsyncValue<void>,
          AsyncValue<void>,
          AsyncValue<void>,
          AuthFormKey
        > {
  AuthFormControllerFamily._()
    : super(
        retry: null,
        name: r'authFormControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AuthFormControllerProvider call(AuthFormKey formKeyArg) =>
      AuthFormControllerProvider._(argument: formKeyArg, from: this);

  @override
  String toString() => r'authFormControllerProvider';
}

abstract class _$AuthFormController extends $Notifier<AsyncValue<void>> {
  late final _$args = ref.$arg as AuthFormKey;
  AuthFormKey get formKeyArg => _$args;

  AsyncValue<void> build(AuthFormKey formKeyArg);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
