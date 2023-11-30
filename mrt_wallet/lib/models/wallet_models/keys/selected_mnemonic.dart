class SelectedMnemonic {
  SelectedMnemonic.notSelected()
      : word = null,
        index = null;
  SelectedMnemonic.select(int this.index, String this.word);

  final String? word;
  final int? index;
  bool get selected => word != null && index != null;

  @override
  operator ==(other) {
    if (other is! SelectedMnemonic) {
      return false;
    }
    if (word == null || index == null) {
      return false;
    }
    return word == other.word && index == other.index;
  }

  @override
  int get hashCode => word.hashCode ^ index.hashCode;
}
