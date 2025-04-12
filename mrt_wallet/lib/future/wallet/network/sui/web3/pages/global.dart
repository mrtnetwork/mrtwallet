import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';

import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:mrt_wallet/future/wallet/network/sui/web3/web3.dart';
import 'package:mrt_wallet/future/wallet/web3/pages/view_controller.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'fields/sign_message.dart';

class SuiWeb3GlobalFieldsView<RESPONSE, T extends Web3SuiRequestParam<RESPONSE>>
    extends StatelessWidget {
  const SuiWeb3GlobalFieldsView(
      {required this.wallet, super.key, required this.request});
  final Web3SuiRequest<RESPONSE, T> request;
  final WalletProvider wallet;

  @override
  Widget build(BuildContext context) {
    return Web3NetworkPageRequestControllerView(
      controller: () => Web3SuiGlobalRequestController<RESPONSE, T>(
          walletProvider: wallet, request: request),
      builder: (context, controller) {
        return [
          _GlobalFieldsView(form: controller.form, controller: controller)
        ];
      },
      request: request,
    );
  }
}

class _GlobalFieldsView extends StatelessWidget {
  const _GlobalFieldsView({required this.form, required this.controller});
  final SuiWeb3Form form;
  final Web3SuiGlobalRequestController controller;
  @override
  Widget build(BuildContext context) {
    switch (form.request.params.method) {
      case Web3SuiRequestMethods.signMessage:
      case Web3SuiRequestMethods.signPersonalMessage:
        return SuiWeb3SignMessageRequestView(
          request: form as Web3SuiSignMessageForm,
        );
      default:
        return const SliverPadding(padding: EdgeInsets.zero);
    }
  }
}
