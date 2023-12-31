import 'package:mrt_wallet/future/pages/wallet_pages/network/ripple_pages/transaction/controller/impl/transaction_impl.dart';
import 'package:xrp_dart/xrp_dart.dart';

typedef OnSetupMemo = Future<XRPLMemo?> Function(XRPLMemo?);

mixin RippleMemoImpl on RippleTransactionImpl {
  final List<XRPLMemo> _memos = [];
  @override
  List<XRPLMemo> get memos => _memos;
  @override
  Future<void> onSetupMemo(XRPLMemo? memo, OnSetupMemo onSetupMemo) async {
    if (memo == null) {
      final newMemo = await onSetupMemo(null);
      if (newMemo != null) {
        _memos.add(newMemo);
      }
    } else {
      final r = _memos.remove(memo);
      if (!r) return;
      final newMemo = await onSetupMemo(memo);
      if (newMemo == null) return;
      _memos.add(newMemo);
    }
  }
}
