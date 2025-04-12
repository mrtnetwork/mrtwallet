import 'package:flutter/material.dart';
import 'package:mrt_wallet/future/wallet/network/cosmos/network/import_chain.dart';
import 'package:mrt_wallet/future/wallet/network/forms/cosmos/cosmos.dart';

class CosmosWeb3AddNewChainRequestView extends StatelessWidget {
  const CosmosWeb3AddNewChainRequestView({required this.request, super.key});
  final Web3CosmosAddNewChainForm request;
  // Web3CosmosSignMessage get param => request.request.params;
  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(slivers: [
      CosmosImportNetworkFieldsView(
          form: request.form, onImport: request.importChain)
    ]);
  }
}
