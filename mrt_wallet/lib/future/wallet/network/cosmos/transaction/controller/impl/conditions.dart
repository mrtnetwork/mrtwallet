import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/widgets/widgets/progress_bar/widgets/progress.dart';
import 'transaction.dart';
import 'package:mrt_wallet/future/state_managment/extension/extension.dart';

mixin CosmosTransactionConditions on CosmosTransactiomImpl {
  late final BaseAccount _ownerAccount;
  late final GetLatestBlockResponse _latestBlock;
  late final ThorNodeNetworkConstants? _thorNodeNetworkConstants;
  @override
  ThorNodeNetworkConstants get thorNodeNetworkConstants =>
      _thorNodeNetworkConstants!;
  @override
  BaseAccount get ownerAccount => _ownerAccount;
  @override
  GetLatestBlockResponse get latestBlock => _latestBlock;
  Future<void> _init() async {
    progressKey.progressText("retrieving_network_condition".tr);
    final result = await MethodUtils.call(() async {
      ThorNodeNetworkConstants? thorNodeNetworkConstants;
      if (isThorChain) {
        thorNodeNetworkConstants = await apiProvider.getThorNodeConstants();
      }
      final acc = await apiProvider.getBaseAccount(address.networkAddress);
      if (acc == null) return (null, null, null);
      final block = await apiProvider.getLatestBlock();
      return (acc, block, thorNodeNetworkConstants);
    });
    if (result.hasError) {
      progressKey.errorText(result.error!.tr, backToIdle: false);
    } else {
      if (result.result.$1 == null) {
        progressKey.errorText("account_not_found".tr, backToIdle: false);
        return;
      }
      _ownerAccount = result.result.$1!;
      _latestBlock = result.result.$2!;
      _thorNodeNetworkConstants = result.result.$3;
      progressKey.success();
    }
  }

  @override
  void ready() {
    super.ready();
    _init();
  }
}
