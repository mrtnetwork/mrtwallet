import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/models/wallet_models/address/address.dart';
import 'package:mrt_wallet/provider/transaction_validator/core/validator.dart';
import 'package:mrt_wallet/types/typedef.dart';

abstract class CosmosTransactionValidator implements TransactionValidator {
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
