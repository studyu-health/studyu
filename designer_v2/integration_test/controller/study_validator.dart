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
    bool bfsDiffNode(DiffNode root) {
      // Create a queue and add the root node
      final List<DiffNode> queue = [root];

      while (queue.isNotEmpty) {
        // Dequeue a node from the front of the queue
        final DiffNode currentNode = queue.removeAt(0);

        // We do not compare IDs, because they are not known in advance
        if (currentNode.changed.containsKey('id')) {
          currentNode.changed.remove('id');
        }

        // Print the current node
        /*print('Node path: ${currentNode.path}');
        print('Added: ${currentNode.added}');
        print('Removed: ${currentNode.removed}');
        print('Changed: ${currentNode.changed}');
        print('----------------');*/

        if (currentNode.changed.isNotEmpty ||
            currentNode.added.isNotEmpty ||
            currentNode.removed.isNotEmpty) {
          return false;
        }

        // Enqueue all child nodes
        queue.addAll(currentNode.node.values);
      }
      return true;
    }

    final fetchedStudy = await _fetchCurrentStudy();

    final studyDiff = JsonDiffer.fromJson(
      studyToCompare.toJson(),
      fetchedStudy.toJson(),
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
