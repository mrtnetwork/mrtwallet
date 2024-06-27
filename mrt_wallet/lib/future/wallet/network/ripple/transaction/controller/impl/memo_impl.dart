import 'package:mrt_wallet/future/wallet/network/ripple/transaction/controller/impl/transaction_impl.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

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
