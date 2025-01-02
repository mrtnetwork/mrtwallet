import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/global/pages/update_network_provider.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:on_chain/on_chain.dart';

class UpdateCardanoProvider extends StatelessWidget {
  const UpdateCardanoProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<ADAChain>(
        clientRequired: false,
        childBulder: (wallet, chain, onAccountChanged) =>
            _UpdateCardanoProvider(chain));
  }
}

class _UpdateCardanoProvider extends StatefulWidget {
  const _UpdateCardanoProvider(this.account);
  final ADAChain account;

  @override
  State<_UpdateCardanoProvider> createState() => _UpdateSolanaProviderState();
}

class _UpdateSolanaProviderState extends State<_UpdateCardanoProvider>
    with
        SafeState<_UpdateCardanoProvider>,
        ProgressMixin<_UpdateCardanoProvider>,
        UpdateNetworkProviderState<
            _UpdateCardanoProvider,
            CardanoAPIProvider,
            ADAAddress,
            ICardanoAddress,
            CardanoClient,
            TokenCore,
            NFTCore,
            ADAChain> {
  @override
  ADAChain get chain => widget.account;

  @override
  CardanoAPIProvider createProvider(
      {required String url,
      required APIProviderServiceInfo service,
      ProviderAuthenticated? auth}) {
    return CardanoAPIProvider(
        serviceName: url,
        websiteUri: url,
        uri: url,
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
  Future<CardanoAPIProvider> validate(CardanoAPIProvider provider) async {
    final client = APIUtils.buildCardanoProvider(
        provider: provider, network: network.toNetwork());
    final init = await client.onInit();
    if (!init) {
      throw WalletException("cardano_network_magic_validator");
    }
    return provider;
  }
}
