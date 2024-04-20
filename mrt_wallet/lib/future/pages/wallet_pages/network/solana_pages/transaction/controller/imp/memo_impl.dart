import 'package:on_chain/solana/solana.dart';

import 'transaction_impl.dart';

typedef OnSetMemo = Future<String?> Function(String? memo);
mixin SolanaMemoImpl on SolanaTransactionImpl {
  MemoProgram? _memo;
  String? get memoStr => (_memo?.layout as MemoLayout?)?.memo;
  bool get hasMemo => memoStr != null;
  @override
  MemoProgram? get memo => _memo;
  void onTapMemo(OnSetMemo onTapMemo) async {
    final txt = await onTapMemo(memoStr);
    if (txt == null) {
      _memo = null;
    } else {
      _memo = MemoProgram(layout: MemoLayout(memo: txt));
    }
    onChange();
  }
}
