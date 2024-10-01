import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart' show APPConst, StateConst;
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

import 'package:mrt_wallet/wallet/wallet.dart'
    show ChainAccount, Chain, APPCHAIN;

typedef PageChainBuilder<T extends APPCHAIN> = Widget Function(
    WalletProvider wallet, T chain, OnNetworkAccountChange onAccountChanged);

typedef OnNetworkAccountChange = void Function(ChainAccount? address);

class NetworkAccountControllerView<T extends APPCHAIN> extends StatefulWidget {
  const NetworkAccountControllerView(
      {super.key, required this.childBulder, required this.title});
  final PageChainBuilder<T> childBulder;
  final String title;

  @override
  State<NetworkAccountControllerView> createState() =>
      _NetworkAccountControllerViewState<T>();
}

class _NetworkAccountControllerViewState<T extends APPCHAIN>
    extends State<NetworkAccountControllerView<T>> with SafeState {
  late WalletProvider wallet;
  late Chain account;
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>();

  void switchAccount(ChainAccount? updateAddress) async {
    if (updateAddress == null) return;
    if (updateAddress == account.address) return;
    progressKey.progressText("switch_account".tr);
    final result = await wallet.wallet.switchAccount(
        account: account, address: updateAddress, closePages: false);
    if (result.hasError) {
      progressKey.errorText(result.error!, backToIdle: false);
    } else {
      _checkAccounts();
      progressKey.success();
    }
  }

  void _checkAccounts() {
    account = wallet.wallet.chain;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    wallet = context.watch<WalletProvider>(StateConst.main);
    _checkAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: PageProgress(
          backToIdle: APPConst.animationDuraion,
          key: progressKey,
          child: (c) =>
              widget.childBulder(wallet, account.cast<T>(), switchAccount)),
    );
  }
}
