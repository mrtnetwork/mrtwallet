import 'package:on_chain/solana/solana.dart';

import 'transaction_impl.dart';

typedef OnSetMemo = Future<String?> Function(String? memo);

mixin SolanaMemoImpl on SolanaTransactionImpl {
  String? _memoStr;
  String? get memoStr => _memoStr;
  bool get hasMemo => _memoStr != null;
  @override
  MemoProgram? get memo =>
      hasMemo ? MemoProgram(layout: MemoLayout(memo: _memoStr!)) : null;

  void onTapMemo(OnSetMemo onTapMemo) async {
    final txt = await onTapMemo(memoStr);
    if (txt == null) {
      _memoStr = null;
    } else {
      _memoStr = txt;
    }
    onChange();
  }
}
