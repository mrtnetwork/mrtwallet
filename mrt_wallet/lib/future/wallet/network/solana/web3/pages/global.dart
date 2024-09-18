import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/network/forms/solana/solana.dart';
import 'package:mrt_wallet/future/wallet/network/solana/web3/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/web3/pages/view_controller.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'fields/request_account.dart';
import 'fields/sign_message.dart';

class SolanaWeb3GlobalFieldsView<RESPONSE,
    T extends Web3SolanaRequestParam<RESPONSE>> extends StatelessWidget {
  const SolanaWeb3GlobalFieldsView(
      {required this.wallet, super.key, required this.request});
  final Web3SolanaRequest<RESPONSE, T> request;
  final WalletProvider wallet;

  @override
  Widget build(BuildContext context) {
    return Web3PageRequestControllerView(
      controller: () => Web3SolanaGlobalRequestController<RESPONSE, T>(
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
  final SolanaWeb3Form form;
  final Web3SolanaGlobalRequestController controller;
  @override
  Widget build(BuildContext context) {
    switch (form.request.params.method) {
      case Web3SolanaRequestMethods.requestAccounts:
        return SolanaWeb3RequestAccountsView(
          controller: controller,
          field: form as SolanaRequestAccountForm,
        );
      case Web3SolanaRequestMethods.signMessage:
        return SolanaWeb3SignMessageRequestView(
          request: form as Web3SolanaSignMessageForm<Web3SolanaSignMessage>,
        );
      default:
        return const SliverPadding(padding: EdgeInsets.zero);
    }
  }
}
