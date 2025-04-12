import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/web3/global/connect/controller/connect.dart';
import 'package:mrt_wallet/future/wallet/web3/pages/permission_view.dart';
import 'package:mrt_wallet/future/wallet/web3/pages/view_controller.dart';
import 'package:mrt_wallet/wallet/web3/networks/global/params/core/core.dart';

class GlobalWeb3ConnectView extends StatelessWidget {
  const GlobalWeb3ConnectView(
      {required this.wallet, super.key, required this.request});
  final Web3GlobalRequest request;
  final WalletProvider wallet;

  @override
  Widget build(BuildContext context) {
    return Web3GlobalPageRequestControllerView(
        controller: () => Web3GlobalRequestConnectStateController(request),
        builder: (context, controller) {
          return Web3ApplicationPermissionView(
              web3RequestController: controller);
        },
        request: request);
  }
}
