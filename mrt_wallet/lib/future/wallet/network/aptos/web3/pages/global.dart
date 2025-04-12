import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/network/aptos/web3/controller/controller/global.dart';
import 'package:mrt_wallet/future/wallet/network/forms/aptos/aptos.dart';
import 'package:mrt_wallet/future/wallet/web3/pages/view_controller.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'fields/sign_message.dart';
import 'fields/switch_chain.dart';

class AptosWeb3GlobalFieldsView<RESPONSE,
    T extends Web3AptosRequestParam<RESPONSE>> extends StatelessWidget {
  const AptosWeb3GlobalFieldsView(
      {required this.wallet, super.key, required this.request});
  final Web3AptosRequest<RESPONSE, T> request;
  final WalletProvider wallet;

  @override
  Widget build(BuildContext context) {
    return Web3NetworkPageRequestControllerView(
      controller: () => Web3AptosGlobalRequestController<RESPONSE, T>(
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
  final AptosWeb3Form form;
  final Web3AptosGlobalRequestController controller;
  @override
  Widget build(BuildContext context) {
    switch (form.request.params.method) {
      case Web3AptosRequestMethods.signMessage:
        return AptosWeb3SignMessageRequestView(
          request: form as Web3AptosSignMessageForm,
        );
      case Web3AptosRequestMethods.switchNetwork:
        return AptosWeb3SwitchChainView(
            request: form as Web3AptosSwitchAptosChain);
      default:
        return const SliverPadding(padding: EdgeInsets.zero);
    }
  }
}
