import 'dart:convert';

import 'package:fitbitter/fitbitter.dart' as fitbitter;
import 'package:studyu_app/constants.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class FitbitHandler() {
  static const String _fitbitCredentialsPrefix = 'fitbit_credentials_';

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

    try {
      if (credentials == null) {
        await SecureStorage.delete(key);
      } else {
        await SecureStorage.write(
          key,
          jsonEncode(_credentialsToJson(credentials)),
        );
      }
    } catch (e) {
      StudyULogger.error('Failed to store Fitbit credentials: $e');
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
    try {
      final valid = await fitbitter.FitbitConnector.isTokenValid(
        fitbitCredentials: currentCredentials,
      );

      if (valid) return currentCredentials;

      final newCredentials = await fitbitter.FitbitConnector.refreshToken(
        fitbitCredentials: currentCredentials,
        clientID: studyCredentials.clientId,
        clientSecret: studyCredentials.clientSecret,
      );

      await _storeCredentials(newCredentials, study.id);

      return newCredentials;
    } catch (e) {
      StudyULogger.error('Failed to refresh Fitbit token: $e');
      return null;
    }
  }

  static Future<fitbitter.FitbitCredentials?> _obtainCredentials(
    Study study,
    List<FitbitQuestionType> types,
  ) async {
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

      final newCredentials = await fitbitter.FitbitConnector.authorize(
        clientID: fitbitCreds.clientId,
        clientSecret: fitbitCreds.clientSecret,
        redirectUri: fitbitRedirectUrl,
        callbackUrlScheme: fitbitCallbackScheme,
        scopeList: scopes,
      );

      if (newCredentials != null) {
        await _storeCredentials(newCredentials, study.id);
        return newCredentials;
      }
    } catch (e) {
      StudyULogger.error('Failed to authorize Fitbit credentials: $e');
    }

    return null;
  }

  static DateTime _startOfToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static Future<List<FitbitHeartData>> _fetchHeartData(
    FitbitAuthCredentials studyCredentials,
    fitbitter.FitbitCredentials credentials,
    DateTime latest,
  ) async {
    final manager = fitbitter.FitbitHeartRateIntradayDataManager(
      clientID: studyCredentials.clientId,
      clientSecret: studyCredentials.clientSecret,
    );

    final startDate = DateTime(latest.year, latest.month, latest.day);

    final url = fitbitter.FitbitHeartRateIntradayAPIURL.dayAndDetailLevel(
      date: startDate,
      fitbitCredentials: credentials,
      intradayDetailLevel: fitbitter.IntradayDetailLevel.ONE_MINUTE,
    );

    final items =
        await manager.fetch(url) as List<fitbitter.FitbitHeartRateIntradayData>;

    return items
        .map((item) => FitbitHeartData(item.value!, item.dateOfMonitoring!))
        .where((data) => data.dateTime.isAfter(latest))
        .toList();
  }

  static Future<List<FitbitSleepData>> _fetchSleepData(
    FitbitAuthCredentials studyCredentials,
    fitbitter.FitbitCredentials credentials,
    DateTime latest,
  ) async {
    final manager = fitbitter.FitbitSleepDataManager(
      clientID: studyCredentials.clientId,
      clientSecret: studyCredentials.clientSecret,
    );

    final startDate = DateTime(latest.year, latest.month, latest.day);

    final url = fitbitter.FitbitSleepAPIURL.dateRange(
      startDate: startDate,
      endDate: DateTime.now(),
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
        .where((data) => data.entryDateTime.isAfter(latest))
        .toList();
  }

  static Future<List<FitbitStepData>> _fetchStepData(
    FitbitAuthCredentials studyCredentials,
    fitbitter.FitbitCredentials credentials,
    DateTime latest,
  ) async {
    final manager = fitbitter.FitbitActivityTimeseriesIntradayDataManager(
      clientID: studyCredentials.clientId,
      clientSecret: studyCredentials.clientSecret,
    );

    final startDate = DateTime(latest.year, latest.month, latest.day);

    final days = DateTime.now().difference(startDate).inDays;

    if (days > 1) {
      final List<fitbitter.FitbitActivityTimeseriesData> items = [];

      for (int i = 0; i < days; i++) {
        final url =
            fitbitter.FitbitActivityTimeseriesIntradayAPIURL.dayWithResource(
              date: startDate.add(Duration(days: i)),
              fitbitCredentials: credentials,
              resource: fitbitter.Resource.steps,
              detailLevel: fitbitter.IntradayDetailLevel.ONE_MINUTE,
            );

        StudyULogger.warning(url);

        items.addAll(
          await manager.fetch(url)
              as List<fitbitter.FitbitActivityTimeseriesData>,
        );
      }

      return items
          .map((item) => FitbitStepData(item.value!, item.dateOfMonitoring!))
          .where((data) => data.dateTime.isAfter(latest))
          .toList();
    } else {
      final url =
          fitbitter.FitbitActivityTimeseriesIntradayAPIURL.dayWithResource(
            date: startDate,
            fitbitCredentials: credentials,
            resource: fitbitter.Resource.steps,
            detailLevel: fitbitter.IntradayDetailLevel.ONE_MINUTE,
          );

      final items = await manager.fetch(
        url,
      ) as List<fitbitter.FitbitActivityTimeseriesData>;

      return items
          .map((item) => FitbitStepData(item.value!, item.dateOfMonitoring!))
          .where((data) => data.dateTime.isAfter(latest))
          .toList();
    }
  }

  static Future<List<FitbitData>> _getFitbitData(
    List<FitbitQuestionType> types,
    FitbitAuthCredentials studyCredentials,
    fitbitter.FitbitCredentials credentials,
    String taskId,
    StudySubject subject,
    FitbitQuestion question,
  ) async {
    final allData = <FitbitData>[];
    for (final type in types) {
      final latest =
          await _findLatestDataEntry(subject, taskId, question.id, type) ??
          _startOfToday();

      switch (type) {
        case FitbitQuestionType.steps:
          allData.addAll(
            await _fetchStepData(studyCredentials, credentials, latest),
          );
        case FitbitQuestionType.heartrate:
          allData.addAll(
            await _fetchHeartData(studyCredentials, credentials, latest),
          );
        case FitbitQuestionType.sleep:
          allData.addAll(
            await _fetchSleepData(studyCredentials, credentials, latest),
          );
      }
    }
    return allData;
  }

  static Map<String, dynamic> parseLine(String line) {
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

        for (final raw in (answer.response as List<dynamic>).cast<String>()) {
          final data = FitbitData.fromJson(parseLine(raw));

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
}
