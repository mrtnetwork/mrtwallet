import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/widgets/progress_bar/widgets/progress.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'transaction.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

mixin CosmosTransactionConditions on CosmosTransactiomImpl {
  late final BaseAccount _ownerAccount;
  Future<void> initializeFee(CosmosTransactionRequirment txRequirment);
  @override
  BaseAccount get ownerAccount => _ownerAccount;
  Future<void> _init() async {
    progressKey.progressText("retrieving_network_condition".tr);
    final result = await MethodUtils.call(() async {
      final txRequirment = await apiProvider.getTransactionRequirment(
          address: address, account: account);
      await validator.validator.initForm(
          account: account, address: address, provider: walletProvider);
      return txRequirment;
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
      await initializeFee(txRequirment);
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
