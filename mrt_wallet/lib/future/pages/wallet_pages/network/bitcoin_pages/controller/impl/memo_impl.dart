import 'package:mrt_wallet/future/pages/wallet_pages/network/bitcoin_pages/controller/impl/transaction.dart';
import 'package:mrt_wallet/types/typedef.dart';

mixin BitcoinTransactionMemoImpl on BitcoinTransactionImpl {
  String? _memo;

  @override
  String? get memo => _memo;
  bool get hasMemo => _memo != null;

  Future<void> onTapMemo(FutureNullString onAdd) async {
    _memo = await onAdd();
  }
}
