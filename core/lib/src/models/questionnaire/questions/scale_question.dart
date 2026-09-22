import 'dart:math';

import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/core.dart';

part 'scale_question.g.dart';

@JsonSerializable()
class ScaleQuestion extends SliderQuestion
    implements AnnotatedScaleQuestion, VisualAnalogueQuestion {
  static const String questionType = 'scale';

  @override
  List<Annotation> annotations = [];

  @JsonKey(name: 'min_color')
  int? minColor;

  @JsonKey(name: 'max_color')
  int? maxColor;

  @JsonKey(includeToJson: false, includeFromJson: false)
  double _step = 0; // autogenerate intermediate values by default

  @override
  double get step => isAutostep ? autostep.toDouble() : _step;

  @override
  set step(double value) => _step = value;

  @JsonKey(includeToJson: false, includeFromJson: false)
  bool get isAutostep => _step == 0;

  @JsonKey(includeToJson: false, includeFromJson: false)
  int get autostep => getAutostepSize(scaleMaxValue: maximum.toInt());

  new() : super(questionType);

  new withId() : super.withId(questionType);

  factory fromJson(Map<String, dynamic> json) => _$ScaleQuestionFromJson(json);

  factory fromAnnotatedScaleQuestion(AnnotatedScaleQuestion question) {
    final result = ScaleQuestion()
      ..id = question.id
      ..prompt = question.prompt
      ..rationale = question.rationale
      ..conditional = question.conditional
      ..minimum = question.minimum
      ..maximum = question.maximum
      ..step = question.step
      ..initial = question.initial
      ..annotations = question.annotations;
    return result;
  }

  factory fromVisualAnalogueQuestion(VisualAnalogueQuestion question) {
    final result = ScaleQuestion()
      ..id = question.id
      ..prompt = question.prompt
      ..rationale = question.rationale
      ..conditional = question.conditional
      ..minimum = question.minimum
      ..maximum = question.maximum
      ..step = question.step
      ..initial = question.initial
      ..minimumColor = question.minimumColor
      ..maximumColor = question.maximumColor
      ..minimumAnnotation = question.minimumAnnotation
      ..maximumAnnotation = question.maximumAnnotation;
    return result;
  }

  @override
  Map<String, dynamic> toJson() => _$ScaleQuestionToJson(this);

  @JsonKey(includeToJson: false, includeFromJson: false)
  List<Annotation> get annotationsSorted =>
      annotations.sorted((a, b) => a.value.compareTo(b.value));

  @JsonKey(includeToJson: false, includeFromJson: false)
  Annotation? get minAnnotation {
    final firstOrNull = annotationsSorted.firstOrNull;
    if (firstOrNull?.value == minimum) {
      return firstOrNull;
    }
    return null;
  }

  @JsonKey(includeToJson: false, includeFromJson: false)
  Annotation? get maxAnnotation {
    final lastOrNull = annotationsSorted.lastOrNull;
    if (lastOrNull?.value == maximum) {
      return lastOrNull;
    }
    return null;
  }

  @JsonKey(includeToJson: false, includeFromJson: false)
  String? get minLabel => minAnnotation?.annotation;

  @JsonKey(includeToJson: false, includeFromJson: false)
  String? get maxLabel => maxAnnotation?.annotation;

  set minLabel(String? newLabel) {
    if (newLabel != null) {
      minimumAnnotation = newLabel; // _setAnnotationLabel
    } else {
      if (minAnnotation != null) {
        annotations.remove(minAnnotation);
      }
    }
  }

  set maxLabel(String? newLabel) {
    if (newLabel != null) {
      maximumAnnotation = newLabel; // _setAnnotationLabel
    } else {
      if (maxAnnotation != null) {
        annotations.remove(maxAnnotation);
      }
    }
  }

  @JsonKey(includeToJson: false, includeFromJson: false)
  List<Annotation> get midAnnotations => annotationsSorted
      .where((a) => a.value != minimum && a.value != maximum)
      .toList();

  set midAnnotations(List<Annotation> annotations) {
    final prevMinAnnotation = minAnnotation;
    final prevMaxAnnotation = maxAnnotation;

    final List<Annotation> newAnnotations = [];
    if (prevMinAnnotation != null) {
      newAnnotations.add(prevMinAnnotation);
    }
    newAnnotations.addAll(annotations);
    if (prevMaxAnnotation != null) {
      newAnnotations.add(prevMaxAnnotation);
    }

    this.annotations = newAnnotations;
  }

  @JsonKey(includeToJson: false, includeFromJson: false)
  List<String> get midLabels =>
      midAnnotations.map((a) => a.annotation).toList();

  @JsonKey(includeToJson: false, includeFromJson: false)
  List<double> get midValues =>
      midAnnotations.map((a) => a.value.toDouble()).toList();

  Annotation addAnnotation({required int value, required String label}) {
    final annotation = Annotation()
      ..value = value
      ..annotation = label;
    annotations.add(annotation);
    return annotation;
  }

  void _setAnnotationLabel({
    required String newLabel,
    required int atSortedIndex,
    required double atValue,
  }) {
    if (annotations.isNotEmpty && atSortedIndex < annotations.length) {
      final existing = annotationsSorted[atSortedIndex];
      // update label for existing annotation
      if (existing.value == atValue) {
        existing.annotation = newLabel;
        return;
      } // else: fall-through & insert new annotation
    }
    addAnnotation(value: atValue.toInt(), label: newLabel);
  }

  @JsonKey(includeToJson: false, includeFromJson: false)
  List<double> get values {
    final List<double> values = [];
    for (double value = minimum; value < maximum; value += step) {
      values.add(value);
    }
    values.add(maximum);
    return values;
  }

  // - VisualAnalogueQuestion

  @override
  @JsonKey(includeToJson: false, includeFromJson: false)
  String get minimumAnnotation =>
      minAnnotation?.annotation ?? minimum.toString();

  @override
  @JsonKey(includeToJson: false, includeFromJson: false)
  String get maximumAnnotation =>
      maxAnnotation?.annotation ?? maximum.toString();

  @override
  @JsonKey(includeToJson: false, includeFromJson: false)
  int get maximumColor => maxColor ?? 0xFFFFFFFF;

  @override
  set maximumColor(int value) => maxColor = value;

  @override
  @JsonKey(includeToJson: false, includeFromJson: false)
  int get minimumColor => minColor ?? 0xFFFFFFFF;

  @override
  set minimumColor(int value) => minColor = value;

  // - AnnotatedScaleQuestion

  @override
  set maximumAnnotation(String newLabel) {
    _setAnnotationLabel(
      newLabel: newLabel,
      atSortedIndex: annotations.length - 1,
      atValue: maximum,
    );
  }

  @override
  set minimumAnnotation(String newLabel) {
    _setAnnotationLabel(newLabel: newLabel, atSortedIndex: 0, atValue: minimum);
  }

  static int getAutostepSize({
    required int scaleMaxValue,
    int numValuesGenerated = 10,
  }) {
    return max((scaleMaxValue / numValuesGenerated).ceil(), 1);
  }

  static List<int> generateMidValues({
    required int scaleMinValue,
    required int scaleMaxValue,
    int numValuesGenerated = 10,
  }) {
    final int midValueStepSize = getAutostepSize(
      scaleMaxValue: scaleMinValue,
      numValuesGenerated: numValuesGenerated,
    );
    final List<int> midValues = [];

    for (
      int midValue = scaleMinValue + midValueStepSize;
      midValue < scaleMaxValue;
      midValue += midValueStepSize
    ) {
      midValues.add(midValue);
      if (midValues.length >= numValuesGenerated) {
        break;
      }
    }
    return midValues;
  }
}
