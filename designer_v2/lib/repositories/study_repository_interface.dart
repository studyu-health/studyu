import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class const StudiesPage({
  required final List<Study> studies,
  required final int totalCount,
});

enum StudiesTableColumn() {
  pin,
  title,
  status,
  participation,
  createdAt,
  enrolled,
  active,
  completed,
  action,
}

abstract class IStudyRepository() implements ModelRepository<Study> {
  Future<void> launch(Study study);
  Future<void> deleteParticipants(Study study);
  Future<void> close(Study study);
  // Future<void> deleteProgress(Study study);

  Future<StudiesPage> fetchPage({
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

  Future<List<Study>> fetchPinned(Set<String> pinnedIds);
}
