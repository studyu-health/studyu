import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/forms/form_data.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:uuid/uuid.dart';

class ConsentItemFormData({
  required final String consentId,
  required final String title,
  required final String description,
  final String? iconName,
}) extends IFormData {
  @override
  String get id => consentId;

  factory fromDomainModel(ConsentItem consentItem) {
    return ConsentItemFormData(
      consentId: consentItem.id,
      title: consentItem.title ?? '',
      description: consentItem.description ?? '',
      iconName: consentItem.iconName,
    );
  }

  ConsentItem toConsentItem() {
    final consentItem = ConsentItem(consentId);
    consentItem.title = title;
    consentItem.description = description;
    consentItem.iconName = iconName ?? 'textBoxCheck';
    return consentItem;
  }

  @override
  ConsentItemFormData copy() {
    return ConsentItemFormData(
      consentId: const Uuid().v4(), // always regenerate id
      title: title.withDuplicateLabel(),
      description: description,
      iconName: iconName,
    );
  }
}
