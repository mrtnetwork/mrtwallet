import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/network/forms/stellar/stellar.dart';
import 'package:mrt_wallet/future/wallet/network/stellar/web3/controller/controller/global.dart';
import 'package:mrt_wallet/future/wallet/web3/pages/view_controller.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/stellar.dart';
import 'fields/request_account.dart';
import 'fields/sign_message.dart';

class StellarWeb3GlobalFieldsView<RESPONSE,
    T extends Web3StellarRequestParam<RESPONSE>> extends StatelessWidget {
  const StellarWeb3GlobalFieldsView(
      {required this.wallet, super.key, required this.request});
  final Web3StellarRequest<RESPONSE, T> request;
  final WalletProvider wallet;

  @override
  Widget build(BuildContext context) {
    return Web3PageRequestControllerView(
      controller: () => Web3StellarGlobalRequestController<RESPONSE, T>(
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
  final StellarWeb3Form form;
  final Web3StellarGlobalRequestController controller;
  @override
  Widget build(BuildContext context) {
    switch (form.request.params.method) {
      case Web3StellarRequestMethods.requestAccounts:
        return StellarWeb3RequestAccountsView(
            controller: controller, field: form as StellarRequestAccountForm);
      case Web3StellarRequestMethods.signMessage:
        return StellarWeb3SignMessageRequestView(
            request:
                form as Web3StellarSignMessageForm<Web3StellarSignMessage>);
      default:
        return const SliverPadding(padding: EdgeInsets.zero);
    }
  }
}
