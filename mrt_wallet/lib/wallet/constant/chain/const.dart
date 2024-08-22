import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/constant/constant.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class _DefaultAppCoins {
  static final BitcoinParams bitcoinCashMainnet = BitcoinParams(
      transactionExplorer: "https://bch.loping.net/tx/#txid",
      addressExplorer: "https://bch.loping.net/address/#address",
      genesis:
          "000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f",
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
      genesis:
          "000000001dd410c49a788668ce26751718cc797474d3152a5fc073dd44fd9f7b",
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
      genesis:
          "000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f",
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
      genesis:
          "000000000933ea01ad0ee984209779baaec3ced90fa3f408719526f8d77f4943",
      token: Token(
          name: "Bitcoin testnet",
          symbol: "tBTC",
          market: const CoingeckoCoin(apiId: "bitcoin", coinName: "bitcoin"),
          decimal: 8,
          assetLogo: APPConst.btc),
      providers: []);
  static final BitcoinParams litecoinMainnet = BitcoinParams(
      genesis:
          "12a765e31ffd4059bada1e25190f6e98c99d9714d334efa41a195a7e7e04bfe2",
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
      genesis:
          "4966625a4b2851d9fdee139e56211a0d88575f59ed816ff5e6a63deb4e3e29a0",
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
      genesis:
          "1a91e3dace36e2be3bf030a65679fe821aa1d6ef92e7c9902eb318182c355691",
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
      genesis:
          "37981c0c48b8d48965376c8a42ece9a0838daadb93ff975cb091f57f8c2a5faa",
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
      genesis:
          "bb0a78264637406b6360aad926284d544d7049f45189db5664f3c4d07350559e",
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
      genesis:
          "000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f",
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
      genesis:
          "00000ffd590b1485b3caadc19b22e6379c733355108f107a430458cdf3407ab6",
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
      genesis:
          "0000000000000000de1aa88295e1fcf982742f773e0419c5a9c134c994a9059e",
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
      genesis:
          "0000000000000000d698d4192c56cb6be724a558448e2684802de4d6cd8690dc",
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
      genesis:
          "00000000000000001ebf88508a03865c71d452e25f4d51194196a1d22b6653dc",
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
      genesis: "5eykt4UsFv8P8NJdTREpY1vzqKqZKvdpKuc147dw2N9d",
      mainnet: true,
      token: Token(
        name: "Solana",
        symbol: "SOL",
        market: const CoingeckoCoin(apiId: "solana", coinName: "solana"),
        decimal: 9,
        assetLogo: APPConst.sol,
      ),
      providers: []);
  static final SolanaNetworkParams solanaTestnet = SolanaNetworkParams(
      transactionExplorer:
          "https://explorer.solana.com/tx/#txid?cluster=testnet",
      addressExplorer:
          "https://explorer.solana.com/address/#address?cluster=testnet",
      genesis: "4uhcVJyU9pJkvQyS88uRDiswHXSCkY3zQawwpjk2NsNY",
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
      bip32CoinType: 931,
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

  static final CosmosNetworkParams osmosisTestnet = CosmosNetworkParams(
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
  static final CosmosNetworkParams osmosis = CosmosNetworkParams(
      transactionExplorer: "https://celatone.osmosis.zone/osmosis-1/txs/#txid",
      addressExplorer:
          "https://celatone.osmosis.zone/osmosis-1/accounts/#address",
      networkType: CosmosNetworkTypes.main,
      mainnet: true,
      hrp: CosmosConst.osmoHrp,
      mainCoin: const CosmosNativeCoin(decimal: 6, denom: 'uosmo'),
      coins: [const CosmosNativeCoin(decimal: 6, denom: 'uosmo')],
      token: Token(
        name: "Osmosis",
        symbol: "Osmo",
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
  static final SubstrateNetworkParams westend = SubstrateNetworkParams(
      transactionExplorer: "https://westend.subscan.io/extrinsic/#txid",
      addressExplorer: "https://westend.subscan.io/account/#address",
      mainnet: false,
      ss58Format: SS58Const.genericSubstrate,
      specVersion: 1014000,
      token:
          Token(name: "Westend", symbol: "WND", decimal: 12, assetLogo: null),
      providers: []);
  static final SubstrateNetworkParams polkadot = SubstrateNetworkParams(
      transactionExplorer: "https://polkadot.subscan.io/extrinsic/#txid",
      addressExplorer: "https://polkadot.subscan.io/account/#address",
      mainnet: true,
      ss58Format: SS58Const.polkadot,
      specVersion: 1002006,
      token: Token(
          name: "Polkadot",
          market: const CoingeckoCoin(
              apiId: "polkadot", coinName: "polkadot", symbol: "DOT"),
          symbol: "DOT",
          decimal: 10,
          assetLogo: APPConst.polkadot),
      providers: []);
  static final SubstrateNetworkParams kusama = SubstrateNetworkParams(
      transactionExplorer: "https://polkadot.subscan.io/extrinsic/#txid",
      addressExplorer: "https://polkadot.subscan.io/account/#address",
      mainnet: true,
      ss58Format: SS58Const.kusama,
      specVersion: 1002006,
      token: Token(
          name: "Kusama",
          symbol: "KSM",
          decimal: 12,
          market: const CoingeckoCoin(
              apiId: "kusama", coinName: "kusama", symbol: "KSM"),
          assetLogo: APPConst.kusama),
      providers: []);
}

class ChainConst {
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
    206: WalletCosmosNetwork(206, _DefaultAppCoins.osmosisTestnet),
    207: WalletCosmosNetwork(207, _DefaultAppCoins.osmosis),
    300: WalletTonNetwork(300, _DefaultAppCoins.tonMainnet),
    301: WalletTonNetwork(301, _DefaultAppCoins.tonTestnet),
    400: WalletPolkadotNetwork(400, _DefaultAppCoins.polkadot),
    450: WalletKusamaNetwork(450, _DefaultAppCoins.kusama),
    451: WalletKusamaNetwork(451, _DefaultAppCoins.westend),
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
    return defaultNetwork.copyWith(
        coinParam: defaultNetwork.coinParam
            .updateProviders(network?.coinParam.providers ?? []),
        value: defaultNetwork.value);
  }
}
