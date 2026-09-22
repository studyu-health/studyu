import 'dart:math';

import 'package:studyu_core/src/models/questionnaire/answer.dart';
import 'package:studyu_core/src/models/questionnaire/question.dart';

abstract class SliderQuestion extends Question<num> {
  double minimum = 0;
  double maximum = 0;
  double _initial = 0;
  double step = 1;

  double get initial => max(_initial, minimum);

  set initial(double? value) {
    _initial = value ?? _initial;
  }

  new(super.type);

  new withId(super.type) : super.withId();

  Answer<num> constructAnswer(double response) =>
      Answer.forQuestion(this, response);
}
