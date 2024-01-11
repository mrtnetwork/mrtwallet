import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/api/api_provider_tracker.dart';
import 'package:mrt_wallet/models/wallet_models/account/bip32_network_account.dart';
import 'package:mrt_wallet/models/wallet_models/network/core/network.dart';
import 'package:mrt_wallet/models/wallet_models/network/params/params.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';
import 'package:on_chain/ethereum/ethereum.dart';
import 'package:on_chain/tron/tron.dart';
import 'package:xrp_dart/xrp_dart.dart';

class _DefaultAppCoins {
  static const BitcoinParams bitcoinMainnet = BitcoinParams(
      transactionExplorer: "https://live.blockcypher.com/btc/tx/#txid/",
      addressExplorer: "https://live.blockcypher.com/btc/address/#address/",
      transacationNetwork: BitcoinNetwork.mainnet,
      token: Token(
          name: "Bitcoin",
          symbol: "BTC",
          decimal: 8,
          assetLogo: "assets/image/btc.png"),
      providers: [ApiProviderService.mempool, ApiProviderService.blockCypher]);
  static const BitcoinParams bitcoinTestnet = BitcoinParams(
      transactionExplorer: "https://live.blockcypher.com/btc-testnet/tx/#txid/",
      addressExplorer:
          "https://live.blockcypher.com/btc-testnet/address/#address/",
      transacationNetwork: BitcoinNetwork.testnet,
      token: Token(
          name: "Bitcoin testnet",
          symbol: "tBTC",
          decimal: 8,
          assetLogo: "assets/image/btc.png"),
      providers: [ApiProviderService.mempool, ApiProviderService.blockCypher]);
  static const BitcoinParams litecoinMainnet = BitcoinParams(
      transactionExplorer: "https://live.blockcypher.com/ltc/tx/#txid/",
      addressExplorer: "https://live.blockcypher.com/ltc/address/#address/",
      transacationNetwork: LitecoinNetwork.mainnet,
      token: Token(
          name: "Litecoin",
          symbol: "LTC",
          decimal: 8,
          assetLogo: "assets/image/ltc.png"),
      providers: [ApiProviderService.blockCypher]);
  static const BitcoinParams dogecoinMainnet = BitcoinParams(
      transactionExplorer: "https://live.blockcypher.com/doge/tx/#txid/",
      addressExplorer: "https://live.blockcypher.com/doge/address/#address/",
      transacationNetwork: DogecoinNetwork.mainnet,
      token: Token(
          name: "Dogecoin",
          symbol: "Ɖ",
          decimal: 8,
          assetLogo: "assets/image/doge.png"),
      providers: [ApiProviderService.blockCypher]);
  static const BitcoinParams dashMainnet = BitcoinParams(
      transactionExplorer: "https://live.blockcypher.com/dash/tx/#txid/",
      addressExplorer: "https://live.blockcypher.com/dash/address/#address/",
      token: Token(
          name: "Dash",
          symbol: "DASH",
          decimal: 8,
          assetLogo: "assets/image/dash.png"),
      transacationNetwork: DashNetwork.mainnet,
      providers: [ApiProviderService.blockCypher]);
  static const RippleNetworkParams xrpMainnet = RippleNetworkParams(
      transactionExplorer: "https://livenet.xrpl.org/transactions/#txid",
      addressExplorer: "https://livenet.xrpl.org/accounts/#address",
      token: Token(
          name: "Ripple",
          symbol: "XRP",
          decimal: 6,
          assetLogo: "assets/image/xrp.png"),
      providers: [ApiProviderService.xrpl]);
  static const RippleNetworkParams xrpTestnet = RippleNetworkParams(
      transactionExplorer: "https://testnet.xrpl.org/transactions/#txid",
      addressExplorer: "https://testnet.xrpl.org/accounts/#address",
      token: Token(
          name: "Ripple testnet",
          symbol: "tXRP",
          decimal: 6,
          assetLogo: "assets/image/xrp.png"),
      providers: [ApiProviderService.xrpl]);
  static const RippleNetworkParams xrpDevnet = RippleNetworkParams(
      transactionExplorer: "https://devnet.xrpl.org/transactions/#txid",
      addressExplorer: "https://devnet.xrpl.org/accounts/#address",
      token: Token(
          name: "Ripple devnet",
          symbol: "tXRP",
          decimal: 6,
          assetLogo: "assets/image/xrp.png"),
      providers: [ApiProviderService.xrpl]);

  static final EVMNetworkParams ethreumMainnet = EVMNetworkParams(
      transactionExplorer: "https://devnet.xrpl.org/transactions/#txid",
      addressExplorer: "https://devnet.xrpl.org/accounts/#address",
      chainId: BigInt.one,
      mainnet: true,
      supportEIP1559: true,
      token: const Token(
          name: "Ethereum",
          symbol: "ETH",
          decimal: 18,
          assetLogo: "assets/image/eth.png"),
      providers: [
        const EVMApiProviderService(
            serviceName: "llamarpc.com",
            websiteUri: "https://eth.llamarpc.com",
            httpUri: "https://eth.llamarpc.com"),
      ]);
  static final EVMNetworkParams ethreumTestnet = EVMNetworkParams(
      transactionExplorer: "https://devnet.xrpl.org/transactions/#txid",
      addressExplorer: "https://devnet.xrpl.org/accounts/#address",
      chainId: BigInt.from(11155111),
      mainnet: false,
      supportEIP1559: true,
      token: const Token(
          name: "Ethereum Sepolia testnet",
          symbol: "tETH",
          decimal: 18,
          assetLogo: "assets/image/eth.png"),
      providers: [
        const EVMApiProviderService(
            serviceName: "publicnode.com",
            websiteUri: "https://ethereum-sepolia.publicnode.com",
            httpUri: "https://ethereum-sepolia.publicnode.com"),
      ]);
  static final EVMNetworkParams polygon = EVMNetworkParams(
      transactionExplorer: "https://devnet.xrpl.org/transactions/#txid",
      addressExplorer: "https://devnet.xrpl.org/accounts/#address",
      chainId: BigInt.from(137),
      supportEIP1559: true,
      mainnet: true,
      token: const Token(
          name: "Polygon",
          symbol: "MATIC",
          decimal: 18,
          assetLogo: "assets/image/matic.png"),
      providers: [
        const EVMApiProviderService(
            serviceName: "publicnode.com",
            websiteUri: "https://polygon-bor.publicnode.com",
            httpUri: "https://polygon-bor.publicnode.com"),
      ]);
  static final EVMNetworkParams polygonTestnet = EVMNetworkParams(
      transactionExplorer: "https://devnet.xrpl.org/transactions/#txid",
      addressExplorer: "https://devnet.xrpl.org/accounts/#address",
      chainId: BigInt.from(80001),
      supportEIP1559: true,
      mainnet: false,
      token: const Token(
          name: "Polygon testnet",
          symbol: "tMATIC",
          decimal: 18,
          assetLogo: "assets/image/matic.png"),
      providers: [
        const EVMApiProviderService(
            serviceName: "publicnode.com",
            httpUri: "https://polygon-mumbai-bor.publicnode.com",
            websiteUri: "https://polygon-mumbai-bor.publicnode.com"),
      ]);
  static final EVMNetworkParams bnb = EVMNetworkParams(
      transactionExplorer: "https://devnet.xrpl.org/transactions/#txid",
      addressExplorer: "https://devnet.xrpl.org/accounts/#address",
      chainId: BigInt.from(56),
      supportEIP1559: false,
      mainnet: true,
      token: const Token(
          name: "BNB Smart Chain",
          symbol: "BNB",
          decimal: 18,
          assetLogo: "assets/image/bnb.png"),
      providers: [
        const EVMApiProviderService(
            serviceName: "publicnode.com",
            httpUri: "https://bsc.publicnode.com",
            websiteUri: "https://bsc.publicnode.com"),
      ]);
  static final EVMNetworkParams bnbTestnet = EVMNetworkParams(
      transactionExplorer: "https://devnet.xrpl.org/transactions/#txid",
      addressExplorer: "https://devnet.xrpl.org/accounts/#address",
      chainId: BigInt.from(97),
      mainnet: false,
      supportEIP1559: false,
      token: const Token(
          name: "BNB Smart chain testnet",
          symbol: "tBNB",
          decimal: 18,
          assetLogo: "assets/image/bnb.png"),
      providers: [
        const EVMApiProviderService(
            serviceName: "publicnode.com",
            websiteUri: "https://bsc-testnet.publicnode.com",
            httpUri: "https://bsc-testnet.publicnode.com"),
      ]);

  /// tron networks
  static const TVMNetworkParams tronShasta = TVMNetworkParams(
      transactionExplorer: "https://devnet.xrpl.org/transactions/#txid",
      addressExplorer: "https://devnet.xrpl.org/accounts/#address",
      mainnet: false,
      token: Token(
          name: "Tron shasta testnet",
          symbol: "tTRX",
          decimal: 6,
          assetLogo: "assets/image/trx.png"),
      providers: [
        TronApiProviderService(
          serviceName: "trongrid",
          websiteUri: "https://trongrid.io",
          httpNodeUri: "https://api.shasta.trongrid.io",
        ),
      ],
      ethereumProviders: [
        EVMApiProviderService(
            serviceName: "https://api.shasta.trongrid.io/jsonrpc",
            websiteUri: "trongrid.io",
            httpUri: "https://api.shasta.trongrid.io/jsonrpc")
      ]);
  static const TVMNetworkParams tronNile = TVMNetworkParams(
      transactionExplorer: "https://devnet.xrpl.org/transactions/#txid",
      addressExplorer: "https://devnet.xrpl.org/accounts/#address",
      mainnet: false,
      token: Token(
          name: "Tron nile testnet",
          symbol: "tTRX",
          decimal: 6,
          assetLogo: "assets/image/trx.png"),
      ethereumProviders: [
        EVMApiProviderService(
            serviceName: "https://nile.trongrid.io/jsonrpc",
            websiteUri: "trongrid.io",
            httpUri: "https://nile.trongrid.io/jsonrpc")
      ],
      providers: [
        TronApiProviderService(
            serviceName: "trongrid",
            websiteUri: "https://trongrid.io",
            httpNodeUri: "https://nile.trongrid.io"),
      ]);
  static const TVMNetworkParams tron = TVMNetworkParams(
      transactionExplorer: "https://devnet.xrpl.org/transactions/#txid",
      addressExplorer: "https://devnet.xrpl.org/accounts/#address",
      mainnet: true,
      token: Token(
          name: "Tron",
          symbol: "TRX",
          decimal: 6,
          assetLogo: "assets/image/trx.png"),
      ethereumProviders: [
        EVMApiProviderService(
            serviceName: "https://api.trongrid.io/jsonrpc",
            websiteUri: "trongrid.io",
            httpUri: "https://api.trongrid.io/jsonrpc")
      ],
      providers: [
        TronApiProviderService(
          serviceName: "trongrid",
          websiteUri: "https://trongrid.io",
          httpNodeUri: "https://api.trongrid.io",
        ),
      ]);
}

class ChainUtils {
  static NetworkApiProvider _buildApiProvider(AppNetworkImpl network,
      {ApiProviderService provider = ApiProviderService.mempool}) {
    if (network is APPEVMNetwork) {
      return _buildEVMProvider(network, provider as EVMApiProviderService);
    } else if (network is AppBitcoinNetwork) {
      return _buildBlockCypherOrMempolProvider(network, provider);
    } else if (network is AppXRPNetwork) {
      return _buildRippleProvider(network, provider);
    } else if (network is APPTVMNetwork) {
      return _buildTVMProvider(network, provider as TronApiProviderService);
    }
    throw WalletExceptionConst.incorrectNetwork;
  }

  static BitcoinApiProvider _buildBlockCypherOrMempolProvider(
      AppBitcoinNetwork network, ApiProviderService provider) {
    final btcNetwork = network.coinParam.transacationNetwork;
    final serviceProvider = ApiProviderTracker(provider: provider);
    final api = provider == ApiProviderService.mempool
        ? ApiProvider.fromMempool(
            btcNetwork, BitcoinApiService(serviceProvider))
        : ApiProvider.fromBlocCypher(
            btcNetwork, BitcoinApiService(serviceProvider));
    return BitcoinApiProvider(provider: api);
  }

  static EVMApiProvider _buildEVMProvider(
      APPEVMNetwork network, EVMApiProviderService provider) {
    final tracker = ApiProviderTracker(provider: provider);
    final emvRPC = EVMRPC(EthereumRPCService(provider.httpUri, tracker));
    return EVMApiProvider(provider: emvRPC);
  }

  static TVMApiProvider _buildTVMProvider(
      APPTVMNetwork network, TronApiProviderService httpProviderService) {
    EVMApiProviderService solidityProviderService =
        network.coinParam.ethereumProviders.first;
    final httpNodeTracker = ApiProviderTracker(provider: httpProviderService);
    final solidityNodeTracker =
        ApiProviderTracker(provider: solidityProviderService);
    final httpNode = TronProvider(
        TronHTTPService(httpProviderService.httpNodeUri, httpNodeTracker));
    final solidityNode = EVMRPC(EthereumRPCService(
        solidityProviderService.httpUri, solidityNodeTracker));
    final solidityApiProvider = EVMApiProvider(provider: solidityNode);
    return TVMApiProvider(
        provider: httpNode, solidityProvider: solidityApiProvider);
  }

  static RippleApiProvider _buildRippleProvider(
      AppXRPNetwork network, ApiProviderService provider) {
    final tracker = ApiProviderTracker(provider: provider);
    XRPLRpc rpcProvider;
    switch (network.value) {
      case 30:
        rpcProvider = XRPLRpc(RippleRPCService(RPCConst.mainetUri, tracker));
        break;
      case 31:
        rpcProvider = XRPLRpc(RippleRPCService(RPCConst.testnetUri, tracker));
        break;
      default:
        rpcProvider = XRPLRpc(RippleRPCService(RPCConst.devnetUri, tracker));
        break;
    }
    return RippleApiProvider(provider: rpcProvider);
  }

  static T buildApiProvider<T extends NetworkApiProvider>(
      AppNetworkImpl network,
      {ApiProviderService? service}) {
    return _buildApiProvider(network,
        provider: network.getProvider(service?.serviceName)) as T;
  }

  static final Map<int, AppNetworkImpl> defaultCoins = Map.unmodifiable({
    0: const AppBitcoinNetwork(0, _DefaultAppCoins.bitcoinMainnet),
    1: const AppBitcoinNetwork(1, _DefaultAppCoins.bitcoinTestnet),
    2: const AppBitcoinNetwork(2, _DefaultAppCoins.litecoinMainnet),
    3: const AppBitcoinNetwork(3, _DefaultAppCoins.dogecoinMainnet),
    4: const AppBitcoinNetwork(4, _DefaultAppCoins.dashMainnet),
    30: const AppXRPNetwork(30, _DefaultAppCoins.xrpMainnet),
    31: const AppXRPNetwork(31, _DefaultAppCoins.xrpTestnet),
    32: const AppXRPNetwork(32, _DefaultAppCoins.xrpDevnet),
    100: APPEVMNetwork(100, _DefaultAppCoins.ethreumMainnet),
    101: APPEVMNetwork(101, _DefaultAppCoins.ethreumTestnet),
    102: APPEVMNetwork(102, _DefaultAppCoins.polygon),
    103: APPEVMNetwork(103, _DefaultAppCoins.polygonTestnet),
    104: APPEVMNetwork(104, _DefaultAppCoins.bnb),
    105: APPEVMNetwork(105, _DefaultAppCoins.bnbTestnet),
    1001: const APPTVMNetwork(1001, _DefaultAppCoins.tron),
    1002: const APPTVMNetwork(1002, _DefaultAppCoins.tronShasta),
    1003: const APPTVMNetwork(1003, _DefaultAppCoins.tronNile),
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
            BitcoinAddress>.fromCborBytesOrObject(network, obj: account);
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
        return Bip32NetworkAccount<BigInt, BitcoinAddress>.setup(network);
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
