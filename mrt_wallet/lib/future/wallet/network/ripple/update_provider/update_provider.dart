import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/global/pages/update_network_provider.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

class UpdateRippleProviderView extends StatelessWidget {
  const UpdateRippleProviderView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<RippleChain>(
        clientRequired: false,
        childBulder: (wallet, chain, onAccountChanged) =>
            _UpdateRippleProvider(chain));
  }
}

class _UpdateRippleProvider extends StatefulWidget {
  const _UpdateRippleProvider(this.account);
  final RippleChain account;

  @override
  State<_UpdateRippleProvider> createState() => _UpdateRippleProviderState();
}

class _UpdateRippleProviderState extends State<_UpdateRippleProvider>
    with
        SafeState<_UpdateRippleProvider>,
        ProgressMixin<_UpdateRippleProvider>,
        UpdateNetworkProviderState<
            _UpdateRippleProvider,
            RippleAPIProvider,
            XRPAddress,
            IXRPAddress,
            RippleClient,
            TokenCore,
            NFTCore,
            RippleChain> {
  @override
  RippleChain get chain => widget.account;

  @override
  RippleAPIProvider createProvider(
      {required String url,
      required APIProviderServiceInfo service,
      ProviderAuthenticated? auth}) {
    return RippleAPIProvider(
        uri: url, identifier: APIUtils.getProviderIdentifier(), auth: auth);
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
  Future<RippleAPIProvider> validate(RippleAPIProvider provider) async {
    final client = APIUtils.buildRippleProvider(
        provider: provider, network: network.toNetwork());
    final init = await client.onInit();
    if (!init) {
      throw WalletException("ripple_provider_network_id_validator");
    }
    return provider;
  }
}
