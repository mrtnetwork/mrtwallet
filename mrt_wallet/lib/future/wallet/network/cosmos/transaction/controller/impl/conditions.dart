import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/widgets/progress_bar/widgets/progress.dart';
import 'transaction.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

mixin CosmosTransactionConditions on CosmosTransactiomImpl {
  late final BaseAccount _ownerAccount;
  late final GetLatestBlockResponse _latestBlock;
  Future<void> initializeFee(
      {required List<Coin> feeTokens, BigInt? nativeTransactionFee});
  @override
  BaseAccount get ownerAccount => _ownerAccount;
  @override
  GetLatestBlockResponse get latestBlock => _latestBlock;
  Future<void> _init() async {
    progressKey.progressText("retrieving_network_condition".tr);
    final result = await MethodUtils.call(() async {
      return apiProvider.getTransactionRequirment(
          address: address, account: account);
    });
    if (result.hasError) {
      progressKey.errorText(result.error!.tr, backToIdle: false);
    } else {
      final txRequirment = result.result;
      if (txRequirment.account == null) {
        progressKey.errorText("account_not_found".tr, backToIdle: false);
        return;
      }
      _ownerAccount = txRequirment.account!;
      _latestBlock = txRequirment.block!;
      await initializeFee(
          feeTokens: txRequirment.accountCoins,
          nativeTransactionFee: txRequirment.fixedNativeGas);
      onCalculateAmount();
      progressKey.success();
    }
  }

  @override
  void ready() {
    super.ready();
    _init();
  }
}
