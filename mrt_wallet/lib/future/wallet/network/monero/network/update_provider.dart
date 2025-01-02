import 'package:flutter/material.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/global/pages/update_network_provider.dart';
import 'package:mrt_wallet/wallet/wallet.dart';

class UpdateMoneroProvider extends StatelessWidget {
  const UpdateMoneroProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<MoneroChain>(
        clientRequired: false,
        childBulder: (wallet, chain, onAccountChanged) =>
            _UpdateMoneroProvider(chain));
  }
}

class _UpdateMoneroProvider extends StatefulWidget {
  const _UpdateMoneroProvider(this.account);
  final MoneroChain account;

  @override
  State<_UpdateMoneroProvider> createState() => _UpdateMoneroProviderState();
}

class _UpdateMoneroProviderState extends State<_UpdateMoneroProvider>
    with
        SafeState<_UpdateMoneroProvider>,
        ProgressMixin<_UpdateMoneroProvider>,
        UpdateNetworkProviderState<
            _UpdateMoneroProvider,
            MoneroAPIProvider,
            MoneroAddress,
            IMoneroAddress,
            MoneroClient,
            TokenCore,
            NFTCore,
            MoneroChain> {
  @override
  MoneroChain get chain => widget.account;

  @override
  MoneroAPIProvider createProvider(
      {required String url,
      required APIProviderServiceInfo service,
      ProviderAuthenticated? auth}) {
    return MoneroAPIProvider(
        httpNodeUri: url,
        auth: auth,
        identifier: APIUtils.getProviderIdentifier());
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
  Future<MoneroAPIProvider> validate(MoneroAPIProvider provider) async {
    final client = APIUtils.buildMoneroClient(
        provider: provider, network: network.toNetwork());
    final init = await client.validateNetworkGenesis();
    if (!init) {
      throw WalletException("network_genesis_hash_validator");
    }
    return provider;
  }
}
