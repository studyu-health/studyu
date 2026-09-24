import 'package:flutter_test/flutter_test.dart';
import 'package:json_diff/json_diff.dart';
import 'package:studyu_core/core.dart';

class StudyValidator(final String userID) {
  Future<Study> _fetchCurrentStudy() async {
    final studies = await SupabaseQuery.getAll<Study>(selectedColumns: ['*']);
    studies.removeWhere((Study s) => s.userId != userID);
    expect(studies.length, 1, reason: 'One study should be created');
    final study = studies.single;
    return study;
  }

  Future<bool> compare(Study studyToCompare) async {
    Object? withoutIds(Object? value) {
      if (value is Map<String, dynamic>) {
        return <String, dynamic>{
          for (final entry in value.entries)
            if (entry.key != 'id') entry.key: withoutIds(entry.value),
        };
      }
      if (value is List) {
        return value.map(withoutIds).toList();
      }
      return value;
    }

    bool bfsDiffNode(DiffNode root) {
      // Create a queue and add the root node
      final List<DiffNode> queue = [root];

      while (queue.isNotEmpty) {
        // Dequeue a node from the front of the queue
        final DiffNode currentNode = queue.removeAt(0);

        // Print the current node
        /*print('Node path: ${currentNode.path}');
        print('Added: ${currentNode.added}');
        print('Removed: ${currentNode.removed}');
        print('Changed: ${currentNode.changed}');
        print('----------------');*/

        // Added and removed values are meaningful differences. In particular,
        // do not ignore list-level changes: they detect missing or duplicate
        // study elements.
        if (currentNode.changed.isNotEmpty ||
            currentNode.added.isNotEmpty ||
            currentNode.removed.isNotEmpty ||
            currentNode.moved.isNotEmpty) {
          return false;
        }

        // Enqueue all child nodes
        queue.addAll(currentNode.node.values);
      }
      return true;
    }

    final fetchedStudy = await _fetchCurrentStudy();

    // IDs are generated independently by the mock and by the designer. Strip
    // them before diffing so json_diff can match otherwise identical list
    // elements, while retaining structural additions and removals.
    final studyDiff = JsonDiffer.fromJson(
      withoutIds(studyToCompare.toJson())!,
      withoutIds(fetchedStudy.toJson())!,
    ).diff();

    final res = bfsDiffNode(studyDiff);
    if (!res) {
      // todo why is this not printing?
      print("Mockup Study: ${studyToCompare.toJson()}");
      print("Fetched Study: ${fetchedStudy.toJson()}");
      print("Differences Detected: $studyDiff");
      print("Study Validation: FAILED");
    }
    expect(res, true, reason: 'Study validation failed: $studyDiff');
    return res;
  }
}
