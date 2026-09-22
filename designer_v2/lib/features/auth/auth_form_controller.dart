import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/services/notification_service.dart';
import 'package:studyu_designer_v2/services/notifications.dart';
import 'package:supabase/supabase.dart';

part 'auth_form_controller.g.dart';

enum AuthFormKey() {
  login,
  signup,
  passwordForgot,
  passwordRecovery,
  passwordReset,
  _loginSubmit,
  _signupSubmit;

  String get title {
    switch (this) {
      case login:
        return tr.login_page_title;
      case signup:
        return tr.signup_page_title;
      case passwordForgot:
        return tr.password_forgot_page_title;
      case passwordRecovery:
        return tr.password_recover_page_title;
      case passwordReset:
        return tr.change_password;
      default:
        return "[AuthFormKey.title]";
    }
  }

  String? get description {
    switch (this) {
      case login:
        return tr.login_page_description;
      case signup:
        return tr.signup_page_description;
      case passwordForgot:
        return tr.password_forgot_page_description;
      case passwordReset:
        return tr.password_change_description;
      default:
        return null;
    }
  }
}

@riverpod
class AuthFormController() extends _$AuthFormController {
  @override
  AsyncValue<void> build(AuthFormKey formKeyArg) {
    _authRepository = ref.watch(authRepositoryProvider);
    _notificationService = ref.watch(notificationServiceProvider);
    _router = ref.watch(routerProvider);

    setFormKey(formKeyArg);
    resetControlsFor(getFormKey());

    listenSelf((previous, next) {
      print("authFormController.state updated");
      if (state.hasError) {
        final AuthException error = state.error! as AuthException;
        switch (error.message) {
          case "Invalid login credentials":
            print("authFormController.state listen self");
            _notificationService.show(Notifications.credentialsInvalid);
          case "User already registered":
            _notificationService.show(Notifications.userAlreadyRegistered);
          default:
            _notificationService.showMessage(error.message);
        }
      }
    });

    ref.onDispose(() {
      print("authFormControllerProvider.DISPOSE");
    });
    _readDebugUser();
    _onChangeFormKey(getFormKey());

    return const AsyncValue.data(null);
  }

  late final IAuthRepository _authRepository;
  late final INotificationService _notificationService;
  late final GoRouter _router;

  // - Form controls

  final FormControl<String> _emailControl = FormControl();
  final FormControl<String> _oldPasswordControl = FormControl();
  final FormControl<String> _passwordControl = FormControl();
  final FormControl<String> _passwordConfirmationControl = FormControl();
  final FormControl<bool> _termsOfServiceControl = FormControl(value: false);

  // Form control access methods
  FormControl<String> getEmailControl() => _emailControl;
  FormControl<String> getOldPasswordControl() => _oldPasswordControl;
  FormControl<String> getPasswordControl() => _passwordControl;
  FormControl<String> getPasswordConfirmationControl() =>
      _passwordConfirmationControl;
  FormControl<bool> getTermsOfServiceControl() => _termsOfServiceControl;

  static final authValidationMessages = {
    ValidationMessage.required: (_) => tr.form_field_required,
    ValidationMessage.email: (_) => tr.form_field_email_invalid,
    ValidationMessage.mustMatch: (_) => tr.form_field_password_mustmatch,
    ValidationMessage.minLength: (error) => tr.form_field_password_minlength(
      (error as Map)['requiredLength'] as num,
    ),
  };

  late final FormGroup _loginForm = FormGroup({
    'email': getEmailControl(),
    'password': getPasswordControl(),
  });

  late final FormGroup _signupForm = FormGroup(
    {
      'email': getEmailControl(),
      'password': getPasswordControl(),
      'passwordConfirmation': getPasswordConfirmationControl(),
      'termsOfService': getTermsOfServiceControl(),
    },
    validators: [Validators.mustMatch('password', 'passwordConfirmation')],
  );

  late final FormGroup _passwordForgotForm = FormGroup({
    'email': getEmailControl(),
  });

  late final FormGroup _passwordRecoveryForm = FormGroup(
    {
      'password': getPasswordControl(),
      'passwordConfirmation': getPasswordConfirmationControl(),
    },
    validators: [Validators.mustMatch('password', 'passwordConfirmation')],
  );

  late final FormGroup _passwordResetForm = FormGroup(
    {
      'oldPassword': getOldPasswordControl(),
      'password': getPasswordControl(),
      'passwordConfirmation': getPasswordConfirmationControl(),
    },
    validators: [Validators.mustMatch('password', 'passwordConfirmation')],
  );

  late final Map<AuthFormKey, Map<FormControl, List<Validator<dynamic>>>>
  _controlValidatorsByForm = {
    AuthFormKey.signup: {
      getEmailControl(): [Validators.required, Validators.email],
      getPasswordControl(): [Validators.minLength(8)],
      getPasswordConfirmationControl(): [Validators.required],
      getTermsOfServiceControl(): [
        Validators.required,
        Validators.requiredTrue,
      ],
    },
    AuthFormKey._signupSubmit: {
      getEmailControl(): [Validators.required, Validators.email],
      getPasswordControl(): [Validators.required, Validators.minLength(8)],
      getPasswordConfirmationControl(): [Validators.required],
      getTermsOfServiceControl(): [
        Validators.required,
        Validators.requiredTrue,
      ],
    },
    AuthFormKey._loginSubmit: {
      getEmailControl(): [Validators.required, Validators.email],
      getPasswordControl(): [Validators.required],
    },
    AuthFormKey.passwordForgot: {
      getEmailControl(): [Validators.required, Validators.email],
    },
    AuthFormKey.passwordRecovery: {
      getPasswordControl(): [Validators.required, Validators.minLength(8)],
      getPasswordConfirmationControl(): [Validators.required],
    },
    AuthFormKey.passwordReset: {
      getOldPasswordControl(): [Validators.required, Validators.minLength(8)],
      getPasswordControl(): [Validators.required, Validators.minLength(8)],
      getPasswordConfirmationControl(): [Validators.required],
    },
  };

  AuthFormKey _formKey = AuthFormKey.login;

  void setFormKey(AuthFormKey key) {
    if (!AuthFormKey.values.contains(key)) {
      throw Exception("Unknown AuthFormKey");
    }
    _onChangeFormKey(_formKey);
    _formKey = key;
  }

  AuthFormKey getFormKey() => _formKey;

  FormGroup? _getFormFor(AuthFormKey key) {
    switch (key) {
      case AuthFormKey.login:
        return _loginForm;
      case AuthFormKey.signup:
        return _signupForm;
      case AuthFormKey.passwordForgot:
        return _passwordForgotForm;
      case AuthFormKey.passwordRecovery:
        return _passwordRecoveryForm;
      case AuthFormKey.passwordReset:
        return _passwordResetForm;
      default:
        return null;
    }
  }

  // Public method to get form instead of getter
  FormGroup? getForm() => _getFormFor(getFormKey());

  void _onChangeFormKey(AuthFormKey key) {
    resetControlsFor(key);
  }

  void resetControlsFor(AuthFormKey key) {
    final formControlValidators = _controlValidatorsByForm[key];
    if (formControlValidators != null) {
      for (final entry in formControlValidators.entries) {
        final control = entry.key;
        final validators = entry.value;
        control.setValidators(validators, autoValidate: true);
        control.markAsUntouched();
      }
    }
    getForm()?.markAsUntouched();
    getForm()?.updateValueAndValidity();
  }

  void _forceValidationMessages(AuthFormKey key) {
    _onChangeFormKey(key);
    final currentForm = getForm();
    if (currentForm != null) {
      for (final control in currentForm.controls.values) {
        control.markAsTouched();
        control.updateValueAndValidity();
      }
      currentForm.markAsTouched();
      currentForm.updateValueAndValidity();
    }
  }

  Future<AuthResponse> signUp() {
    _forceValidationMessages(AuthFormKey._signupSubmit);
    if (getEmailControl().isNullOrEmpty || getPasswordControl().isNullOrEmpty) {
      return Future.value(AuthResponse());
    }
    return _signUp(getEmailControl().value!, getPasswordControl().value!);
  }

  Future<AuthResponse> _signUp(String email, String password) async {
    _forceValidationMessages(AuthFormKey._loginSubmit);
    final currentForm = getForm();
    if (currentForm == null || !currentForm.valid) {
      return await Future.value(AuthResponse());
    }
    try {
      state = const AsyncValue.loading();
      return await _authRepository.signUp(email: email, password: password);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } finally {
      state = const AsyncValue.data(null);
    }
    return AuthResponse();
  }

  Future<AuthResponse> signIn() async {
    _forceValidationMessages(AuthFormKey._loginSubmit);
    final currentForm = getForm();
    if (currentForm == null ||
        !currentForm.valid ||
        getEmailControl().isNullOrEmpty ||
        getPasswordControl().isNullOrEmpty) {
      return await Future.value(AuthResponse());
    }
    return await _signInWith(
      getEmailControl().value!,
      getPasswordControl().value!,
    );
  }

  Future<AuthResponse> _signInWith(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      final response = await _authRepository.signInWith(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } finally {
      state = const AsyncValue.data(null);
    }
    return await Future.value(AuthResponse());
  }

  Future<void> signOut() async {
    try {
      state = const AsyncValue.loading();
      return await _authRepository.signOut();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } finally {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> resetPasswordForEmail(String email) async {
    try {
      state = const AsyncValue.loading();
      return await _authRepository.resetPasswordForEmail(email: email);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } finally {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> sendPasswordResetLink() {
    final currentForm = getForm();
    if (currentForm == null || !currentForm.valid) {
      return Future.value();
    }
    return resetPasswordForEmail(getEmailControl().value!)
        .then((_) => _notificationService.show(Notifications.passwordReset));
  }

  Future<void> recoverPassword() {
    final currentForm = getForm();
    if (currentForm == null || !currentForm.valid) {
      return Future.value();
    }
    return updateUser(getPasswordControl().value!)
        .then(
          (_) => _notificationService.show(Notifications.passwordResetSuccess),
        )
        .then((_) => _router.dispatch(RoutingIntents.studies));
  }

  Future<bool> resetPassword() async {
    final currentForm = getForm();
    if (currentForm == null || !currentForm.valid) {
      return false;
    }

    final isOldPasswordValid = await _isOldPasswordValid(
      getOldPasswordControl().value!,
    );

    if (!isOldPasswordValid) {
      return false;
    }

    return await updateUser(getPasswordControl().value!);
  }

  Future<bool> updateUser(String newPassword) async {
    try {
      state = const AsyncValue.loading();
      return (await _authRepository.updateUser(newPassword: newPassword))
              .user !=
          null;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } finally {
      state = const AsyncValue.data(null);
    }
    return false;
  }

  Future<bool> _isOldPasswordValid(String oldPassword) async {
    if (oldPassword.isEmpty || _authRepository.currentUser?.email == null) {
      return false;
    }

    try {
      state = const AsyncValue.loading();

      final response = await _authRepository.signInWith(
        email: _authRepository.currentUser!.email!,
        password: oldPassword,
      );

      return response.session != null;
    } catch (e) {
      return false;
    } finally {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> _readDebugUser() async {
    if (!kDebugMode || getFormKey() != AuthFormKey.login) return;
    const email = String.fromEnvironment('EMAIL');
    const password = String.fromEnvironment('PASSWORD');
    const autoLogin = bool.fromEnvironment('AUTO_LOGIN');
    if (email.isNotEmpty && password.isNotEmpty) {
      getEmailControl().value = email;
      getPasswordControl().value = password;
      final currentForm = getForm();
      if (autoLogin && currentForm != null && currentForm.valid) await signIn();
    }
  }
}
