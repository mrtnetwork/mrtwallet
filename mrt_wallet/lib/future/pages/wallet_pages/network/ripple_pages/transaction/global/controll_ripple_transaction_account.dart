import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/constant.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/controller/wallet_provider.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/models/wallet_models/account/core/account.dart';
import 'package:mrt_wallet/models/wallet_models/address/network_address/xrp/xrp_account.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/provider/api/networks/ripple/ripple_api_provider.dart';

typedef OnRippleTransactipnPage = Widget Function(
    WalletProvider wallet,
    NetworkAccountCore account,
    IXRPAddress address,
    AppXRPNetwork network,
    RippleApiProvider provider,
    OnSwitchRippleAccount switchRippleAccount);
typedef OnSwitchRippleAccount = void Function(IXRPAddress? address);

class ControllerRippleTransactionAccountView extends StatefulWidget {
  const ControllerRippleTransactionAccountView(
      {super.key, required this.childBulder, required this.title});
  final OnRippleTransactipnPage childBulder;
  final String title;
  @override
  State<ControllerRippleTransactionAccountView> createState() =>
      _ControllerRippleTransactionAccountViewState();
}

class _ControllerRippleTransactionAccountViewState
    extends State<ControllerRippleTransactionAccountView> with SafeState {
  late WalletProvider wallet;
  late NetworkAccountCore account;
  late IXRPAddress address;
  late AppXRPNetwork network;
  late RippleApiProvider provider;
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>();

  void switchAccount(IXRPAddress? updateAddress) async {
    if (updateAddress == null) return;
    if (!account.addresses.contains(updateAddress)) return;
    if (updateAddress == address) return;
    progressKey.progressText("switch_account".tr);
    final result = await wallet.switchAccount(updateAddress);
    if (result.hasError) {
      progressKey.errorText(result.error!, backToIdle: false);
    } else {
      _checkAccounts();
      progressKey.success();
    }
  }

  void _checkAccounts() {
    account = wallet.networkAccount;
    network = wallet.network as AppXRPNetwork;
    address = account.address as IXRPAddress;
    provider = wallet.getNetworkApiProvider(network);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    wallet = context.watch<WalletProvider>(StateIdsConst.main);
    _checkAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: PageProgress(
          backToIdle: AppGlobalConst.animationDuraion,
          key: progressKey,
          child: () => widget.childBulder(
              wallet, account, address, network, provider, switchAccount)),
    );
  }
}
