import 'package:flutter/rendering.dart';
import 'package:studyu_designer_v2/utils/typings.dart';

/// JSON-encodable version of [Color]
class SerializableColor(super.value) extends Color {
  JsonMap toJson() => {"value": super.toARGB32()};
  SerializableColor fromJson(JsonMap json) =>
      SerializableColor(int.parse(json["value"].toString()));
}
