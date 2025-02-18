import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/web3/pages/page_progress.dart';
import 'package:on_chain/on_chain.dart';

import '../wallet/models/access/wallet_access.dart';

class TestWidget extends StatefulWidget {
  const TestWidget({super.key});

  @override
  State<TestWidget> createState() => _Web3PermissionUpdateViewTestState();
}

class _Web3PermissionUpdateViewTestState extends State<TestWidget> {
  final GlobalKey<Web3PageProgressState> page = GlobalKey();
  void success() {
    page.response();
  }

  void suucessRespone() {
    page.successRequest();
  }

  @override
  Widget build(BuildContext context) {
    return PasswordCheckerView(
      appbar: AppBar(
        actions: [
          TextButton(
              onPressed: () {
                page.errorResponse(error: DartSuiPluginException("jafar "));
              },
              child: Text("close request")),
          TextButton(
              onPressed: () {
                page.error(
                  error: WalletExceptionConst.rejectSigning,
                  showBackButton: true,
                );
              },
              child: Text("error")),
          TextButton(
              onPressed: () {
                page.idle();
              },
              child: Text("idle")),
          TextButton(
              onPressed: () {
                page.process(text: "working ...");
              },
              child: Text("process"))
        ],
      ),
      accsess: WalletAccsessType.unlock,
      onAccsess: (credential, password, network) {
        return Web3PageProgress(
          key: page,
          child: (context) {
            return Column(children: [
              SizedBox(
                  width: 100,
                  height: 100,
                  child: Container(color: context.colors.inverseSurface))
            ]);
          },
        );
      },
    );
  }
}
