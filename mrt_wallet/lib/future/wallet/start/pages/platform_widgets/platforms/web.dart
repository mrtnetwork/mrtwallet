import 'package:flutter/material.dart';
import 'package:mrt_native_support/web/api/chrome/api/core.dart';
import 'package:mrt_wallet/app/constant/global/state.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/controller/impl/web3_request_controller.dart';
import 'package:mrt_wallet/future/wallet/controller/wallet/cross/web.dart';
import 'package:mrt_wallet/future/wallet/web3/pages/permission_view.dart';
import 'package:mrt_wallet/future/widgets/widgets/widget_constant.dart';

List<Widget> bottomAppBarWidgets(BuildContext context) {
  if (isExtension) {
    return [
      IconButton(
          onPressed: () {
            final wallet = context.watch<WalletProvider>(StateConst.main);
            context.openDialogPage(
              "update_permission".tr,
              fullWidget: Web3PermissionUpdateView(
                  controller: wallet.wallet as Web3RequestControllerImpl),
            );
          },
          icon: const Icon(Icons.travel_explore))
    ];
  }
  return [];
}

Widget appbarWidgets() {
  if (isExtension) return _AppbarExtentionWidget();
  return WidgetConstant.sizedBox;
}

class _AppbarExtentionWidget extends StatelessWidget {
  const _AppbarExtentionWidget();

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>(StateConst.main).wallet
        as ExtentionWallet;

    return LiveWidget(() {
      final value = wallet.fromActionLive;
      if (value.value) {
        return IconButton(
            onPressed: () {
              wallet.openPopup(
                () {
                  context.showAlert("another_instance_already_active".tr);
                },
              );
            },
            icon: const Icon(Icons.open_in_new_rounded));
      }
      return WidgetConstant.sizedBox;
    });
  }
}
