import 'package:mrt_wallet/models/wallet_models/network/custom/bitcoin/memo.dart';
import 'package:mrt_wallet/types/typedef.dart';

mixin BitcoinTransactionMemoImpl {
  List<BitcoinMemo> _memoScripts = [];

  List<BitcoinMemo> get memoScripts => _memoScripts;
  bool get hasMemo => _memoScripts.isNotEmpty;

  Future<void> onTapMemo(FutureNullString onAdd) async {
    final newMemo = await onAdd();
    if (newMemo != null) {
      _memoScripts = List<BitcoinMemo>.unmodifiable(
          [..._memoScripts, BitcoinMemo(newMemo)]);
    }
  }

  void onRemoveMemo(BitcoinMemo? memo) {
    final memos = List<BitcoinMemo>.from(_memoScripts);
    memos.removeWhere((element) => element == memo);
    _memoScripts = List<BitcoinMemo>.unmodifiable(memos);
  }

  void addBCMR(BitcoinMemo bcmr) {
    _memoScripts = List<BitcoinMemo>.unmodifiable([..._memoScripts, bcmr]);
  }
}
