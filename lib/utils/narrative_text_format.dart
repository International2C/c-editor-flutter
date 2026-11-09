// Only paired, nonempty double tildes mark strikethrough. Unmatched tildes
// such as the existing Chinese farewell "再见~~！" remain literal.
final _strikethroughPattern = RegExp(r'~~(.+?)~~', dotAll: true);
// Dialogue can start with a digit immediately after the six color digits.
final _colorCommandPattern = RegExp(
  r'\^([0-9a-f]{6}|oldclr)',
  caseSensitive: false,
);

typedef NarrativeTextRun = ({String text, int? rgb, bool strikethrough});

/// Splits game color commands and paired tildes into independently styled runs.
Iterable<NarrativeTextRun> narrativeTextRuns(String text) sync* {
  final markers = <({int start, int end, int? rgb, bool? strike})>[
    for (final command in _colorCommandPattern.allMatches(text))
      (
        start: command.start,
        end: command.end,
        rgb: int.tryParse(command.group(1)!, radix: 16),
        strike: null,
      ),
    for (final match in _strikethroughPattern.allMatches(text)) ...[
      (start: match.start, end: match.start + 2, rgb: null, strike: true),
      (start: match.end - 2, end: match.end, rgb: null, strike: false),
    ],
  ]..sort((a, b) => a.start.compareTo(b.start));

  int? rgb;
  var strikethrough = false;
  var offset = 0;
  for (final marker in markers) {
    if (offset < marker.start) {
      yield (
        text: text.substring(offset, marker.start),
        rgb: rgb,
        strikethrough: strikethrough,
      );
    }
    if (marker.strike case final strike?) {
      strikethrough = strike;
    } else {
      rgb = marker.rgb;
    }
    offset = marker.end;
  }
  if (offset < text.length || markers.isEmpty) {
    yield (
      text: text.substring(offset),
      rgb: rgb,
      strikethrough: strikethrough,
    );
  }
}

/// Search and accessibility text keep the words without formatting markers.
String narrativePlainText(String text) {
  if (!text.contains('^') && !text.contains('~~')) return text;
  return narrativeTextRuns(text).map((run) => run.text).join();
}
