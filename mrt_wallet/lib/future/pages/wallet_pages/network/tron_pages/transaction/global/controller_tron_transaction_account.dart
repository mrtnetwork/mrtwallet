import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/controller/wallet_provider.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

typedef OnTronTransactionPage = Widget Function(
    WalletProvider wallet,
    AppChain chain,
    ITronAddress address,
    OnSwitchTronAccount switchRippleAccount);
typedef OnSwitchTronAccount = void Function(ITronAddress? address);

class ControllerTronTransactionAccountView extends StatefulWidget {
  const ControllerTronTransactionAccountView(
      {super.key, required this.childBulder, required this.title});
  final OnTronTransactionPage childBulder;
  final String title;
  @override
  State<ControllerTronTransactionAccountView> createState() =>
      _ControllerTronTransactionAccountViewState();
}

class _ControllerTronTransactionAccountViewState
    extends State<ControllerTronTransactionAccountView> with SafeState {
  late WalletProvider wallet;
  late AppChain chainAccount;
  late ITronAddress address;
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>();

  void switchAccount(ITronAddress? updateAddress) async {
    if (updateAddress == null) return;
    if (!chainAccount.account.addresses.contains(updateAddress)) return;
    if (updateAddress == chainAccount.account.address) return;
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
    chainAccount = wallet.chain;
    address = chainAccount.account.address as ITronAddress;
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
              widget.childBulder(wallet, chainAccount, address, switchAccount)),
    );
  }
}
