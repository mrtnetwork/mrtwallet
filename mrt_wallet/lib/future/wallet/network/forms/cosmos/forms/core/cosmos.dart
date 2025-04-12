import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/app/models/models/typedef.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/wallet/api/client/networks/cosmos/cosmos.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/cosmos/cosmos.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/models/networks/cosmos/models/transaction_output.dart';
import 'package:mrt_wallet/wallet/web3/networks/cosmos/cosmos.dart';

abstract class CosmosTransactionForm extends TransactionForm {
  BigInt get callValue;
  CosmosChain? _account;
  CosmosChain get account => _account!;
  ICosmosAddress? _address;
  ICosmosAddress get address => _address!;
  CosmosClient get client => account.client;
  WalletCosmosNetwork get network => account.network;
  @override
  String? validateError({ICosmosAddress? account});
  List<ServiceMessage> messages(CosmosBaseAddress signer);
  void setFeeToken(CosmosTransactionFeeInfo fee) {}

  Future<void> initForm({
    required CosmosChain account,
    required ICosmosAddress address,
    required WalletProvider provider,
  }) async {
    _account = account;
    _address = address;
  }
}

abstract class CosmosWeb3Form<PARAMS extends Web3CosmosRequestParam>
    extends Web3Form<CosmosBaseAddress, CosmosChain, Web3CosmosChainAccount,
        Web3CosmosChain, PARAMS> {
  @override
  abstract final Web3CosmosRequest<dynamic, PARAMS> request;

  DynamicVoid? onStimateChanged;

  @override
  String get name => request.params.method.name;

  void confirmRequest({Object? response}) {
    onCompleteForm?.call(response);
  }

  CosmosClient? _client;
  CosmosClient get client => _client!;
  ICosmosAddress? _address;
  ICosmosAddress get address => _address!;
  CosmosChain? _account;
  CosmosChain get account => _account!;
  WalletCosmosNetwork get network => _account!.network;

  Future<void> initForm(
      {required CosmosChain account, required ICosmosAddress? address}) async {
    _account = account;
    _address = address;
    _client = account.clientNullable;
  }

  @override
  void close() {
    super.close();
    onCompleteForm = null;
    _client = null;
    _address = null;
    _account = null;
  }
}
