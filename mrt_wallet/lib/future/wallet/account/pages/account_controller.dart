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
      {super.key,
      required this.childBulder,
      this.title,
      this.allowEmptyAccount = true,
      this.clientRequired = true});
  final PageChainBuilder<T> childBulder;
  final String? title;
  final bool allowEmptyAccount;
  final bool clientRequired;

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
  StreamWidgetStatus status = StreamWidgetStatus.idle;
  String error = "page_required_address".tr;
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
    if (!widget.allowEmptyAccount && !account.haveAddress) {
      status = StreamWidgetStatus.error;
      error = "page_required_address".tr;
    } else if (account is! T) {
      status = StreamWidgetStatus.error;
      error = "requested_chain_differs".tr;
    } else if (widget.clientRequired && account.clientNullable == null) {
      status = StreamWidgetStatus.error;
      error = "page_required_provider".tr;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    wallet = context.watch<WalletProvider>(StateConst.main);
    _checkAccounts();
  }

  PreferredSizeWidget? appBar() {
    if (widget.title == null) return null;
    return AppBar(title: Text(widget.title ?? ''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: PageProgress(
          initialStatus: status,
          backToIdle: APPConst.animationDuraion,
          initialWidget: ProgressWithTextView(
            text: error,
            icon: WidgetConstant.errorIconLarge,
          ),
          key: progressKey,
          child: (c) =>
              widget.childBulder(wallet, account.cast<T>(), switchAccount)),
    );
  }
}
