import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/network/forms/ton/ton.dart';
import 'package:mrt_wallet/future/wallet/network/ton/web3/controller/controller/global.dart';
import 'package:mrt_wallet/future/wallet/web3/pages/view_controller.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/ton.dart';
import 'fields/request_account.dart';
import 'fields/sign_message.dart';

class TonWeb3GlobalFieldsView<RESPONSE, T extends Web3TonRequestParam<RESPONSE>>
    extends StatelessWidget {
  const TonWeb3GlobalFieldsView(
      {required this.wallet, super.key, required this.request});
  final Web3TonRequest<RESPONSE, T> request;
  final WalletProvider wallet;

  @override
  Widget build(BuildContext context) {
    return Web3PageRequestControllerView(
      controller: () => Web3TonGlobalRequestController<RESPONSE, T>(
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
  final TonWeb3Form form;
  final Web3TonGlobalRequestController controller;
  @override
  Widget build(BuildContext context) {
    switch (form.request.params.method) {
      case Web3TonRequestMethods.requestAccounts:
        return TonWeb3RequestAccountsView(
            controller: controller, field: form as TonRequestAccountForm);
      case Web3TonRequestMethods.signMessage:
        return TonWeb3SignMessageRequestView(
            request: form as Web3TonSignMessageForm<Web3TonSignMessage>);
      default:
        return const SliverPadding(padding: EdgeInsets.zero);
    }
  }
}
