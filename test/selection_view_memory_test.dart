import 'package:c_editor/utils/selection_view_memory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(SelectionViewMemoryStore.clear);

  test('the same state bucket restores named view offsets', () {
    final firstVisit = SelectionViewMemoryStore.forKey('level-a:narrative');
    firstVisit.scrollOffsets['grid:mainWorlds'] = 128;
    firstVisit.scrollOffsets['section:ancientEgypt'] = 640;

    final returnVisit = SelectionViewMemoryStore.forKey('level-a:narrative');

    expect(returnVisit.scrollOffsets['grid:mainWorlds'], 128);
    expect(returnVisit.scrollOffsets['section:ancientEgypt'], 640);
  });

  test('different state buckets keep view offsets isolated', () {
    SelectionViewMemoryStore.forKey(
      'level-a:narrative',
    ).scrollOffsets['section:ancientEgypt'] = 640;

    final otherLevel = SelectionViewMemoryStore.forKey('level-b:narrative');

    expect(otherLevel.scrollOffsets, isEmpty);
  });
}
