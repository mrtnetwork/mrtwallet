import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart'
    show APPConst, SafeState, StateConst, Translate, QuickContextAccsess;
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';

import 'package:mrt_wallet/wallet/wallet.dart'
    show WalletNetwork, CryptoAddress, ChainHandler;

typedef SolanaAccountBuilder<N extends WalletNetwork, A extends CryptoAddress?>
    = Widget Function(WalletProvider wallet, ChainHandler account, A address,
        N network, OnNetworkAccountChange onAccountChanged);

typedef OnNetworkAccountChange = void Function(CryptoAddress? address);

class NetworkAccountControllerView<N extends WalletNetwork,
    A extends CryptoAddress?> extends StatefulWidget {
  const NetworkAccountControllerView(
      {super.key, required this.childBulder, required this.title});
  final SolanaAccountBuilder<N, A> childBulder;
  final String title;
  @override
  State<NetworkAccountControllerView> createState() =>
      _NetworkAccountControllerViewState<N, A>();
}

class _NetworkAccountControllerViewState<N extends WalletNetwork,
        A extends CryptoAddress?>
    extends State<NetworkAccountControllerView<N, A>> with SafeState {
  late WalletProvider wallet;
  late ChainHandler account;
  late A address;
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>();

  void switchAccount(CryptoAddress? updateAddress) async {
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

    if (!account.haveAddress) {
      address = null as A;
    } else {
      address = account.account.address as A;
    }
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
          child: () => widget.childBulder(
              wallet, account, address, account.network as N, switchAccount)),
    );
  }
}
