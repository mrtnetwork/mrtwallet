import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/pages/start_page/controller/wallet_provider.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/main.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

typedef SolanaAccountBuilder<N extends AppNetworkImpl,
        A extends Bip32AddressCore>
    = Widget Function(WalletProvider wallet, AppChain account, A address,
        N network, OnNetworkAccountChange onAccountChanged);

typedef OnNetworkAccountChange = void Function(Bip32AddressCore? address);

class NetworkAccountControllerView<N extends AppNetworkImpl,
    A extends Bip32AddressCore> extends StatefulWidget {
  const NetworkAccountControllerView(
      {super.key, required this.childBulder, required this.title});
  final SolanaAccountBuilder<N, A> childBulder;
  final String title;
  @override
  State<NetworkAccountControllerView> createState() =>
      _NetworkAccountControllerViewState<N, A>();
}

class _NetworkAccountControllerViewState<N extends AppNetworkImpl,
        A extends Bip32AddressCore>
    extends State<NetworkAccountControllerView<N, A>> with SafeState {
  late WalletProvider wallet;
  late AppChain account;
  late A address;
  final GlobalKey<PageProgressState> progressKey =
      GlobalKey<PageProgressState>();

  void switchAccount(Bip32AddressCore? updateAddress) async {
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
    address = account.account.address as A;
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
              wallet, account, address, account.network as N, switchAccount)),
    );
  }
}
