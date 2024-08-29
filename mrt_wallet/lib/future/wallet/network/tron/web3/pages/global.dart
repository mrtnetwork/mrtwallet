import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/network/forms/tron/forms/forms.dart';
import 'package:mrt_wallet/future/wallet/network/tron/web3/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/web3/pages/view_controller.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'fields/request_account.dart';
import 'fields/sign_message_v2.dart';

class TronWeb3GlobalFieldsView<RESPONSE,
    T extends Web3TronRequestParam<RESPONSE>> extends StatelessWidget {
  const TronWeb3GlobalFieldsView(
      {required this.wallet, super.key, required this.request});
  final Web3TronRequest<RESPONSE, T> request;
  final WalletProvider wallet;

  @override
  Widget build(BuildContext context) {
    return Web3PageRequestControllerView(
      controller: () => Web3TronGlobalRequestController<RESPONSE, T>(
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
  const _GlobalFieldsView(
      {required this.form, required this.controller, Key? key})
      : super(key: key);
  final TronWeb3Form form;
  final Web3TronGlobalRequestController controller;
  @override
  Widget build(BuildContext context) {
    switch (form.request.params.method) {
      case Web3TronRequestMethods.requestAccounts:
        return TronWeb3RequestAccountsView(
          controller: controller,
          field: form as TronRequestAccountForm,
        );
      case Web3TronRequestMethods.signMessageV2:
        return TronWeb3SignMessageV2RequestView(
          request: form as TronWeb3Form<Web3TronSignMessageV2>,
        );
      default:
        return const SliverPadding(padding: EdgeInsets.zero);
    }
  }
}
