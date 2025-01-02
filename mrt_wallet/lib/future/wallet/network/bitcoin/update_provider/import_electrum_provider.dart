import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:flutter/material.dart';
import 'package:mrt_native_support/platform_interface.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/global/pages/update_network_provider.dart';
import 'package:mrt_wallet/wallet/wallet.dart';

class ImportElectrumProviderView extends StatelessWidget {
  const ImportElectrumProviderView({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<BitcoinChain>(
        childBulder: (wallet, chain, onAccountChanged) =>
            _ImportElectrumProvider(chain),
        clientRequired: false);
  }
}

class _ImportElectrumProvider extends StatefulWidget {
  const _ImportElectrumProvider(this.account);
  final BitcoinChain account;

  @override
  State<_ImportElectrumProvider> createState() =>
      __ImportElectrumProviderState();
}

class __ImportElectrumProviderState extends State<_ImportElectrumProvider>
    with
        SafeState<_ImportElectrumProvider>,
        ProgressMixin<_ImportElectrumProvider>,
        UpdateNetworkProviderState<
            _ImportElectrumProvider,
            BaseBitcoinAPIProvider,
            BitcoinBaseAddress,
            IBitcoinAddress,
            BitcoinClient,
            TokenCore,
            NFTCore,
            BitcoinChain> {
  @override
  BitcoinChain get chain => widget.account;

  @override
  BaseBitcoinAPIProvider createProvider(
      {required String url,
      required APIProviderServiceInfo service,
      ProviderAuthenticated? auth}) {
    return ElectrumAPIProvider(
        url: url,
        protocol: protocol,
        identifier: APIUtils.getProviderIdentifier());
  }

  @override
  late final List<ServiceProtocol> supportedProtocol;

  void init() {
    if (PlatformInterface.isWeb) {
      supportedProtocol = [ServiceProtocol.websocket];
    } else {
      supportedProtocol = [
        ServiceProtocol.ssl,
        ServiceProtocol.tcp,
        ServiceProtocol.websocket
      ];
    }
    protocol = supportedProtocol.first;
  }

  @override
  void onInitOnce() {
    MethodUtils.after(() async => init());
    super.onInitOnce();
  }

  @override
  Future<BaseBitcoinAPIProvider> validate(
      BaseBitcoinAPIProvider provider) async {
    final client = APIUtils.buildBitcoinElectrumProvider(
        provider: provider as ElectrumAPIProvider,
        network: network.toNetwork());
    final init = await client.onInit();
    if (!init) {
      throw WalletException("network_genesis_hash_validator");
    }
    return provider;
  }
}
