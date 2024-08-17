import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/cosmos/cosmos.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';
import 'package:mrt_wallet/app/models/models/typedef.dart';

abstract class CosmosTransactionForm implements TransactionForm {
  BigInt get callValue;
  @override
  String? validateError({ICosmosAddress? account});
  StringVoid? onReadyField;
  List<ServiceMessage> messages(CosmosBaseAddress signer);
  CosmosBaseAddress? _owner;
  CosmosBaseAddress? get owner => _owner;
  BigInt _fee = BigInt.zero;
  BigInt get fee => _fee;

  void setOwner(CosmosBaseAddress? account) {
    _owner = account;
  }

  void setFee(BigInt? fee) {
    _fee = fee ?? BigInt.zero;
  }
}
