import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/domain/study_invite.dart';
import 'package:studyu_designer_v2/domain/study_subject.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_to_postgrest.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';
import 'package:studyu_designer_v2/repositories/study_repository_interface.dart';
import 'package:studyu_designer_v2/repositories/supabase_client.dart';
import 'package:studyu_designer_v2/utils/debug_print.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'api_client.g.dart';

abstract class StudyUApi() {
  Future<Study> saveStudy(Study study);

  Future<Study> fetchStudy(
    StudyID studyId, {
    bool withParticipantActivity = true,
    bool withInvites = false,
  });

  Future<List<Study>> getUserStudies({
    bool withParticipantActivity = false,
    bool forDashboardDisplay = false,
  });

  Future<StudiesPage> getUserStudiesPage({
    required int offset,
    required int limit,
    required StudiesTableColumn sortBy,
    required bool ascending,
    required StudiesFilter preset,
    required User currentUser,
    String? searchQuery,
    FilterGroup? advancedFilter,
    List<String> excludeIds,
  });

  Future<List<Study>> getPinnedUserStudies({required Set<String> pinnedIds});

  Future<void> deleteStudy(Study study);

  Future<StudyInvite> saveStudyInvite(StudyInvite invite);

  Future<StudyInvite> fetchStudyInvite(String code);

  Future<List<StudyInvite>> fetchStudyInvitesPage(
    StudyID studyId, {
    required int offset,
    required int limit,
    String? query,
    InviteCodesSortColumn sortBy = InviteCodesSortColumn.code,
    bool ascending = true,
  });

  Future<int> countStudyInvites(StudyID studyId, {String? query});

  Future<Study> fetchStudyFromInvite(String code);

  Future<void> deleteStudyInvite(StudyInvite invite);

  Future<void> deleteStudyInvites(StudyID studyId);

  Future<List<StudySubject>> deleteParticipants(
    Study study,
    List<StudySubject> participants,
  );

  /*
  Future<List<SubjectProgress>> deleteStudyProgress(
      Study study, List<SubjectProgress> records);
   */
  Future<AppConfig> fetchAppConfig();

  Future<StudyUUser> fetchUser(String userId);

  Future<StudyUUser> saveUser(StudyUUser user);

  Future<StudyFitbitCredentials> saveStudyFitbitCredentials(
    StudyFitbitCredentials credentials,
  );

  Future<StudyFitbitCredentials> fetchStudyFitbitCredentials(StudyID studyId);

  Future<void> deleteStudyFitbitCredentials(StudyFitbitCredentials credentials);
}

typedef SupabaseQueryExceptionHandler = void Function(SupabaseQueryError error);

/// Base class for domain-specific exceptions
class APIException() implements Exception;

class StudyNotFoundException() extends APIException;

class MeasurementNotFoundException() extends APIException;

class QuestionNotFoundException() extends APIException;

class ConsentItemNotFoundException() extends APIException;

class InterventionNotFoundException() extends APIException;

class InterventionTaskNotFoundException() extends APIException;

class ReportNotFoundException() extends APIException;

class ReportSectionNotFoundException() extends APIException;

class StudyInviteNotFoundException() extends APIException;

class UserNotFoundException() extends APIException;

abstract class PostgrestErrorCodes() {
  static const String isNotSingleItem = 'PGRST116';
}

class StudyUApiClient({
  /// Reference to the [SupabaseClient] injected via Riverpod
  @override required final SupabaseClient supabaseClient,
  final int testDelayMilliseconds = 0,
}) extends SupabaseClientDependant
    with SupabaseQueryMixin
    implements StudyUApi {
  static const studyInviteColumn = 'study_invite!study_invite_studyId_fkey(*)';

  static final studyColumns = [
    '*',
    'repo(*)',
    'study_fitbit_credentials!study_fitbit_credentials_studyId_fkey(*)',
    'study_participant_count',
    'study_ended_count',
    'active_subject_count',
    'study_missed_days',
  ];

  static final studyDisplayColumns = [
    'id',
    'title',
    'description',
    'user_id',
    'collaborator_emails',
    'participation',
    'result_sharing',
    'status',
    'registry_published',
    'study_participant_count',
    'study_ended_count',
    'active_subject_count',
    'contact',
    'created_at',
  ];

  static final studyWithParticipantActivityColumns = [
    ...studyColumns,
    'study_subject!study_subject_studyId_fkey(*)',
    'study_progress_export(*)',
  ];

  @override
  Future<List<StudySubject>> deleteParticipants(
    Study study,
    List<StudySubject> participants,
  ) async {
    await _testDelay();
    if (participants.isEmpty) {
      return await Future.value([]);
    }
    final selectionCriteria = participants.first.foreignKey(study);
    final request = deleteAll<StudySubject>(selectionCriteria);
    return await _awaitGuarded(request);
  }

  /*
  @override
  Future<List<SubjectProgress>> deleteStudyProgress(
      Study study, List<SubjectProgress> records) async {
    await _testDelay();
    if (records.isEmpty) {
      return Future.value([]);
    }
    final selectionCriteria = records
        .map((record) => {...record.primaryKeys, ...record.foreignKey(study)})
        .toList();
    final request = deleteAll<SubjectProgress>(selectionCriteria);
    return _awaitGuarded(request);
    return Future.value([]);
  }
   */

  /// This function fetches all studies for the current user.
  /// [withParticipantActivity] includes additional participant activity with all columns of Study table => [studyWithParticipantActivityColumns]
  /// [forDashboardDisplay] includes only columns required for the Dashboard page display => [studyDisplayColumns]
  /// otherwise, all columns are fetched => [studyColumns]
  ///
  ///
  /// @return List`<Study`>
  @override
  Future<List<Study>> getUserStudies({
    bool withParticipantActivity = false,
    bool forDashboardDisplay = true,
  }) async {
    await _testDelay();
    // TODO: fix Postgres policy for proper multi-tenancy
    final columns = withParticipantActivity
        ? studyWithParticipantActivityColumns
        : forDashboardDisplay
        ? studyDisplayColumns
        : studyColumns;
    final request = getAll<Study>(selectedColumns: columns);
    return await _awaitGuarded(request);
  }

  @override
  Future<StudiesPage> getUserStudiesPage({
    required int offset,
    required int limit,
    required StudiesTableColumn sortBy,
    required bool ascending,
    required StudiesFilter preset,
    required User currentUser,
    String? searchQuery,
    FilterGroup? advancedFilter,
    List<String> excludeIds = const [],
  }) async {
    await _testDelay();
    final sortColumn = _dbColumnForSort(sortBy);
    if (sortColumn == null) {
      throw ArgumentError(
        'Column ${sortBy.name} cannot be used for server-side sorting',
      );
    }

    try {
      var q = supabaseClient
          .from(Study.tableName)
          .select(studyDisplayColumns.join(','));

      q = _applyPresetFilter(q, preset, currentUser);

      final trimmed = searchQuery?.trim() ?? '';
      if (trimmed.isNotEmpty) {
        final escaped = escapePostgrestLikeLiteral(trimmed);
        q = q.ilike('title', '%$escaped%');
      }

      if (advancedFilter != null) {
        final expr = buildPostgrestFilterExpression(
          advancedFilter,
          currentUser,
        );
        if (expr != null && expr.isNotEmpty) {
          q = q.or(expr);
        }
      }

      if (excludeIds.isNotEmpty) {
        q = q.not('id', 'in', '(${excludeIds.join(',')})');
      }

      final response = await q
          .order(sortColumn, ascending: ascending)
          .order('id', ascending: true) // stable tiebreaker
          .range(offset, offset + limit - 1)
          .count(CountOption.exact);

      return StudiesPage(
        studies: deserializeList<Study>(response.data),
        totalCount: response.count,
      );
    } on UnsupportedFilterException {
      rethrow;
    } on PostgrestException catch (error) {
      throw _apiException(
        error: SupabaseQueryError(
          statusCode: error.code,
          message: error.message,
          details: error.details,
        ),
      );
    } catch (e) {
      throw _apiException(error: e);
    }
  }

  @override
  Future<List<Study>> getPinnedUserStudies({
    required Set<String> pinnedIds,
  }) async {
    if (pinnedIds.isEmpty) return [];
    await _testDelay();
    try {
      final data = await supabaseClient
          .from(Study.tableName)
          .select(studyDisplayColumns.join(','))
          .inFilter('id', pinnedIds.toList());
      return deserializeList<Study>(data);
    } on PostgrestException catch (error) {
      throw _apiException(
        error: SupabaseQueryError(
          statusCode: error.code,
          message: error.message,
          details: error.details,
        ),
      );
    } catch (e) {
      throw _apiException(error: e);
    }
  }

  PostgrestFilterBuilder<List<Map<String, dynamic>>> _applyPresetFilter(
    PostgrestFilterBuilder<List<Map<String, dynamic>>> q,
    StudiesFilter preset,
    User currentUser,
  ) {
    switch (preset) {
      case StudiesFilter.owned:
        return q.eq('user_id', currentUser.id);
      case StudiesFilter.shared:
        return q.contains('collaborator_emails', [currentUser.email ?? '']);
      case StudiesFilter.public:
        return q.or('registry_published.eq.true,result_sharing.eq.public');
      case StudiesFilter.all:
        return q;
    }
  }

  static String? _dbColumnForSort(StudiesTableColumn column) {
    switch (column) {
      case StudiesTableColumn.title:
        return 'title';
      case StudiesTableColumn.status:
        return 'status';
      case StudiesTableColumn.participation:
        return 'participation';
      case StudiesTableColumn.createdAt:
        return 'created_at';
      case StudiesTableColumn.enrolled:
        return 'study_participant_count';
      case StudiesTableColumn.active:
        return 'active_subject_count';
      case StudiesTableColumn.completed:
        return 'study_ended_count';
      case StudiesTableColumn.pin:
      case StudiesTableColumn.action:
        return null;
    }
  }

  @override
  Future<Study> fetchStudy(
    StudyID studyId, {
    bool withParticipantActivity = true,
    bool withInvites = false,
  }) async {
    await _testDelay();
    final columns = [
      ...(withParticipantActivity
          ? studyWithParticipantActivityColumns
          : studyColumns),
      if (withInvites) studyInviteColumn,
    ];
    final request = getById<Study>(studyId, selectedColumns: columns);
    return await _awaitGuarded(
      request,
      onError: {
        PostgrestErrorCodes.isNotSingleItem: (e) =>
            throw StudyNotFoundException(),
      },
    );
  }

  @override
  Future<void> deleteStudy(Study study) async {
    await _testDelay();
    await study.delete();
  }

  @override
  Future<Study> saveStudy(Study study) async {
    await _testDelay();
    // Chain a fetch request to make sure we return a complete and updated study
    final request = study.save().then((study) => fetchStudy(study.id));
    return await _awaitGuarded<Study>(request);
  }

  @override
  Future<StudyInvite> fetchStudyInvite(String code) async {
    final cleanCode = code.trim().toLowerCase();
    await _testDelay();
    final request = getByColumn<StudyInvite>('code', cleanCode);
    return await _awaitGuarded(
      request,
      onError: {
        PostgrestErrorCodes.isNotSingleItem: (e) =>
            throw StudyInviteNotFoundException(),
      },
    );
  }

  @override
  Future<List<StudyInvite>> fetchStudyInvitesPage(
    StudyID studyId, {
    required int offset,
    required int limit,
    String? query,
    InviteCodesSortColumn sortBy = InviteCodesSortColumn.code,
    bool ascending = true,
  }) async {
    await _testDelay();
    final request = _applyInviteCodeQuery(
      supabaseClient
          .from(StudyInvite.tableName)
          .select('*,study_invite_participant_count'),
      studyId: studyId,
      query: query,
    );
    final response = await _awaitGuarded(
      _applyInviteCodeSorting(
        request,
        sortBy: sortBy,
        ascending: ascending,
      ).range(offset, offset + limit - 1),
    );
    return deserializeList<StudyInvite>(response);
  }

  @override
  Future<int> countStudyInvites(StudyID studyId, {String? query}) async {
    await _testDelay();
    return await _awaitGuarded(
      _applyInviteCodeQuery(
        supabaseClient.from(StudyInvite.tableName).count(),
        studyId: studyId,
        query: query,
      ),
    );
  }

  @override
  Future<Study> fetchStudyFromInvite(String code) async {
    final cleanCode = code.trim().toLowerCase();
    await _testDelay();
    try {
      final request = await executeRpc(
        'get_study_record_from_invite',
        params: {'invite_code': cleanCode},
      );
      return deserializeObject<Study>(request);
    } catch (e) {
      throw StudyInviteNotFoundException();
    }
  }

  String? _trimmedOrNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  PostgrestTransformBuilder<PostgrestList> _applyInviteCodeSorting(
    PostgrestTransformBuilder<PostgrestList> request, {
    required InviteCodesSortColumn sortBy,
    required bool ascending,
  }) {
    return switch (sortBy) {
      InviteCodesSortColumn.code => request.order('code', ascending: ascending),
      InviteCodesSortColumn.enrolled =>
        request
            .order('study_invite_participant_count', ascending: ascending)
            .order('code', ascending: true),
    };
  }

  PostgrestFilterBuilder<T> _applyInviteCodeQuery<T>(
    PostgrestFilterBuilder<T> request, {
    required StudyID studyId,
    required String? query,
  }) {
    PostgrestFilterBuilder<T> filtered = request.eq('study_id', studyId);

    final trimmedQuery = _trimmedOrNull(query);
    if (trimmedQuery != null) {
      filtered = filtered.ilike('code', '%$trimmedQuery%');
    }

    return filtered;
  }

  @override
  Future<StudyInvite> saveStudyInvite(StudyInvite invite) async {
    await _testDelay();
    final request = invite.save(); // upsert will override existing record
    return await _awaitGuarded<StudyInvite>(request);
  }

  @override
  Future<void> deleteStudyInvite(StudyInvite invite) async {
    await _testDelay();
    // Delegate to [SupabaseObjectMethods]
    final request = invite.delete(); // upsert will override existing record
    return await _awaitGuarded<void>(request);
  }

  @override
  Future<void> deleteStudyInvites(StudyID studyId) async {
    await _testDelay();
    try {
      await supabaseClient
          .from(StudyInvite.tableName)
          .delete()
          .eq('study_id', studyId);
    } on PostgrestException catch (error) {
      throw SupabaseQueryError(
        statusCode: error.code,
        message: error.message,
        details: error.details,
      );
    }
  }

  @override
  Future<AppConfig> fetchAppConfig() {
    final request = AppConfig.getAppConfig();
    return _awaitGuarded(request);
  }

  @override
  Future<StudyUUser> fetchUser(String userId) async {
    await _testDelay();
    final request = getById<StudyUUser>(userId);
    return await _awaitGuarded(
      request,
      onError: {
        PostgrestErrorCodes.isNotSingleItem: (e) =>
            throw UserNotFoundException(),
      },
    );
  }

  @override
  Future<StudyUUser> saveUser(StudyUUser user) async {
    await _testDelay();
    final request = user.save();
    return await _awaitGuarded<StudyUUser>(request);
  }

  @override
  Future<StudyFitbitCredentials> saveStudyFitbitCredentials(
    StudyFitbitCredentials credentials,
  ) async {
    await _testDelay();
    final request = credentials.save();
    return await _awaitGuarded<StudyFitbitCredentials>(request);
  }

  @override
  Future<StudyFitbitCredentials> fetchStudyFitbitCredentials(
    StudyID studyId,
  ) async {
    await _testDelay();
    final request = getById<StudyFitbitCredentials>(studyId);
    return await _awaitGuarded(
      request,
      onError: {
        PostgrestErrorCodes.isNotSingleItem: (e) =>
            throw StudyNotFoundException(),
      },
    );
  }

  @override
  Future<void> deleteStudyFitbitCredentials(
    StudyFitbitCredentials credentials,
  ) async {
    await _testDelay();
    final request = credentials.delete();
    return await _awaitGuarded<void>(request);
  }

  /// Helper that tries to complete the given Supabase query [future] while
  /// dispatching errors to the registered [onError] handlers.
  ///
  /// [onError] handlers may resolve the error directly or re-raise a
  /// domain-specific exception that bubbles up to the data layer.
  ///
  /// Raises a generic [APIException] for errors that cannot be handled.
  Future<T> _awaitGuarded<T>(
    Future<T> future, {
    Map<String, SupabaseQueryExceptionHandler>? onError,
  }) async {
    try {
      final result = await future;
      return result;
    } on SupabaseQueryError catch (e) {
      if (onError == null ||
          onError[e.statusCode] == null ||
          e.statusCode == null) {
        throw _apiException(error: e);
      }
      final errorHandler = onError[e.statusCode]!;
      errorHandler(e);
    } catch (e) {
      throw _apiException(error: e);
    }
    throw _apiException();
  }

  APIException _apiException({Object? error}) {
    if (error != null && error is SupabaseQueryError) {
      debugLog("Supabase Exception encountered");
      debugLog(error.statusCode.toString());
      debugLog(error.details.toString());
      debugLog(error.message);
    } else if (error != null) {
      debugLog("Unknown exception encountered");
      debugLog(error.toString());
    } else {
      debugLog("Unknown exception encountered. No error provided.");
    }
    return APIException();
  }

  Future<void> _testDelay() async {
    await Future.delayed(
      Duration(milliseconds: testDelayMilliseconds),
      () => null,
    );
  }
}

@riverpod
StudyUApiClient apiClient(Ref ref) =>
    StudyUApiClient(supabaseClient: ref.watch(supabaseClientProvider));
