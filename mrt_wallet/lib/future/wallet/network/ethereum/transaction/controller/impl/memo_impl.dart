import 'package:mrt_wallet/future/wallet/network/ethereum/transaction/controller/impl/transaction_impl.dart';

typedef OnAddETHMemo = Future<String?> Function(String?);
mixin ETHMemoImpl on EthTransactionImpl {
  String? _memo;
  String? get memo => _memo;
  bool get hasMemo => _memo != null;

  Future<void> onTapMemo(OnAddETHMemo onAddMemo) async {
    _memo = await onAddMemo(_memo);
  }
}
