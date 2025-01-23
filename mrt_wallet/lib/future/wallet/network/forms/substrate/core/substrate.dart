import 'package:mrt_wallet/app/models/models.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';
import 'package:mrt_wallet/app/models/models/typedef.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/wallet/web3/networks/substrate/substrate.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

typedef ONSUBSTRATEREQUESTSIGNATURE = Future<List<int>> Function(
    List<int> digest);

abstract class SubstrateTransactionForm extends TransactionForm {
  BigInt get callValue;
  @override
  String? validateError({ISubstrateAddress? account});
  DynamicVoid? onReadyField;
  Future<void> init(
      {required SubstrateChain chain,
      required ISubstrateAddress address}) async {}
  void calculateNativeValue();
  // Future<ExtrinsicInfo> buildEstimateTransaction(
  //     {required ISubstrateAddress address, List<String> memos = const []});
  Future<ExtrinsicInfo> buildAndSignTransaction(
      {ONSUBSTRATEREQUESTSIGNATURE? onGenerateSignature,
      required ISubstrateAddress address,
      List<String> memos = const []});

  BigInt _fee = BigInt.zero;
  BigInt get fee => _fee;
  void setupFee(BigInt fee) {
    _fee = fee;
    calculateNativeValue();
    onChanged?.call();
  }
}

abstract class SubstrateWeb3Form<PARAMS extends Web3SubstrateRequestParam>
    implements
        Web3Form<BaseSubstrateAddress, SubstrateChain,
            Web3SubstrateChainAccount, Web3SubstrateChain, PARAMS> {
  @override
  abstract final Web3SubstrateRequest<dynamic, PARAMS> request;

  DynamicVoid? onStimateChanged;
  @override
  ObjectVoid? onCompleteForm;

  @override
  String get name => request.params.method.name;

  void confirmRequest({Object? response}) {
    onCompleteForm?.call(response);
  }
}
