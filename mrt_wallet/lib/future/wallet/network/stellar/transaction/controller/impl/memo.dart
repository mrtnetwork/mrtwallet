import 'package:mrt_wallet/wallet/models/networks/stellar/stellar.dart';
import 'package:stellar_dart/stellar_dart.dart';
import 'transaction_impl.dart';

typedef OnSetupStellarMemo = Future<StellarMemo?> Function(StellarMemoDetils?);

mixin StellarTransactionMemoImpl on StellarTransactionImpl {
  StellarMemoDetils? _memo;
  @override
  StellarMemoDetils? get memo => _memo;
  @override
  Future<void> onSetupMemo(OnSetupStellarMemo onSetupMemo) async {
    final result = await onSetupMemo(_memo);
    if (result == null) return;
    if (result.type == MemoType.none) {
      _memo = null;
    } else {
      _memo = StellarMemoDetils(result);
    }
    notify();
  }
}
