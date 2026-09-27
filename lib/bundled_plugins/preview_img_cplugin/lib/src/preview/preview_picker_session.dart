/// In-memory browsing state, owned by one generator instance per picker.
/// It survives closing the picker without persisting into the preview document.
class PreviewPickerSession {
  String query = '';
  double _scrollOffset = 0;

  double get scrollOffset => _scrollOffset;

  void rememberScrollOffset(double offset) {
    _scrollOffset = offset.isFinite && offset > 0 ? offset : 0;
  }
}
