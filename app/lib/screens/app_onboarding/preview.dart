import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/util/fitbit_handler.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Preview(
  final Map<String, String>? queryParameters,
  final AppLanguage appLanguage,
) {
  String? selectedRoute;
  String? extra;

  bool hasRoute() => selectedRoute != null && selectedRoute!.isNotEmpty;
  Study? study;
  String? selectedStudyObjectId;
  StudySubject? subject;

  this {
    handleQueries();
  }

  void handleQueries() {
    selectedRoute = getSelectedRoute();
    extra = queryParameters!['extra'];
  }

  Future init() async {
    previewSubjectIdKey();
    try {
      selectedStudyObjectId = await getActiveSubjectId().timeout(
        const Duration(seconds: 5),
      );
    } catch (_) {
      selectedStudyObjectId = null;
    }

    if (containsQuery('languageCode')) {
      final locale = Locale(queryParameters!['languageCode']!);
      appLanguage.changeLanguage(locale);
    }
  }

  Future<bool> handleAuthorization(
    String session, {
    Future<void> Function(String)? recoverSession,
  }) async {
    if (!containsQuery('studyid') || session.isEmpty) return false;

    try {
      await (recoverSession ?? Supabase.instance.client.auth.recoverSession)(
        session,
      );
    } catch (_) {
      return false;
    }

    if (study == null) {
      final savedStudy = await SupabaseQuery.getById<Study>(
        queryParameters!['studyid']!,
      );
      study ??= savedStudy;
    }
    // todo are results visible for published studies inside preview?
    if (study == null) return false;

    return true;
  }

  Future<void> runCommands() async {
    // delete study subscription and progress
    if (containsQueryPair('cmd', 'reset')) {
      final String userId = Supabase.instance.client.auth.currentUser!.id;

      final List<StudySubject> subjects =
          await SupabaseQuery.getAll<StudySubject>(
            selectedColumns: [
              '*',
              'study!study_subject_studyId_fkey(*)',
              'subject_progress(*)',
            ],
            filters: {'user_id': userId},
          );

      for (final subject in subjects) {
        try {
          await subject.delete();
          await FitbitHandler.deleteFitbitCredentials(subject.studyId);
        } catch (e) {
          print(
            '[PreviewApp]: Failed deleting subject ${subject.id} for user $userId: $e',
          );
        }
      }

      deleteActiveStudyReference();
      selectedStudyObjectId = null;
      return;
    }
  }

  String? getSelectedRoute() {
    // check if route is allowed and can be handled
    for (final k in queryParameters!.keys) {
      if ('route' == k) {
        switch (queryParameters![k]) {
          case 'consent':
            return '/${RouteNames.consent}';
          case 'eligibilityCheck': // this should include questionnaire and eligibility_criteria
            return '/${RouteNames.eligibilityCheck}';
          case 'interventionSelection':
            return '/${RouteNames.interventionSelection}';
          case 'journey':
            return '/${RouteNames.journey}';
          case 'questionnaire':
            return '/${RouteNames.questionnaire}';
          case 'dashboard':
            return '/${RouteNames.dashboard}';
          case 'studyOverview':
            return '/${RouteNames.studyOverview}';
          case 'intervention':
            return '/intervention';
          case 'observation':
            return '/observation';
        }
      }
    }
    return null;
  }

  bool containsQuery(String key) {
    return queryParameters!.containsKey(key) &&
        queryParameters![key]!.isNotEmpty;
  }

  bool containsQueryPair(String key, String value) {
    return queryParameters!.containsKey(key) && queryParameters![key] == value;
  }

  /// createSubject: If true, the method will return a new StudySubject if none can be found. Otherwise, null is returned
  Future<StudySubject?> getStudySubject(
    AppState state, {
    bool createSubject = false,
  }) async {
    if (selectedStudyObjectId != null) {
      try {
        if (selectedRoute == '/intervention') {
          final studySubjects = await SupabaseQuery.getAll<StudySubject>(
            selectedColumns: [
              '*',
              'study!study_subject_studyId_fkey(*)',
              'subject_progress(*)',
            ],
          );
          // If the user has a study object Id, there was already a subject created
          // and we need to find the last one they created for the study
          // with the correct interventions
          subject = studySubjects.lastWhere((foundSubject) {
            // todo baseline
            foundSubject.study.schedule.includeBaseline = false;
            return foundSubject.userId ==
                    Supabase.instance.client.auth.currentUser!.id &&
                foundSubject.studyId == study!.id &&
                listEquals(
                  foundSubject.selectedInterventions.map((i) => i.id).toList(),
                  getInterventionIds(),
                );
          });
          // We switch the currently selected study subject with the one we found
          // that has fitting interventions in the correct order
          // Therefore, we get different subject entries for different interventions
          selectedStudyObjectId = subject!.id;
          await storeActiveSubjectId(selectedStudyObjectId!);
          // User is already subscribed to a study
          return subject;
        }
        subject = await SupabaseQuery.getById<StudySubject>(
          selectedStudyObjectId!,
          selectedColumns: [
            '*',
            'study!study_subject_studyId_fkey(*)',
            'subject_progress(*)',
          ],
        );
        if (subject != null && subject!.studyId == study!.id) {
          // User is already subscribed to the study
          return subject;
        }
      } catch (e) {
        print(
          '[PreviewApp]: Failed fetching subject. Maybe subject was reset? Error: $e',
        );
        await deleteActiveStudyReference();
        selectedStudyObjectId = null;
        // todo try sign in again if token expired see loading screen
      }
    }
    if (createSubject) {
      // Create a new study subject
      subject = await _createFakeSubject(state);
      if (selectedRoute == '/intervention') {
        // print("disable base 2");
        // todo might be unnecessary if we have study.schedule.includeBaseline = false;
        subject!.study.schedule.includeBaseline = false;
      }
      return subject;
    }
    return null;
  }

  Future<StudySubject?> _createFakeSubject(AppState state) async {
    if (selectedRoute == '/intervention') {
      // todo maybe remove
      // print("disable base ?");
      study!.schedule.includeBaseline = false;
    }
    subject = StudySubject.fromStudy(
      study!,
      Supabase.instance.client.auth.currentUser!.id,
      getInterventionIds(),
      null, // no invite code
    );
    subject!.startedAt = DateTime.now().toUtc();

    if (state.trackParticipantProgress) {
      // print("[PreviewApp]: Tracking Participant progress");
      try {
        subject = await subject!.save();
        await storeActiveSubjectId(subject!.id);
        // print("[PreviewApp]: Saved subject");
      } catch (e) {
        print('[PreviewApp]: Failed creating subject: $e');
      }
    }
    return subject;
  }

  List<String> getInterventionIds() {
    final interventionList = study!.interventions.map((i) => i.id).toList();
    if (interventionList.isEmpty) {
      return const [];
    }

    List<String> newInterventionList = [];
    // If we have a specific intervention we want to show, select that and another one
    if (selectedRoute == '/intervention' && extra != null) {
      final String? selectedInterventionId = interventionList
          .cast<String?>()
          .firstWhere((id) => id == extra, orElse: () => null);

      if (selectedInterventionId != null) {
        newInterventionList.add(selectedInterventionId);
      }

      final String? alternativeInterventionId = interventionList
          .cast<String?>()
          .firstWhere(
            (id) => id != null && id != selectedInterventionId,
            orElse: () => null,
          );
      if (alternativeInterventionId != null) {
        newInterventionList.add(alternativeInterventionId);
      }
    } else {
      newInterventionList = interventionList.take(2).toList();
    }
    return newInterventionList;
  }
}
