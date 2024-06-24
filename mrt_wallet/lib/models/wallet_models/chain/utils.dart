import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/api/api_provider_tracker.dart';
import 'package:mrt_wallet/models/app/app_image.dart';
import 'package:mrt_wallet/models/wallet_models/chain/defauilt_node_providers.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';
import 'package:on_chain/on_chain.dart';
import 'package:on_chain/solana/solana.dart';
import 'package:ton_dart/ton_dart.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

class _DefaultAppCoins {
  static final BitcoinParams bitcoinCashMainnet = BitcoinParams(
      transactionExplorer: "https://bch.loping.net/tx/#txid",
      addressExplorer: "https://bch.loping.net/address/#address",
      transacationNetwork: BitcoinCashNetwork.mainnet,
      token: Token(
        name: "BitcoinCash",
        symbol: "BCH",
        decimal: 8,
        assetLogo: const AppImage.local("assets/image/bch.png"),
      ),
      providers: []);
  static final BitcoinParams bitcoinCashChipnet = BitcoinParams(
      transactionExplorer: "https://cbch.loping.net/tx/#txid",
      addressExplorer: "https://cbch.loping.net/address/#address",
      transacationNetwork: BitcoinCashNetwork.testnet,
      token: Token(
          name: "BitcoinCash chipnet",
          symbol: "tBCH",
          decimal: 8,
          assetLogo: const AppImage.local("assets/image/bch.png")),
      providers: []);
  static final BitcoinParams bitcoinMainnet = BitcoinParams(
      transactionExplorer: "https://live.blockcypher.com/btc/tx/#txid/",
      addressExplorer: "https://live.blockcypher.com/btc/address/#address/",
      transacationNetwork: BitcoinNetwork.mainnet,
      token: Token(
          name: "Bitcoin",
          symbol: "BTC",
          decimal: 8,
          assetLogo: const AppImage.local("assets/image/btc.png")),
      providers: []);
  static final BitcoinParams bitcoinTestnet = BitcoinParams(
      transactionExplorer: "https://live.blockcypher.com/btc-testnet/tx/#txid/",
      addressExplorer:
          "https://live.blockcypher.com/btc-testnet/address/#address/",
      transacationNetwork: BitcoinNetwork.testnet,
      token: Token(
          name: "Bitcoin testnet",
          symbol: "tBTC",
          decimal: 8,
          assetLogo: const AppImage.local("assets/image/btc.png")),
      providers: []);
  static final BitcoinParams litecoinMainnet = BitcoinParams(
      transactionExplorer: "https://live.blockcypher.com/ltc/tx/#txid/",
      addressExplorer: "https://live.blockcypher.com/ltc/address/#address/",
      transacationNetwork: LitecoinNetwork.mainnet,
      token: Token(
          name: "Litecoin",
          symbol: "LTC",
          decimal: 8,
          assetLogo: const AppImage.local("assets/image/ltc.png")),
      providers: []);
  static final BitcoinParams litecoinTestnet = BitcoinParams(
      transactionExplorer: "https://live.blockcypher.com/ltc/tx/#txid/",
      addressExplorer: "https://live.blockcypher.com/ltc/address/#address/",
      transacationNetwork: LitecoinNetwork.testnet,
      token: Token(
          name: "Litecoin testnet",
          symbol: "tLTC",
          decimal: 8,
          assetLogo: const AppImage.local("assets/image/ltc.png")),
      providers: []);
  static final BitcoinParams dogecoinMainnet = BitcoinParams(
      transactionExplorer: "https://live.blockcypher.com/doge/tx/#txid/",
      addressExplorer: "https://live.blockcypher.com/doge/address/#address/",
      transacationNetwork: DogecoinNetwork.mainnet,
      token: Token(
          name: "Dogecoin",
          symbol: "Ɖ",
          decimal: 8,
          assetLogo: const AppImage.local("assets/image/doge.png")),
      providers: []);
  static final BitcoinParams pepecoinMainnet = BitcoinParams(
      transactionExplorer: "https://pepeexplorer.com/tx/#txid",
      addressExplorer: "https://pepeexplorer.com/address/#address",
      transacationNetwork: PepeNetwork.mainnet,
      token: Token(
          name: "Pepecoin",
          symbol: "₱",
          decimal: 8,
          assetLogo: const AppImage.local("assets/image/pepecoin.png")),
      providers: []);
  static final BitcoinParams dogeTestnet = BitcoinParams(
      transactionExplorer: "https://live.blockcypher.com/doge/tx/#txid/",
      addressExplorer: "https://live.blockcypher.com/doge/address/#address/",
      transacationNetwork: DogecoinNetwork.testnet,
      token: Token(
          name: "Dogecoin testnet",
          symbol: "tƉ",
          decimal: 8,
          assetLogo: const AppImage.local("assets/image/doge.png")),
      providers: []);
  static final BitcoinParams bsvMainnet = BitcoinParams(
      transactionExplorer: "https://whatsonchain.com/tx/#txid",
      addressExplorer: "https://whatsonchain.com/address/#address",
      transacationNetwork: BitcoinSVNetwork.mainnet,
      token: Token(
          name: "BitcoinSV",
          symbol: "BSV",
          decimal: 8,
          assetLogo: const AppImage.local("assets/image/bsv.png")),
      providers: []);
  static final BitcoinParams dashMainnet = BitcoinParams(
      transactionExplorer: "https://live.blockcypher.com/dash/tx/#txid/",
      addressExplorer: "https://live.blockcypher.com/dash/address/#address/",
      token: Token(
          name: "Dash",
          symbol: "DASH",
          decimal: 8,
          assetLogo: const AppImage.local("assets/image/dash.png")),
      transacationNetwork: DashNetwork.mainnet,
      providers: []);
  static final RippleNetworkParams xrpMainnet = RippleNetworkParams(
      transactionExplorer: "https://livenet.xrpl.org/transactions/#txid",
      addressExplorer: "https://livenet.xrpl.org/accounts/#address",
      token: Token(
          name: "Ripple",
          symbol: "XRP",
          decimal: 6,
          assetLogo: const AppImage.local("assets/image/xrp.png")),
      providers: [],
      mainnet: true);
  static final RippleNetworkParams xrpTestnet = RippleNetworkParams(
      transactionExplorer: "https://testnet.xrpl.org/transactions/#txid",
      addressExplorer: "https://testnet.xrpl.org/accounts/#address",
      token: Token(
          name: "Ripple testnet",
          symbol: "tXRP",
          decimal: 6,
          assetLogo: const AppImage.local("assets/image/xrp.png")),
      providers: [],
      mainnet: false);
  static final RippleNetworkParams xrpDevnet = RippleNetworkParams(
      transactionExplorer: "https://devnet.xrpl.org/transactions/#txid",
      addressExplorer: "https://devnet.xrpl.org/accounts/#address",
      token: Token(
          name: "Ripple devnet",
          symbol: "tXRP",
          decimal: 6,
          assetLogo: const AppImage.local("assets/image/xrp.png")),
      providers: [],
      mainnet: false);

  static final EVMNetworkParams ethreumMainnet = EVMNetworkParams(
      transactionExplorer: "https://etherscan.io/tx/#txid",
      addressExplorer: "https://etherscan.io/address/#address",
      chainId: BigInt.one,
      mainnet: true,
      supportEIP1559: true,
      token: Token(
          name: "Ethereum",
          symbol: "ETH",
          decimal: 18,
          assetLogo: const AppImage.local("assets/image/eth.png")),
      providers: []);
  static final EVMNetworkParams ethreumTestnet = EVMNetworkParams(
      transactionExplorer: "https://sepolia.etherscan.io/tx/#txid",
      addressExplorer: "https://sepolia.etherscan.io/address/#address",
      chainId: BigInt.from(11155111),
      mainnet: false,
      supportEIP1559: true,
      token: Token(
          name: "Ethereum Sepolia testnet",
          symbol: "tETH",
          decimal: 18,
          assetLogo: const AppImage.local("assets/image/eth.png")),
      providers: []);
  static final EVMNetworkParams polygon = EVMNetworkParams(
      transactionExplorer: "https://polygonscan.com/tx/#txid",
      addressExplorer: "https://polygonscan.com/address/#address",
      chainId: BigInt.from(137),
      supportEIP1559: true,
      mainnet: true,
      token: Token(
          name: "Polygon",
          symbol: "MATIC",
          decimal: 18,
          assetLogo: const AppImage.local("assets/image/matic.png")),
      providers: []);
  static final EVMNetworkParams polygonTestnet = EVMNetworkParams(
      transactionExplorer: "https://mumbai.polygonscan.com/tx/#txid",
      addressExplorer: "https://mumbai.polygonscan.com/address/#address",
      chainId: BigInt.from(80001),
      supportEIP1559: true,
      mainnet: false,
      token: Token(
          name: "Polygon mumbai testnet",
          symbol: "tMATIC",
          decimal: 18,
          assetLogo: const AppImage.local("assets/image/matic.png")),
      providers: []);
  static final EVMNetworkParams bnb = EVMNetworkParams(
      transactionExplorer: "https://bscscan.com/tx/#txid",
      addressExplorer: "https://bscscan.com/address/#address",
      chainId: BigInt.from(56),
      supportEIP1559: false,
      mainnet: true,
      token: Token(
          name: "BNB Smart Chain",
          symbol: "BNB",
          decimal: 18,
          assetLogo: const AppImage.local("assets/image/bnb.png")),
      providers: []);
  static final EVMNetworkParams bnbTestnet = EVMNetworkParams(
      transactionExplorer: "https://testnet.bscscan.com/tx/#txid",
      addressExplorer: "https://testnet.bscscan.com/address/#address",
      chainId: BigInt.from(97),
      mainnet: false,
      supportEIP1559: false,
      token: Token(
          name: "BNB Smart chain testnet",
          symbol: "tBNB",
          decimal: 18,
          assetLogo: const AppImage.local("assets/image/bnb.png")),
      providers: []);

  /// tron networks
  static final TVMNetworkParams tronShasta = TVMNetworkParams(
      transactionExplorer: "https://shasta.tronscan.org/#/transaction/#txid",
      addressExplorer: "https://shasta.tronscan.org/#/address/#address",
      mainnet: false,
      token: Token(
          name: "Tron shasta testnet",
          symbol: "tTRX",
          decimal: 6,
          assetLogo: const AppImage.local("assets/image/trx.png")),
      providers: [],
      ethereumProviders: []);
  static final TVMNetworkParams tronNile = TVMNetworkParams(
      transactionExplorer: "https://nile.tronscan.org/#/transaction/#txid",
      addressExplorer: "https://nile.tronscan.org/#/address/#address",
      mainnet: false,
      token: Token(
          name: "Tron nile testnet",
          symbol: "tTRX",
          decimal: 6,
          assetLogo: const AppImage.local("assets/image/trx.png")),
      ethereumProviders: [],
      providers: []);
  static final TVMNetworkParams tron = TVMNetworkParams(
      transactionExplorer: "https://tronscan.org/#/transaction/#txid",
      addressExplorer: "https://tronscan.org/#/address/#address",
      mainnet: true,
      token: Token(
          name: "Tron",
          symbol: "TRX",
          decimal: 6,
          assetLogo: const AppImage.local("assets/image/trx.png")),
      ethereumProviders: [],
      providers: []);

  static final SolanaNetworkParams solana = SolanaNetworkParams(
      transactionExplorer: "https://explorer.solana.com/tx/#txid",
      addressExplorer: "https://explorer.solana.com/address/#address",
      mainnet: true,
      token: Token(
          name: "Solana",
          symbol: "SOL",
          decimal: 9,
          assetLogo: const AppImage.local("assets/image/sol.png")),
      providers: []);
  static final SolanaNetworkParams solanaTestnet = SolanaNetworkParams(
      transactionExplorer:
          "https://explorer.solana.com/tx/#txid?cluster=testnet",
      addressExplorer:
          "https://explorer.solana.com/address/#address?cluster=testnet",
      mainnet: false,
      token: Token(
          name: "Solana testnet",
          symbol: "tSOL",
          decimal: 9,
          assetLogo: const AppImage.local("assets/image/sol.png")),
      providers: []);

  static final CardanoNetworkParams cardanoTestnet = CardanoNetworkParams(
      transactionExplorer:
          "https://preprod.beta.explorer.cardano.org/en/transaction/#txid",
      addressExplorer:
          "https://preprod.beta.explorer.cardano.org/en/address/#address",
      mainnet: false,
      token: Token(
          name: "Cardano preprod",
          symbol: "tADA",
          decimal: 6,
          assetLogo: const AppImage.local("assets/image/ada.png")),
      providers: []);
  static final CardanoNetworkParams cardano = CardanoNetworkParams(
      transactionExplorer:
          "https://beta.explorer.cardano.org/en/transaction/#txid",
      addressExplorer: "https://beta.explorer.cardano.org/en/address/#address",
      mainnet: true,
      token: Token(
          name: "Cardano",
          symbol: "ADA",
          decimal: 6,
          assetLogo: const AppImage.local("assets/image/ada.png")),
      providers: []);
  static final CosmosNetworkParams cosmosTestnet = CosmosNetworkParams(
      transactionExplorer:
          "https://explorer.polypore.xyz/theta-testnet-001/tx/#txid",
      addressExplorer:
          "https://explorer.polypore.xyz/theta-testnet-001/account/#address",
      networkType: CosmosNetworkTypes.main,
      mainnet: false,
      hrp: CosmosAddrConst.accHRP,
      mainCoin: const CosmosNativeCoin(decimal: 6, denom: 'uatom'),
      coins: [const CosmosNativeCoin(decimal: 6, denom: 'uatom')],
      token: Token(
          name: "Cosmos hub testnet",
          symbol: "tATOM",
          decimal: 6,
          assetLogo: const AppImage.local("assets/image/atom.png")),
      providers: []);
  static final CosmosNetworkParams cosmos = CosmosNetworkParams(
      transactionExplorer: "https://ping.pub/cosmos/tx/#txid",
      addressExplorer: "https://ping.pub/cosmos/account/#address",
      networkType: CosmosNetworkTypes.main,
      mainnet: true,
      hrp: CosmosAddrConst.accHRP,
      mainCoin: const CosmosNativeCoin(decimal: 6, denom: 'uatom'),
      coins: [const CosmosNativeCoin(decimal: 6, denom: 'uatom')],
      token: Token(
          name: "Cosmos hub",
          symbol: "ATOM",
          decimal: 6,
          assetLogo: const AppImage.local("assets/image/atom.png")),
      providers: []);
  static final CosmosNetworkParams maya = CosmosNetworkParams(
      transactionExplorer: "https://www.mayascan.org/tx/#txid",
      addressExplorer: "https://www.mayascan.org/address/#address",
      mainnet: true,
      hrp: CosmosAddrConst.mayaProtocol,
      mainCoin: const CosmosNativeCoin(decimal: 10, denom: 'cacao'),
      coins: [const CosmosNativeCoin(decimal: 10, denom: 'cacao')],
      networkType: CosmosNetworkTypes.thorAndForked,
      token: Token(
          name: "Maya Protocol",
          symbol: "Cacao",
          decimal: 10,
          assetLogo: const AppImage.local("assets/image/cacao.png")),
      providers: []);
  static final CosmosNetworkParams thorchain = CosmosNetworkParams(
      transactionExplorer: "https://www.thorscanner.org/tx/#txid",
      addressExplorer: "https://www.thorscanner.org/address/#address",
      mainnet: true,
      hrp: CosmosAddrConst.thor,
      mainCoin: const CosmosNativeCoin(decimal: 8, denom: 'rune'),
      coins: [const CosmosNativeCoin(decimal: 8, denom: 'rune')],
      networkType: CosmosNetworkTypes.thorAndForked,
      token: Token(
          name: "THORChain",
          symbol: "Rune",
          decimal: 8,
          assetLogo: const AppImage.local("assets/image/thor.png")),
      providers: []);
  static final CosmosNetworkParams kujiraTestnet = CosmosNetworkParams(
      transactionExplorer: "https://finder.kujira.network/harpoon-4/tx/#txid",
      addressExplorer:
          "https://finder.kujira.network/harpoon-4/address/#address",
      mainnet: false,
      hrp: CosmosAddrConst.kujira,
      mainCoin: const CosmosNativeCoin(decimal: 6, denom: 'ukuji'),
      coins: [const CosmosNativeCoin(decimal: 6, denom: 'ukuji')],
      networkType: CosmosNetworkTypes.forked,
      token: Token(
          name: "Kujira Testnet",
          symbol: "tKuji",
          decimal: 6,
          assetLogo: const AppImage.local("assets/image/kujira.png")),
      providers: []);
  static final CosmosNetworkParams kujira = CosmosNetworkParams(
      transactionExplorer: "https://finder.kujira.network/kaiyo-1/tx/#txid",
      addressExplorer: "https://finder.kujira.network/kaiyo-1/address/#address",
      mainnet: true,
      hrp: CosmosAddrConst.kujira,
      mainCoin: const CosmosNativeCoin(decimal: 6, denom: 'ukuji'),
      coins: [const CosmosNativeCoin(decimal: 6, denom: 'ukuji')],
      networkType: CosmosNetworkTypes.forked,
      token: Token(
          name: "Kujira",
          symbol: "Kuji",
          decimal: 6,
          assetLogo: const AppImage.local("assets/image/kujira.png")),
      providers: []);

  static final CosmosNetworkParams osmosTestnet = CosmosNetworkParams(
      transactionExplorer:
          "https://celatone.osmosis.zone/osmo-test-5/txs/#txid",
      addressExplorer:
          "https://celatone.osmosis.zone/osmo-test-5/accounts/#address",
      networkType: CosmosNetworkTypes.main,
      mainnet: false,
      hrp: CosmosConstants.osmoHrp,
      mainCoin: const CosmosNativeCoin(decimal: 6, denom: 'uosmo'),
      coins: [const CosmosNativeCoin(decimal: 6, denom: 'uosmo')],
      token: Token(
          name: "Osmo testnet",
          symbol: "tOsmo",
          decimal: 6,
          assetLogo: const AppImage.local("assets/image/osmo.png")),
      providers: []);
  static final TonNetworkParams tonTestnet = TonNetworkParams(
      transactionExplorer: "https://testnet.tonscan.org/tx/#txid",
      addressExplorer: "https://testnet.tonscan.org/address/#address",
      mainnet: false,
      workchain: -1,
      token: Token(
          name: "TonCoin testnet",
          symbol: "tTon",
          decimal: 9,
          assetLogo: const AppImage.local("assets/image/ton.png")),
      providers: []);

  static final TonNetworkParams tonMainnet = TonNetworkParams(
      transactionExplorer: "https://tonscan.org/tx/#txid",
      addressExplorer: "https://tonscan.org/address/#address",
      mainnet: true,
      workchain: 0,
      token: Token(
          name: "TonCoin",
          symbol: "Ton",
          decimal: 9,
          assetLogo: const AppImage.local("assets/image/ton.png")),
      providers: []);
}

class ChainUtils {
  static BitcoinExplorerApiProvider _buildBlockCypherOrMempolProvider(
      AppBitcoinNetwork network, ApiProviderService provider) {
    final btcNetwork = network.coinParam.transacationNetwork;
    final serviceProvider = ApiProviderTracker(provider: provider);
    final api = provider == ApiProviderService.mempool
        ? ApiProvider.fromMempool(
            btcNetwork, BitcoinApiService(serviceProvider))
        : ApiProvider.fromBlocCypher(
            btcNetwork, BitcoinApiService(serviceProvider));
    return BitcoinExplorerApiProvider(provider: api, network: network);
  }

  static BitcoinElectrumApiProvider _buildBitcoinElectrumProvider(
      ElectrumApiProviderService provider, AppNetworkImpl network) {
    final serviceTracker = ApiProviderTracker(provider: provider);
    return BitcoinElectrumApiProvider(
        provider: ElectrumApiProvider(ElectrumService.fromProvider(
            provider: serviceTracker, service: provider)),
        network: network);
  }

  static BasedBitcoinApiProvider buildBitcoinApiPorivder(
      AppBitcoinNetwork network, ApiProviderService provider) {
    if (provider is ElectrumApiProviderService) {
      return _buildBitcoinElectrumProvider(provider, network);
    }
    return _buildBlockCypherOrMempolProvider(network, provider);
  }

  static EVMRPC _buildEVMRPC(
      ApiProviderTracker<EVMApiProviderService> provider) {
    if (provider.provider.protocol == ProviderProtocol.websocket) {
      return EVMRPC(EthereumWebsocketCService(
          provider: provider, url: provider.provider.uri));
    }
    return EVMRPC(EthereumHTTPRPCService(provider.provider.uri, provider));
  }

  static EVMApiProvider buildEVMProvider(
      EVMApiProviderService provider, AppNetworkImpl network) {
    final tracker = ApiProviderTracker(provider: provider);
    return EVMApiProvider(provider: _buildEVMRPC(tracker), network: network);
  }

  static CardanoApiProvider buildCardanoProvider(
      CardanoAPIProviderService provider, APPCardanoNetwork network) {
    final tracker = ApiProviderTracker(provider: provider);
    return CardanoApiProvider(
        provider: BlockforestProvider(CardaboHttpProvider(provider: tracker)),
        network: network);
  }

  static CosmosApiProvider buildTendermintProvider(
      CosmosAPIProviderService provider, APPCosmosNetwork network) {
    final tracker = ApiProviderTracker(provider: provider);
    return CosmosApiProvider(
        provider: TendermintProvider(
            TendermintHTTPProvider(provider: tracker, url: provider.uri)),
        network: network,
        nodeProvider: provider.nodeUri == null
            ? null
            : ThorNodeProvider(ThorNodeHTTPProvider(
                provider: tracker, url: provider.nodeUri!)));
  }

  static TonApiProvider buildTonApiProvider(
      TonAPIProviderService provider, APPTonNetwork network) {
    final tracker = ApiProviderTracker(provider: provider);
    return TonApiProvider(
      provider: TonProvider(TonHTTPProvider(provider: tracker)),
      network: network,
    );
  }

  static SolanaApiProvider buildSoalanaProvider(
      SolanaApiProviderService provider, APPSolanaNetwork network) {
    final tracker = ApiProviderTracker(provider: provider);
    return SolanaApiProvider(
        provider: SolanaRPC(RPCHttpService(provider.httpNodeUri, tracker)),
        network: network);
  }

  static TVMApiProvider buildTVMProvider(
      APPTVMNetwork network, TronApiProviderService httpProviderService) {
    EVMApiProviderService solidityProviderService =
        DefaultNodeProviders.getEVMService(network)!;
    final httpNodeTracker = ApiProviderTracker(provider: httpProviderService);
    final httpNode = TronProvider(
        TronHTTPService(httpProviderService.httpNodeUri, httpNodeTracker));

    final solidityApiProvider =
        buildEVMProvider(solidityProviderService, network);
    return TVMApiProvider(
        provider: httpNode,
        solidityProvider: solidityApiProvider,
        network: network);
  }

  static RpcService _xrpHttpService(
      AppXRPNetwork network, ApiProviderTracker tracker) {
    RpcService service;
    switch (network.value) {
      case 30:
        service = RippleHTTPRPCService(RPCConst.mainetUri, tracker);
        break;
      case 31:
        service = RippleHTTPRPCService(RPCConst.testnetUri, tracker);
        break;
      default:
        service = RippleHTTPRPCService(RPCConst.devnetUri, tracker);
        break;
    }
    return service;
  }

  static RpcService _xrpWebsocketService(
      AppXRPNetwork network, ApiProviderTracker tracker) {
    RpcService service;
    switch (network.value) {
      case 30:
        service = RippleWebsocketCService(
            url: RPCConst.mainetWebsocketUri, provider: tracker);
        break;
      case 31:
        service = RippleWebsocketCService(
            url: RPCConst.testnetWebsocketUri, provider: tracker);
        break;
      default:
        service = RippleWebsocketCService(
            url: RPCConst.devnetWebsocketUri, provider: tracker);
        break;
    }
    return service;
  }

  static RippleApiProvider buildRippleProvider(
      AppXRPNetwork network, ApiProviderService provider) {
    final tracker = ApiProviderTracker(provider: provider);
    final service = provider.protocol == ProviderProtocol.http
        ? _xrpHttpService(network, tracker)
        : _xrpWebsocketService(network, tracker);
    return RippleApiProvider(provider: XRPLRpc(service), network: network);
  }

  static T? buildApiProvider<T extends NetworkApiProvider>(
      AppNetworkImpl network,
      {ApiProviderService? service}) {
    ApiProviderService? serviceProvider = network.getProvider(service);
    serviceProvider ??=
        DefaultNodeProviders.getDefaultService(network, service: service);
    if (serviceProvider == null) return null;
    return serviceProvider.toProvider(network) as T;
  }

  static final Map<int, AppNetworkImpl> defaultCoins = Map.unmodifiable({
    0: AppBitcoinNetwork(0, _DefaultAppCoins.bitcoinMainnet),
    1: AppBitcoinNetwork(1, _DefaultAppCoins.bitcoinTestnet),
    2: AppBitcoinNetwork(2, _DefaultAppCoins.litecoinMainnet),
    7: AppBitcoinNetwork(7, _DefaultAppCoins.litecoinTestnet),
    3: AppBitcoinNetwork(3, _DefaultAppCoins.dogecoinMainnet),
    8: AppBitcoinNetwork(8, _DefaultAppCoins.dogeTestnet),
    9: AppBitcoinNetwork(9, _DefaultAppCoins.bsvMainnet),
    4: AppBitcoinNetwork(4, _DefaultAppCoins.dashMainnet),
    10: AppBitcoinCashNetwork(10, _DefaultAppCoins.bitcoinCashMainnet),
    11: AppBitcoinCashNetwork(11, _DefaultAppCoins.bitcoinCashChipnet),
    12: AppBitcoinNetwork(12, _DefaultAppCoins.pepecoinMainnet),
    30: AppXRPNetwork(30, _DefaultAppCoins.xrpMainnet),
    31: AppXRPNetwork(31, _DefaultAppCoins.xrpTestnet),
    32: AppXRPNetwork(32, _DefaultAppCoins.xrpDevnet),
    33: APPSolanaNetwork(33, _DefaultAppCoins.solana),
    34: APPSolanaNetwork(34, _DefaultAppCoins.solanaTestnet),
    50: APPCardanoNetwork(50, _DefaultAppCoins.cardano),
    51: APPCardanoNetwork(51, _DefaultAppCoins.cardanoTestnet),
    100: APPEVMNetwork(100, _DefaultAppCoins.ethreumMainnet),
    101: APPEVMNetwork(101, _DefaultAppCoins.ethreumTestnet),
    102: APPEVMNetwork(102, _DefaultAppCoins.polygon),
    103: APPEVMNetwork(103, _DefaultAppCoins.polygonTestnet),
    104: APPEVMNetwork(104, _DefaultAppCoins.bnb),
    105: APPEVMNetwork(105, _DefaultAppCoins.bnbTestnet),
    200: APPCosmosNetwork(200, _DefaultAppCoins.cosmos),
    201: APPCosmosNetwork(201, _DefaultAppCoins.cosmosTestnet),
    202: APPCosmosNetwork(202, _DefaultAppCoins.maya),
    203: APPCosmosNetwork(203, _DefaultAppCoins.thorchain),
    204: APPCosmosNetwork(204, _DefaultAppCoins.kujiraTestnet),
    205: APPCosmosNetwork(205, _DefaultAppCoins.kujira),
    206: APPCosmosNetwork(206, _DefaultAppCoins.osmosTestnet),
    300: APPTonNetwork(300, _DefaultAppCoins.tonMainnet),
    301: APPTonNetwork(301, _DefaultAppCoins.tonTestnet),
    1001: APPTVMNetwork(1001, _DefaultAppCoins.tron),
    1002: APPTVMNetwork(1002, _DefaultAppCoins.tronShasta),
    1003: APPTVMNetwork(1003, _DefaultAppCoins.tronNile),
  });
  static Bip32NetworkAccount toNetworkAccount(
      AppNetworkImpl network, CborTagValue account) {
    switch (network.type) {
      case NetworkType.ethereum:
        return Bip32NetworkAccount<BigInt, ETHAddress>.fromCborBytesOrObject(
            network,
            obj: account);
      case NetworkType.tron:
        return Bip32NetworkAccount<BigInt, TronAddress>.fromCborBytesOrObject(
            network,
            obj: account);
      case NetworkType.xrpl:
        return Bip32NetworkAccount<BigRational,
            XRPAddress>.fromCborBytesOrObject(network, obj: account);
      case NetworkType.solana:
        return Bip32NetworkAccount<BigInt, SolAddress>.fromCborBytesOrObject(
            network,
            obj: account);
      case NetworkType.cardano:
        return Bip32NetworkAccount<BigInt, ADAAddress>.fromCborBytesOrObject(
            network,
            obj: account);
      case NetworkType.cosmos:
        return Bip32NetworkAccount<BigInt,
            CosmosBaseAddress>.fromCborBytesOrObject(network, obj: account);
      case NetworkType.ton:
        return Bip32NetworkAccount<BigInt, TonAddress>.fromCborBytesOrObject(
            network,
            obj: account);
      default:
        return Bip32NetworkAccount<BigInt,
            BitcoinBaseAddress>.fromCborBytesOrObject(network, obj: account);
    }
  }

  static Bip32NetworkAccount createNetworkAccount(AppNetworkImpl network) {
    switch (network.runtimeType) {
      case APPEVMNetwork:
        return Bip32NetworkAccount<BigInt, ETHAddress>.setup(network);
      case APPTVMNetwork:
        return Bip32NetworkAccount<BigInt, TronAddress>.setup(network);
      case AppXRPNetwork:
        return Bip32NetworkAccount<BigRational, XRPAddress>.setup(network);
      case APPSolanaNetwork:
        return Bip32NetworkAccount<BigInt, SolAddress>.setup(network);
      case APPCardanoNetwork:
        return Bip32NetworkAccount<BigInt, ADAAddress>.setup(network);
      case APPCosmosNetwork:
        return Bip32NetworkAccount<BigInt, CosmosBaseAddress>.setup(network);
      case APPTonNetwork:
        return Bip32NetworkAccount<BigInt, TonAddress>.setup(network);
      default:
        return Bip32NetworkAccount<BigInt, BitcoinBaseAddress>.setup(network);
    }
  }

  static Bip32NetworkAccount account(
      AppNetworkImpl network, CborTagValue? account) {
    try {
      return toNetworkAccount(network, account!);
    } catch (e) {
      return createNetworkAccount(network);
    }
  }
}
