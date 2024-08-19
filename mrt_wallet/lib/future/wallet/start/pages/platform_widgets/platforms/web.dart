import 'package:flutter/material.dart';
import 'package:mrt_native_support/web/api/chrome/api/core.dart';
import 'package:mrt_wallet/app/constant/global/state.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/controller/impl/web3_request_controller.dart';
import 'package:mrt_wallet/future/wallet/web3/pages/permission_view.dart';

List<Widget> bottomAppBarWidgets(BuildContext context) {
  if (isExtention) {
    return [
      IconButton(
          onPressed: () {
            final wallet = context.watch<WalletProvider>(StateConst.main);

            context.openSliverBottomSheet("update_permission".tr,
                bodyBuilder: (c) => Web3PermissionUpdateView(
                    controller: wallet.wallet as Web3RequestControllerImpl,
                    scrollController: c),
                centerContent: false);
          },
          icon: const Icon(Icons.travel_explore))
    ];
  }
  return [];
}