import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/constant/constant.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
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
        market: const CoingeckoCoin(
            apiId: "bitcoin-cash", coinName: "bitcoin-cash"),
        symbol: "BCH",
        decimal: 8,
        assetLogo: APPConst.bch,
      ),
      providers: []);
  static final BitcoinParams bitcoinCashChipnet = BitcoinParams(
      transactionExplorer: "https://cbch.loping.net/tx/#txid",
      addressExplorer: "https://cbch.loping.net/address/#address",
      transacationNetwork: BitcoinCashNetwork.testnet,
      token: Token(
        name: "BitcoinCash chipnet",
        symbol: "tBCH",
        market: const CoingeckoCoin(
            apiId: "bitcoin-cash", coinName: "bitcoin-cash"),
        decimal: 8,
        assetLogo: APPConst.bch,
      ),
      providers: []);
  static final BitcoinParams bitcoinMainnet = BitcoinParams(
      transactionExplorer: "https://live.blockcypher.com/btc/tx/#txid/",
      addressExplorer: "https://live.blockcypher.com/btc/address/#address/",
      transacationNetwork: BitcoinNetwork.mainnet,
      token: Token(
          name: "Bitcoin",
          symbol: "BTC",
          market: const CoingeckoCoin(apiId: "bitcoin", coinName: "bitcoin"),
          decimal: 8,
          assetLogo: APPConst.btc),
      providers: []);
  static final BitcoinParams bitcoinTestnet = BitcoinParams(
      transactionExplorer: "https://live.blockcypher.com/btc-testnet/tx/#txid/",
      addressExplorer:
          "https://live.blockcypher.com/btc-testnet/address/#address/",
      transacationNetwork: BitcoinNetwork.testnet,
      token: Token(
          name: "Bitcoin testnet",
          symbol: "tBTC",
          market: const CoingeckoCoin(apiId: "bitcoin", coinName: "bitcoin"),
          decimal: 8,
          assetLogo: APPConst.btc),
      providers: []);
  static final BitcoinParams litecoinMainnet = BitcoinParams(
      transactionExplorer: "https://live.blockcypher.com/ltc/tx/#txid/",
      addressExplorer: "https://live.blockcypher.com/ltc/address/#address/",
      transacationNetwork: LitecoinNetwork.mainnet,
      token: Token(
          name: "Litecoin",
          symbol: "LTC",
          market: const CoingeckoCoin(apiId: "litecoin", coinName: "litecoin"),
          decimal: 8,
          assetLogo: APPConst.ltc),
      providers: []);
  static final BitcoinParams litecoinTestnet = BitcoinParams(
      transactionExplorer: "https://live.blockcypher.com/ltc/tx/#txid/",
      addressExplorer: "https://live.blockcypher.com/ltc/address/#address/",
      transacationNetwork: LitecoinNetwork.testnet,
      token: Token(
          name: "Litecoin testnet",
          symbol: "tLTC",
          market: const CoingeckoCoin(apiId: "litecoin", coinName: "litecoin"),
          decimal: 8,
          assetLogo: APPConst.ltc),
      providers: []);
  static final BitcoinParams dogecoinMainnet = BitcoinParams(
      transactionExplorer: "https://live.blockcypher.com/doge/tx/#txid/",
      addressExplorer: "https://live.blockcypher.com/doge/address/#address/",
      transacationNetwork: DogecoinNetwork.mainnet,
      token: Token(
          name: "Dogecoin",
          market: const CoingeckoCoin(apiId: "dogecoin", coinName: "dogecoin"),
          symbol: "Ɖ",
          decimal: 8,
          assetLogo: APPConst.doge),
      providers: []);
  static final BitcoinParams pepecoinMainnet = BitcoinParams(
      transactionExplorer: "https://pepeexplorer.com/tx/#txid",
      addressExplorer: "https://pepeexplorer.com/address/#address",
      transacationNetwork: PepeNetwork.mainnet,
      token: Token(
          name: "Pepecoin",
          symbol: "₱",
          decimal: 8,
          market: const CoingeckoCoin(
              apiId: "pepecoin-network", coinName: "pepecoin-network"),
          assetLogo: APPConst.pepecoin),
      providers: []);
  static final BitcoinParams dogeTestnet = BitcoinParams(
      transactionExplorer: "https://live.blockcypher.com/doge/tx/#txid/",
      addressExplorer: "https://live.blockcypher.com/doge/address/#address/",
      transacationNetwork: DogecoinNetwork.testnet,
      token: Token(
        name: "Dogecoin testnet",
        symbol: "tƉ",
        market: const CoingeckoCoin(apiId: "dogecoin", coinName: "dogecoin"),
        decimal: 8,
        assetLogo: APPConst.doge,
      ),
      providers: []);
  static final BitcoinParams bsvMainnet = BitcoinParams(
      transactionExplorer: "https://whatsonchain.com/tx/#txid",
      addressExplorer: "https://whatsonchain.com/address/#address",
      transacationNetwork: BitcoinSVNetwork.mainnet,
      token: Token(
        name: "BitcoinSV",
        symbol: "BSV",
        market: const CoingeckoCoin(
            apiId: "bitcoin-cash-sv", coinName: "bitcoin-sv"),
        decimal: 8,
        assetLogo: APPConst.bsv,
      ),
      providers: []);
  static final BitcoinParams dashMainnet = BitcoinParams(
      transactionExplorer: "https://live.blockcypher.com/dash/tx/#txid/",
      addressExplorer: "https://live.blockcypher.com/dash/address/#address/",
      token: Token(
        name: "Dash",
        symbol: "DASH",
        market: const CoingeckoCoin(apiId: "dash", coinName: "dash"),
        decimal: 8,
        assetLogo: APPConst.dash,
      ),
      transacationNetwork: DashNetwork.mainnet,
      providers: []);
  static final RippleNetworkParams xrpMainnet = RippleNetworkParams(
      transactionExplorer: "https://livenet.xrpl.org/transactions/#txid",
      addressExplorer: "https://livenet.xrpl.org/accounts/#address",
      token: Token(
        name: "Ripple",
        symbol: "XRP",
        decimal: 6,
        market: const CoingeckoCoin(apiId: "ripple", coinName: "xrp"),
        assetLogo: APPConst.xrp,
      ),
      providers: [],
      mainnet: true);
  static final RippleNetworkParams xrpTestnet = RippleNetworkParams(
      transactionExplorer: "https://testnet.xrpl.org/transactions/#txid",
      addressExplorer: "https://testnet.xrpl.org/accounts/#address",
      token: Token(
        name: "Ripple testnet",
        symbol: "tXRP",
        decimal: 6,
        market: const CoingeckoCoin(apiId: "ripple", coinName: "xrp"),
        assetLogo: APPConst.xrp,
      ),
      providers: [],
      mainnet: false);
  static final RippleNetworkParams xrpDevnet = RippleNetworkParams(
      transactionExplorer: "https://devnet.xrpl.org/transactions/#txid",
      addressExplorer: "https://devnet.xrpl.org/accounts/#address",
      token: Token(
        name: "Ripple devnet",
        symbol: "tXRP",
        decimal: 6,
        market: const CoingeckoCoin(apiId: "ripple", coinName: "xrp"),
        assetLogo: APPConst.xrp,
      ),
      providers: [],
      mainnet: false);

  static final EthereumNetworkParams ethreumMainnet = EthereumNetworkParams(
      transactionExplorer: "https://etherscan.io/tx/#txid",
      addressExplorer: "https://etherscan.io/address/#address",
      chainId: BigInt.one,
      mainnet: true,
      supportEIP1559: true,
      token: Token(
        name: "Ethereum",
        symbol: "ETH",
        market: const CoingeckoCoin(apiId: "ethereum", coinName: "ethereum"),
        decimal: 18,
        assetLogo: APPConst.eth,
      ),
      providers: []);
  static final EthereumNetworkParams ethreumTestnet = EthereumNetworkParams(
      transactionExplorer: "https://sepolia.etherscan.io/tx/#txid",
      addressExplorer: "https://sepolia.etherscan.io/address/#address",
      chainId: BigInt.from(11155111),
      mainnet: false,
      supportEIP1559: true,
      token: Token(
        name: "Ethereum Sepolia testnet",
        symbol: "tETH",
        market: const CoingeckoCoin(apiId: "ethereum", coinName: "ethereum"),
        decimal: 18,
        assetLogo: APPConst.eth,
      ),
      providers: []);
  static final EthereumNetworkParams polygon = EthereumNetworkParams(
      transactionExplorer: "https://polygonscan.com/tx/#txid",
      addressExplorer: "https://polygonscan.com/address/#address",
      chainId: BigInt.from(137),
      supportEIP1559: true,
      mainnet: true,
      token: Token(
        name: "Polygon",
        symbol: "MATIC",
        market:
            const CoingeckoCoin(apiId: "matic-network", coinName: "polygon"),
        decimal: 18,
        assetLogo: APPConst.matic,
      ),
      providers: []);
  static final EthereumNetworkParams polygonTestnet = EthereumNetworkParams(
      transactionExplorer: "https://mumbai.polygonscan.com/tx/#txid",
      addressExplorer: "https://mumbai.polygonscan.com/address/#address",
      chainId: BigInt.from(80001),
      supportEIP1559: true,
      mainnet: false,
      token: Token(
        name: "Polygon mumbai testnet",
        symbol: "tMATIC",
        market:
            const CoingeckoCoin(apiId: "matic-network", coinName: "polygon"),
        decimal: 18,
        assetLogo: APPConst.matic,
      ),
      providers: []);
  static final EthereumNetworkParams bnb = EthereumNetworkParams(
      transactionExplorer: "https://bscscan.com/tx/#txid",
      addressExplorer: "https://bscscan.com/address/#address",
      chainId: BigInt.from(56),
      supportEIP1559: false,
      mainnet: true,
      token: Token(
          name: "BNB Smart Chain",
          symbol: "BNB",
          market: const CoingeckoCoin(apiId: "binancecoin", coinName: "bnb"),
          decimal: 18,
          assetLogo: APPConst.bnb),
      providers: []);
  static final EthereumNetworkParams bnbTestnet = EthereumNetworkParams(
      transactionExplorer: "https://testnet.bscscan.com/tx/#txid",
      addressExplorer: "https://testnet.bscscan.com/address/#address",
      chainId: BigInt.from(97),
      mainnet: false,
      supportEIP1559: false,
      token: Token(
          name: "BNB Smart chain testnet",
          symbol: "tBNB",
          market: const CoingeckoCoin(apiId: "binancecoin", coinName: "bnb"),
          decimal: 18,
          assetLogo: APPConst.bnb),
      providers: []);

  /// tron networks
  static final TronNetworkParams tronShasta = TronNetworkParams(
      transactionExplorer: "https://shasta.tronscan.org/#/transaction/#txid",
      addressExplorer: "https://shasta.tronscan.org/#/address/#address",
      mainnet: false,
      token: Token(
        name: "Tron shasta testnet",
        symbol: "tTRX",
        market: const CoingeckoCoin(apiId: "tron", coinName: "tron"),
        decimal: 6,
        assetLogo: APPConst.trx,
      ),
      providers: [],
      ethereumProviders: []);
  static final TronNetworkParams tronNile = TronNetworkParams(
      transactionExplorer: "https://nile.tronscan.org/#/transaction/#txid",
      addressExplorer: "https://nile.tronscan.org/#/address/#address",
      mainnet: false,
      token: Token(
        name: "Tron nile testnet",
        symbol: "tTRX",
        market: const CoingeckoCoin(apiId: "tron", coinName: "tron"),
        decimal: 6,
        assetLogo: APPConst.trx,
      ),
      ethereumProviders: [],
      providers: []);
  static final TronNetworkParams tron = TronNetworkParams(
      transactionExplorer: "https://tronscan.org/#/transaction/#txid",
      addressExplorer: "https://tronscan.org/#/address/#address",
      mainnet: true,
      token: Token(
        name: "Tron",
        symbol: "TRX",
        decimal: 6,
        market: const CoingeckoCoin(apiId: "tron", coinName: "tron"),
        assetLogo: APPConst.trx,
      ),
      ethereumProviders: [],
      providers: []);

  static final SolanaNetworkParams solana = SolanaNetworkParams(
      transactionExplorer: "https://explorer.solana.com/tx/#txid",
      addressExplorer: "https://explorer.solana.com/address/#address",
      mainnet: true,
      token: Token(
          name: "Solana",
          symbol: "SOL",
          market: const CoingeckoCoin(apiId: "solana", coinName: "solana"),
          decimal: 9,
          assetLogo: APPConst.sol),
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
        market: const CoingeckoCoin(apiId: "solana", coinName: "solana"),
        decimal: 9,
        assetLogo: APPConst.sol,
      ),
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
        market: const CoingeckoCoin(apiId: "cardano", coinName: "cardano"),
        decimal: 6,
        assetLogo: APPConst.ada,
      ),
      providers: []);
  static final CardanoNetworkParams cardano = CardanoNetworkParams(
      transactionExplorer:
          "https://beta.explorer.cardano.org/en/transaction/#txid",
      addressExplorer: "https://beta.explorer.cardano.org/en/address/#address",
      mainnet: true,
      token: Token(
        name: "Cardano",
        symbol: "ADA",
        market: const CoingeckoCoin(apiId: "cardano", coinName: "cardano"),
        decimal: 6,
        assetLogo: APPConst.ada,
      ),
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
        market: const CoingeckoCoin(apiId: "cosmos", coinName: "cosmos-hub"),
        decimal: 6,
        assetLogo: APPConst.atom,
      ),
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
        market: const CoingeckoCoin(apiId: "cosmos", coinName: "cosmos-hub"),
        decimal: 6,
        assetLogo: APPConst.atom,
      ),
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
          market:
              const CoingeckoCoin(apiId: "cacao", coinName: "maya-protocol"),
          decimal: 10,
          assetLogo: APPConst.cacao),
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
          market:
              const CoingeckoCoin(apiId: "thorchain", coinName: "thorchain"),
          decimal: 8,
          assetLogo: APPConst.thor),
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
          market: const CoingeckoCoin(apiId: "kujira", coinName: "kujira"),
          decimal: 6,
          assetLogo: APPConst.kujira),
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
          market: const CoingeckoCoin(apiId: "kujira", coinName: "kujira"),
          decimal: 6,
          assetLogo: APPConst.kujira),
      providers: []);

  static final CosmosNetworkParams osmosTestnet = CosmosNetworkParams(
      transactionExplorer:
          "https://celatone.osmosis.zone/osmo-test-5/txs/#txid",
      addressExplorer:
          "https://celatone.osmosis.zone/osmo-test-5/accounts/#address",
      networkType: CosmosNetworkTypes.main,
      mainnet: false,
      hrp: CosmosConst.osmoHrp,
      mainCoin: const CosmosNativeCoin(decimal: 6, denom: 'uosmo'),
      coins: [const CosmosNativeCoin(decimal: 6, denom: 'uosmo')],
      token: Token(
        name: "Osmo testnet",
        symbol: "tOsmo",
        decimal: 6,
        market: const CoingeckoCoin(apiId: "osmosis", coinName: "osmosis"),
        assetLogo: APPConst.osmo,
      ),
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
        market:
            const CoingeckoCoin(apiId: "the-open-network", coinName: "toncoin"),
        assetLogo: APPConst.ton,
      ),
      providers: []);

  static final TonNetworkParams tonMainnet = TonNetworkParams(
      transactionExplorer: "https://tonscan.org/tx/#txid",
      addressExplorer: "https://tonscan.org/address/#address",
      mainnet: true,
      workchain: 0,
      token: Token(
          name: "TonCoin",
          symbol: "Ton",
          market: const CoingeckoCoin(
              apiId: "the-open-network", coinName: "toncoin"),
          decimal: 9,
          assetLogo: APPConst.ton),
      providers: []);
}

class ChainUtils {
  static final Map<int, WalletNetwork> defaultCoins = Map.unmodifiable({
    0: WalletBitcoinNetwork(0, _DefaultAppCoins.bitcoinMainnet),
    1: WalletBitcoinNetwork(1, _DefaultAppCoins.bitcoinTestnet),
    2: WalletBitcoinNetwork(2, _DefaultAppCoins.litecoinMainnet),
    7: WalletBitcoinNetwork(7, _DefaultAppCoins.litecoinTestnet),
    3: WalletBitcoinNetwork(3, _DefaultAppCoins.dogecoinMainnet),
    8: WalletBitcoinNetwork(8, _DefaultAppCoins.dogeTestnet),
    9: WalletBitcoinNetwork(9, _DefaultAppCoins.bsvMainnet),
    4: WalletBitcoinNetwork(4, _DefaultAppCoins.dashMainnet),
    10: WalletBitcoinCashNetwork(10, _DefaultAppCoins.bitcoinCashMainnet),
    11: WalletBitcoinCashNetwork(11, _DefaultAppCoins.bitcoinCashChipnet),
    12: WalletBitcoinNetwork(12, _DefaultAppCoins.pepecoinMainnet),
    30: WalletXRPNetwork(30, _DefaultAppCoins.xrpMainnet),
    31: WalletXRPNetwork(31, _DefaultAppCoins.xrpTestnet),
    32: WalletXRPNetwork(32, _DefaultAppCoins.xrpDevnet),
    33: WalletSolanaNetwork(33, _DefaultAppCoins.solana),
    34: WalletSolanaNetwork(34, _DefaultAppCoins.solanaTestnet),
    50: WalletCardanoNetwork(50, _DefaultAppCoins.cardano),
    51: WalletCardanoNetwork(51, _DefaultAppCoins.cardanoTestnet),
    100: WalletEthereumNetwork(100, _DefaultAppCoins.ethreumMainnet),
    101: WalletEthereumNetwork(101, _DefaultAppCoins.ethreumTestnet),
    102: WalletEthereumNetwork(102, _DefaultAppCoins.polygon),
    103: WalletEthereumNetwork(103, _DefaultAppCoins.polygonTestnet),
    104: WalletEthereumNetwork(104, _DefaultAppCoins.bnb),
    105: WalletEthereumNetwork(105, _DefaultAppCoins.bnbTestnet),
    200: WalletCosmosNetwork(200, _DefaultAppCoins.cosmos),
    201: WalletCosmosNetwork(201, _DefaultAppCoins.cosmosTestnet),
    202: WalletCosmosNetwork(202, _DefaultAppCoins.maya),
    203: WalletCosmosNetwork(203, _DefaultAppCoins.thorchain),
    204: WalletCosmosNetwork(204, _DefaultAppCoins.kujiraTestnet),
    205: WalletCosmosNetwork(205, _DefaultAppCoins.kujira),
    206: WalletCosmosNetwork(206, _DefaultAppCoins.osmosTestnet),
    300: WalletTonNetwork(300, _DefaultAppCoins.tonMainnet),
    301: WalletTonNetwork(301, _DefaultAppCoins.tonTestnet),
    1001: WalletTronNetwork(1001, _DefaultAppCoins.tron),
    1002: WalletTronNetwork(1002, _DefaultAppCoins.tronShasta),
    1003: WalletTronNetwork(1003, _DefaultAppCoins.tronNile),
  });
  static Bip32NetworkAccount toNetworkAccount(
      WalletNetwork network, CborTagValue account) {
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

  static Bip32NetworkAccount createNetworkAccount(WalletNetwork network) {
    switch (network.runtimeType) {
      case WalletEthereumNetwork:
        return Bip32NetworkAccount<BigInt, ETHAddress>.setup(network);
      case WalletTronNetwork:
        return Bip32NetworkAccount<BigInt, TronAddress>.setup(network);
      case WalletXRPNetwork:
        return Bip32NetworkAccount<BigRational, XRPAddress>.setup(network);
      case WalletSolanaNetwork:
        return Bip32NetworkAccount<BigInt, SolAddress>.setup(network);
      case WalletCardanoNetwork:
        return Bip32NetworkAccount<BigInt, ADAAddress>.setup(network);
      case WalletCosmosNetwork:
        return Bip32NetworkAccount<BigInt, CosmosBaseAddress>.setup(network);
      case WalletTonNetwork:
        return Bip32NetworkAccount<BigInt, TonAddress>.setup(network);
      default:
        return Bip32NetworkAccount<BigInt, BitcoinBaseAddress>.setup(network);
    }
  }

  static Bip32NetworkAccount account(
      WalletNetwork network, CborTagValue? account) {
    try {
      return toNetworkAccount(network, account!);
    } catch (e) {
      return createNetworkAccount(network);
    }
  }

  static WalletNetwork updateNetwork({int? networkId, WalletNetwork? network}) {
    if (networkId == null || network != null && networkId != network.value) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    if (!defaultCoins.containsKey(networkId)) {
      if (network == null) {
        throw WalletExceptionConst.dataVerificationFailed;
      }
      return network;
    }
    final WalletNetwork defaultNetwork = defaultCoins[networkId]!;
    return defaultNetwork.copyWith(
        coinParam: defaultNetwork.coinParam
            .updateProviders(network?.coinParam.providers ?? []),
        value: defaultNetwork.value);
  }
}
