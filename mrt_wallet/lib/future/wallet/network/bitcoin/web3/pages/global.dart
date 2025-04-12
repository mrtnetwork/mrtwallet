import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/network/bitcoin/web3/controller/controller/global.dart';

import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:mrt_wallet/future/wallet/web3/pages/view_controller.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'fields/sign_message.dart';

class BitcoinWeb3GlobalFieldsView<RESPONSE,
    T extends Web3BitcoinRequestParam<RESPONSE>> extends StatelessWidget {
  const BitcoinWeb3GlobalFieldsView(
      {required this.wallet, super.key, required this.request});
  final Web3BitcoinRequest<RESPONSE, T> request;
  final WalletProvider wallet;

  @override
  Widget build(BuildContext context) {
    return Web3NetworkPageRequestControllerView(
      controller: () => Web3BitcoinGlobalRequestController<RESPONSE, T>(
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
  final BitcoinWeb3Form form;
  final Web3BitcoinGlobalRequestController controller;
  @override
  Widget build(BuildContext context) {
    switch (form.request.params.method) {
      case Web3BitcoinRequestMethods.signPersonalMessage:
        return BitcoinWeb3SignMessageRequestView(
          request: form as Web3BitcoinSignMessageForm,
        );
      default:
        return const SliverPadding(padding: EdgeInsets.zero);
    }
  }
}
