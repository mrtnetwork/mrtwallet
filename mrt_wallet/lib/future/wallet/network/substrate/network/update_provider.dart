import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/global/pages/update_network_provider.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class UpdateSubstrateProvider extends StatelessWidget {
  const UpdateSubstrateProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<SubstrateChain>(
        clientRequired: false,
        childBulder: (wallet, chain, onAccountChanged) =>
            _UpdateSubstrateProvider(chain));
  }
}

class _UpdateSubstrateProvider extends StatefulWidget {
  const _UpdateSubstrateProvider(this.account);
  final SubstrateChain account;

  @override
  State<_UpdateSubstrateProvider> createState() => _UpdateSolanaProviderState();
}

class _UpdateSolanaProviderState extends State<_UpdateSubstrateProvider>
    with
        SafeState<_UpdateSubstrateProvider>,
        ProgressMixin<_UpdateSubstrateProvider>,
        UpdateNetworkProviderState<
            _UpdateSubstrateProvider,
            SubstrateAPIProvider,
            BaseSubstrateAddress,
            ISubstrateAddress,
            SubstrateClient,
            TokenCore,
            NFTCore,
            SubstrateChain> {
  @override
  SubstrateChain get chain => widget.account;

  @override
  SubstrateAPIProvider createProvider(
      {required String url,
      required APIProviderServiceInfo service,
      ProviderAuthenticated? auth}) {
    return SubstrateAPIProvider(
        uri: url, auth: auth, identifier: APIUtils.getProviderIdentifier());
  }

  @override
  late final List<ServiceProtocol> supportedProtocol;

  void init() {
    supportedProtocol = [ServiceProtocol.http, ServiceProtocol.websocket];
    protocol = supportedProtocol.first;
  }

  @override
  void onInitOnce() {
    MethodUtils.after(() async => init());
    super.onInitOnce();
  }

  @override
  Future<SubstrateAPIProvider> validate(SubstrateAPIProvider provider) async {
    final client = APIUtils.buildsubstrateClient(
        provider: provider, network: network.toNetwork());
    final init = await client.validateNetworkGenesis();
    if (!init) {
      throw WalletException("network_genesis_hash_validator");
    }
    return provider;
  }
}
