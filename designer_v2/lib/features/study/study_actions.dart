import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:studyu_designer_v2/domain/study.dart';

Map<StudyActionType, IconData> studyActionIcons = {
  StudyActionType.pin: MdiIcons.pin,
  StudyActionType.pinoff: MdiIcons.pinOff,
  StudyActionType.edit: Icons.edit_rounded,
  StudyActionType.duplicate: Icons.file_copy_rounded,
  StudyActionType.duplicateDraft: Icons.file_copy_rounded,
  StudyActionType.addCollaborator: Icons.person_add_rounded,
  StudyActionType.export: Icons.download_rounded,
  StudyActionType.exportDefinition: Icons.file_present_rounded,
  StudyActionType.close: Icons.lock_rounded,
  StudyActionType.delete: Icons.delete_rounded,
};
