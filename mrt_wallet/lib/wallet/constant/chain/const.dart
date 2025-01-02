import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/bip/bip.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/constant/constant.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:stellar_dart/stellar_dart.dart';

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
  static final BitcoinParams bitcoinTestnet4 = BitcoinParams(
      transactionExplorer: "https://mempool.space/testnet4/tx/#txid/",
      addressExplorer: "https://mempool.space/testnet4/address/#address/",
      transacationNetwork: BitcoinNetwork.testnet,
      genesis:
          "00000000da84f2bafbbc53dee25a72ae507ff4914b867c565be350b0da8bf043",
      token: Token(
          name: "Bitcoin testnet4",
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
      chainType: ChainType.mainnet,
      networkId: 0);
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
      chainType: ChainType.testnet,
      networkId: 1);
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
      chainType: ChainType.testnet,
      networkId: 2);

  static final EthereumNetworkParams ethreumMainnet = EthereumNetworkParams(
      transactionExplorer: "https://etherscan.io/tx/#txid",
      addressExplorer: "https://etherscan.io/address/#address",
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
      transactionExplorer: "https://subnets.avax.network/c-chain/tx/#txid",
      addressExplorer: "https://subnets.avax.network/c-chain/address/#address",
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
      transactionExplorer: "https://arbitrum.blockscout.com/tx/#txid",
      addressExplorer: "https://arbitrum.blockscout.com/address/#address",
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
      transactionExplorer: "https://base.blockscout.com/tx/#txid",
      addressExplorer: "https://base.blockscout.com/address/#address",
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
      transactionExplorer: "https://optimistic.etherscan.io/tx/#txid",
      addressExplorer: "https://optimistic.etherscan.io/address/#address",
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
      transactionExplorer: "https://sepolia.etherscan.io/tx/#txid",
      addressExplorer: "https://sepolia.etherscan.io/address/#address",
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
      transactionExplorer: "https://polygonscan.com/tx/#txid",
      addressExplorer: "https://polygonscan.com/address/#address",
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
      transactionExplorer: "https://mumbai.polygonscan.com/tx/#txid",
      addressExplorer: "https://mumbai.polygonscan.com/address/#address",
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
      transactionExplorer: "https://bscscan.com/tx/#txid",
      addressExplorer: "https://bscscan.com/address/#address",
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
      transactionExplorer: "https://testnet.bscscan.com/tx/#txid",
      addressExplorer: "https://testnet.bscscan.com/address/#address",
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
      transactionExplorer: "https://shasta.tronscan.org/#/transaction/#txid",
      addressExplorer: "https://shasta.tronscan.org/#/address/#address",
      genesis:
          "0000000000000000de1aa88295e1fcf982742f773e0419c5a9c134c994a9059e",
      chainType: ChainType.testnet,
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
      chainType: ChainType.testnet,
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
      chainType: ChainType.mainnet,
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
      genesis: SolanaConst.mainnetGenesis,
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
      transactionExplorer:
          "https://explorer.solana.com/tx/#txid?cluster=testnet",
      addressExplorer:
          "https://explorer.solana.com/address/#address?cluster=testnet",
      genesis: SolanaConst.testnetGenesis,
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
      transactionExplorer:
          "https://explorer.solana.com/tx/#txid?cluster=devnet",
      addressExplorer:
          "https://explorer.solana.com/address/#address?cluster=devnet",
      genesis: SolanaConst.devnetGenesis,
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
      transactionExplorer: "https://preprod.cardanoscan.io/transaction/#txid",
      addressExplorer: "https://preprod.cardanoscan.io/address/#address",
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
      transactionExplorer: "https://cardanoscan.io/transaction/#txid",
      addressExplorer: "https://cardanoscan.io/address/#address",
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
      transactionExplorer:
          "https://explorer.polypore.xyz/theta-testnet-001/tx/#txid",
      addressExplorer:
          "https://explorer.polypore.xyz/theta-testnet-001/account/#address",
      networkType: CosmosNetworkTypes.main,
      chainType: ChainType.testnet,
      hrp: CosmosAddrConst.accHRP,
      denom: "uatom",
      chainId: "provider",
      feeTokens: [
        CosmosFeeToken(
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
      transactionExplorer: "https://ping.pub/cosmos/tx/#txid",
      addressExplorer: "https://ping.pub/cosmos/account/#address",
      networkType: CosmosNetworkTypes.main,
      chainType: ChainType.mainnet,
      hrp: CosmosAddrConst.accHRP,
      chainId: "cosmoshub-4",
      denom: "uatom",
      feeTokens: [
        CosmosFeeToken(
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
      transactionExplorer: "https://www.mayascan.org/tx/#txid",
      addressExplorer: "https://www.mayascan.org/address/#address",
      chainType: ChainType.mainnet,
      hrp: CosmosAddrConst.mayaProtocol,
      denom: "cacao",
      feeTokens: [
        CosmosFeeToken(
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
      transactionExplorer: "https://www.thorscanner.org/tx/#txid",
      addressExplorer: "https://www.thorscanner.org/address/#address",
      chainType: ChainType.mainnet,
      hrp: CosmosAddrConst.thor,
      denom: "rune",
      feeTokens: [
        CosmosFeeToken(
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
      keysAlgs: [
        CosmosKeysAlgs.secp256k1,
      ]);
  static final CosmosNetworkParams kujiraTestnet = CosmosNetworkParams(
      transactionExplorer: "https://finder.kujira.network/harpoon-4/tx/#txid",
      addressExplorer:
          "https://finder.kujira.network/harpoon-4/address/#address",
      chainType: ChainType.testnet,
      hrp: CosmosAddrConst.kujira,
      denom: "ukuji",
      feeTokens: [
        CosmosFeeToken(
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
      transactionExplorer: "https://finder.kujira.network/kaiyo-1/tx/#txid",
      addressExplorer: "https://finder.kujira.network/kaiyo-1/address/#address",
      chainType: ChainType.mainnet,
      hrp: CosmosAddrConst.kujira,
      denom: "ukuji",
      feeTokens: [
        CosmosFeeToken(
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
      transactionExplorer:
          "https://celatone.osmosis.zone/osmo-test-5/txs/#txid",
      addressExplorer:
          "https://celatone.osmosis.zone/osmo-test-5/accounts/#address",
      networkType: CosmosNetworkTypes.main,
      chainType: ChainType.testnet,
      hrp: CosmosConst.osmoHrp,
      feeTokens: [
        CosmosFeeToken(
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
      keysAlgs: [
        CosmosKeysAlgs.secp256k1,
      ]);
  static final CosmosNetworkParams osmosis = CosmosNetworkParams(
      transactionExplorer: "https://celatone.osmosis.zone/osmosis-1/txs/#txid",
      addressExplorer:
          "https://celatone.osmosis.zone/osmosis-1/accounts/#address",
      networkType: CosmosNetworkTypes.main,
      chainType: ChainType.mainnet,
      hrp: CosmosConst.osmoHrp,
      denom: "uosmo",
      feeTokens: [
        CosmosFeeToken(
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
      transactionExplorer: "https://testnet.tonscan.org/tx/#txid",
      addressExplorer: "https://testnet.tonscan.org/address/#address",
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
      transactionExplorer: "https://tonscan.org/tx/#txid",
      addressExplorer: "https://tonscan.org/address/#address",
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
      transactionExplorer: "https://westend.subscan.io/extrinsic/#txid",
      addressExplorer: "https://westend.subscan.io/account/#address",
      chainType: ChainType.testnet,
      ss58Format: SS58Const.genericSubstrate,
      extrinsicType: SubstrateExtrinsicType.metadata,
      token:
          Token(name: "Westend", symbol: "WND", decimal: 12, assetLogo: null),
      providers: [],
      gnesis:
          "e143f23803ac50e8f6f8e62695d1ce9e4e1d68aa36c1cd2cfd15340213f3423e");
  static final SubstrateNetworkParams westendAssetHub = SubstrateNetworkParams(
      transactionExplorer:
          "https://assethub-westend.subscan.io/extrinsic/#txid",
      addressExplorer: "https://assethub-westend.subscan.io/account/#address",
      chainType: ChainType.testnet,
      ss58Format: SS58Const.genericSubstrate,
      extrinsicType: SubstrateExtrinsicType.asset,
      token: Token(
          name: "Westend Asset Hub",
          symbol: "WND",
          decimal: 12,
          assetLogo: null),
      providers: [],
      gnesis:
          "67f9723393ef76214df0118c34bbbd3dbebc8ed46a10973a8c969d48fe7598c9");
  static final SubstrateNetworkParams westendBridgeHub = SubstrateNetworkParams(
      transactionExplorer:
          "https://bridgehub-westend.subscan.io/extrinsic/#txid",
      addressExplorer: "https://bridgehub-westend.subscan.io/account/#address",
      chainType: ChainType.testnet,
      ss58Format: SS58Const.genericSubstrate,
      extrinsicType: SubstrateExtrinsicType.metadata,
      token: Token(
          name: "Westend Bridge Hub",
          symbol: "WND",
          decimal: 12,
          assetLogo: null),
      providers: [],
      gnesis:
          "0441383e31d1266a92b4cb2ddd4c2e3661ac476996db7e5844c52433b81fe782");
  static final SubstrateNetworkParams polkadot = SubstrateNetworkParams(
      transactionExplorer: "https://polkadot.subscan.io/extrinsic/#txid",
      addressExplorer: "https://polkadot.subscan.io/account/#address",
      chainType: ChainType.mainnet,
      ss58Format: SS58Const.polkadot,
      extrinsicType: SubstrateExtrinsicType.metadata,
      token: Token(
          name: "Polkadot",
          market: const CoingeckoCoin(
              apiId: "polkadot", coinName: "polkadot", symbol: "DOT"),
          symbol: "DOT",
          decimal: 10,
          assetLogo: APPConst.polkadot),
      providers: [],
      gnesis:
          "91b171bb158e2d3848fa23a9f1c25182fb8e20313b2c1eb49219da7a70ce90c3");
  static final SubstrateNetworkParams polkadotAssetHub = SubstrateNetworkParams(
      transactionExplorer:
          "https://assethub-polkadot.subscan.io/extrinsic/#txid",
      addressExplorer: "https://assethub-polkadot.subscan.io/account/#address",
      chainType: ChainType.mainnet,
      ss58Format: SS58Const.polkadot,
      extrinsicType: SubstrateExtrinsicType.asset,
      token: Token(
          name: "Polkadot Asset Hub",
          market: const CoingeckoCoin(
              apiId: "polkadot", coinName: "polkadot", symbol: "DOT"),
          symbol: "DOT",
          decimal: 10,
          assetLogo: APPConst.polkadot),
      providers: [],
      gnesis:
          "68d56f15f85d3136970ec16946040bc1752654e906147f7e43e9d539d7c3de2f");
  static final SubstrateNetworkParams polkadotBridgeHub = SubstrateNetworkParams(
      transactionExplorer:
          "https://bridgehub-polkadot.subscan.io/extrinsic/#txid",
      addressExplorer: "https://bridgehub-polkadot.subscan.io/account/#address",
      chainType: ChainType.mainnet,
      ss58Format: SS58Const.polkadot,
      extrinsicType: SubstrateExtrinsicType.metadata,
      token: Token(
          name: "polkadot Bridge Hub",
          market: const CoingeckoCoin(
              apiId: "polkadot", coinName: "polkadot", symbol: "DOT"),
          symbol: "DOT",
          decimal: 10,
          assetLogo: APPConst.polkadot),
      providers: [],
      gnesis:
          "dcf691b5a3fbe24adc99ddc959c0561b973e329b1aef4c4b22e7bb2ddecb4464");
  static final SubstrateNetworkParams kusama = SubstrateNetworkParams(
      transactionExplorer: "https://kusama.subscan.io/extrinsic/#txid",
      addressExplorer: "https://kusama.subscan.io/account/#address",
      chainType: ChainType.mainnet,
      ss58Format: SS58Const.kusama,
      extrinsicType: SubstrateExtrinsicType.metadata,
      token: Token(
          name: "Kusama",
          symbol: "KSM",
          decimal: 12,
          market: const CoingeckoCoin(
              apiId: "kusama", coinName: "kusama", symbol: "KSM"),
          assetLogo: APPConst.kusama),
      providers: [],
      gnesis:
          "b0a8d493285c2df73290dfb7e61f870f17b41801197a149ca93654499ea3dafe");
  static final SubstrateNetworkParams kusamaAssetHub = SubstrateNetworkParams(
      transactionExplorer: "https://assethub-kusama.subscan.io/extrinsic/#txid",
      addressExplorer: "https://assethub-kusama.subscan.io/account/#address",
      chainType: ChainType.mainnet,
      ss58Format: SS58Const.kusama,
      extrinsicType: SubstrateExtrinsicType.asset,
      token: Token(
          name: "Kusama Asset Hub",
          symbol: "KSM",
          decimal: 12,
          market: const CoingeckoCoin(
              apiId: "kusama", coinName: "kusama", symbol: "KSM"),
          assetLogo: APPConst.kusama),
      providers: [],
      gnesis:
          "48239ef607d7928874027a43a67689209727dfb3d3dc5e5b03a39bdc2eda771a");
  static final SubstrateNetworkParams kusamaBridgeHub = SubstrateNetworkParams(
      transactionExplorer:
          "https://bridgehub-kusama.subscan.io/extrinsic/#txid",
      addressExplorer: "https://bridgehub-kusama.subscan.io/account/#address",
      chainType: ChainType.mainnet,
      ss58Format: SS58Const.kusama,
      extrinsicType: SubstrateExtrinsicType.metadata,
      token: Token(
          name: "Kusama Bridge Hub",
          symbol: "KSM",
          decimal: 12,
          market: const CoingeckoCoin(
              apiId: "kusama", coinName: "kusama", symbol: "KSM"),
          assetLogo: APPConst.kusama),
      providers: [],
      gnesis:
          "00dcb981df86429de8bbacf9803401f09485366c44efbf53af9ecfab03adc7e5");

  static final StellarNetworkParams stellarMainnet = StellarNetworkParams(
      transactionExplorer: "https://stellar.expert/explorer/public/tx/#txid",
      addressExplorer:
          "https://stellar.expert/explorer/public/account/#address",
      token: Token(
          name: "Stellar",
          symbol: "XLM",
          decimal: StellarConst.decimal,
          market: const CoingeckoCoin(
              apiId: "stellar", coinName: "stellar", symbol: "XLM"),
          assetLogo: APPConst.stellar),
      providers: const [],
      chainType: ChainType.mainnet,
      passphrase: StellarNetwork.mainnet.passphrase);
  static final StellarNetworkParams stellarTestnet = StellarNetworkParams(
      transactionExplorer: "https://stellar.expert/explorer/testnet/tx/#txid",
      addressExplorer:
          "https://stellar.expert/explorer/testnet/account/#address",
      token: Token(
          name: "Stellar testnet",
          symbol: "tXLM",
          decimal: StellarConst.decimal,
          market: const CoingeckoCoin(
              apiId: "stellar", coinName: "stellar", symbol: "XLM"),
          assetLogo: APPConst.stellar),
      providers: const [],
      chainType: ChainType.testnet,
      passphrase: StellarNetwork.testnet.passphrase);

  static final MoneroNetworkParams moneroTestnet = MoneroNetworkParams(
      transactionExplorer: "https://stagenet.xmrchain.net/tx/#txid",
      gnesisHash:
          "76ee3cc98646292206cd3e86f74d88b4dcc1d937088645e9b0cbca84b7ce74eb",
      addressExplorer: "",
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
      transactionExplorer: "https://xmrchain.net/tx/#txid",
      gnesisHash:
          "418015bb9ae982a1975da7d79277c2705727a56894ba0fb246adaabb1f4632e3",
      addressExplorer: "",
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
}

class ChainConst {
  static const int importedNetworkStartId = 2000;
  static final Map<int, WalletNetwork> defaultCoins = Map.unmodifiable({
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
    400: WalletPolkadotNetwork(400, _DefaultAppCoins.polkadot),
    401: WalletPolkadotNetwork(401, _DefaultAppCoins.polkadotAssetHub),
    402: WalletPolkadotNetwork(402, _DefaultAppCoins.polkadotBridgeHub),
    450: WalletKusamaNetwork(450, _DefaultAppCoins.kusama),
    451: WalletKusamaNetwork(451, _DefaultAppCoins.westend),
    452: WalletKusamaNetwork(452, _DefaultAppCoins.westendAssetHub),
    453: WalletKusamaNetwork(453, _DefaultAppCoins.kusamaAssetHub),
    454: WalletKusamaNetwork(454, _DefaultAppCoins.kusamaBridgeHub),

    455: WalletKusamaNetwork(455, _DefaultAppCoins.westendBridgeHub),

    ///
    600: WalletStellarNetwork(600, _DefaultAppCoins.stellarMainnet),
    601: WalletStellarNetwork(601, _DefaultAppCoins.stellarTestnet),

    /// monero
    700: WalletMoneroNetwork(700, _DefaultAppCoins.monero),
    701: WalletMoneroNetwork(701, _DefaultAppCoins.moneroTestnet),

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
    return defaultNetwork.copyWith(
        coinParam: defaultNetwork.coinParam
            .updateProviders(network?.coinParam.providers ?? []),
        value: defaultNetwork.value);
  }

  static List<String> services(WalletNetwork network) {
    switch (network.type) {
      case NetworkType.xrpl:
        return ["services", "tokens"];
      case NetworkType.tron:
        return ["services", "tokens"];
      case NetworkType.ethereum:
        return ["tokens"];
      case NetworkType.solana:
        return ["services", "tokens"];
      case NetworkType.ton:
        return ["services", "jettons"];
      case NetworkType.stellar:
        return ["services", "tokens"];
      case NetworkType.cosmos:
        return ["services", "tokens"];
      case NetworkType.monero:
        return ["services", "activity"];
      default:
        return ["services"];
    }
  }
}
