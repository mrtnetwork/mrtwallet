import 'transaction.dart';

typedef OnAddSubstrateMemo = Future<String?> Function();

mixin SubstrateMemoImpl on SubstrateTransactiomImpl {
  List<String> _memos = [];
  @override
  List<String> get memos => _memos;

  Future<void> onTapMemo(OnAddSubstrateMemo onAddMemo) async {
    final memo = await onAddMemo();
    if (memo != null) {
      _memos = List<String>.unmodifiable([memo, ...memos]);
    }
  }

  void removeMemo(int index) {
    final m = List<String>.from(memos)..removeAt(index);
    _memos = List<String>.unmodifiable(m);
  }
}
