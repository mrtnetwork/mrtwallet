import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/network/cosmos/web3/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/network/cosmos/web3/pages/fields/add_new_chain.dart';
import 'package:mrt_wallet/future/wallet/network/forms/forms.dart';
import 'package:mrt_wallet/future/wallet/web3/pages/view_controller.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import 'fields/sign_message.dart';
import 'fields/switch_chain.dart';

class CosmosWeb3GlobalFieldsView<RESPONSE,
    T extends Web3CosmosRequestParam<RESPONSE>> extends StatelessWidget {
  const CosmosWeb3GlobalFieldsView(
      {required this.wallet, super.key, required this.request});
  final Web3CosmosRequest<RESPONSE, T> request;
  final WalletProvider wallet;

  @override
  Widget build(BuildContext context) {
    return Web3NetworkPageRequestControllerView(
      controller: () => Web3CosmosGlobalRequestController<RESPONSE, T>(
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
  final CosmosWeb3Form form;
  final Web3CosmosGlobalRequestController controller;
  @override
  Widget build(BuildContext context) {
    switch (form.request.params.method) {
      case Web3CosmosRequestMethods.signMessage:
        return CosmosWeb3SignMessageRequestView(
            request: form as Web3CosmosSignMessageForm);
      case Web3CosmosRequestMethods.switchNetwork:
        return CosmosWeb3SwitchChainView(
            request: form as Web3CosmosSwitchCosmosChain);
      case Web3CosmosRequestMethods.addNewChain:
        return CosmosWeb3AddNewChainRequestView(
            request: form as Web3CosmosAddNewChainForm);
      default:
        return const SliverPadding(padding: EdgeInsets.zero);
    }
  }
}
