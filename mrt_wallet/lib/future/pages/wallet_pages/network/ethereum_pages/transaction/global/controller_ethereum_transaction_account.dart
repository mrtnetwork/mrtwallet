import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/controller/wallet_provider.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

typedef OnEthereumTransactionPage = Widget Function(
    WalletProvider wallet,
    AppChain account,
    IEthAddress address,
    OnSwitchEthereumAccount switchRippleAccount);
typedef OnSwitchEthereumAccount = void Function(IEthAddress? address);

class ControllerEthereumTransactionAccountView extends StatefulWidget {
  const ControllerEthereumTransactionAccountView(
      {super.key, required this.childBulder, required this.title});
  final OnEthereumTransactionPage childBulder;
  final String title;
  @override
  State<ControllerEthereumTransactionAccountView> createState() =>
      _ControllerEthereumTransactionAccountViewState();
}

class _ControllerEthereumTransactionAccountViewState
    extends State<ControllerEthereumTransactionAccountView> with SafeState {
  late WalletProvider wallet;
  late AppChain account;
  late IEthAddress address;
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>();

  void switchAccount(IEthAddress? updateAddress) async {
    if (updateAddress == null) return;
    if (!account.account.addresses.contains(updateAddress)) return;
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
    account = wallet.chain;
    address = account.account.address as IEthAddress;
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
          child: () =>
              widget.childBulder(wallet, account, address, switchAccount)),
    );
  }
}
