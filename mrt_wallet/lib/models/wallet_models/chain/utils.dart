import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/models/api/api_provider_tracker.dart';
import 'package:mrt_wallet/models/wallet_models/account/bip32_network_account.dart';
import 'package:mrt_wallet/models/wallet_models/chain/defauilt_node_providers.dart';
import 'package:mrt_wallet/models/wallet_models/network/core/network.dart';
import 'package:mrt_wallet/models/wallet_models/network/params/params.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';
import 'package:mrt_wallet/provider/api/http_services/ethereum_websocket_service.dart';
import 'package:mrt_wallet/provider/api/http_services/ripple_websocet_service.dart';
import 'package:on_chain/ethereum/ethereum.dart';
import 'package:on_chain/tron/tron.dart';
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
        assetLogo: "assets/image/bch.png",
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
          assetLogo: "assets/image/bch.png"),
      providers: []);
  static final BitcoinParams bitcoinMainnet = BitcoinParams(
      transactionExplorer: "https://live.blockcypher.com/btc/tx/#txid/",
      addressExplorer: "https://live.blockcypher.com/btc/address/#address/",
      transacationNetwork: BitcoinNetwork.mainnet,
      token: Token(
          name: "Bitcoin",
          symbol: "BTC",
          decimal: 8,
          assetLogo: "assets/image/btc.png"),
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
          assetLogo: "assets/image/btc.png"),
      providers: []);
  static final BitcoinParams litecoinMainnet = BitcoinParams(
      transactionExplorer: "https://live.blockcypher.com/ltc/tx/#txid/",
      addressExplorer: "https://live.blockcypher.com/ltc/address/#address/",
      transacationNetwork: LitecoinNetwork.mainnet,
      token: Token(
          name: "Litecoin",
          symbol: "LTC",
          decimal: 8,
          assetLogo: "assets/image/ltc.png"),
      providers: []);
  static final BitcoinParams litecoinTestnet = BitcoinParams(
      transactionExplorer: "https://live.blockcypher.com/ltc/tx/#txid/",
      addressExplorer: "https://live.blockcypher.com/ltc/address/#address/",
      transacationNetwork: LitecoinNetwork.testnet,
      token: Token(
          name: "Litecoin testnet",
          symbol: "tLTC",
          decimal: 8,
          assetLogo: "assets/image/ltc.png"),
      providers: []);
  static final BitcoinParams dogecoinMainnet = BitcoinParams(
      transactionExplorer: "https://live.blockcypher.com/doge/tx/#txid/",
      addressExplorer: "https://live.blockcypher.com/doge/address/#address/",
      transacationNetwork: DogecoinNetwork.mainnet,
      token: Token(
          name: "Dogecoin",
          symbol: "Ɖ",
          decimal: 8,
          assetLogo: "assets/image/doge.png"),
      providers: []);
  static final BitcoinParams dogeTestnet = BitcoinParams(
      transactionExplorer: "https://live.blockcypher.com/doge/tx/#txid/",
      addressExplorer: "https://live.blockcypher.com/doge/address/#address/",
      transacationNetwork: DogecoinNetwork.testnet,
      token: Token(
          name: "Dogecoin testnet",
          symbol: "tƉ",
          decimal: 8,
          assetLogo: "assets/image/doge.png"),
      providers: []);
  static final BitcoinParams bsvMainnet = BitcoinParams(
      transactionExplorer: "https://whatsonchain.com/tx/#txid",
      addressExplorer: "https://whatsonchain.com/address/#address",
      transacationNetwork: BitcoinSVNetwork.mainnet,
      token: Token(
          name: "BitcoinSV",
          symbol: "BSV",
          decimal: 8,
          assetLogo: "assets/image/bsv.png"),
      providers: []);
  static final BitcoinParams dashMainnet = BitcoinParams(
      transactionExplorer: "https://live.blockcypher.com/dash/tx/#txid/",
      addressExplorer: "https://live.blockcypher.com/dash/address/#address/",
      token: Token(
          name: "Dash",
          symbol: "DASH",
          decimal: 8,
          assetLogo: "assets/image/dash.png"),
      transacationNetwork: DashNetwork.mainnet,
      providers: []);
  static final RippleNetworkParams xrpMainnet = RippleNetworkParams(
      transactionExplorer: "https://livenet.xrpl.org/transactions/#txid",
      addressExplorer: "https://livenet.xrpl.org/accounts/#address",
      token: Token(
          name: "Ripple",
          symbol: "XRP",
          decimal: 6,
          assetLogo: "assets/image/xrp.png"),
      providers: []);
  static final RippleNetworkParams xrpTestnet = RippleNetworkParams(
      transactionExplorer: "https://testnet.xrpl.org/transactions/#txid",
      addressExplorer: "https://testnet.xrpl.org/accounts/#address",
      token: Token(
          name: "Ripple testnet",
          symbol: "tXRP",
          decimal: 6,
          assetLogo: "assets/image/xrp.png"),
      providers: []);
  static final RippleNetworkParams xrpDevnet = RippleNetworkParams(
      transactionExplorer: "https://devnet.xrpl.org/transactions/#txid",
      addressExplorer: "https://devnet.xrpl.org/accounts/#address",
      token: Token(
          name: "Ripple devnet",
          symbol: "tXRP",
          decimal: 6,
          assetLogo: "assets/image/xrp.png"),
      providers: []);

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
          assetLogo: "assets/image/eth.png"),
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
          assetLogo: "assets/image/eth.png"),
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
          assetLogo: "assets/image/matic.png"),
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
          assetLogo: "assets/image/matic.png"),
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
          assetLogo: "assets/image/bnb.png"),
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
          assetLogo: "assets/image/bnb.png"),
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
          assetLogo: "assets/image/trx.png"),
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
          assetLogo: "assets/image/trx.png"),
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
          assetLogo: "assets/image/trx.png"),
      ethereumProviders: [],
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
    return BitcoinExplorerApiProvider(provider: api);
  }

  static BitcoinElectrumApiProvider _buildBitcoinElectrumProvider(
      ElectrumApiProviderService provider) {
    final serviceTracker = ApiProviderTracker(provider: provider);
    return BitcoinElectrumApiProvider(
        provider: ElectrumApiProvider(ElectrumService.fromProvider(
            provider: serviceTracker, service: provider)));
  }

  static BasedBitcoinApiProvider buildBitcoinApiPorivder(
      AppBitcoinNetwork network, ApiProviderService provider) {
    if (provider is ElectrumApiProviderService) {
      return _buildBitcoinElectrumProvider(provider);
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

  static EVMApiProvider buildEVMProvider(EVMApiProviderService provider) {
    final tracker = ApiProviderTracker(provider: provider);
    return EVMApiProvider(provider: _buildEVMRPC(tracker));
  }

  static TVMApiProvider buildTVMProvider(
      APPTVMNetwork network, TronApiProviderService httpProviderService) {
    EVMApiProviderService solidityProviderService =
        DefaultNodeProviders.getEVMService(network)!;
    final httpNodeTracker = ApiProviderTracker(provider: httpProviderService);
    final httpNode = TronProvider(
        TronHTTPService(httpProviderService.httpNodeUri, httpNodeTracker));

    final solidityApiProvider = buildEVMProvider(solidityProviderService);
    return TVMApiProvider(
        provider: httpNode, solidityProvider: solidityApiProvider);
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
    return RippleApiProvider(provider: XRPLRpc(service));
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
    30: AppXRPNetwork(30, _DefaultAppCoins.xrpMainnet),
    31: AppXRPNetwork(31, _DefaultAppCoins.xrpTestnet),
    32: AppXRPNetwork(32, _DefaultAppCoins.xrpDevnet),
    100: APPEVMNetwork(100, _DefaultAppCoins.ethreumMainnet),
    101: APPEVMNetwork(101, _DefaultAppCoins.ethreumTestnet),
    102: APPEVMNetwork(102, _DefaultAppCoins.polygon),
    103: APPEVMNetwork(103, _DefaultAppCoins.polygonTestnet),
    104: APPEVMNetwork(104, _DefaultAppCoins.bnb),
    105: APPEVMNetwork(105, _DefaultAppCoins.bnbTestnet),
    1001: APPTVMNetwork(1001, _DefaultAppCoins.tron),
    1002: APPTVMNetwork(1002, _DefaultAppCoins.tronShasta),
    1003: APPTVMNetwork(1003, _DefaultAppCoins.tronNile),
  });
  static Bip32NetworkAccount toNetworkAccount(
      AppNetworkImpl network, CborTagValue account) {
    switch (network.runtimeType) {
      case APPEVMNetwork:
        return Bip32NetworkAccount<BigInt, ETHAddress>.fromCborBytesOrObject(
            network,
            obj: account);
      case APPTVMNetwork:
        return Bip32NetworkAccount<BigInt, TronAddress>.fromCborBytesOrObject(
            network,
            obj: account);
      case AppXRPNetwork:
        return Bip32NetworkAccount<BigRational,
            XRPAddress>.fromCborBytesOrObject(network, obj: account);
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
