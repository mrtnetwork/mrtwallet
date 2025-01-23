import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/constant/constant.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';

import '../wallet/models/access/wallet_access.dart';

class Web3PermissionUpdateViewTest extends StatelessWidget {
  const Web3PermissionUpdateViewTest({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstraintsBoxView(
      alignment: Alignment.center,
      // maxHeight: APPConst.maxDialogHeight,
      padding: WidgetConstant.paddingHorizontal20,
      maxWidth: APPConst.dialogWidth,
      child: ClipRRect(
          borderRadius: WidgetConstant.border25,
          child: PasswordCheckerView(
            backgroundColor: Colors.transparent,
            accsess: WalletAccsessType.unlock,
            onAccsess: (credential, password, network) => ClipRRect(
              borderRadius: WidgetConstant.border25,
              child: ConstraintsBoxView(
                alignment: Alignment.center,
                maxHeight: APPConst.maxDialogHeight,
                padding: WidgetConstant.paddingHorizontal20,
                maxWidth: APPConst.dialogWidth,
                child: Container(
                  color: Colors.red,
                ),
              ),
            ),
          )),
    );
  }
}

class TestWidget extends StatefulWidget {
  const TestWidget({super.key});

  @override
  State<TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      ElevatedButton(
          onPressed: () {
            context.openDialogPage(
              "update_permission".tr,
              fullWidget: Web3PermissionUpdateViewTest(),
            );
          },
          child: Text("Test")),
    ]);
  }
}
