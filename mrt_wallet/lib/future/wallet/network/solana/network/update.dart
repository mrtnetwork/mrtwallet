import 'package:flutter/material.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/future/future.dart';
import 'package:mrt_wallet/future/state_managment/state_managment.dart';
import 'package:mrt_wallet/future/wallet/global/pages/update_network_provider.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:on_chain/solana/src/address/sol_address.dart';

class UpdateSolanaProvider extends StatelessWidget {
  const UpdateSolanaProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return NetworkAccountControllerView<SolanaChain>(
        clientRequired: false,
        childBulder: (wallet, chain, onAccountChanged) =>
            _UpdateSolanaProvider(chain));
  }
}

class _UpdateSolanaProvider extends StatefulWidget {
  const _UpdateSolanaProvider(this.account);
  final SolanaChain account;

  @override
  State<_UpdateSolanaProvider> createState() => _UpdateSolanaProviderState();
}

class _UpdateSolanaProviderState extends State<_UpdateSolanaProvider>
    with
        SafeState<_UpdateSolanaProvider>,
        ProgressMixin<_UpdateSolanaProvider>,
        UpdateNetworkProviderState<
            _UpdateSolanaProvider,
            SolanaAPIProvider,
            SolAddress,
            ISolanaAddress,
            SolanaClient,
            TokenCore,
            NFTCore,
            SolanaChain> {
  @override
  SolanaChain get chain => widget.account;

  @override
  SolanaAPIProvider createProvider(
      {required String url,
      required APIProviderServiceInfo service,
      ProviderAuthenticated? auth}) {
    return SolanaAPIProvider(
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
  Future<SolanaAPIProvider> validate(SolanaAPIProvider provider) async {
    final client = APIUtils.buildSoalanaProvider(
        provider: provider, network: network.toNetwork());
    final init = await client.validateNetworkGenesis();
    if (!init) {
      throw WalletException("network_genesis_hash_validator");
    }
    return provider;
  }
}
