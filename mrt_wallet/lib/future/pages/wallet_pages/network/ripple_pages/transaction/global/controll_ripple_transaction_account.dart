import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/controller/wallet_provider.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

typedef OnRippleTransactipnPage = Widget Function(
    WalletProvider wallet,
    AppChain account,
    IXRPAddress address,
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
  late AppChain account;
  late IXRPAddress address;
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>();

  void switchAccount(IXRPAddress? updateAddress) async {
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
    address = account.account.address as IXRPAddress;
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
