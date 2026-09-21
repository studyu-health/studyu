import 'dart:async';
import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/subjects.dart';
import 'package:studyu_designer_v2/features/app_controller.dart';
import 'package:studyu_designer_v2/repositories/supabase_client.dart';
import 'package:studyu_designer_v2/utils/behaviour_subject.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_repository.g.dart';

abstract class IAuthRepository() extends IAppDelegate {
  // - Authentication
  User? get currentUser;
  bool get isLoggedIn;
  Session? get session;
  String? get serializedSession;
  late bool allowPasswordReset = false;
  Stream<User?> watchAuthStateChanges({bool emitLastEvent});
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  });
  Future<AuthResponse> signInWith({
    required String email,
    required String password,
  });
  Future<void> signOut();
  Future<void> resetPasswordForEmail({required String email});
  Future<UserResponse> updateUser({required String newPassword});
  // - Lifecycle
  void dispose();
}

class AuthRepository({
  /// Reference to the Supabase API client injected via Riverpod
  required final SupabaseClient supabaseClient,
}) implements IAuthRepository {
  /// A stream controller for broadcasting the currently logged in user
  /// Broadcasts null if the user is logged out
  final BehaviorSubject<User?> _authStateStreamController =
      BehaviorSubject.seeded(null);
  late final _authStateSuppressedController = SuppressedBehaviorSubject(
    _authStateStreamController,
  );

  /// Private subscription for synchronizing with [SupabaseClient] auth state
  late final StreamSubscription<AuthState> _authSubscription;

  GoTrueClient get authClient => supabaseClient.auth;

  @override
  Session? get session => authClient.currentSession;

  this {
    _registerAuthListener();
  }

  /// Register as a listener on [SupabaseClient] to re-expose auth state
  /// changes on the repository's stream
  void _registerAuthListener() {
    _authSubscription = supabaseClient.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;

      // Handle auth state change
      switch (event) {
        case AuthChangeEvent.initialSession:
          print("authRepo initialSession");
          _authStateStreamController.add(authClient.currentUser);
        case AuthChangeEvent.signedIn:
          print("authRepo signedIn");
          // Update stream with logged in user
          _authStateStreamController.add(authClient.currentUser);
        case AuthChangeEvent.signedOut:
          print("authRepo signedOut");
          // Send null to indicate that no user is available (logged out)
          _authStateStreamController.add(null);
        case AuthChangeEvent.userUpdated:
          print("authRepo userUpdated");
          // Update stream with new user object
          _authStateStreamController.add(authClient.currentUser);
        case AuthChangeEvent.passwordRecovery:
          print("authRepo passwordRecovery");
          //router.dispatch(RoutingIntents.passwordRecovery);
          allowPasswordReset = true;
        case AuthChangeEvent.tokenRefreshed:
          print("authRepo tokenRefreshed");
        // ignore: deprecated_member_use
        case AuthChangeEvent.userDeleted:
          print("authRepo userDeleted");
          _authStateStreamController.add(null);
        case AuthChangeEvent.mfaChallengeVerified:
          print("authRepo mfaChallengeVerified");
      }
    });
  }

  @override
  bool allowPasswordReset = false;

  @override
  String? get serializedSession => jsonEncode(session);

  @override
  User? get currentUser => _authStateStreamController.value;

  @override
  bool get isLoggedIn => currentUser != null;

  @override
  BehaviorSubject<User?> watchAuthStateChanges({bool emitLastEvent = true}) =>
      emitLastEvent
      ? _authStateStreamController
      : _authStateSuppressedController.subject;

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await authClient.signUp(email: email, password: password);
  }

  @override
  Future<AuthResponse> signInWith({
    required String email,
    required String password,
  }) async {
    return await authClient.signInWithPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signOut() async {
    return await authClient.signOut();
  }

  @override
  Future<void> resetPasswordForEmail({required String email}) async {
    return await authClient.resetPasswordForEmail(email);
  }

  @override
  Future<UserResponse> updateUser({required String newPassword}) async {
    return await authClient.updateUser(UserAttributes(password: newPassword));
  }

  @override
  void dispose() {
    _authStateStreamController.close();
    _authStateSuppressedController.close();
    _authSubscription.cancel();
  }

  // - IAppDelegate

  @override
  Future<bool> onAppStart() async {
    return true;
  }
}

@riverpod
AuthRepository authRepository(Ref ref) {
  final authRepository = AuthRepository(
    supabaseClient: ref.watch(supabaseClientProvider),
  );
  return authRepository;
}
