import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/filter_types.dart';
import 'package:studyu_designer_v2/routing/router_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum StudiesFilter() with GoRouteParamEnum {
  all,
  owned,
  shared,
  public,
}

extension StudiesFilterByUser on StudiesFilter {
  FilterGroup toFilterGroup(User user) {
    switch (this) {
      case StudiesFilter.all:
        return FilterGroup(); // Empty group matches all
      case StudiesFilter.owned:
        return FilterGroup(
          children: [
            FilterCondition(
              property: StudyProperty.owner,
              operator: FilterOperator.equals,
              value: true,
            ),
          ],
        );
      case StudiesFilter.shared:
        return FilterGroup(
          children: [
            FilterCondition(
              property: StudyProperty.editor,
              operator: FilterOperator.equals,
              value: true,
            ),
          ],
        );
      case StudiesFilter.public:
        return FilterGroup(
          logic: FilterLogic.or,
          children: [
            FilterCondition(
              property: StudyProperty.registryPublished,
              operator: FilterOperator.equals,
              value: true,
            ),
            FilterCondition(
              property: StudyProperty.resultSharing,
              operator: FilterOperator.equals,
              value: ResultSharing.public.name,
            ),
          ],
        );
    }
  }

  Iterable<Study> apply({
    required Iterable<Study> studies,
    required User user,
  }) {
    // Deprecated: logic moved to FilterEvaluator
    // Keeping for backward compatibility if needed temporarily
    switch (this) {
      case StudiesFilter.all:
        return studies;
      case StudiesFilter.owned:
        return studies.where((s) => s.isOwner(user));
      case StudiesFilter.shared:
        return studies.where((s) => s.isEditor(user));
      case StudiesFilter.public:
        // show studies published to registry irrespective of their status
        return studies.where(
          (s) => s.registryPublished || s.resultSharing == ResultSharing.public,
        );
    }
  }
}
