import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/bip/bip.dart';
import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/constant/constant.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class _DefaultAppCoins {
  static final BitcoinParams bitcoinCashMainnet = BitcoinParams(
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
      transacationNetwork: BitcoinNetwork.mainnet,
      token: Token(
          name: "Bitcoin",
          symbol: "BTC",
          market: const CoingeckoCoin(apiId: "bitcoin", coinName: "bitcoin"),
          decimal: 8,
          assetLogo: APPConst.btc),
      providers: []);
  static final BitcoinParams bitcoinTestnet = BitcoinParams(
      transacationNetwork: BitcoinNetwork.testnet,
      token: Token(
          name: "Bitcoin testnet",
          symbol: "tBTC",
          market: const CoingeckoCoin(apiId: "bitcoin", coinName: "bitcoin"),
          decimal: 8,
          assetLogo: APPConst.btc),
      providers: []);
  static final BitcoinParams bitcoinTestnet4 = BitcoinParams(
      transacationNetwork: BitcoinNetwork.testnet4,
      token: Token(
          name: "Bitcoin testnet4",
          symbol: "tBTC",
          market: const CoingeckoCoin(apiId: "bitcoin", coinName: "bitcoin"),
          decimal: 8,
          assetLogo: APPConst.btc),
      providers: []);
  static final BitcoinParams litecoinMainnet = BitcoinParams(
      transacationNetwork: LitecoinNetwork.mainnet,
      token: Token(
          name: "Litecoin",
          symbol: "LTC",
          market: const CoingeckoCoin(apiId: "litecoin", coinName: "litecoin"),
          decimal: 8,
          assetLogo: APPConst.ltc),
      providers: []);
  static final BitcoinParams litecoinTestnet = BitcoinParams(
      transacationNetwork: LitecoinNetwork.testnet,
      token: Token(
          name: "Litecoin testnet",
          symbol: "tLTC",
          market: const CoingeckoCoin(apiId: "litecoin", coinName: "litecoin"),
          decimal: 8,
          assetLogo: APPConst.ltc),
      providers: []);
  static final BitcoinParams dogecoinMainnet = BitcoinParams(
      transacationNetwork: DogecoinNetwork.mainnet,
      token: Token(
          name: "Dogecoin",
          market: const CoingeckoCoin(apiId: "dogecoin", coinName: "dogecoin"),
          symbol: "Ɖ",
          decimal: 8,
          assetLogo: APPConst.doge),
      providers: []);
  static final BitcoinParams pepecoinMainnet = BitcoinParams(
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
      token: Token(
        name: "Ripple",
        symbol: "XRP",
        decimal: 6,
        market: const CoingeckoCoin(apiId: "ripple", coinName: "xrp"),
        assetLogo: APPConst.xrp,
      ),
      providers: [],
      chainType: ChainType.mainnet,
      networkId: 0);
  static final RippleNetworkParams xrpTestnet = RippleNetworkParams(
      token: Token(
        name: "Ripple testnet",
        symbol: "tXRP",
        decimal: 6,
        market: const CoingeckoCoin(apiId: "ripple", coinName: "xrp"),
        assetLogo: APPConst.xrp,
      ),
      providers: [],
      chainType: ChainType.testnet,
      networkId: 1);
  static final RippleNetworkParams xrpDevnet = RippleNetworkParams(
      token: Token(
        name: "Ripple devnet",
        symbol: "tXRP",
        decimal: 6,
        market: const CoingeckoCoin(apiId: "ripple", coinName: "xrp"),
        assetLogo: APPConst.xrp,
      ),
      providers: [],
      chainType: ChainType.testnet,
      networkId: 2);

  static final EthereumNetworkParams ethreumMainnet = EthereumNetworkParams(
      chainId: BigInt.one,
      chainType: ChainType.mainnet,
      supportEIP1559: true,
      token: Token(
        name: "Ethereum",
        symbol: "ETH",
        market: const CoingeckoCoin(apiId: "ethereum", coinName: "ethereum"),
        decimal: 18,
        assetLogo: APPConst.eth,
      ),
      providers: []);
  static final EthereumNetworkParams avalanche = EthereumNetworkParams(
      chainId: BigInt.from(43114),
      chainType: ChainType.mainnet,
      supportEIP1559: true,
      token: Token(
        name: "Avalanche",
        symbol: "AVAX",
        market:
            const CoingeckoCoin(apiId: "avalanche-2", coinName: "avalanche"),
        decimal: 18,
        assetLogo: APPConst.avalance,
      ),
      providers: []);
  static final EthereumNetworkParams arbitrum = EthereumNetworkParams(
      chainId: BigInt.from(42161),
      chainType: ChainType.mainnet,
      supportEIP1559: true,
      token: Token(
        name: "Arbitrum",
        symbol: "ARB",
        market: const CoingeckoCoin(apiId: "arbitrum", coinName: "arbitrum"),
        decimal: 18,
        assetLogo: APPConst.arbitrum,
      ),
      providers: []);
  static final EthereumNetworkParams base = EthereumNetworkParams(
      chainId: BigInt.from(8453),
      chainType: ChainType.mainnet,
      supportEIP1559: true,
      token: Token(
        name: "Base Mainnet",
        symbol: "ETH",
        decimal: 18,
        assetLogo: APPConst.base,
      ),
      providers: []);
  static final EthereumNetworkParams optimism = EthereumNetworkParams(
      chainId: BigInt.from(10),
      chainType: ChainType.mainnet,
      supportEIP1559: true,
      token: Token(
        name: "OP Mainnet",
        symbol: "ETH",
        decimal: 18,
        assetLogo: APPConst.optimistic,
      ),
      providers: []);
  static final EthereumNetworkParams ethreumTestnet = EthereumNetworkParams(
      chainId: BigInt.from(11155111),
      chainType: ChainType.testnet,
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
      chainId: BigInt.from(137),
      supportEIP1559: true,
      chainType: ChainType.mainnet,
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
      chainId: BigInt.from(80001),
      supportEIP1559: true,
      chainType: ChainType.testnet,
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
      chainId: BigInt.from(56),
      supportEIP1559: false,
      chainType: ChainType.mainnet,
      token: Token(
          name: "BNB Smart Chain",
          symbol: "BNB",
          market: const CoingeckoCoin(apiId: "binancecoin", coinName: "bnb"),
          decimal: 18,
          assetLogo: APPConst.bnb),
      providers: []);
  static final EthereumNetworkParams bnbTestnet = EthereumNetworkParams(
      chainId: BigInt.from(97),
      chainType: ChainType.testnet,
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
      chainType: ChainType.testnet,
      token: Token(
        name: "Tron shasta testnet",
        symbol: "tTRX",
        market: const CoingeckoCoin(apiId: "tron", coinName: "tron"),
        decimal: 6,
        assetLogo: APPConst.trx,
      ),
      providers: []);
  static final TronNetworkParams tronNile = TronNetworkParams(
      chainType: ChainType.testnet,
      token: Token(
        name: "Tron nile testnet",
        symbol: "tTRX",
        market: const CoingeckoCoin(apiId: "tron", coinName: "tron"),
        decimal: 6,
        assetLogo: APPConst.trx,
      ),
      providers: []);
  static final TronNetworkParams tron = TronNetworkParams(
      chainType: ChainType.mainnet,
      token: Token(
        name: "Tron",
        symbol: "TRX",
        decimal: 6,
        market: const CoingeckoCoin(apiId: "tron", coinName: "tron"),
        assetLogo: APPConst.trx,
      ),
      providers: []);

  static final SolanaNetworkParams solana = SolanaNetworkParams(
      chainType: ChainType.mainnet,
      token: Token(
        name: "Solana",
        symbol: "SOL",
        market: const CoingeckoCoin(apiId: "solana", coinName: "solana"),
        decimal: SolanaConst.decimal,
        assetLogo: APPConst.sol,
      ),
      providers: [],
      chainId: 101,
      type: SolanaNetworkType.mainnet);
  static final SolanaNetworkParams solanaTestnet = SolanaNetworkParams(
      chainType: ChainType.testnet,
      token: Token(
        name: "Solana testnet",
        symbol: "tSOL",
        market: const CoingeckoCoin(apiId: "solana", coinName: "solana"),
        decimal: SolanaConst.decimal,
        assetLogo: APPConst.sol,
      ),
      providers: [],
      chainId: 102,
      type: SolanaNetworkType.testnet);
  static final SolanaNetworkParams solanaDevnet = SolanaNetworkParams(
      chainType: ChainType.testnet,
      token: Token(
          name: "Solana devnet",
          symbol: "tSOL",
          market: const CoingeckoCoin(apiId: "solana", coinName: "solana"),
          decimal: SolanaConst.decimal,
          assetLogo: APPConst.sol),
      providers: [],
      chainId: 103,
      type: SolanaNetworkType.devnet);

  static final CardanoNetworkParams cardanoPreprod = CardanoNetworkParams(
      chainType: ChainType.testnet,
      token: Token(
        name: "Cardano preprod",
        symbol: "tADA",
        market: const CoingeckoCoin(apiId: "cardano", coinName: "cardano"),
        decimal: 6,
        assetLogo: APPConst.ada,
      ),
      providers: [],
      magic: 1);
  static final CardanoNetworkParams cardano = CardanoNetworkParams(
      chainType: ChainType.mainnet,
      token: Token(
        name: "Cardano",
        symbol: "ADA",
        market: const CoingeckoCoin(apiId: "cardano", coinName: "cardano"),
        decimal: 6,
        assetLogo: APPConst.ada,
      ),
      providers: [],
      magic: 764824073);
  static final CosmosNetworkParams cosmosTestnet = CosmosNetworkParams(
      networkType: CosmosNetworkTypes.main,
      chainType: ChainType.testnet,
      hrp: CosmosAddrConst.accHRP,
      chainRegisteryName: "cosmosicsprovidertestnet",
      denom: "uatom",
      chainId: "provider",
      feeTokens: [
        CosmosFeeToken(
            averageGasPrice: BigRational.parseDecimal("0.025"),
            highGasPrice: BigRational.parseDecimal("0.03"),
            lowGasPrice: BigRational.parseDecimal("0.01"),
            token: Token(
                name: "ICS Provider Testnet",
                symbol: "tATOM",
                market: const CoingeckoCoin(
                    apiId: "cosmos", coinName: "cosmos-hub"),
                decimal: 6,
                assetLogo: APPConst.atom),
            denom: 'uatom')
      ],
      token: Token(
          name: "ICS Provider Testnet",
          symbol: "tATOM",
          market: const CoingeckoCoin(apiId: "cosmos", coinName: "cosmos-hub"),
          decimal: 6,
          assetLogo: APPConst.atom),
      providers: [],
      keysAlgs: [
        CosmosKeysAlgs.secp256k1,
      ]);
  static final CosmosNetworkParams cosmos = CosmosNetworkParams(
      networkType: CosmosNetworkTypes.main,
      chainType: ChainType.mainnet,
      hrp: CosmosAddrConst.accHRP,
      chainRegisteryName: "cosmoshub",
      chainId: "cosmoshub-4",
      denom: "uatom",
      feeTokens: [
        CosmosFeeToken(
            averageGasPrice: BigRational.parseDecimal("0.025"),
            highGasPrice: BigRational.parseDecimal("0.03"),
            lowGasPrice: BigRational.parseDecimal("0.01"),
            token: Token(
              name: "Cosmos hub",
              symbol: "ATOM",
              market:
                  const CoingeckoCoin(apiId: "cosmos", coinName: "cosmos-hub"),
              decimal: 6,
              assetLogo: APPConst.atom,
            ),
            denom: 'uatom')
      ],
      token: Token(
        name: "Cosmos hub",
        symbol: "ATOM",
        market: const CoingeckoCoin(apiId: "cosmos", coinName: "cosmos-hub"),
        decimal: 6,
        assetLogo: APPConst.atom,
      ),
      providers: [],
      keysAlgs: [
        CosmosKeysAlgs.secp256k1,
      ]);
  static final CosmosNetworkParams maya = CosmosNetworkParams(
      chainType: ChainType.mainnet,
      hrp: CosmosAddrConst.mayaProtocol,
      chainRegisteryName: "mayachain",
      denom: "cacao",
      feeTokens: [
        CosmosFeeToken(
            averageGasPrice: BigRational.from(2000000000),
            token: Token(
              name: "Maya Protocol",
              symbol: "Cacao",
              market: const CoingeckoCoin(
                  apiId: "cacao", coinName: "maya-protocol"),
              decimal: 10,
              assetLogo: APPConst.cacao,
            ),
            denom: 'cacao')
      ],
      // coins: [const CosmosFeeToken(decimal: 10, denom: 'cacao')],
      networkType: CosmosNetworkTypes.thorAndForked,
      token: Token(
        name: "Maya Protocol",
        symbol: "Cacao",
        market: const CoingeckoCoin(apiId: "cacao", coinName: "maya-protocol"),
        decimal: 10,
        assetLogo: APPConst.cacao,
      ),
      providers: [],
      chainId: "mayachain-mainnet-v1",
      networkConstantUri: "https://mayanode.mayachain.info/mayachain/constants",
      keysAlgs: [
        CosmosKeysAlgs.secp256k1,
      ]);
  static final CosmosNetworkParams thorchain = CosmosNetworkParams(
      chainType: ChainType.mainnet,
      hrp: CosmosAddrConst.thor,
      chainRegisteryName: "thorchain",
      denom: "rune",
      feeTokens: [
        CosmosFeeToken(
            averageGasPrice: BigRational.from(2000000),
            token: Token(
                name: "THORChain",
                symbol: "Rune",
                market: const CoingeckoCoin(
                    apiId: "thorchain", coinName: "thorchain"),
                decimal: 8,
                assetLogo: APPConst.thor),
            denom: 'rune')
      ],
      bip32CoinType: 931,
      networkType: CosmosNetworkTypes.thorAndForked,
      token: Token(
          name: "THORChain",
          symbol: "Rune",
          market:
              const CoingeckoCoin(apiId: "thorchain", coinName: "thorchain"),
          decimal: 8,
          assetLogo: APPConst.thor),
      providers: [],
      chainId: "thorchain-1",
      networkConstantUri: "https://thornode.ninerealms.com/thorchain/constants",
      keysAlgs: [CosmosKeysAlgs.secp256k1]);
  static final CosmosNetworkParams kujiraTestnet = CosmosNetworkParams(
      chainType: ChainType.testnet,
      hrp: CosmosAddrConst.kujira,
      chainRegisteryName: "kujiratestnet",
      denom: "ukuji",
      feeTokens: [
        CosmosFeeToken(
            averageGasPrice: BigRational.parseDecimal("0.0051"),
            highGasPrice: BigRational.parseDecimal("0.00681"),
            lowGasPrice: BigRational.parseDecimal("0.0034"),
            token: Token(
                name: "Kujira Testnet",
                symbol: "tKuji",
                market:
                    const CoingeckoCoin(apiId: "kujira", coinName: "kujira"),
                decimal: 6,
                assetLogo: APPConst.kujira),
            denom: 'ukuji')
      ],
      networkType: CosmosNetworkTypes.forked,
      token: Token(
          name: "Kujira Testnet",
          symbol: "tKuji",
          market: const CoingeckoCoin(apiId: "kujira", coinName: "kujira"),
          decimal: 6,
          assetLogo: APPConst.kujira),
      providers: [],
      chainId: "harpoon-4",
      keysAlgs: [
        CosmosKeysAlgs.secp256k1,
      ]);
  static final CosmosNetworkParams kujira = CosmosNetworkParams(
      chainType: ChainType.mainnet,
      hrp: CosmosAddrConst.kujira,
      denom: "ukuji",
      chainRegisteryName: "kujira",
      feeTokens: [
        CosmosFeeToken(
            averageGasPrice: BigRational.parseDecimal("0.0051"),
            highGasPrice: BigRational.parseDecimal("0.00681"),
            lowGasPrice: BigRational.parseDecimal("0.0034"),
            token: Token(
                name: "Kujira",
                symbol: "Kuji",
                market:
                    const CoingeckoCoin(apiId: "kujira", coinName: "kujira"),
                decimal: 6,
                assetLogo: APPConst.kujira),
            denom: 'ukuji')
      ],
      networkType: CosmosNetworkTypes.forked,
      token: Token(
          name: "Kujira",
          symbol: "Kuji",
          market: const CoingeckoCoin(apiId: "kujira", coinName: "kujira"),
          decimal: 6,
          assetLogo: APPConst.kujira),
      providers: [],
      chainId: "kaiyo-1",
      keysAlgs: [
        CosmosKeysAlgs.secp256k1,
      ]);

  static final CosmosNetworkParams osmosisTestnet = CosmosNetworkParams(
      networkType: CosmosNetworkTypes.main,
      chainType: ChainType.testnet,
      hrp: CosmosConst.osmoHrp,
      chainRegisteryName: "osmosistestnet",
      feeTokens: [
        CosmosFeeToken(
            averageGasPrice: BigRational.parseDecimal("0.025"),
            highGasPrice: BigRational.parseDecimal("0.04"),
            lowGasPrice: BigRational.parseDecimal("0.0025"),
            token: Token(
              name: "Osmo testnet",
              symbol: "tOsmo",
              decimal: 6,
              market:
                  const CoingeckoCoin(apiId: "osmosis", coinName: "osmosis"),
              assetLogo: APPConst.osmo,
            ),
            denom: 'uosmo')
      ],
      denom: "uosmo",
      token: Token(
        name: "Osmo testnet",
        symbol: "tOsmo",
        decimal: 6,
        market: const CoingeckoCoin(apiId: "osmosis", coinName: "osmosis"),
        assetLogo: APPConst.osmo,
      ),
      providers: [],
      chainId: "osmo-test-5",
      keysAlgs: [CosmosKeysAlgs.secp256k1]);
  static final CosmosNetworkParams osmosis = CosmosNetworkParams(
      networkType: CosmosNetworkTypes.main,
      chainRegisteryName: "osmosis",
      chainType: ChainType.mainnet,
      hrp: CosmosConst.osmoHrp,
      denom: "uosmo",
      feeTokens: [
        CosmosFeeToken(
            averageGasPrice: BigRational.parseDecimal("0.025"),
            highGasPrice: BigRational.parseDecimal("0.04"),
            lowGasPrice: BigRational.parseDecimal("0.0025"),
            token: Token(
              name: "Osmosis",
              symbol: "Osmo",
              decimal: 6,
              market:
                  const CoingeckoCoin(apiId: "osmosis", coinName: "osmosis"),
              assetLogo: APPConst.osmo,
            ),
            denom: 'uosmo')
      ],
      token: Token(
        name: "Osmosis",
        symbol: "Osmo",
        decimal: 6,
        market: const CoingeckoCoin(apiId: "osmosis", coinName: "osmosis"),
        assetLogo: APPConst.osmo,
      ),
      providers: [],
      chainId: "osmosis-1",
      keysAlgs: [
        CosmosKeysAlgs.secp256k1,
      ]);
  static final TonNetworkParams tonTestnet = TonNetworkParams(
      chainType: ChainType.testnet,
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
      chainType: ChainType.mainnet,
      workchain: 0,
      token: Token(
          name: "TonCoin",
          symbol: "Ton",
          market: const CoingeckoCoin(
              apiId: "the-open-network", coinName: "toncoin"),
          decimal: 9,
          assetLogo: APPConst.ton),
      providers: []);
  static final SubstrateNetworkParams westend = SubstrateNetworkParams(
      chainType: ChainType.testnet,
      ss58Format: SS58Const.genericSubstrate,
      token:
          Token(name: "Westend", symbol: "WND", decimal: 12, assetLogo: null),
      providers: [],
      substrateChainType: SubstrateChainType.substrate,
      specVersion: 1017001);
  static final SubstrateNetworkParams westendAssetHub = SubstrateNetworkParams(
      chainType: ChainType.testnet,
      ss58Format: SS58Const.genericSubstrate,
      token: Token(
          name: "Westend Asset Hub",
          symbol: "WND",
          decimal: 12,
          assetLogo: null),
      providers: [],
      substrateChainType: SubstrateChainType.substrate,
      specVersion: 1017004);
  static final SubstrateNetworkParams westendBridgeHub = SubstrateNetworkParams(
      chainType: ChainType.testnet,
      ss58Format: SS58Const.genericSubstrate,
      token: Token(
          name: "Westend Bridge Hub",
          symbol: "WND",
          decimal: 12,
          assetLogo: null),
      providers: [],
      substrateChainType: SubstrateChainType.substrate,
      specVersion: 1017001);
  static final SubstrateNetworkParams polkadot = SubstrateNetworkParams(
      chainType: ChainType.mainnet,
      ss58Format: SS58Const.polkadot,
      token: Token(
        name: "Polkadot",
        market: const CoingeckoCoin(
            apiId: "polkadot", coinName: "polkadot", symbol: "DOT"),
        symbol: "DOT",
        decimal: 10,
        assetLogo: APPConst.polkadot,
      ),
      providers: [],
      substrateChainType: SubstrateChainType.substrate,
      specVersion: 1003004);
  static final SubstrateNetworkParams polkadotAssetHub = SubstrateNetworkParams(
      chainType: ChainType.mainnet,
      ss58Format: SS58Const.polkadot,
      token: Token(
          name: "Polkadot Asset Hub",
          market: const CoingeckoCoin(
              apiId: "polkadot", coinName: "polkadot", symbol: "DOT"),
          symbol: "DOT",
          decimal: 10,
          assetLogo: APPConst.polkadot),
      providers: [],
      substrateChainType: SubstrateChainType.substrate,
      specVersion: 1003004);
  static final SubstrateNetworkParams polkadotBridgeHub =
      SubstrateNetworkParams(
          chainType: ChainType.mainnet,
          ss58Format: SS58Const.polkadot,
          token: Token(
              name: "polkadot Bridge Hub",
              market: const CoingeckoCoin(
                  apiId: "polkadot", coinName: "polkadot", symbol: "DOT"),
              symbol: "DOT",
              decimal: 10,
              assetLogo: APPConst.polkadot),
          providers: [],
          substrateChainType: SubstrateChainType.substrate,
          specVersion: 1003003);
  static final SubstrateNetworkParams kusama = SubstrateNetworkParams(
      chainType: ChainType.mainnet,
      ss58Format: SS58Const.kusama,
      token: Token(
          name: "Kusama",
          symbol: "KSM",
          decimal: 12,
          market: const CoingeckoCoin(
              apiId: "kusama", coinName: "kusama", symbol: "KSM"),
          assetLogo: APPConst.kusama),
      providers: [],
      substrateChainType: SubstrateChainType.substrate,
      specVersion: 1003003);
  static final SubstrateNetworkParams kusamaAssetHub = SubstrateNetworkParams(
      chainType: ChainType.mainnet,
      ss58Format: SS58Const.kusama,
      token: Token(
          name: "Kusama Asset Hub",
          symbol: "KSM",
          decimal: 12,
          market: const CoingeckoCoin(
              apiId: "kusama", coinName: "kusama", symbol: "KSM"),
          assetLogo: APPConst.kusama),
      providers: [],
      substrateChainType: SubstrateChainType.substrate,
      specVersion: 1003004);
  static final SubstrateNetworkParams kusamaBridgeHub = SubstrateNetworkParams(
      chainType: ChainType.mainnet,
      ss58Format: SS58Const.kusama,
      token: Token(
          name: "Kusama Bridge Hub",
          symbol: "KSM",
          decimal: 12,
          market: const CoingeckoCoin(
              apiId: "kusama", coinName: "kusama", symbol: "KSM"),
          assetLogo: APPConst.kusama),
      providers: [],
      substrateChainType: SubstrateChainType.substrate,
      specVersion: 1003003);

  static final SubstrateNetworkParams moonBase = SubstrateNetworkParams(
      chainType: ChainType.testnet,
      ss58Format: SS58Const.moonbeam,
      token: Token(
          name: "Moonbase Alpha",
          market: const CoingeckoCoin(
              apiId: "moonbeam", coinName: "moonbeam", symbol: "GLMR"),
          symbol: "GLMR",
          decimal: 18,
          assetLogo: APPConst.moonbeam),
      providers: [],
      substrateChainType: SubstrateChainType.ethereum,
      keyAlgorithms: [SubstrateKeyAlgorithm.ethereum],
      specVersion: 3400);
  static final SubstrateNetworkParams moonbeam = SubstrateNetworkParams(
      chainType: ChainType.mainnet,
      ss58Format: SS58Const.moonbeam,
      token: Token(
          name: "Moonbeam",
          market: const CoingeckoCoin(
              apiId: "moonbeam", coinName: "moonbeam", symbol: "GLMR"),
          symbol: "GLMR",
          decimal: 18,
          assetLogo: APPConst.moonbeam),
      providers: [],
      substrateChainType: SubstrateChainType.ethereum,
      keyAlgorithms: [SubstrateKeyAlgorithm.ethereum],
      specVersion: 3300);
  static final SubstrateNetworkParams moonriver = SubstrateNetworkParams(
      chainType: ChainType.mainnet,
      ss58Format: SS58Const.moonriver,
      token: Token(
          name: "Moonriver",
          market: const CoingeckoCoin(
              apiId: "moonriver", coinName: "moonriver", symbol: "MOVR"),
          symbol: "MOVR",
          decimal: 18,
          assetLogo: APPConst.moonriver),
      providers: [],
      substrateChainType: SubstrateChainType.ethereum,
      keyAlgorithms: [SubstrateKeyAlgorithm.ethereum],
      specVersion: 3400);
  static final SubstrateNetworkParams astar = SubstrateNetworkParams(
      chainType: ChainType.mainnet,
      ss58Format: SS58Const.astar,
      token: Token(
          name: "Astar",
          market: const CoingeckoCoin(
              apiId: "astar", coinName: "astar", symbol: "ASTR"),
          symbol: "ASTR",
          decimal: 18,
          assetLogo: APPConst.astar),
      providers: [],
      substrateChainType: SubstrateChainType.substrate,
      specVersion: 1200);

  static final SubstrateNetworkParams centrifuge = SubstrateNetworkParams(
      chainType: ChainType.mainnet,
      ss58Format: SS58Const.centrifuge,
      token: Token(
          name: "Centrifuge",
          market: const CoingeckoCoin(
              apiId: "centrifuge", coinName: "centrifuge", symbol: "CFG"),
          symbol: "CFG",
          decimal: 18,
          assetLogo: APPConst.centrifuge),
      providers: [],
      substrateChainType: SubstrateChainType.substrate,
      specVersion: 1400);

  static final SubstrateNetworkParams acala = SubstrateNetworkParams(
      chainType: ChainType.mainnet,
      ss58Format: SS58Const.acala,
      token: Token(
          name: "Acala",
          market: const CoingeckoCoin(
              apiId: "acala", coinName: "acala", symbol: "ACA"),
          symbol: "ACA",
          decimal: 12,
          assetLogo: APPConst.acala),
      providers: [],
      substrateChainType: SubstrateChainType.substrate,
      specVersion: 2270);

  static final StellarNetworkParams stellarMainnet = StellarNetworkParams(
      token: Token(
          name: "Stellar",
          symbol: "XLM",
          decimal: StellarConst.decimal,
          market: const CoingeckoCoin(
              apiId: "stellar", coinName: "stellar", symbol: "XLM"),
          assetLogo: APPConst.stellar),
      providers: const [],
      chainType: ChainType.mainnet,
      stellarChainType: StellarChainType.mainnet);
  static final StellarNetworkParams stellarTestnet = StellarNetworkParams(
      token: Token(
          name: "Stellar testnet",
          symbol: "tXLM",
          decimal: StellarConst.decimal,
          market: const CoingeckoCoin(
              apiId: "stellar", coinName: "stellar", symbol: "XLM"),
          assetLogo: APPConst.stellar),
      providers: const [],
      chainType: ChainType.testnet,
      stellarChainType: StellarChainType.testnet);

  static final MoneroNetworkParams moneroTestnet = MoneroNetworkParams(
      token: Token(
          name: "Monero stagenet",
          symbol: "tXMR",
          decimal: MoneroConst.decimal,
          market: const CoingeckoCoin(
              apiId: "monero", coinName: "monero", symbol: "XMR"),
          assetLogo: APPConst.monero),
      providers: const [],
      chainType: ChainType.testnet,
      network: MoneroNetwork.stagenet,
      rctHeight: 96211);
  static final MoneroNetworkParams monero = MoneroNetworkParams(
      token: Token(
          name: "Monero",
          symbol: "XMR",
          decimal: MoneroConst.decimal,
          market: const CoingeckoCoin(
              apiId: "monero", coinName: "monero", symbol: "XMR"),
          assetLogo: APPConst.monero),
      providers: const [],
      chainType: ChainType.mainnet,
      network: MoneroNetwork.mainnet,
      rctHeight: 1220517);
  static final AptosNetworkParams aptos = AptosNetworkParams(
      token: Token(
          name: "Aptos",
          symbol: "APT",
          decimal: AptosConst.decimal,
          market: const CoingeckoCoin(
              apiId: "aptos", coinName: "aptos", symbol: "APT"),
          assetLogo: APPConst.aptos),
      providers: const [],
      chainType: ChainType.mainnet,
      aptosChainType: AptosChainType.mainnet);
  static final AptosNetworkParams aptosTestnet = AptosNetworkParams(
      token: Token(
          name: "Aptos Testnet",
          symbol: "tAPT",
          decimal: AptosConst.decimal,
          market: const CoingeckoCoin(
              apiId: "aptos", coinName: "aptos", symbol: "APT"),
          assetLogo: APPConst.aptos),
      providers: const [],
      chainType: ChainType.testnet,
      aptosChainType: AptosChainType.testnet,
      bip32CoinType: 1);
  static final AptosNetworkParams aptosDevnet = AptosNetworkParams(
      token: Token(
          name: "Aptos Devnet",
          symbol: "tAPT",
          decimal: AptosConst.decimal,
          market: const CoingeckoCoin(
              apiId: "aptos", coinName: "aptos", symbol: "APT"),
          assetLogo: APPConst.aptos),
      providers: const [],
      chainType: ChainType.testnet,
      aptosChainType: AptosChainType.devnet,
      bip32CoinType: 1);

  static final SuiNetworkParams sui = SuiNetworkParams(
      token: Token(
          name: "Sui",
          symbol: "SUI",
          decimal: SUIConst.decimal,
          market:
              const CoingeckoCoin(apiId: "sui", coinName: "sui", symbol: "SUI"),
          assetLogo: APPConst.sui),
      providers: const [],
      chainType: ChainType.mainnet,
      identifier: SUIConst.mainnetIdentifier,
      suiChain: SuiChainType.mainnet);
  static final SuiNetworkParams suiDevnet = SuiNetworkParams(
      token: Token(
        name: "Sui Devnet",
        symbol: "tSUI",
        decimal: SUIConst.decimal,
        market:
            const CoingeckoCoin(apiId: "sui", coinName: "sui", symbol: "SUI"),
        assetLogo: APPConst.sui,
      ),
      providers: const [],
      chainType: ChainType.testnet,
      identifier: SUIConst.devnetIdentifier,
      bip32CoinType: 1,
      suiChain: SuiChainType.devnet);

  static final SuiNetworkParams suiTestnet = SuiNetworkParams(
      token: Token(
          name: "Sui Testnet",
          symbol: "tSUI",
          decimal: SUIConst.decimal,
          market:
              const CoingeckoCoin(apiId: "sui", coinName: "sui", symbol: "SUI"),
          assetLogo: APPConst.sui),
      providers: const [],
      chainType: ChainType.testnet,
      identifier: SUIConst.testnetIdentifier,
      bip32CoinType: 1,
      suiChain: SuiChainType.testnet);
  static const Map<int, String> defaultChainGenesis = {
    0: "000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f",
    1: "000000000933ea01ad0ee984209779baaec3ced90fa3f408719526f8d77f4943",
    5: "00000000da84f2bafbbc53dee25a72ae507ff4914b867c565be350b0da8bf043",
    2: "12a765e31ffd4059bada1e25190f6e98c99d9714d334efa41a195a7e7e04bfe2",
    7: "4966625a4b2851d9fdee139e56211a0d88575f59ed816ff5e6a63deb4e3e29a0",
    3: "1a91e3dace36e2be3bf030a65679fe821aa1d6ef92e7c9902eb318182c355691",
    8: "bb0a78264637406b6360aad926284d544d7049f45189db5664f3c4d07350559e",
    9: "000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f",
    4: "00000ffd590b1485b3caadc19b22e6379c733355108f107a430458cdf3407ab6",
    10: "000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f",
    11: "000000001dd410c49a788668ce26751718cc797474d3152a5fc073dd44fd9f7b",
    12: "37981c0c48b8d48965376c8a42ece9a0838daadb93ff975cb091f57f8c2a5faa",
    400: "91b171bb158e2d3848fa23a9f1c25182fb8e20313b2c1eb49219da7a70ce90c3",
    401: "68d56f15f85d3136970ec16946040bc1752654e906147f7e43e9d539d7c3de2f",
    402: "dcf691b5a3fbe24adc99ddc959c0561b973e329b1aef4c4b22e7bb2ddecb4464",
    450: "b0a8d493285c2df73290dfb7e61f870f17b41801197a149ca93654499ea3dafe",
    451: "e143f23803ac50e8f6f8e62695d1ce9e4e1d68aa36c1cd2cfd15340213f3423e",
    452: "67f9723393ef76214df0118c34bbbd3dbebc8ed46a10973a8c969d48fe7598c9",
    453: "48239ef607d7928874027a43a67689209727dfb3d3dc5e5b03a39bdc2eda771a",
    454: "00dcb981df86429de8bbacf9803401f09485366c44efbf53af9ecfab03adc7e5",
    455: "0441383e31d1266a92b4cb2ddd4c2e3661ac476996db7e5844c52433b81fe782",
    461: "91bc6e169807aaa54802737e1c504b2577d4fafedd5a02c10293b1cd60e39527",
    462: "401a1f9dca3da46f5c4091016c8a2f26dcea05865116b286f60f668207d1474b",
    460: "fe58ea77779b7abda7da4ec526d14db9b1e9cd40a217c34892af80a9b332b76d",
    463: "9eb76c5184c4ab8679d2d5d819fdf90b9c001403e9e17da2e14b6d8aec4029c6",
    464: "b3db41421702df9a7fcac62b53ffeac85f7853cc4e689e0b93aeb3db18c09d82",
    465: "fc41b9bd8ef8fe53d58c7ea67c794c7ec9a73daf05e6d54b14ff6342c99ba64c",
    1001: "00000000000000001ebf88508a03865c71d452e25f4d51194196a1d22b6653dc",
    1002: "0000000000000000de1aa88295e1fcf982742f773e0419c5a9c134c994a9059e",
    1003: "0000000000000000d698d4192c56cb6be724a558448e2684802de4d6cd8690dc",
    700: "418015bb9ae982a1975da7d79277c2705727a56894ba0fb246adaabb1f4632e3",
    701: "76ee3cc98646292206cd3e86f74d88b4dcc1d937088645e9b0cbca84b7ce74eb",
    33: SolanaConst.mainnetGenesis,
    34: SolanaConst.testnetGenesis,
    35: SolanaConst.devnetGenesis,
  };

  static const Map<int, String> addressExplorer = {
    0: "https://live.blockcypher.com/btc/address/#address/",
    1: "https://live.blockcypher.com/btc-testnet/address/#address/",
    5: "https://mempool.space/testnet4/address/#address/",
    2: "https://live.blockcypher.com/ltc/address/#address/",
    7: "https://live.blockcypher.com/ltc/address/#address/",
    3: "https://live.blockcypher.com/doge/address/#address/",
    8: "https://live.blockcypher.com/doge/address/#address/",
    9: "https://whatsonchain.com/address/#address",
    4: "https://live.blockcypher.com/dash/address/#address/",
    10: "https://bch.loping.net/address/#address",
    11: "https://cbch.loping.net/address/#address",
    12: "https://pepeexplorer.com/address/#address",
    30: "https://livenet.xrpl.org/accounts/#address",
    31: "https://testnet.xrpl.org/accounts/#address",
    32: "https://devnet.xrpl.org/accounts/#address",
    33: "https://explorer.solana.com/address/#address",
    34: "https://explorer.solana.com/address/#address?cluster=testnet",
    35: "https://explorer.solana.com/address/#address?cluster=devnet",
    50: "https://cardanoscan.io/address/#address",
    51: "https://preprod.cardanoscan.io/address/#address",
    100: "https://etherscan.io/address/#address",
    101: "https://sepolia.etherscan.io/address/#address",
    102: "https://polygonscan.com/address/#address",
    103: "https://mumbai.polygonscan.com/address/#address",
    104: "https://bscscan.com/address/#address",
    105: "https://testnet.bscscan.com/address/#address",
    106: "https://subnets.avax.network/c-chain/address/#address",
    107: "https://arbitrum.blockscout.com/address/#address",
    108: "https://base.blockscout.com/address/#address",
    109: "https://optimistic.etherscan.io/address/#address",
    200: "https://ping.pub/cosmos/account/#address",
    201: "https://explorer.polypore.xyz/theta-testnet-001/account/#address",
    202: "https://www.mayascan.org/address/#address",
    203: "https://www.thorscanner.org/address/#address",
    204: "https://finder.kujira.network/harpoon-4/address/#address",
    205: "https://finder.kujira.network/kaiyo-1/address/#address",
    206: "https://celatone.osmosis.zone/osmo-test-5/accounts/#address",
    207: "https://celatone.osmosis.zone/osmosis-1/accounts/#address",
    300: "https://tonscan.org/address/#address",
    301: "https://testnet.tonscan.org/address/#address",
    400: "https://polkadot.subscan.io/account/#address",
    401: "https://assethub-polkadot.subscan.io/account/#address",
    402: "https://bridgehub-polkadot.subscan.io/account/#address",
    450: "https://kusama.subscan.io/account/#address",
    451: "https://westend.subscan.io/account/#address",
    452: "https://assethub-westend.subscan.io/account/#address",
    453: "https://assethub-kusama.subscan.io/account/#address",
    454: "https://bridgehub-kusama.subscan.io/account/#address",
    455: "https://bridgehub-westend.subscan.io/account/#address",
    461: "https://moonbase.subscan.io/account/#address",
    462: "https://moonriver.subscan.io/account/#address",
    463: "https://astar.subscan.io/account/#address",
    464: "https://centrifuge.subscan.io/account/#address",
    465: "https://acala.subscan.io/account/#address",
    460: "https://moonbeam.subscan.io/account/#address",
    600: "https://stellar.expert/explorer/public/account/#address",
    601: "https://stellar.expert/explorer/testnet/account/#address",
    800: "https://suiscan.xyz/mainnet/account/#address",
    801: "https://suiscan.xyz/devnet/account/#address",
    802: "https://suiscan.xyz/testnet/account/#address",
    810: "https://explorer.aptoslabs.com/account/#address?network=mainnet",
    811: "https://explorer.aptoslabs.com/account/#address?network=testnet",
    812: "https://explorer.aptoslabs.com/account/#address?network=devnet",
    1001: "https://tronscan.org/#/address/#address",
    1002: "https://shasta.tronscan.org/#/address/#address",
    1003: "https://nile.tronscan.org/#/address/#address"
  };

  static const Map<int, String> txExplorer = {
    0: "https://live.blockcypher.com/btc/tx/#txid/",
    1: "https://live.blockcypher.com/btc-testnet/tx/#txid/",
    5: "https://mempool.space/testnet4/tx/#txid/",
    2: "https://live.blockcypher.com/ltc/tx/#txid/",
    7: "https://live.blockcypher.com/ltc/tx/#txid/",
    3: "https://live.blockcypher.com/doge/tx/#txid/",
    8: "https://live.blockcypher.com/doge/tx/#txid/",
    9: "https://whatsonchain.com/tx/#txid",
    4: "https://live.blockcypher.com/dash/tx/#txid/",
    10: "https://bch.loping.net/tx/#txid",
    11: "https://cbch.loping.net/tx/#txid",
    12: "https://pepeexplorer.com/tx/#txid",
    30: "https://livenet.xrpl.org/transactions/#txid",
    31: "https://testnet.xrpl.org/transactions/#txid",
    32: "https://devnet.xrpl.org/transactions/#txid",
    33: "https://explorer.solana.com/tx/#txid",
    34: "https://explorer.solana.com/tx/#txid?cluster=testnet",
    35: "https://explorer.solana.com/tx/#txid?cluster=devnet",
    50: "https://cardanoscan.io/transaction/#txid",
    51: "https://preprod.cardanoscan.io/transaction/#txid",
    100: "https://etherscan.io/tx/#txid",
    101: "https://sepolia.etherscan.io/tx/#txid",
    102: "https://polygonscan.com/tx/#txid",
    103: "https://mumbai.polygonscan.com/tx/#txid",
    104: "https://bscscan.com/tx/#txid",
    105: "https://testnet.bscscan.com/tx/#txid",
    106: "https://subnets.avax.network/c-chain/tx/#txid",
    107: "https://arbitrum.blockscout.com/tx/#txid",
    108: "https://base.blockscout.com/tx/#txid",
    109: "https://optimistic.etherscan.io/tx/#txid",
    200: "https://ping.pub/cosmos/tx/#txid",
    201: "https://explorer.polypore.xyz/theta-testnet-001/tx/#txid",
    202: "https://www.mayascan.org/tx/#txid",
    203: "https://www.thorscanner.org/tx/#txid",
    204: "https://finder.kujira.network/harpoon-4/tx/#txid",
    205: "https://finder.kujira.network/kaiyo-1/tx/#txid",
    206: "https://celatone.osmosis.zone/osmo-test-5/txs/#txid",
    207: "https://celatone.osmosis.zone/osmosis-1/txs/#txid",
    300: "https://tonscan.org/tx/#txid",
    301: "https://testnet.tonscan.org/tx/#txid",
    400: "https://polkadot.subscan.io/extrinsic/#txid",
    401: "https://assethub-polkadot.subscan.io/extrinsic/#txid",
    402: "https://bridgehub-polkadot.subscan.io/extrinsic/#txid",
    450: "https://kusama.subscan.io/extrinsic/#txid",
    451: "https://westend.subscan.io/extrinsic/#txid",
    452: "https://assethub-westend.subscan.io/extrinsic/#txid",
    453: "https://assethub-kusama.subscan.io/extrinsic/#txid",
    454: "https://bridgehub-kusama.subscan.io/extrinsic/#txid",
    455: "https://bridgehub-westend.subscan.io/extrinsic/#txid",
    460: "https://moonbeam.subscan.io/extrinsic/#txid",
    462: "https://moonriver.subscan.io/extrinsic/#txid",
    461: "https://moonbase.subscan.io/extrinsic/#txid",
    463: "https://astar.subscan.io/extrinsic/#txid",
    464: "https://centrifuge.subscan.io/extrinsic/#txid",
    465: "https://acala.subscan.io/extrinsic/#txid",
    600: "https://stellar.expert/explorer/public/tx/#txid",
    601: "https://stellar.expert/explorer/testnet/tx/#txid",
    700: "https://xmrchain.net/tx/#txid",
    701: "https://stagenet.xmrchain.net/tx/#txid",
    800: "https://suiscan.xyz/mainnet/tx/#txid",
    801: "https://suiscan.xyz/devnet/tx/#txid",
    802: "https://suiscan.xyz/testnet/tx/#txid",
    811: "https://explorer.aptoslabs.com/txn/#txid?network=testnet",
    810: "https://explorer.aptoslabs.com/txn/#txid?network=mainnet",
    812: "https://explorer.aptoslabs.com/txn/#txid?network=devnet",
    1001: "https://tronscan.org/#/transaction/#txid",
    1002: "https://shasta.tronscan.org/#/transaction/#txid",
    1003: "https://nile.tronscan.org/#/transaction/#txid"
  };
}

class ChainConst {
  // static int suiMainnetId = 800;
  // static int aptosMainnetId = 810;
  // static int ethereumMainnetId = 100;
  // static int solanaMainnetId = 33;
  // static int stellarMainnetId = 600;
  // static int polkadotMainnetId = 400;
  // static int tonMainnetId = 300;
  // static int tronMainnetId = 1001;
  // static int cosmosHubMainnetId = 200;
  // static int bitcoinMainnetId = 0;

  static const int importedNetworkStartId = 2000;
  static const int maxAccountTokens = 1000;
  static final Map<int, WalletNetwork> defaultCoins =
      Map<int, WalletNetwork>.unmodifiable({
    0: WalletBitcoinNetwork(0, _DefaultAppCoins.bitcoinMainnet),
    1: WalletBitcoinNetwork(1, _DefaultAppCoins.bitcoinTestnet),
    5: WalletBitcoinNetwork(5, _DefaultAppCoins.bitcoinTestnet4),
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
    35: WalletSolanaNetwork(35, _DefaultAppCoins.solanaDevnet),

    50: WalletCardanoNetwork(50, _DefaultAppCoins.cardano),
    51: WalletCardanoNetwork(51, _DefaultAppCoins.cardanoPreprod),

    100: WalletEthereumNetwork(100, _DefaultAppCoins.ethreumMainnet),
    101: WalletEthereumNetwork(101, _DefaultAppCoins.ethreumTestnet),
    102: WalletEthereumNetwork(102, _DefaultAppCoins.polygon),
    103: WalletEthereumNetwork(103, _DefaultAppCoins.polygonTestnet),
    104: WalletEthereumNetwork(104, _DefaultAppCoins.bnb),
    105: WalletEthereumNetwork(105, _DefaultAppCoins.bnbTestnet),
    106: WalletEthereumNetwork(106, _DefaultAppCoins.avalanche),
    107: WalletEthereumNetwork(107, _DefaultAppCoins.arbitrum),
    108: WalletEthereumNetwork(108, _DefaultAppCoins.base),
    109: WalletEthereumNetwork(109, _DefaultAppCoins.optimism),
    200: WalletCosmosNetwork(200, _DefaultAppCoins.cosmos),
    201: WalletCosmosNetwork(201, _DefaultAppCoins.cosmosTestnet),
    202: WalletCosmosNetwork(202, _DefaultAppCoins.maya),
    203: WalletCosmosNetwork(203, _DefaultAppCoins.thorchain),
    204: WalletCosmosNetwork(204, _DefaultAppCoins.kujiraTestnet),
    205: WalletCosmosNetwork(205, _DefaultAppCoins.kujira),
    206: WalletCosmosNetwork(206, _DefaultAppCoins.osmosisTestnet),
    207: WalletCosmosNetwork(207, _DefaultAppCoins.osmosis),
    300: WalletTonNetwork(300, _DefaultAppCoins.tonMainnet),
    301: WalletTonNetwork(301, _DefaultAppCoins.tonTestnet),
    400: WalletSubstrateNetwork(400, _DefaultAppCoins.polkadot),
    401: WalletSubstrateNetwork(401, _DefaultAppCoins.polkadotAssetHub),
    402: WalletSubstrateNetwork(402, _DefaultAppCoins.polkadotBridgeHub),
    450: WalletSubstrateNetwork(450, _DefaultAppCoins.kusama),
    451: WalletSubstrateNetwork(451, _DefaultAppCoins.westend),
    452: WalletSubstrateNetwork(452, _DefaultAppCoins.westendAssetHub),
    453: WalletSubstrateNetwork(453, _DefaultAppCoins.kusamaAssetHub),
    454: WalletSubstrateNetwork(454, _DefaultAppCoins.kusamaBridgeHub),
    455: WalletSubstrateNetwork(455, _DefaultAppCoins.westendBridgeHub),
    460: WalletSubstrateNetwork(460, _DefaultAppCoins.moonbeam),
    461: WalletSubstrateNetwork(461, _DefaultAppCoins.moonBase),
    462: WalletSubstrateNetwork(462, _DefaultAppCoins.moonriver),
    463: WalletSubstrateNetwork(463, _DefaultAppCoins.astar),
    464: WalletSubstrateNetwork(464, _DefaultAppCoins.centrifuge),
    465: WalletSubstrateNetwork(465, _DefaultAppCoins.acala),

    ///
    600: WalletStellarNetwork(600, _DefaultAppCoins.stellarMainnet),
    601: WalletStellarNetwork(601, _DefaultAppCoins.stellarTestnet),

    /// monero
    700: WalletMoneroNetwork(700, _DefaultAppCoins.monero),
    701: WalletMoneroNetwork(701, _DefaultAppCoins.moneroTestnet),
    // sui
    800: WalletSuiNetwork(800, _DefaultAppCoins.sui),
    801: WalletSuiNetwork(801, _DefaultAppCoins.suiDevnet),
    802: WalletSuiNetwork(802, _DefaultAppCoins.suiTestnet),

    /// aptos
    810: WalletAptosNetwork(810, _DefaultAppCoins.aptos),
    811: WalletAptosNetwork(811, _DefaultAppCoins.aptosTestnet),
    812: WalletAptosNetwork(812, _DefaultAppCoins.aptosDevnet),

    ///
    TronChainType.mainnet.id:
        WalletTronNetwork(TronChainType.mainnet.id, _DefaultAppCoins.tron),
    TronChainType.shasta.id:
        WalletTronNetwork(TronChainType.shasta.id, _DefaultAppCoins.tronShasta),
    TronChainType.nile.id:
        WalletTronNetwork(TronChainType.nile.id, _DefaultAppCoins.tronNile),
  });

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
    if (network == null) return defaultNetwork;
    return defaultNetwork.copyWith(
      coinParam: defaultNetwork.coinParam.updateParams(
          updateProviders: network.coinParam.providers,
          token: network.coinParam.token,
          addressExplorer: network.coinParam.addressExplorer,
          transactionExplorer: network.coinParam.transactionExplorer),
    );
  }

  static List<String> services(WalletNetwork network) {
    switch (network.type) {
      case NetworkType.xrpl:
      case NetworkType.tron:
      case NetworkType.solana:
      case NetworkType.stellar:
      case NetworkType.cosmos:
      case NetworkType.aptos:
      case NetworkType.sui:
        return ["services", "tokens"];
      case NetworkType.ethereum:
        return ["tokens"];
      case NetworkType.ton:
        return ["services", "jettons"];
      case NetworkType.monero:
        return ["services", "activity"];
      default:
        return ["services"];
    }
  }

  static String getDefaultGenesisBlock(int value) {
    final genesis = _DefaultAppCoins.defaultChainGenesis[value];
    if (genesis == null) {
      throw WalletExceptionConst.networkDoesNotExist;
    }
    return genesis;
  }

  static String? getAddressExplorer(int value) {
    return _DefaultAppCoins.addressExplorer[value];
  }

  static String? getTxExplorer(int value) {
    return _DefaultAppCoins.txExplorer[value];
  }
}
