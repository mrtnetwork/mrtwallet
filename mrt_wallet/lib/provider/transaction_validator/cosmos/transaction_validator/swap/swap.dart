import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/models/wallet_models/address/network_address/cosmos/cosmos.dart';
import 'package:mrt_wallet/provider/transaction_validator/core/live_validator.dart';
import 'package:mrt_wallet/provider/transaction_validator/core/validator_fields.dart';
import 'package:mrt_wallet/provider/transaction_validator/cosmos/transaction_validator/core/cosmos_field_validator.dart';

class ThorChainSwapValidator extends CosmosTransactionValidator {
  @override
  OnChangeValidator? onChanged;

  @override
  BigInt get callValue => throw UnimplementedError();

  @override
  List<ValidatorField> get fields => throw UnimplementedError();

  @override
  List<ServiceMessage> messages(CosmosBaseAddress signer) {
    throw UnimplementedError();
  }

  @override
  String get name => throw UnimplementedError();

  @override
  void setValue<T>(ValidatorField<T>? field, T? value) {}

  @override
  String? validateError({ICosmosAddress? account}) {
    throw UnimplementedError();
  }
}
