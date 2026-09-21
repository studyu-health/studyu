import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/src/utils/connection_status.dart';
import 'package:studyu_flutter_common/src/utils/date_time_format.dart';
import 'package:studyu_flutter_common/src/utils/user.dart';

void main() {
  tearDown(() {
    appConnectionStatusController.reset();
  });

  test('infers date format from locale', () {
    expect(
      DateTimeFormat.defaultDateFormat(const Locale('de', 'DE')),
      DateFormatPreference.german,
    );
    expect(
      DateTimeFormat.defaultDateFormat(const Locale('en', 'US')),
      DateFormatPreference.us,
    );
    expect(
      DateTimeFormat.defaultDateFormat(const Locale('en', 'GB')),
      DateFormatPreference.european,
    );
    expect(
      DateTimeFormat.defaultDateFormat(const Locale('en', 'AU')),
      DateFormatPreference.european,
    );
    expect(
      DateTimeFormat.defaultDateFormat(const Locale('en', 'IE')),
      DateFormatPreference.european,
    );
    expect(
      DateTimeFormat.defaultDateFormat(const Locale('fr', 'FR')),
      DateFormatPreference.iso,
    );
  });

  test('infers time format from locale', () {
    expect(
      DateTimeFormat.defaultTimeFormatForLocale(const Locale('en', 'US')),
      TimeFormatPreference.h12,
    );
    expect(
      DateTimeFormat.defaultTimeFormatForLocale(const Locale('en', 'GB')),
      TimeFormatPreference.h24,
    );
    expect(
      DateTimeFormat.defaultTimeFormatForLocale(const Locale('de', 'DE')),
      TimeFormatPreference.h24,
    );
  });

  test('uses the supplied locale for default formatting', () async {
    await initializeDateFormatting('de_DE');
    expect(
      DateTimeFormat.formatDateForLocale(
        const Locale('de', 'DE'),
        DateTime(2024, 12, 31),
      ),
      '31.12.2024',
    );
    expect(
      DateTimeFormat.formatTimeForLocale(
        const Locale('en', 'US'),
        const TimeOfDay(hour: 14, minute: 30),
      ),
      '2:30 PM',
    );
  });

  test('formats time with the selected preference', () {
    const time = TimeOfDay(hour: 14, minute: 30);

    expect(
      DateTimeFormat.formatTimeForLocale(
        const Locale('en', 'US'),
        time,
        preference: TimeFormatPreference.h12,
      ),
      '2:30 PM',
    );
    expect(
      DateTimeFormat.formatTimeForLocale(
        const Locale('en', 'US'),
        time,
        preference: TimeFormatPreference.h24,
      ),
      '14:30',
    );
  });

  test('formats dates and date-times with explicit preferences', () {
    final dateTime = DateTime(2024, 12, 31, 14, 30);

    expect(
      DateTimeFormat.formatDateForLocale(
        const Locale('en', 'US'),
        dateTime,
        preference: DateFormatPreference.iso,
      ),
      '2024-12-31',
    );
    expect(
      DateTimeFormat.formatDateTimeForLocale(
        const Locale('en', 'US'),
        dateTime,
        datePreference: DateFormatPreference.european,
        timePreference: TimeFormatPreference.h24,
      ),
      '31/12/2024 14:30',
    );
  });

  testWidgets('uses MediaQuery preferences with a BuildContext', (
    tester,
  ) async {
    Future<void> verify(
      bool? alwaysUse24HourFormat,
      String expectedTime,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', 'US'),
          home: MediaQuery(
            data: MediaQueryData(
              alwaysUse24HourFormat: alwaysUse24HourFormat ?? false,
            ),
            child: Builder(
              builder: (context) {
                if (alwaysUse24HourFormat == null) {
                  expect(
                    DateTimeFormat.defaultTimeFormatForLocale(
                      const Locale('en', 'US'),
                    ),
                    TimeFormatPreference.h12,
                  );
                } else {
                  expect(
                    DateTimeFormat.defaultTimeFormat(context),
                    alwaysUse24HourFormat
                        ? TimeFormatPreference.h24
                        : TimeFormatPreference.h12,
                  );
                }
                expect(
                  DateTimeFormat.formatDate(
                    context,
                    DateTime(2024, 12, 31),
                    preference: DateFormatPreference.iso,
                  ),
                  '2024-12-31',
                );
                expect(
                  DateTimeFormat.formatTime(
                    context,
                    const TimeOfDay(hour: 14, minute: 30),
                  ),
                  expectedTime,
                );
                expect(
                  DateTimeFormat.formatDateTime(
                    context,
                    DateTime(2024, 12, 31, 14, 30),
                  ),
                  '${DateTimeFormat.formatDateForLocale(const Locale('en', 'US'), DateTime(2024, 12, 31))} $expectedTime',
                );
                return const SizedBox();
              },
            ),
          ),
        ),
      );
    }

    await verify(false, '2:30 PM');
    await verify(true, '14:30');
  });

  testWidgets('uses platform defaults without MediaQuery', (tester) async {
    tester.platformDispatcher.localeTestValue = const Locale('en', 'US');
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);

    await tester.pumpWidget(
      Builder(
        builder: (context) {
          expect(DateTimeFormat.defaultDateFormat(), DateFormatPreference.us);
          expect(
            DateTimeFormat.defaultTimeFormat(context),
            TimeFormatPreference.h12,
          );
          return const SizedBox();
        },
      ),
    );
  });

  test('ensureParticipantSignedIn returns true for existing session', () async {
    var signInCalls = 0;
    var signUpCalls = 0;
    var validateCalls = 0;

    final success = await ensureParticipantSignedIn(
      isSignedIn: () => true,
      validateSession: () async {
        validateCalls++;
        return true;
      },
      signIn: () async {
        signInCalls++;
        return false;
      },
      signUp: () async {
        signUpCalls++;
        return false;
      },
    );

    expect(success, isTrue);
    expect(validateCalls, 1);
    expect(signInCalls, 0);
    expect(signUpCalls, 0);
  });

  test('ensureParticipantSignedIn clears invalid current session before restoring credentials', () async {
    var clearSessionCalls = 0;
    var signInCalls = 0;
    var signUpCalls = 0;

    final success = await ensureParticipantSignedIn(
      isSignedIn: () => true,
      validateSession: () async => false,
      clearSession: () async {
        clearSessionCalls++;
      },
      signIn: () async {
        signInCalls++;
        return false;
      },
      signUp: () async {
        signUpCalls++;
        return true;
      },
    );

    expect(success, isTrue);
    expect(clearSessionCalls, 1);
    expect(signInCalls, 1);
    expect(signUpCalls, 1);
  });

  test(
    'ensureParticipantSignedIn reuses stored participant credentials',
    () async {
      var signUpCalls = 0;

      final success = await ensureParticipantSignedIn(
        isSignedIn: () => false,
        signIn: () async => true,
        signUp: () async {
          signUpCalls++;
          return true;
        },
      );

      expect(success, isTrue);
      expect(signUpCalls, 0);
    },
  );

  test(
    'ensureParticipantSignedIn signs up when no session can be restored',
    () async {
      var signUpCalls = 0;

      final success = await ensureParticipantSignedIn(
        isSignedIn: () => false,
        signIn: () async => false,
        signUp: () async {
          signUpCalls++;
          return true;
        },
      );

      expect(success, isTrue);
      expect(signUpCalls, 1);
    },
  );

  test(
    'ensureParticipantSignedIn keeps credentials on connectivity failure',
    () async {
      var signInCalls = 0;
      var signUpCalls = 0;

      final success = await ensureParticipantSignedIn(
        isSignedIn: () => true,
        validateSession: () => Future<bool>.error(
          Exception(
            'AuthRetryableFetchException(message: ClientException: Failed to fetch)',
          ),
        ),
        signIn: () async {
          signInCalls++;
          return true;
        },
        signUp: () async {
          signUpCalls++;
          return true;
        },
      );

      expect(success, isFalse);
      expect(signInCalls, 0);
      expect(signUpCalls, 0);
      expect(
        appConnectionStatusController.status,
        AppConnectionStatus.backendUnavailable,
      );
    },
  );

  test('ensureParticipantSignedIn trusts existing session while connectivity is degraded', () async {
    appConnectionStatusController.setStatus(
      AppConnectionStatus.backendUnavailable,
    );
    var validateCalls = 0;
    var signInCalls = 0;
    var signUpCalls = 0;

    final success = await ensureParticipantSignedIn(
      isSignedIn: () => true,
      validateSession: () async {
        validateCalls++;
        return false;
      },
      signIn: () async {
        signInCalls++;
        return false;
      },
      signUp: () async {
        signUpCalls++;
        return false;
      },
    );

    expect(success, isTrue);
    expect(validateCalls, 0);
    expect(signInCalls, 0);
    expect(signUpCalls, 0);
  });

  test('ensureParticipantSignedIn skips auth recovery without session while connectivity is degraded', () async {
    appConnectionStatusController.setStatus(AppConnectionStatus.deviceOffline);
    var signInCalls = 0;
    var signUpCalls = 0;

    final success = await ensureParticipantSignedIn(
      isSignedIn: () => false,
      signIn: () async {
        signInCalls++;
        return true;
      },
      signUp: () async {
        signUpCalls++;
        return true;
      },
    );

    expect(success, isFalse);
    expect(signInCalls, 0);
    expect(signUpCalls, 0);
  });

  test('shouldAttemptParticipantAuthRecovery skips connectivity errors', () {
    expect(
      shouldAttemptParticipantAuthRecovery(
        Exception('ClientException: Failed to fetch'),
      ),
      isFalse,
    );
    expect(
      shouldAttemptParticipantAuthRecovery(
        Exception('AuthApiException(code: invalid_credentials)'),
      ),
      isTrue,
    );
  });

  test(
    'connectionStatusFromError keeps invalid credentials out of connectivity',
    () {
      expect(
        connectionStatusFromError(
          Exception('AuthApiException(code: invalid_credentials)'),
        ),
        isNull,
      );
    },
  );

  test('connectionStatusFromError treats connection refused as backend unavailable', () {
    expect(
      connectionStatusFromError(
        Exception('SocketException: Connection refused'),
      ),
      AppConnectionStatus.backendUnavailable,
    );
  });
}
