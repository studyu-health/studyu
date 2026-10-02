import 'dart:async';
import 'dart:convert';

import 'package:fitbitter/fitbitter.dart' as fitbitter;
import 'package:flutter/foundation.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:studyu_app/constants.dart';
import 'package:studyu_app/models/deferred_fitbit_request.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:uuid/uuid.dart';

mixin _FitbitHttpResponse on fitbitter.FitbitDataManager {
  @override
  Future<dynamic> getResponse(fitbitter.FitbitAPIURL url) =>
      FitbitHandler._getDataResponse(url);
}

class _HeartDataManager({required super.clientID, required super.clientSecret})
    extends fitbitter.FitbitHeartRateIntradayDataManager
    with _FitbitHttpResponse;
class _SleepDataManager({required super.clientID, required super.clientSecret})
    extends fitbitter.FitbitSleepDataManager
    with _FitbitHttpResponse;
class _StepDataManager({required super.clientID, required super.clientSecret})
    extends fitbitter.FitbitActivityTimeseriesIntradayDataManager
    with _FitbitHttpResponse;

class FitbitHandler() {
  static const String _fitbitCredentialsPrefix = 'fitbit_credentials_';

  @visibleForTesting
  static http.Client? debugAuthHttpClient;
  @visibleForTesting
  static Future<String> Function(String url, String callbackScheme)?
  debugAuthorizeBrowserOverride;

  static Future<Map<String, dynamic>?> _postAuth(
    fitbitter.FitbitAuthAPIURL url,
  ) async {
    final client = debugAuthHttpClient ?? http.Client();
    try {
      final response = await client
          .post(
            Uri.parse(url.url),
            body: url.data,
            headers: {
              'Authorization': url.authorizationHeader!,
              'Content-Type': 'application/x-www-form-urlencoded',
            },
          )
          .timeout(const Duration(seconds: 30));
      if ([400, 401, 403].contains(response.statusCode)) return null;
      if (response.statusCode >= 500) {
        throw http.ClientException(
          'Failed to fetch Fitbit authorization: HTTP ${response.statusCode}',
        );
      }
      if (response.statusCode != 200) {
        throw StateError(
          'Fitbit authorization request failed: HTTP ${response.statusCode}',
        );
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } finally {
      if (debugAuthHttpClient == null) client.close();
    }
  }

  static Future<dynamic> _getDataResponse(fitbitter.FitbitAPIURL url) async {
    final client = debugAuthHttpClient ?? http.Client();
    try {
      final response = await client
          .get(
            Uri.parse(url.url),
            headers: {
              'Authorization':
                  'Bearer ${url.fitbitCredentials!.fitbitAccessToken}',
            },
          )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode >= 500) {
        throw http.ClientException(
          'Failed to fetch Fitbit data: HTTP ${response.statusCode}',
        );
      }
      if (response.statusCode != 200) {
        throw StateError(
          'Fitbit data request failed: HTTP ${response.statusCode}',
        );
      }
      return jsonDecode(response.body);
    } finally {
      if (debugAuthHttpClient == null) client.close();
    }
  }

  static Future<fitbitter.FitbitCredentials?> _authorizeCredentials(
    FitbitAuthCredentials credentials,
    List<fitbitter.FitbitAuthScope> scopes,
  ) async {
    final state = const Uuid().v4();
    final base = Uri.parse(
      fitbitter.FitbitAuthAPIURL.authorizeForm(
        redirectUri: fitbitRedirectUrl,
        clientID: credentials.clientId,
        scopeList: scopes,
        expiresIn: 28800,
      ).url,
    );
    final url = base
        .replace(queryParameters: {...base.queryParameters, 'state': state})
        .toString();
    final callback =
        await (debugAuthorizeBrowserOverride ??
            (url, scheme) => FlutterWebAuth2.authenticate(
              url: url,
              callbackUrlScheme: scheme,
            ))(url, fitbitCallbackScheme);
    final parameters = Uri.parse(callback).queryParameters;
    final code = parameters['code'];
    if (parameters['state'] != state || code == null || code.isEmpty) {
      return null;
    }
    final data = await _postAuth(
      fitbitter.FitbitAuthAPIURL.authorize(
        redirectUri: fitbitRedirectUrl,
        code: code,
        clientID: credentials.clientId,
        clientSecret: credentials.clientSecret,
      ),
    );
    return data == null
        ? null
        : fitbitter.FitbitCredentials(
            userID: data['user_id'] as String,
            fitbitAccessToken: data['access_token'] as String,
            fitbitRefreshToken: data['refresh_token'] as String,
          );
  }

  @visibleForTesting
  static Future<fitbitter.FitbitCredentials?> Function(
    FitbitAuthCredentials credentials,
    List<FitbitQuestionType> types,
  )?
  debugAuthorizeCredentialsOverride;

  @visibleForTesting
  static Future<bool> Function(Study study, List<FitbitQuestionType> types)?
  debugAuthorizeForOfflineParticipationOverride;

  @visibleForTesting
  static Future<DateTime?> Function(
    StudySubject subject,
    String taskId,
    String questionId,
    FitbitQuestionType type,
  )?
  debugFindLatestDataEntryOverride;

  @visibleForTesting
  static Future<List<FitbitData>> Function(
    StudySubject subject,
    DeferredFitbitRequest request,
    FitbitQuestion question,
  )?
  debugResolveDeferredRequestOverride;

  static Map<String, dynamic> _credentialsToJson(
    fitbitter.FitbitCredentials credentials,
  ) {
    return {
      'userID': credentials.userID,
      'fitbitAccessToken': credentials.fitbitAccessToken,
      'fitbitRefreshToken': credentials.fitbitRefreshToken,
    };
  }

  static fitbitter.FitbitCredentials _credentialsFromJson(
    Map<String, dynamic> jsonData,
  ) {
    return fitbitter.FitbitCredentials(
      userID: jsonData['userID'] as String,
      fitbitAccessToken: jsonData['fitbitAccessToken'] as String,
      fitbitRefreshToken: jsonData['fitbitRefreshToken'] as String,
    );
  }

  static Future<void> deleteFitbitCredentials(String studyKey) async {
    if (await SecureStorage.containsKey('$_fitbitCredentialsPrefix$studyKey')) {
      await SecureStorage.delete('$_fitbitCredentialsPrefix$studyKey');
    }
  }

  static Future<void> _storeCredentials(
    fitbitter.FitbitCredentials? credentials,
    String studyKey,
  ) async {
    final key = '$_fitbitCredentialsPrefix$studyKey';

    if (credentials == null) {
      await SecureStorage.delete(key);
    } else {
      await SecureStorage.write(
        key,
        jsonEncode(_credentialsToJson(credentials)),
      );
    }
  }

  static Future<fitbitter.FitbitCredentials?> _loadCredentials(
    String studyKey,
  ) async {
    final key = '$_fitbitCredentialsPrefix$studyKey';

    try {
      if (await SecureStorage.containsKey(key)) {
        final storedString = await SecureStorage.read(key);
        if (storedString != null) {
          final jsonData = jsonDecode(storedString) as Map<String, dynamic>;
          return _credentialsFromJson(jsonData);
        }
      }
    } catch (e) {
      StudyULogger.error('Failed to load Fitbit credentials: $e');
    }

    return null;
  }

  static Future<fitbitter.FitbitCredentials?> _validateToken(
    Study study,
    FitbitAuthCredentials studyCredentials,
    fitbitter.FitbitCredentials currentCredentials,
  ) async {
    final validation = await _postAuth(
      fitbitter.FitbitAuthAPIURL.isTokenValid(
        fitbitAccessToken: currentCredentials.fitbitAccessToken,
      ),
    );
    if (validation?['active'] == true) return currentCredentials;
    final data = await _postAuth(
      fitbitter.FitbitAuthAPIURL.refreshToken(
        fitbitCredentials: currentCredentials,
        clientID: studyCredentials.clientId,
        clientSecret: studyCredentials.clientSecret,
      ),
    );
    if (data == null) return null;
    final refreshed = currentCredentials.copyWith(
      fitbitAccessToken: data['access_token'] as String,
      fitbitRefreshToken: data['refresh_token'] as String,
    );
    await _storeCredentials(refreshed, study.id);
    return refreshed;
  }

  static Future<fitbitter.FitbitCredentials?> _obtainCredentials(
    Study study,
    List<FitbitQuestionType> types, {
    bool interactive = true,
  }) async {
    final fitbitCreds = study.fitbitCredentials?.fitbitCredentials;

    if (fitbitCreds == null) {
      StudyULogger.error('Study is missing Fitbit credentials.');
      return null;
    }

    final storedCredentials = await _loadCredentials(study.id);

    if (storedCredentials != null) {
      final validCredentials = await _validateToken(
        study,
        fitbitCreds,
        storedCredentials,
      );

      if (validCredentials != null) return validCredentials;
    }
    if (!interactive) return null;
    fitbitter.FitbitCredentials? newCredentials;
    try {
      final scopes = <fitbitter.FitbitAuthScope>[];

      for (final type in types) {
        switch (type) {
          case FitbitQuestionType.steps:
            scopes.add(fitbitter.FitbitAuthScope.ACTIVITY);
          case FitbitQuestionType.heartrate:
            scopes.add(fitbitter.FitbitAuthScope.HEART_RATE);
          case FitbitQuestionType.sleep:
            scopes.add(fitbitter.FitbitAuthScope.SLEEP);
        }
      }

      newCredentials = debugAuthorizeCredentialsOverride != null
          ? await debugAuthorizeCredentialsOverride!(fitbitCreds, types)
          : await _authorizeCredentials(fitbitCreds, scopes);
    } catch (e) {
      if (connectionStatusFromError(e) != null) rethrow;
      StudyULogger.error('Failed to authorize Fitbit credentials: $e');
      return null;
    }
    if (newCredentials != null) {
      await _storeCredentials(newCredentials, study.id);
    }
    return newCredentials;
  }

  static DateTime _startOfToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static bool _withinWindow(DateTime dateTime, DateTime latest, DateTime? end) {
    return dateTime.isAfter(latest) && (end == null || !dateTime.isAfter(end));
  }

  static List<DateTime> fetchDays(DateTime start, DateTime end) {
    final days = <DateTime>[];
    var day = _startOfDay(start.toLocal());
    final last = _startOfDay(end.toLocal());
    while (!day.isAfter(last)) {
      days.add(day);
      day = day.isUtc
          ? DateTime.utc(day.year, day.month, day.day + 1)
          : DateTime(day.year, day.month, day.day + 1);
    }
    return days;
  }

  static Future<List<FitbitHeartData>> _fetchHeartData(
    FitbitAuthCredentials studyCredentials,
    fitbitter.FitbitCredentials credentials,
    DateTime latest, {
    DateTime? end,
  }) async {
    final manager = _HeartDataManager(
      clientID: studyCredentials.clientId,
      clientSecret: studyCredentials.clientSecret,
    );

    final items = <fitbitter.FitbitHeartRateIntradayData>[];
    for (final day in fetchDays(latest, end ?? DateTime.now())) {
      final url = fitbitter.FitbitHeartRateIntradayAPIURL.dayAndDetailLevel(
        date: day,
        fitbitCredentials: credentials,
        intradayDetailLevel: fitbitter.IntradayDetailLevel.ONE_MINUTE,
      );
      items.addAll(
        await manager.fetch(url) as List<fitbitter.FitbitHeartRateIntradayData>,
      );
    }

    return items
        .map((item) => FitbitHeartData(item.value!, item.dateOfMonitoring!))
        .where((data) => _withinWindow(data.dateTime, latest, end))
        .toList();
  }

  static Future<List<FitbitSleepData>> _fetchSleepData(
    FitbitAuthCredentials studyCredentials,
    fitbitter.FitbitCredentials credentials,
    DateTime latest, {
    DateTime? end,
  }) async {
    final manager = _SleepDataManager(
      clientID: studyCredentials.clientId,
      clientSecret: studyCredentials.clientSecret,
    );

    final startDate = _startOfDay(latest.toLocal());

    final url = fitbitter.FitbitSleepAPIURL.dateRange(
      startDate: startDate,
      endDate: end?.toLocal() ?? DateTime.now(),
      fitbitCredentials: credentials,
    );

    final items = await manager.fetch(url) as List<fitbitter.FitbitSleepData>;

    //TODO: handle data that spans multiple days
    return items
        .map(
          (item) => FitbitSleepData(
            item.level!,
            item.entryDateTime!,
            item.dateOfSleep!,
          ),
        )
        .where((data) => _withinWindow(data.entryDateTime, latest, end))
        .toList();
  }

  static Future<List<FitbitStepData>> _fetchStepData(
    FitbitAuthCredentials studyCredentials,
    fitbitter.FitbitCredentials credentials,
    DateTime latest, {
    DateTime? end,
  }) async {
    final manager = _StepDataManager(
      clientID: studyCredentials.clientId,
      clientSecret: studyCredentials.clientSecret,
    );

    final items = <fitbitter.FitbitActivityTimeseriesData>[];
    for (final day in fetchDays(latest, end ?? DateTime.now())) {
      final url =
          fitbitter.FitbitActivityTimeseriesIntradayAPIURL.dayWithResource(
            date: day,
            fitbitCredentials: credentials,
            resource: fitbitter.Resource.steps,
            detailLevel: fitbitter.IntradayDetailLevel.ONE_MINUTE,
          );
      items.addAll(
        await manager.fetch(url)
            as List<fitbitter.FitbitActivityTimeseriesData>,
      );
    }
    return items
        .map((item) => FitbitStepData(item.value!, item.dateOfMonitoring!))
        .where((data) => _withinWindow(data.dateTime, latest, end))
        .toList();
  }

  /// Fetches Fitbit data for each of [types]. For live (online) syncing,
  /// each type's own fetch window starts right after that type's last known
  /// entry (or today, if none) and ends now — [windowStartOverride]/
  /// [windowEnd] are used instead when resolving a deferred request, so the
  /// window matches what was recorded at defer time regardless of what's
  /// changed since.
  static Future<List<FitbitData>> _getFitbitData(
    List<FitbitQuestionType> types,
    FitbitAuthCredentials studyCredentials,
    fitbitter.FitbitCredentials credentials,
    String taskId,
    StudySubject subject,
    FitbitQuestion question, {
    DateTime? windowStartOverride,
    Map<FitbitQuestionType, DateTime> windowStarts = const {},
    DateTime? windowEnd,
  }) async {
    final allData = <FitbitData>[];
    for (final type in types) {
      var latest =
          windowStarts[type] ??
          await _latestDataEntryFor(subject, taskId, question.id, type) ??
          windowStartOverride ??
          _startOfToday();
      if (windowStartOverride != null && latest.isBefore(windowStartOverride)) {
        latest = windowStartOverride;
      }
      if (windowEnd != null && latest.isAfter(windowEnd)) latest = windowEnd;

      switch (type) {
        case FitbitQuestionType.steps:
          allData.addAll(
            await _fetchStepData(
              studyCredentials,
              credentials,
              latest,
              end: windowEnd,
            ),
          );
        case FitbitQuestionType.heartrate:
          allData.addAll(
            await _fetchHeartData(
              studyCredentials,
              credentials,
              latest,
              end: windowEnd,
            ),
          );
        case FitbitQuestionType.sleep:
          allData.addAll(
            await _fetchSleepData(
              studyCredentials,
              credentials,
              latest,
              end: windowEnd,
            ),
          );
      }
    }
    return allData;
  }

  static Map<String, dynamic> parseLine(String line) {
    try {
      final decoded = jsonDecode(line);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      /* Read older answer strings below. */
    }
    var cleanedLine = line.trim();
    if (cleanedLine.startsWith('"') && cleanedLine.endsWith('"')) {
      cleanedLine = cleanedLine.substring(1, cleanedLine.length - 1);
    }
    if (cleanedLine.startsWith('{') && cleanedLine.endsWith('}')) {
      cleanedLine = cleanedLine.substring(1, cleanedLine.length - 1).trim();
    }
    final parts = cleanedLine.split(',');
    final mapped = <String, dynamic>{};
    for (var part in parts) {
      part = part.trim();
      final idx = part.indexOf(':');
      if (idx == -1) continue;
      final key = part.substring(0, idx).trim();
      final val = part.substring(idx + 1).trim();
      if (key == 'value') {
        mapped[key] = double.tryParse(val) ?? val;
      } else {
        mapped[key] = val;
      }
    }
    return mapped;
  }

  /*static Future<DateTime?> _findLatestDataEntry(
    StudySubject subject,
    String taskId,
    String questionId,
    FitbitQuestionType type,
  ) async {
    if (subject.progress.isEmpty) {
      return null;
    }

    final answers = subject.progress
        .where((entry) =>
            entry.taskId == taskId && entry.resultType == 'QuestionnaireState')
        .map((entry) =>
            (entry.result as Result<QuestionnaireState>).result.answers.values)
        .expand((answerList) => answerList)
        .where((answer) => answer.question == questionId)
        .map((answer) => answer.response as List<dynamic>)
        .toList();

    if (answers.isEmpty) return null;

    final fitbitData = answers
        .map((raw) => raw.cast<String>())
        .map((stringList) => stringList.map(parseLine).toList())
        .map((parsedList) => parsedList.map(FitbitData.fromJson).toList())
        .toList()
        .expand((element) => element)
        .toList();

    if (fitbitData.isEmpty) return null;

    final fitbitDataTypedList = fitbitData
        .where((data) =>
            data.type.toLowerCase() == type.toReadable().toLowerCase())
        .toList();

    if (fitbitDataTypedList.isEmpty) return null;

    switch (type) {
      case FitbitQuestionType.steps:
        return fitbitDataTypedList.last.dateTime;
      case FitbitQuestionType.heartrate:
        return fitbitDataTypedList.last.dateTime;
      case FitbitQuestionType.sleep:
        return (fitbitDataTypedList.last as FitbitSleepData).entryDateTime;
    }
  }*/

  //refactored
  static Future<DateTime?> _findLatestDataEntry(
    StudySubject subject,
    String taskId,
    String questionId,
    FitbitQuestionType type,
  ) async {
    if (subject.progress.isEmpty) return null;

    DateTime? latestDate;
    final typeLower = type.toReadable().toLowerCase();

    for (final entry in subject.progress) {
      if (entry.taskId != taskId || entry.resultType != 'QuestionnaireState') {
        continue;
      }

      final questionnaireState =
          (entry.result as Result<QuestionnaireState>).result;

      for (final answer in questionnaireState.answers.values) {
        if (answer.question != questionId) continue;

        for (final raw in answer.response as List<dynamic>) {
          final data = raw is FitbitData
              ? raw
              : FitbitData.fromJson(parseLine(raw as String));

          if (data.type.toLowerCase() != typeLower) continue;

          final DateTime date = switch (type) {
            FitbitQuestionType.sleep => (data as FitbitSleepData).entryDateTime,
            _ => data.dateTime,
          };

          if (latestDate == null || date.isAfter(latestDate)) {
            latestDate = date;
          }
        }
      }
    }

    return latestDate;
  }

  static Future<DateTime?> _latestDataEntryFor(
    StudySubject subject,
    String taskId,
    String questionId,
    FitbitQuestionType type,
  ) {
    final override = debugFindLatestDataEntryOverride;
    if (override != null) return override(subject, taskId, questionId, type);
    return _findLatestDataEntry(subject, taskId, questionId, type);
  }

  static DateTime _startOfDay(DateTime date) => date.isUtc
      ? DateTime.utc(date.year, date.month, date.day)
      : DateTime(date.year, date.month, date.day);

  static Future<List<FitbitData>> syncFitbitData(
    Study study,
    FitbitQuestion question,
    String taskId,
    StudySubject subject,
  ) async {
    final credentials = await _obtainCredentials(study, question.types);

    if (credentials == null) {
      throw Exception(
        'Failed to obtain Fitbit credentials. Please try syncing again',
      );
    }
    return await _getFitbitData(
      question.types,
      study.fitbitCredentials!.fitbitCredentials,
      credentials,
      taskId,
      subject,
      question,
    );
  }

  /// The union of Fitbit data types any `FitbitQuestion` in [study] needs —
  /// empty when the study has no Fitbit-based questions at all.
  static List<FitbitQuestionType> requiredTypesForStudy(Study study) {
    final tasks = <Task>[
      ...study.observations,
      ...study.interventions.expand((intervention) => intervention.tasks),
    ];
    return tasks
        .whereType<QuestionnaireTask>()
        .expand((task) => task.questions.questions.whereType<FitbitQuestion>())
        .expand((question) => question.types)
        .toSet()
        .toList();
  }

  /// Gates study-start subject creation on obtaining Fitbit authorization
  /// up front, while still online, so later offline completions can use the
  /// already-stored credentials. A study with no Fitbit questions trivially
  /// succeeds without attempting anything.
  static Future<bool> authorizeForOfflineParticipation(Study study) async {
    final types = requiredTypesForStudy(study);
    if (types.isEmpty) return true;
    final override = debugAuthorizeForOfflineParticipationOverride;
    if (override != null) return await override(study, types);
    return await _obtainCredentials(study, types) != null;
  }

  /// Captures what [resolveDeferredRequest] will need to re-fetch this
  /// [question]'s data later: the fetch window
  /// `[lastKnownDataEntry ?? startOfAnswerDay, completedAt]`. When [question]
  /// requires more than one data type, the earliest known entry across all
  /// of them is used as the window start, so no type's data is missed — the
  /// per-type fetch at resolve time still only keeps what's actually after
  /// that type's own last entry.
  static Future<DeferredFitbitRequest> createDeferredRequest({
    required StudySubject subject,
    required String interventionId,
    required String taskId,
    required String periodId,
    required FitbitQuestion question,
    required DateTime completedAt,
  }) async {
    final windowEnd = completedAt.toUtc();
    DateTime? earliestLatest;
    final windowStarts = <FitbitQuestionType, DateTime>{};
    for (final type in question.types) {
      final latest =
          await _latestDataEntryFor(subject, taskId, question.id, type) ??
          _startOfDay(completedAt.toLocal()).toUtc();
      windowStarts[type] = latest.toUtc();
      if (earliestLatest == null || latest.isBefore(earliestLatest)) {
        earliestLatest = latest;
      }
    }
    return DeferredFitbitRequest(
      subjectId: subject.id,
      interventionId: interventionId,
      taskId: taskId,
      periodId: periodId,
      questionId: question.id,
      windowStart: earliestLatest ?? _startOfDay(completedAt.toLocal()).toUtc(),
      windowStarts: windowStarts,
      windowEnd: windowEnd,
      completedAt: completedAt,
    );
  }

  /// Re-fetches Fitbit data for [request]'s recorded window, using
  /// current/refreshed credentials — the idempotent-retry path in
  /// spec.md's sync state machine relies on the caller checking for an
  /// already-matching remote progress entry *before* calling this.
  static Future<List<FitbitData>> resolveDeferredRequest(
    StudySubject subject,
    DeferredFitbitRequest request,
    FitbitQuestion question, {
    @visibleForTesting DateTime? resolveTime,
  }) async {
    final now = (resolveTime ?? DateTime.now()).toUtc();
    final end = request.windowEnd.isAfter(now) ? now : request.windowEnd;
    final start = request.windowStart.isAfter(end) ? end : request.windowStart;
    final effectiveRequest =
        start == request.windowStart && end == request.windowEnd
        ? request
        : DeferredFitbitRequest(
            subjectId: request.subjectId,
            interventionId: request.interventionId,
            taskId: request.taskId,
            periodId: request.periodId,
            questionId: request.questionId,
            windowStart: start,
            windowEnd: end,
            windowStarts: request.windowStarts,
            questionnaireState: request.questionnaireState,
            completedAt: request.completedAt,
          );
    final override = debugResolveDeferredRequestOverride;
    if (override != null) {
      return await override(subject, effectiveRequest, question);
    }
    final study = subject.study;
    final credentials = await _obtainCredentials(
      study,
      question.types,
      interactive: false,
    );
    if (credentials == null) {
      throw Exception(
        'Failed to obtain Fitbit credentials. Please try syncing again',
      );
    }
    return await _getFitbitData(
      question.types,
      study.fitbitCredentials!.fitbitCredentials,
      credentials,
      request.taskId,
      subject,
      question,
      windowStartOverride: effectiveRequest.windowStart,
      windowStarts: effectiveRequest.windowStarts,
      windowEnd: effectiveRequest.windowEnd,
    );
  }
}
