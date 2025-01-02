import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/global/pages/update_network_provider.dart';
import 'package:mrt_wallet/wallet/wallet.dart';

class UpdateCosmosProvider extends StatelessWidget {
  const UpdateCosmosProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<CosmosChain>(
        clientRequired: false,
        childBulder: (wallet, chain, onAccountChanged) =>
            _UpdateCosmosProvider(chain));
  }
}

class _UpdateCosmosProvider extends StatefulWidget {
  const _UpdateCosmosProvider(this.account);
  final CosmosChain account;

  @override
  State<_UpdateCosmosProvider> createState() => _UpdateCosmosProviderState();
}

class _UpdateCosmosProviderState extends State<_UpdateCosmosProvider>
    with
        SafeState<_UpdateCosmosProvider>,
        ProgressMixin<_UpdateCosmosProvider>,
        UpdateNetworkProviderState<
            _UpdateCosmosProvider,
            CosmosAPIProvider,
            CosmosBaseAddress,
            ICosmosAddress,
            CosmosClient,
            TokenCore,
            NFTCore,
            CosmosChain> {
  @override
  CosmosChain get chain => widget.account;

  @override
  CosmosAPIProvider createProvider(
      {required String url,
      required APIProviderServiceInfo service,
      ProviderAuthenticated? auth}) {
    return CosmosAPIProvider(
        uri: url, auth: auth, identifier: APIUtils.getProviderIdentifier());
  }

  @override
  late final List<ServiceProtocol> supportedProtocol;

  void init() {
    supportedProtocol = [ServiceProtocol.http];
    protocol = supportedProtocol.first;
  }

  @override
  void onInitOnce() {
    MethodUtils.after(() async => init());
    super.onInitOnce();
  }

  @override
  Future<CosmosAPIProvider> validate(CosmosAPIProvider provider) async {
    final client = APIUtils.buildTendermintProvider(
        provider: provider, network: network.toNetwork());
    final init = await client.validateNetworkChainId();
    if (!init) {
      throw WalletException("network_incorrect_chain_id");
    }
    return provider;
  }
}
