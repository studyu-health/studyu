import 'package:studyu_core/src/models/questionnaire/answer.dart';

class QuestionnaireAnswerMetadata({
  var bool restoredFromCache = false,
  var bool needsReview = false,
  Map<String, Object?>? cacheContext,
}) {
  Map<String, Object?>? cacheContext = cacheContext == null
      ? null
      : Map<String, Object?>.from(cacheContext);

  QuestionnaireAnswerMetadata copy() {
    return QuestionnaireAnswerMetadata(
      restoredFromCache: restoredFromCache,
      needsReview: needsReview,
      cacheContext: cacheContext,
    );
  }
}

class QuestionnaireState {
  Map<String, Answer> answers;
  Map<String, QuestionnaireAnswerMetadata> answerMetadata;

  new() : answers = {}, answerMetadata = {};

  new fromJson(List<Map<String, dynamic>> json)
    : answers = Map<String, Answer>.fromIterable(
        json.map<Answer>(Answer.fromJson),
        key: (answer) => (answer as Answer).question,
      ),
      answerMetadata = {};
  List<Map<String, dynamic>> toJson() =>
      answers.values.map((answer) => answer.toJson()).toList();

  bool hasAnswer<T>(String question) {
    return answers[question] is Answer<T>;
  }

  T getAnswer<T>(String question) {
    final dynamic answer = answers[question];
    if (answer is Answer<T>) {
      return answer.response;
    } else {
      throw ArgumentError(
        "'Answer<$T>' requested but found '${answer.runtimeType}'.",
      );
    }
  }
}
