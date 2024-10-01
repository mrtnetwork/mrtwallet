import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/wallet/api/client/client.dart';
import 'package:mrt_wallet/wallet/api/constant/constant.dart';
import 'package:mrt_wallet/wallet/api/provider/provider.dart';
import 'package:mrt_wallet/wallet/api/services/service.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/crypto/utils/global/utils.dart';
import 'package:on_chain/on_chain.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:stellar_dart/stellar_dart.dart';
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

  static String getProviderIdentifier(String? identifier) {
    identifier ??= BlockchainUtils.generateRandomString(8);
    return identifier;
  }

  static BitcoinElectrumClient _buildBitcoinElectrumProvider(
      ElectrumAPIProvider provider, WalletBitcoinNetwork network) {
    return BitcoinElectrumClient(
        provider: ElectrumApiProvider(ElectrumService.fromProvider(
            provider: provider, service: provider)),
        network: network);
  }

  static EVMRPC _buildEthereumRPC(EthereumAPIProvider provider,
      {Duration? requestTimeout}) {
    if (provider.protocol == ServiceProtocol.websocket) {
      return EVMRPC(
          EthereumWebsocketService(provider: provider, url: provider.uri));
    }
    return EVMRPC(EthereumHTTPService(provider.uri, provider,
        requestTimeout: requestTimeout));
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
      EthereumAPIProvider provider, WalletNetwork network,
      {Duration? requestTimeout}) {
    return EthereumClient(
        provider: _buildEthereumRPC(provider, requestTimeout: requestTimeout),
        network: network);
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

  static StellarClient buildStellarClient(
      StellarAPIProvider provider, WalletStellarNetwork network) {
    return StellarClient(
        provider: HorizonProvider(StellarHTTPService(provider)),
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

  static T? createApiClient<T extends NetworkClient>(WalletNetwork network,
      {APIProvider? service,
      Duration? requestTimeut,
      bool allowInWeb3 = false}) {
    APIProvider? serviceProvider =
        network.getProvider(selectProvider: service, allowInWeb3: allowInWeb3);
    serviceProvider ??=
        ProvidersConst.getDefaultService(network, service: service);
    if (serviceProvider == null) return null;
    NetworkClient? client;
    switch (network.type) {
      case NetworkType.bitcoinAndForked:
      case NetworkType.bitcoinCash:
        client = buildBitcoinApiPorivder(serviceProvider, network.toNetwork());
        break;
      case NetworkType.cardano:
        client = buildCardanoProvider(
            serviceProvider.toProvider(), network.toNetwork());
        break;
      case NetworkType.cosmos:
        client = buildTendermintProvider(
            serviceProvider.toProvider(), network.toNetwork());
        break;
      case NetworkType.ethereum:
        client = buildEthereumProvider(serviceProvider.toProvider(), network,
            requestTimeout: requestTimeut);
        break;
      case NetworkType.xrpl:
        client = buildRippleProvider(
            serviceProvider.toProvider(), network.toNetwork());
        break;
      case NetworkType.solana:
        client = buildSoalanaProvider(
            serviceProvider.toProvider(), network.toNetwork());
        break;
      case NetworkType.stellar:
        client = buildStellarClient(
            serviceProvider.toProvider(), network.toNetwork());
        break;
      case NetworkType.tron:
        client = buildTronProvider(
            serviceProvider.toProvider(), network.toNetwork());
        break;
      case NetworkType.ton:
        client = buildTonApiProvider(
            serviceProvider.toProvider(), network.toNetwork());
        break;
      case NetworkType.polkadot:
      case NetworkType.kusama:
        client = builSibstrateClient(
            serviceProvider.toProvider(), network.toNetwork());
        break;
      default:
        throw WalletExceptionConst.incorrectNetwork;
    }

    if (client is! T) {
      return null;
    }
    return client;
  }
}
