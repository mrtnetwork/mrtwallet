import 'package:mrt_wallet/app/models/models/typedef.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/stellar.dart';
import 'package:stellar_dart/stellar_dart.dart';

abstract class StellarTransactionForm implements TransactionForm {
  BigInt get callValue;
  DynamicVoid? onReadyField;
  @override
  String? validateError({IStellarAddress? account});
  List<Operation> toOperations();
  int get operations;
  late final WalletStellarNetwork network;
  late final StellarClient client;
  bool get hasUnknowReceipt;

  void init(StellarChain chain, int baseReserveStroop) {
    network = chain.network;
    client = chain.provider()!;
  }
}

abstract class StellarWeb3Form<PARAMS extends Web3StellarRequestParam>
    implements
        Web3Form<StellarAddress, StellarChain, Web3StellarChainAccount,
            Web3StellarChain, PARAMS> {
  @override
  abstract final Web3StellarRequest<dynamic, PARAMS> request;

  DynamicVoid? onStimateChanged;
  @override
  ObjectVoid? onCompeleteForm;

  @override
  String get name => request.params.method.name;

  void confirmRequest({Object? response}) {
    onCompeleteForm?.call(response);
  }
}
