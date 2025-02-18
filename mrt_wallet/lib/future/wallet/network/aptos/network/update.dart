import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/global/pages/update_network_provider.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:on_chain/aptos/src/address/address/address.dart';

class UpdateAptosProvider extends StatelessWidget {
  const UpdateAptosProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<AptosChain>(
        clientRequired: false,
        childBulder: (wallet, chain, onAccountChanged) =>
            _UpdateAptosProvider(chain));
  }
}

class _UpdateAptosProvider extends StatefulWidget {
  const _UpdateAptosProvider(this.account);
  final AptosChain account;

  @override
  State<_UpdateAptosProvider> createState() => _UpdateAptosProviderState();
}

class _UpdateAptosProviderState extends State<_UpdateAptosProvider>
    with
        SafeState<_UpdateAptosProvider>,
        ProgressMixin<_UpdateAptosProvider>,
        UpdateNetworkProviderState<
            _UpdateAptosProvider,
            AptosAPIProvider,
            AptosAddress,
            IAptosAddress,
            AptosClient,
            TokenCore,
            NFTCore,
            AptosChain> {
  @override
  AptosChain get chain => widget.account;

  @override
  AptosAPIProvider createProvider(
      {required String url,
      required APIProviderServiceInfo service,
      ProviderAuthenticated? auth}) {
    final bool isGraphQl = service.name == ProvidersConst.aptosGraphQlName;
    return AptosAPIProvider(
        fullNodeUri: url,
        auth: auth,
        identifier: APIUtils.getProviderIdentifier(),
        type: isGraphQl
            ? AptosAPIProviderType.graphQl
            : AptosAPIProviderType.fullnode);
  }

  @override
  late final List<ServiceProtocol> supportedProtocol;

  List<AptosAPIProvider> aptosProviders = [];

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
  Future<AptosAPIProvider> validate(AptosAPIProvider provider) async {
    List<AptosAPIProvider> providers = [
      provider,
      AptosAPIProvider(
          identifier: '-1',
          fullNodeUri: '',
          type: provider.type.isFullNode
              ? AptosAPIProviderType.graphQl
              : AptosAPIProviderType.fullnode)
    ];
    final client = APIUtils.buildAptosProvider(
        provider: providers, network: network.toNetwork());
    bool init;
    if (provider.type.isFullNode) {
      init = await client.validateFullNode();
    } else {
      init = await client.validateGraphQl();
    }
    if (!init) {
      throw WalletException("network_incorrect_chain_id");
    }
    return provider;
  }
}
