import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/models/models/typedef.dart';
import 'package:mrt_wallet/future/router/page_router.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/widgets/custom_widgets.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';

class NoAccountFoundInChainWidget extends StatelessWidget {
  const NoAccountFoundInChainWidget(this.chainAccount,
      {this.onClosePage, Key? key})
      : super(key: key);
  final Chain chainAccount;
  final DynamicVoid? onClosePage;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: WidgetConstant.padding20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PageTitleSubtitle(
              title: "setup_network_address"
                  .tr
                  .replaceOne(chainAccount.network.coinParam.token.name),
              body: Text("setup_network_address_desc"
                  .tr
                  .replaceOne(chainAccount.network.coinParam.token.name)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FixedElevatedButton(
                    padding: WidgetConstant.paddingVertical20,
                    onPressed: () {
                      context
                          .to(PageRouter.setupGenericAddress,
                              argruments: chainAccount)
                          .then((e) {
                        onClosePage?.call();
                      });
                    },
                    child: Text("setup_address".tr)),
              ],
            )
          ],
        ));
  }
}
