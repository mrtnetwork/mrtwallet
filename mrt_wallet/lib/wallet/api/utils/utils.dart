import 'package:monero_dart/monero_dart.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/isolate/types.dart';
import 'package:mrt_wallet/wallet/api/client/client.dart';
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
  static BitcoinExplorerApiProvider _buildBlockCypherOrMempolProvider({
    required WalletBitcoinNetwork network,
    required BitcoinExplorerAPIProvider provider,
    APPIsolate isolate = APPIsolate.separate,
  }) {
    final btcNetwork = network.coinParam.transacationNetwork;
    final api = ApiProvider(
        api: provider.config(btcNetwork),
        service: BitcoinHTTPService(provider: provider, isolate: isolate));
    return BitcoinExplorerApiProvider(provider: api, network: network);
  }

  static String getProviderIdentifier() {
    return BlockchainUtils.generateRandomString(8);
  }

  static BitcoinElectrumClient buildBitcoinElectrumProvider({
    required ElectrumAPIProvider provider,
    required WalletBitcoinNetwork network,
    APPIsolate isolate = APPIsolate.separate,
  }) {
    return BitcoinElectrumClient(
        provider: ElectrumProvider(ElectrumService.fromProvider(provider)),
        network: network);
  }

  static EthereumProvider _buildEthereumRPC({
    required EthereumAPIProvider provider,
    APPIsolate isolate = APPIsolate.separate,
    Duration? requestTimeout,
  }) {
    if (provider.protocol == ServiceProtocol.websocket) {
      return EthereumProvider(EthereumWebsocketService(provider: provider));
    }
    return EthereumProvider(EthereumHTTPService(
        provider: provider, isolate: isolate, requestTimeout: requestTimeout));
  }

  static XRPServiceProvider _buildRippleProvider({
    required RippleAPIProvider provider,
    APPIsolate isolate = APPIsolate.separate,
  }) {
    if (provider.protocol == ServiceProtocol.websocket) {
      return RippleWebsocketService(provider: provider);
    }
    return RippleHTTPService(provider: provider, isolate: isolate);
  }

  static BitcoinClient buildBitcoinApiPorivder({
    required APIProvider provider,
    required WalletBitcoinNetwork network,
    APPIsolate isolate = APPIsolate.separate,
  }) {
    if (provider is ElectrumAPIProvider) {
      return buildBitcoinElectrumProvider(
          provider: provider, network: network, isolate: isolate);
    }
    return _buildBlockCypherOrMempolProvider(
        network: network,
        provider: provider as BitcoinExplorerAPIProvider,
        isolate: isolate);
  }

  static EthereumClient buildEthereumProvider(
      {required EthereumAPIProvider provider,
      required WalletNetwork network,
      APPIsolate isolate = APPIsolate.separate,
      Duration? requestTimeout}) {
    return EthereumClient(
        provider: _buildEthereumRPC(
            provider: provider,
            isolate: isolate,
            requestTimeout: requestTimeout),
        network: network);
  }

  static RippleClient buildRippleProvider({
    required RippleAPIProvider provider,
    required WalletXRPNetwork network,
    APPIsolate isolate = APPIsolate.separate,
  }) {
    return RippleClient(
        provider: XRPProvider(
            _buildRippleProvider(provider: provider, isolate: isolate)),
        network: network);
  }

  static CardanoClient buildCardanoProvider({
    required CardanoAPIProvider provider,
    required WalletCardanoNetwork network,
    APPIsolate isolate = APPIsolate.separate,
  }) {
    return CardanoClient(
        provider: BlockFrostProvider(
            CardanoHTTPService(provider: provider, isolate: isolate)),
        network: network);
  }

  static CosmosClient buildTendermintProvider({
    required CosmosAPIProvider provider,
    required WalletCosmosNetwork network,
    APPIsolate isolate = APPIsolate.separate,
  }) {
    return CosmosClient(
        provider: TendermintProvider(
            TendermintHTTPService(provider: provider, isolate: isolate)),
        network: network);
  }

  static TonClient buildTonApiProvider({
    required TonAPIProvider provider,
    required WalletTonNetwork network,
    APPIsolate isolate = APPIsolate.separate,
  }) {
    return TonClient(
        provider:
            TonProvider(TonHTTPService(provider: provider, isolate: isolate)),
        network: network);
  }

  static SubstrateClient buildsubstrateClient(
      {required SubstrateAPIProvider provider,
      required WalletPolkadotNetwork network,
      APPIsolate isolate = APPIsolate.separate}) {
    if (provider.protocol == ServiceProtocol.websocket) {
      return SubstrateClient(
          provider:
              SubstrateProvider(SubstrateWebsocketService(provider: provider)),
          network: network);
    }
    return SubstrateClient(
        provider: SubstrateProvider(
            SubstrateHTTPService(provider: provider, isolate: isolate)),
        network: network);
  }

  static MoneroClient buildMoneroClient(
      {required MoneroAPIProvider provider,
      required WalletMoneroNetwork? network,
      APPIsolate isolate = APPIsolate.separate}) {
    return MoneroClient(
      provider: MoneroProvider(MoneroHTTPService(provider, isolate: isolate)),
      network: network,
    );
  }

  static SolanaClient buildSoalanaProvider(
      {required SolanaAPIProvider provider,
      required WalletSolanaNetwork network,
      APPIsolate isolate = APPIsolate.separate}) {
    return SolanaClient(
        provider: SolanaProvider(
            SolanaHTTPService(provider: provider, isolate: isolate)),
        network: network);
  }

  static StellarClient buildStellarClient(
      {required StellarAPIProvider provider,
      required WalletStellarNetwork network,
      APPIsolate isolate = APPIsolate.separate}) {
    return StellarClient(
        provider: StellarProvider(
            StellarHTTPService(provider: provider, isolate: isolate)),
        network: network);
  }

  static TronClient buildTronProvider(
      {required TronAPIProvider httpProviderService,
      required WalletTronNetwork network,
      APPIsolate isolate = APPIsolate.separate}) {
    final httpNode = TronProvider(
        TronHTTPService(provider: httpProviderService, isolate: isolate));
    return TronClient(
        provider: httpNode,
        solidityProvider: buildEthereumProvider(
            provider: httpProviderService.solidityProvider,
            network: network,
            isolate: isolate),
        network: network);
  }

  static T? createApiClient<T extends NetworkClient>(WalletNetwork network,
      {String? identifier,
      Duration? requestTimeut,
      bool allowInWeb3 = false,
      APPIsolate isolate = APPIsolate.separate}) {
    List<APIProvider> providers = network.getAllProviders();
    if (allowInWeb3) {
      providers = providers.where((e) => e.allowInWeb3).toList();
    }
    APIProvider? serviceProvider;
    if (providers.isNotEmpty) {
      serviceProvider = providers.firstWhere((e) => e.identifier == identifier,
          orElse: () => providers.first);
    }
    if (serviceProvider == null) return null;
    NetworkClient? client;
    switch (network.type) {
      case NetworkType.bitcoinAndForked:
      case NetworkType.bitcoinCash:
        client = buildBitcoinApiPorivder(
            provider: serviceProvider,
            network: network.toNetwork(),
            isolate: isolate);
        break;
      case NetworkType.cardano:
        client = buildCardanoProvider(
            provider: serviceProvider.toProvider(),
            network: network.toNetwork(),
            isolate: isolate);
        break;
      case NetworkType.cosmos:
        client = buildTendermintProvider(
            provider: serviceProvider.toProvider(),
            network: network.toNetwork(),
            isolate: isolate);
        break;
      case NetworkType.ethereum:
        client = buildEthereumProvider(
            provider: serviceProvider.toProvider(),
            network: network,
            requestTimeout: requestTimeut,
            isolate: isolate);
        break;
      case NetworkType.xrpl:
        client = buildRippleProvider(
            provider: serviceProvider.toProvider(),
            network: network.toNetwork(),
            isolate: isolate);
        break;
      case NetworkType.solana:
        client = buildSoalanaProvider(
            provider: serviceProvider.toProvider(),
            network: network.toNetwork(),
            isolate: isolate);
        break;
      case NetworkType.stellar:
        client = buildStellarClient(
            provider: serviceProvider.toProvider(),
            network: network.toNetwork(),
            isolate: isolate);
        break;
      case NetworkType.tron:
        client = buildTronProvider(
            httpProviderService: serviceProvider.toProvider(),
            network: network.toNetwork(),
            isolate: isolate);
        break;
      case NetworkType.ton:
        client = buildTonApiProvider(
            provider: serviceProvider.toProvider(),
            network: network.toNetwork(),
            isolate: isolate);
        break;
      case NetworkType.monero:
        client = buildMoneroClient(
            provider: serviceProvider.toProvider(),
            network: network.toNetwork(),
            isolate: isolate);
        break;
      case NetworkType.polkadot:
      case NetworkType.kusama:
        client = buildsubstrateClient(
            provider: serviceProvider.toProvider(),
            network: network.toNetwork(),
            isolate: isolate);
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
