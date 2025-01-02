import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/global/pages/update_network_provider.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:ton_dart/ton_dart.dart';

class UpdateTonProvider extends StatelessWidget {
  const UpdateTonProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<TheOpenNetworkChain>(
        clientRequired: false,
        childBulder: (wallet, chain, onAccountChanged) =>
            _UpdateTonProvider(chain));
  }
}

class _UpdateTonProvider extends StatefulWidget {
  const _UpdateTonProvider(this.account);
  final TheOpenNetworkChain account;

  @override
  State<_UpdateTonProvider> createState() => _UpdateSolanaProviderState();
}

class _UpdateSolanaProviderState extends State<_UpdateTonProvider>
    with
        SafeState<_UpdateTonProvider>,
        ProgressMixin<_UpdateTonProvider>,
        UpdateNetworkProviderState<
            _UpdateTonProvider,
            TonAPIProvider,
            TonAddress,
            ITonAddress,
            TonClient,
            TokenCore,
            NFTCore,
            TheOpenNetworkChain> {
  @override
  TheOpenNetworkChain get chain => widget.account;

  @override
  TonAPIProvider createProvider(
      {required String url,
      required APIProviderServiceInfo service,
      ProviderAuthenticated? auth}) {
    return TonAPIProvider(
        serviceName: url,
        websiteUri: url,
        uri: url,
        auth: auth,
        apiType: TonApiType.fromValue(service.name),
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
  Future<TonAPIProvider> validate(TonAPIProvider provider) async {
    final client = APIUtils.buildTonApiProvider(
        provider: provider, network: network.toNetwork());
    await client.getWorkChainId();
    return provider;
  }
}
