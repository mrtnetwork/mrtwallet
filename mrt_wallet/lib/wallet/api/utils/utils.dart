import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/api/client/client.dart';
import 'package:mrt_wallet/wallet/api/constant/constant.dart';
import 'package:mrt_wallet/wallet/api/provider/provider.dart';
import 'package:mrt_wallet/wallet/api/services/service.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'package:mrt_wallet/wroker/models/networks.dart';
import 'package:on_chain/on_chain.dart';
import 'package:on_chain/solana/solana.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:ton_dart/ton_dart.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';

class APIUtils {
  static BitcoinExplorerApiProvider _buildBlockCypherOrMempolProvider(
      WalletBitcoinNetwork network, BitcoinExplorerAPIProvider provider) {
    final btcNetwork = network.coinParam.transacationNetwork;
    final api = ApiProvider(
        api: provider.config(btcNetwork),
        service: BitcoinHTTPService(provider));
    return BitcoinExplorerApiProvider(provider: api, network: network);
  }

  static BitcoinElectrumClient _buildBitcoinElectrumProvider(
      ElectrumAPIProvider provider, WalletBitcoinNetwork network) {
    return BitcoinElectrumClient(
        provider: ElectrumApiProvider(ElectrumService.fromProvider(
            provider: provider, service: provider)),
        network: network);
  }

  static EVMRPC _buildEthereumRPC(EthereumAPIProvider provider) {
    if (provider.protocol == ServiceProtocol.websocket) {
      return EVMRPC(
          EthereumWebsocketService(provider: provider, url: provider.uri));
    }
    return EVMRPC(EthereumHTTPService(provider.uri, provider));
  }

  static RpcService _buildRippleProvider(RippleAPIProvider provider) {
    if (provider.protocol == ServiceProtocol.websocket) {
      return RippleWebsocketService(url: provider.callUrl, provider: provider);
    }
    return RippleHTTPService(provider.callUrl, provider);
  }

  static BitcoinClient buildBitcoinApiPorivder(
      APIProvider provider, WalletBitcoinNetwork network) {
    if (provider is ElectrumAPIProvider) {
      return _buildBitcoinElectrumProvider(provider, network);
    }
    return _buildBlockCypherOrMempolProvider(
        network, provider as BitcoinExplorerAPIProvider);
  }

  static EthereumClient buildEthereumProvider(
      EthereumAPIProvider provider, WalletNetwork network) {
    return EthereumClient(
        provider: _buildEthereumRPC(provider), network: network);
  }

  static RippleClient buildRippleProvider(
      RippleAPIProvider provider, WalletXRPNetwork network) {
    return RippleClient(
        provider: XRPLRpc(_buildRippleProvider(provider)), network: network);
  }

  static CardanoClient buildCardanoProvider(
      CardanoAPIProvider provider, WalletCardanoNetwork network) {
    return CardanoClient(
        provider: BlockforestProvider(CardanoHTTPService(provider: provider)),
        network: network);
  }

  static CosmosClient buildTendermintProvider(
      CosmosAPIProvider provider, WalletCosmosNetwork network) {
    return CosmosClient(
        provider: TendermintProvider(
            TendermintHTTPService(provider: provider, url: provider.uri)),
        network: network,
        nodeProvider: provider.nodeUri == null
            ? null
            : ThorNodeProvider(ThorNodeHTTPService(
                provider: provider, url: provider.nodeUri!)));
  }

  static TonClient buildTonApiProvider(
      TonAPIProvider provider, WalletTonNetwork network) {
    return TonClient(
      provider: TonProvider(TonHTTPService(provider: provider)),
      network: network,
    );
  }

  static SubstrateClient builSibstrateClient(
      SubstrateAPIProvider provider, WalletPolkadotNetwork network) {
    return SubstrateClient(
        provider: SubstrateRPC(SubstrateHttpService(provider)),
        network: network);
  }

  static SolanaClient buildSoalanaProvider(
      SolanaAPIProvider provider, WalletSolanaNetwork network) {
    return SolanaClient(
        provider: SolanaRPC(SolanaHTTPService(provider.httpNodeUri, provider)),
        network: network);
  }

  static TronClient buildTronProvider(
      TronAPIProvider httpProviderService, WalletTronNetwork network) {
    final httpNode = TronProvider(
        TronHTTPService(httpProviderService.httpNodeUri, httpProviderService));
    return TronClient(
        provider: httpNode,
        solidityProvider: buildEthereumProvider(
            httpProviderService.solidityProvider, network),
        network: network);
  }

  static NetworkClient? createApiClient<T extends NetworkClient>(
      WalletNetwork network,
      {APIProvider? service}) {
    APIProvider? serviceProvider = network.getProvider(service);
    serviceProvider ??=
        ProvidersConst.getDefaultService(network, service: service);
    if (serviceProvider == null) return null;
    switch (network.type) {
      case NetworkType.bitcoinAndForked:
      case NetworkType.bitcoinCash:
        return buildBitcoinApiPorivder(serviceProvider, network.toNetwork());
      case NetworkType.cardano:
        return buildCardanoProvider(
            serviceProvider.toProvider(), network.toNetwork());
      case NetworkType.cosmos:
        return buildTendermintProvider(
            serviceProvider.toProvider(), network.toNetwork());
      case NetworkType.ethereum:
        return buildEthereumProvider(serviceProvider.toProvider(), network);
      case NetworkType.xrpl:
        return buildRippleProvider(
            serviceProvider.toProvider(), network.toNetwork());
      case NetworkType.solana:
        return buildSoalanaProvider(
            serviceProvider.toProvider(), network.toNetwork());
      case NetworkType.tron:
        return buildTronProvider(
            serviceProvider.toProvider(), network.toNetwork());
      case NetworkType.ton:
        return buildTonApiProvider(
            serviceProvider.toProvider(), network.toNetwork());
      case NetworkType.polkadot:
      case NetworkType.kusama:
        return builSibstrateClient(
            serviceProvider.toProvider(), network.toNetwork());
      default:
        throw WalletExceptionConst.incorrectNetwork;
    }
  }
}
