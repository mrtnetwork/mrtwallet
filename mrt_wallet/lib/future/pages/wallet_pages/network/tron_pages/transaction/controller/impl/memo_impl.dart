import 'package:mrt_wallet/future/pages/wallet_pages/network/tron_pages/transaction/controller/impl/transaction.dart';

typedef OnAddTronMemo = Future<String?> Function(String?);
mixin TronMemoImpl on TronTransactionImpl {
  String? _memo;
  @override
  String? get memo => _memo;
  bool get hasMemo => _memo != null;

  Future<void> onTapMemo(OnAddTronMemo onAddMemo) async {
    _memo = await onAddMemo(_memo);
  }
}
