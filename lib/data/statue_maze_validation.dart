/// Returns one-based round numbers that have no rotation steps.
/// An absent round list is displayed by the editor as one empty round.
List<int> statueMazeRoundsWithoutRotations(dynamic data) {
  final rounds = data is Map ? data['SetInfos'] : null;
  if (rounds is! List || rounds.isEmpty) return [1];
  return [
    for (var index = 0; index < rounds.length; index++)
      if (rounds[index] is! Map ||
          rounds[index]['MatrixInfos'] is! List ||
          !(rounds[index]['MatrixInfos'] as List).any((step) => step is Map))
        index + 1,
  ];
}
