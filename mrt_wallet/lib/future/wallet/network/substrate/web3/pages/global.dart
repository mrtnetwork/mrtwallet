import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/wallet/controller/controller.dart';
import 'package:mrt_wallet/future/wallet/network/forms/substrate/substrate.dart';
import 'package:mrt_wallet/future/wallet/network/substrate/web3/pages/fields/add_new_chain.dart';
import 'package:mrt_wallet/future/wallet/network/substrate/web3/pages/fields/update_chain_metadata.dart';
import 'package:mrt_wallet/future/wallet/network/substrate/web3/web3.dart';
import 'package:mrt_wallet/future/wallet/web3/pages/view_controller.dart';
import 'package:mrt_wallet/wallet/web3/networks/substrate/substrate.dart';
import 'fields/request_account.dart';
import 'fields/sign_message.dart';

class SubstrateWeb3GlobalFieldsView<RESPONSE,
    T extends Web3SubstrateRequestParam<RESPONSE>> extends StatelessWidget {
  const SubstrateWeb3GlobalFieldsView(
      {required this.wallet, super.key, required this.request});
  final Web3SubstrateRequest<RESPONSE, T> request;
  final WalletProvider wallet;

  @override
  Widget build(BuildContext context) {
    return Web3PageRequestControllerView(
      controller: () => Web3SubstrateGlobalRequestController<RESPONSE, T>(
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
  final SubstrateWeb3Form form;
  final Web3SubstrateGlobalRequestController controller;
  @override
  Widget build(BuildContext context) {
    switch (form.request.params.method) {
      case Web3SubstrateRequestMethods.requestAccounts:
        return SubstrateWeb3RequestAccountsView(
            controller: controller, field: form as SubstrateRequestAccountForm);
      case Web3SubstrateRequestMethods.signMessage:
        return SubstrateWeb3SignMessageRequestView(
            request:
                form as Web3SubstrateSignMessageForm<Web3SubstrateSignMessage>);
      case Web3SubstrateRequestMethods.addSubstrateChain:
        final addNewChain = form as Web3SubstrateAddNewChainForm;
        if (addNewChain.chain != null) {
          return SubstrateWeb3UpdateChainMetadataRequestView(
              request: addNewChain);
        }
        return SubstrateWeb3AddNewChainRequestView(request: addNewChain);
      default:
        return const SliverPadding(padding: EdgeInsets.zero);
    }
  }
}
