typedef StudyUReadScreen = Future<StudyUIScreenSnapshot> Function();

typedef StudyUWaitForKey =
    Future<bool> Function(String key, {required Duration timeout});

typedef StudyUTapKey = Future<void> Function(String key);

class StudyUIScreenSnapshot {
  const StudyUIScreenSnapshot({
    required this.screen,
    required this.visibleKeys,
  });

  final String screen;
  final Set<String> visibleKeys;

  bool hasKey(String key) => visibleKeys.contains(key);

  Map<String, Object?> toJson() => {
    'screen': screen,
    'visibleKeys': visibleKeys.toList()..sort(),
  };
}
