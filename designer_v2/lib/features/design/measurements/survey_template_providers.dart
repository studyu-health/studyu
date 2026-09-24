import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';

/// Provider for the [SurveyTemplateRepository].
///
/// Currently returns [BuiltInSurveyTemplateRepository] (system presets only).
/// To add user-created/shared templates, swap this with a composite repository
/// that merges built-in + Supabase-backed templates.
final surveyTemplateRepositoryProvider = Provider<SurveyTemplateRepository>(
  (ref) => BuiltInSurveyTemplateRepository(),
);
