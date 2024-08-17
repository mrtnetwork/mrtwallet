import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/cosmos/cosmos.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:mrt_wallet/future/wallet/network/forms/cosmos/forms/core/cosmos.dart';

class CosmosSwapForm extends CosmosTransactionForm {
  @override
  OnChangeForm? onChanged;

  @override
  BigInt get callValue => throw UnimplementedError();

  @override
  List<ServiceMessage> messages(CosmosBaseAddress signer) {
    throw UnimplementedError();
  }

  @override
  String get name => throw UnimplementedError();

  @override
  String? validateError({ICosmosAddress? account}) {
    throw UnimplementedError();
  }
}
