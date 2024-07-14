import 'package:mrt_wallet/app/models/models.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';
import 'package:mrt_wallet/app/models/models/typedef.dart';
import 'package:mrt_wallet/wallet/wallet.dart';

abstract class SubstrateTransactionForm implements TransactionForm {
  BigInt get callValue;
  @override
  String? validateError({ISubstrateAddress? account});
  DynamicVoid? onReadyField;
  abstract final WalletPolkadotNetwork network;

  List<Map<String, dynamic>> toMessage();
  void calculateNativeValue();

  int get methodsLength;

  BigInt _fee = BigInt.zero;
  BigInt get fee => _fee;
  void setupFee(BigInt fee) {
    _fee = fee;
    calculateNativeValue();
    onChanged?.call();
  }
}
