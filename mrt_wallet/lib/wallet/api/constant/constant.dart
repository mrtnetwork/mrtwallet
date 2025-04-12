import 'package:mrt_native_support/platform_interface.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/api/api.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:ton_dart/ton_dart.dart';
import 'package:mrt_wallet/app/http/models/auth.dart';

class ProvidersConst {
  static const String tonApiName = "Ton API";
  static const String aptosGraphQlName = "Aptos GraphQL";
  static List<APIProviderServiceInfo> networkSupportServices(
      WalletNetwork network) {
    return switch (network.type) {
      NetworkType.bitcoinAndForked || NetworkType.bitcoinCash => [
          APIProviderServiceInfo(name: "Electrum")
        ],
      NetworkType.cardano => [
          APIProviderServiceInfo(
              name: "Blockfrost", url: "https://blockfrost.io/"),
        ],
      NetworkType.ethereum => [
          APIProviderServiceInfo(
              name: "JSON RPC",
              url: "https://ethereum.org/en/developers/docs/apis/json-rpc/"),
        ],
      NetworkType.solana => [
          APIProviderServiceInfo(
              name: "JSON RPC", url: "https://solana.com/docs/rpc"),
        ],
      NetworkType.substrate => [
          APIProviderServiceInfo(
              name: "JSON RPC",
              url: "https://wiki.polkadot.network/docs/maintain-endpoints"),
        ],
      NetworkType.ton => [
          APIProviderServiceInfo(
              name: TonApiType.tonCenter.name, url: "https://toncenter.com/"),
          APIProviderServiceInfo(
              name: TonApiType.tonApi.name, url: "https://tonapi.io/"),
        ],
      NetworkType.cosmos => [
          APIProviderServiceInfo(
              name: "Tendermint", url: "https://docs.tendermint.com/v0.34/rpc/")
        ],
      NetworkType.xrpl => [
          APIProviderServiceInfo(
              name: "JSON RPC",
              url: "https://xrpl.org/docs/references/http-websocket-apis")
        ],
      NetworkType.stellar => [
          APIProviderServiceInfo(
              name: "Horizon",
              url: "https://developers.stellar.org/docs/data/horizon")
        ],
      NetworkType.monero => [
          APIProviderServiceInfo(
              name: "Daemon RPC",
              url: "https://docs.getmonero.org/rpc-library/monerod-rpc/")
        ],
      NetworkType.tron => [
          APIProviderServiceInfo(
              name: "Fullnode",
              url: "https://developers.tron.network/docs/nodes-and-clients"),
        ],
      NetworkType.aptos => [
          APIProviderServiceInfo(
              name: "Aptos Node",
              url:
                  "https://aptos.dev/en/build/apis/fullnode-rest-api-reference"),
          APIProviderServiceInfo(
              name: aptosGraphQlName,
              url: "https://aptos.dev/en/build/indexer"),
        ],
      NetworkType.sui => [
          APIProviderServiceInfo(
              name: "Sui Node", url: "https://docs.sui.io/sui-api-ref"),
        ],
      _ => throw UnimplementedError("invalid network."),
    };
  }

  static const String defaultidentifierName = "default-";
  static final Map<int, List<APIProvider>> _providers =
      Map<int, List<APIProvider>>.unmodifiable({
    0: <APIProvider>[
      ElectrumAPIProvider(
          identifier: "${defaultidentifierName}0",
          url: "142.93.6.38:50002",
          protocol: ServiceProtocol.ssl),
      ElectrumAPIProvider(
          identifier: "${defaultidentifierName}1",
          url: "wss://bitcoin.aranguren.org:50004",
          protocol: ServiceProtocol.websocket),
      ElectrumAPIProvider(
          identifier: "${defaultidentifierName}2",
          url: "wss://104.198.149.61:8443",
          protocol: ServiceProtocol.websocket),
      ElectrumAPIProvider(
          identifier: "${defaultidentifierName}3",
          url: "104.248.139.211:50002",
          protocol: ServiceProtocol.ssl),
      BitcoinExplorerAPIProviderConst.mempool,
      BitcoinExplorerAPIProviderConst.blockCypher,
    ],
    1: <APIProvider>[
      ElectrumAPIProvider(
          identifier: "${defaultidentifierName}4",
          url: "wss://testnet.aranguren.org:51004",
          protocol: ServiceProtocol.websocket),
      ElectrumAPIProvider(
          identifier: "${defaultidentifierName}5",
          url: "testnet.aranguren.org:51002",
          protocol: ServiceProtocol.ssl),
      ElectrumAPIProvider(
          identifier: "${defaultidentifierName}6",
          url: "blockstream.info:700",
          protocol: ServiceProtocol.ssl),
      BitcoinExplorerAPIProviderConst.mempool,
      BitcoinExplorerAPIProviderConst.blockCypher,
    ],
    5: <APIProvider>[
      ElectrumAPIProvider(
          identifier: "${defaultidentifierName}tbtc4",
          url: "testnet4-electrumx.wakiyamap.dev:51002",
          protocol: ServiceProtocol.ssl),
      ElectrumAPIProvider(
          identifier: "${defaultidentifierName}tbtc4_1",
          url: "testnet4-electrumx.wakiyamap.dev:51001",
          protocol: ServiceProtocol.tcp),
      ElectrumAPIProvider(
          identifier: "${defaultidentifierName}tbtc4_2",
          url: "wss://blackie.c3-soft.com:57012",
          protocol: ServiceProtocol.websocket),
    ],
    2: <APIProvider>[
      ElectrumAPIProvider(
          identifier: "${defaultidentifierName}7",
          url: "wss://electrum.qortal.link:50004",
          protocol: ServiceProtocol.websocket),
      ElectrumAPIProvider(
          identifier: "${defaultidentifierName}8",
          url: "wss://46.101.3.154:50004",
          protocol: ServiceProtocol.websocket),
      ElectrumAPIProvider(
          identifier: "${defaultidentifierName}9",
          url: "46.101.3.154:50002",
          protocol: ServiceProtocol.ssl),
      ElectrumAPIProvider(
          identifier: "${defaultidentifierName}10",
          url: "backup.electrum-ltc.org:443",
          protocol: ServiceProtocol.ssl),
      BitcoinExplorerAPIProviderConst.blockCypher,
    ],
    7: <APIProvider>[
      ElectrumAPIProvider(
          identifier: "${defaultidentifierName}11",
          url: "electrum-ltc.bysh.me:51002",
          protocol: ServiceProtocol.ssl),
      ElectrumAPIProvider(
          identifier: "${defaultidentifierName}12",
          url: "electrum.ltc.xurious.com:51002",
          protocol: ServiceProtocol.ssl),
    ],
    3: <APIProvider>[
      ElectrumAPIProvider(
          identifier: "${defaultidentifierName}13",
          url: "electrum.qortal.link:54002",
          protocol: ServiceProtocol.ssl),
      ElectrumAPIProvider(
          identifier: "${defaultidentifierName}14",
          url: "wss://electrum.qortal.link:54004",
          protocol: ServiceProtocol.websocket),
      BitcoinExplorerAPIProviderConst.blockCypher
    ],
    8: <APIProvider>[],
    9: <APIProvider>[
      ElectrumAPIProvider(
          identifier: "${defaultidentifierName}15",
          url: "electrumx.bitcoinsv.io:50002",
          protocol: ServiceProtocol.ssl),
    ],
    4: <APIProvider>[
      BitcoinExplorerAPIProviderConst.blockCypher,
    ],
    10: <APIProvider>[
      ElectrumAPIProvider(
          identifier: "${defaultidentifierName}16",
          url: "wss://electrum.imaginary.cash:50004",
          protocol: ServiceProtocol.websocket),
      ElectrumAPIProvider(
          identifier: "${defaultidentifierName}17",
          url: "electrum.imaginary.cash:50002",
          protocol: ServiceProtocol.ssl),

      ///
      ElectrumAPIProvider(
          identifier: "${defaultidentifierName}18",
          url: "wss://bch.loping.net:50004",
          protocol: ServiceProtocol.websocket),
      ElectrumAPIProvider(
          identifier: "${defaultidentifierName}19",
          url: "bch.loping.net:50002",
          protocol: ServiceProtocol.ssl),
    ],
    11: <APIProvider>[
      ElectrumAPIProvider(
          identifier: "${defaultidentifierName}0",
          url: "ws://cbch.loping.net:62103",
          protocol: ServiceProtocol.websocket),
      ElectrumAPIProvider(
          identifier: "${defaultidentifierName}1",
          url: "ws://cbch.loping.net:62104",
          protocol: ServiceProtocol.websocket),
      ElectrumAPIProvider(
          identifier: "${defaultidentifierName}3",
          url: "cbch.loping.net:62102",
          protocol: ServiceProtocol.ssl),
      ElectrumAPIProvider(
          identifier: "${defaultidentifierName}21",
          url: "chipnet.imaginary.cash:50002",
          protocol: ServiceProtocol.ssl)
    ],
    12: <APIProvider>[
      ElectrumAPIProvider(
          identifier: "${defaultidentifierName}22",
          url: "mainnet.pepeblocks.com:50002",
          protocol: ServiceProtocol.ssl),
      ElectrumAPIProvider(
          identifier: "${defaultidentifierName}24",
          url: "mainnet.pepeblocks.com:50001",
          protocol: ServiceProtocol.tcp),
      ElectrumAPIProvider(
          identifier: "${defaultidentifierName}24",
          url: "wss://mainnet.pepeblocks.com:50004",
          protocol: ServiceProtocol.websocket),
      ElectrumAPIProvider(
          identifier: "${defaultidentifierName}25",
          url: "mainnet.pepelum.site:50002",
          protocol: ServiceProtocol.ssl),
      ElectrumAPIProvider(
          identifier: "${defaultidentifierName}26",
          url: "mainnet.pepelum.site:50001",
          protocol: ServiceProtocol.tcp),
      ElectrumAPIProvider(
          identifier: "${defaultidentifierName}27",
          url: "wss://mainnet.pepelum.site:50004",
          protocol: ServiceProtocol.websocket)
    ],
    30: <APIProvider>[
      RippleAPIProvider(
          identifier: "${defaultidentifierName}28",
          uri: "https://xrplcluster.com/"),
      RippleAPIProvider(
          identifier: "${defaultidentifierName}29",
          uri: "wss://xrplcluster.com/"),
    ],
    31: <APIProvider>[
      RippleAPIProvider(
        identifier: "${defaultidentifierName}30",
        uri: "https://s.altnet.rippletest.net:51234/",
      ),
      RippleAPIProvider(
        identifier: "${defaultidentifierName}31",
        uri: "wss://s.altnet.rippletest.net:51233",
      ),
    ],
    32: <APIProvider>[
      RippleAPIProvider(
        identifier: "${defaultidentifierName}32",
        uri: "https://s.devnet.rippletest.net:51234/",
      ),
      RippleAPIProvider(
        identifier: "${defaultidentifierName}33",
        uri: "wss://s.devnet.rippletest.net:51233",
      ),
    ],
    33: <APIProvider>[
      const SolanaAPIProvider(
        httpNodeUri: "https://api.mainnet-beta.solana.com",
        identifier: "${defaultidentifierName}34",
      )
    ],
    34: <APIProvider>[
      const SolanaAPIProvider(
        httpNodeUri: "https://api.testnet.solana.com",
        identifier: "${defaultidentifierName}35",
      )
    ],
    35: <APIProvider>[
      const SolanaAPIProvider(
        httpNodeUri: "https://api.devnet.solana.com",
        identifier: "${defaultidentifierName}200",
      )
    ],
    50: <APIProvider>[
      CardanoAPIProvider(
        uri: "https://cardano-mainnet.blockfrost.io/api/v0/",
        identifier: "${defaultidentifierName}36",
        serviceName: "blockfrost",
        websiteUri: "blockfrost.io",
        auth: const BasicProviderAuthenticated(
            type: ProviderAuthType.header,
            key: "project_id",
            value: "mainnetolePdeWQLX8TrfG9V6RVaAshQi4pWzbU"),
      )
    ],
    51: <APIProvider>[
      CardanoAPIProvider(
          uri: "https://cardano-preprod.blockfrost.io/api/v0/",
          identifier: "${defaultidentifierName}37",
          serviceName: "blockfrost",
          websiteUri: "blockfrost.io",
          auth: const BasicProviderAuthenticated(
              type: ProviderAuthType.header,
              key: "project_id",
              value: "preprodMVwzqm4PuBDBSfEULoMzoj5QZcy5o3z5"))
    ],
    100: <APIProvider>[
      EthereumAPIProvider(
        identifier: "${defaultidentifierName}38",
        uri: "wss://ethereum.publicnode.com",
      ),
      EthereumAPIProvider(
        identifier: "${defaultidentifierName}39",
        uri: "https://ethereum.publicnode.com",
      ),
    ],
    101: <APIProvider>[
      EthereumAPIProvider(
        identifier: "${defaultidentifierName}40",
        uri: "https://ethereum-sepolia.publicnode.com",
      ),
    ],
    102: <APIProvider>[
      EthereumAPIProvider(
        identifier: "${defaultidentifierName}41",
        uri: "https://polygon-bor.publicnode.com",
      )
    ],
    103: <APIProvider>[
      EthereumAPIProvider(
        identifier: "${defaultidentifierName}42",
        uri: "https://polygon-mumbai-bor.publicnode.com",
      ),
    ],
    104: <APIProvider>[
      EthereumAPIProvider(
        identifier: "${defaultidentifierName}43",
        uri: "https://bsc.publicnode.com",
      ),
    ],
    105: <APIProvider>[
      EthereumAPIProvider(
        identifier: "${defaultidentifierName}44",
        uri: "https://bsc-testnet.publicnode.com",
      ),
    ],
    200: <APIProvider>[
      CosmosAPIProvider(
        identifier: "${defaultidentifierName}45",
        uri: "https://cosmos-rpc.publicnode.com:443",
      ),
    ],
    206: <APIProvider>[
      CosmosAPIProvider(
        identifier: "${defaultidentifierName}46",
        uri: "https://rpc.testnet.osmosis.zone/",
      ),
    ],
    207: <APIProvider>[
      CosmosAPIProvider(
        identifier: "${defaultidentifierName}47",
        uri: "https://rpc.osmosis.zone/",
      ),
    ],
    201: <APIProvider>[
      CosmosAPIProvider(
        identifier: "${defaultidentifierName}48",
        uri: "https://rpc.provider-sentry-02.ics-testnet.polypore.xyz",
      ),
    ],
    202: <APIProvider>[
      CosmosAPIProvider(
          identifier: "${defaultidentifierName}49",
          uri: "https://tendermint.mayachain.info"),
    ],
    203: <APIProvider>[
      CosmosAPIProvider(
          identifier: "${defaultidentifierName}50",
          uri: "https://rpc.thorchain.liquify.com/"),
    ],
    204: <APIProvider>[
      CosmosAPIProvider(
          identifier: "${defaultidentifierName}51",
          uri: "https://kujira-testnet-rpc.polkachu.com/"),
    ],
    205: <APIProvider>[
      CosmosAPIProvider(
          identifier: "${defaultidentifierName}52",
          uri: "https://rpc.cosmos.directory/kujira"),
    ],
    300: <APIProvider>[
      TonAPIProvider(
          identifier: "${defaultidentifierName}53",
          serviceName: "TonAPI",
          websiteUri: "https://tonapi.io",
          uri: "https://tonapi.io",
          apiType: TonApiType.tonApi),
      TonAPIProvider(
          identifier: "${defaultidentifierName}54",
          serviceName: "TonCenter",
          websiteUri: "https://toncenter.io",
          uri: "https://toncenter.com",
          apiType: TonApiType.tonCenter,
          auth: const BasicProviderAuthenticated(
              type: ProviderAuthType.header,
              key: "X-API-Key",
              value:
                  "cc8597229bb486a012f29743732b56c2331aff7f87c3d2cb84d456a04213b3ac")),
    ],
    301: <APIProvider>[
      TonAPIProvider(
          identifier: "${defaultidentifierName}55",
          serviceName: "TonAPI",
          websiteUri: "https://tonapi.io",
          uri: "https://testnet.tonapi.io",
          apiType: TonApiType.tonApi),
      TonAPIProvider(
          identifier: "${defaultidentifierName}56",
          serviceName: "TonCenter",
          websiteUri: "https://toncenter.io",
          uri: "https://testnet.toncenter.com",
          apiType: TonApiType.tonCenter,
          auth: const BasicProviderAuthenticated(
              type: ProviderAuthType.header,
              key: "X-API-Key",
              value:
                  "d3800f756738ac7b39599914b8a84465960ff869f555c2317664c9a62529baf3")),
    ],
    400: <APIProvider>[
      SubstrateAPIProvider(
          identifier: "${defaultidentifierName}57",
          uri: "https://rpc.polkadot.io"),
    ],
    401: <APIProvider>[
      SubstrateAPIProvider(
          identifier: "${defaultidentifierName}401",
          uri: "wss://polkadot-asset-hub-rpc.polkadot.io"),
    ],
    402: <APIProvider>[
      SubstrateAPIProvider(
          identifier: "${defaultidentifierName}402",
          uri: "wss://polkadot-bridge-hub-rpc.polkadot.io"),
    ],

    ///
    450: <APIProvider>[
      SubstrateAPIProvider(
          identifier: "${defaultidentifierName}58",
          uri: "https://kusama-rpc.polkadot.io"),
    ],
    451: <APIProvider>[
      SubstrateAPIProvider(
          identifier: "${defaultidentifierName}59",
          uri: "wss://westend-rpc.polkadot.io"),
      SubstrateAPIProvider(
          identifier: "${defaultidentifierName}60",
          uri: "https://westend-rpc.polkadot.io"),
    ],
    452: <APIProvider>[
      SubstrateAPIProvider(
          identifier: "${defaultidentifierName}452",
          uri: "wss://westmint-rpc.dwellir.com:443"),
    ],
    453: <APIProvider>[
      SubstrateAPIProvider(
          identifier: "${defaultidentifierName}453",
          uri: "wss://kusama-asset-hub-rpc.polkadot.io"),
    ],
    454: <APIProvider>[
      SubstrateAPIProvider(
          identifier: "${defaultidentifierName}454",
          uri: "wss://kusama-bridge-hub-rpc.polkadot.io"),
    ],
    455: <APIProvider>[
      SubstrateAPIProvider(
          identifier: "${defaultidentifierName}455",
          uri: "wss://westend-bridge-hub-rpc.polkadot.io:443"),
    ],
    461: <APIProvider>[
      SubstrateAPIProvider(
          identifier: "${defaultidentifierName}461",
          uri: "wss://moonbase-rpc.dwellir.com"),
      SubstrateAPIProvider(
          identifier: "${defaultidentifierName}461/2",
          uri: "wss://moonbeam-alpha.api.onfinality.io:443/public-ws"),
    ],
    460: <APIProvider>[
      SubstrateAPIProvider(
          identifier: "${defaultidentifierName}460",
          uri: "wss://moonbeam-rpc.dwellir.com"),
      SubstrateAPIProvider(
          identifier: "${defaultidentifierName}460/2",
          uri: "wss://moonbeam.api.onfinality.io/public"),
    ],
    462: <APIProvider>[
      SubstrateAPIProvider(
          identifier: "${defaultidentifierName}462",
          uri: "wss://moonriver-rpc.dwellir.com"),
      SubstrateAPIProvider(
          identifier: "${defaultidentifierName}462/2",
          uri: "wss://moonriver.api.onfinality.io/public"),
    ],
    463: <APIProvider>[
      SubstrateAPIProvider(
          identifier: "${defaultidentifierName}463",
          uri: "wss://astar-rpc.dwellir.com"),
      SubstrateAPIProvider(
          identifier: "${defaultidentifierName}463/2",
          uri: "wss://astar.api.onfinality.io/public"),
    ],
    464: <APIProvider>[
      SubstrateAPIProvider(
          identifier: "${defaultidentifierName}462",
          uri: "wss://centrifuge-rpc.dwellir.com"),
    ],
    465: <APIProvider>[
      SubstrateAPIProvider(
          identifier: "${defaultidentifierName}465",
          uri: "wss://acala-rpc-0.aca-api.network"),
    ],

    /// wss%3A%2F%2Ffullnode.centrifuge.io
    600: <APIProvider>[
      const StellarAPIProvider(
          identifier: "${defaultidentifierName}600",
          horizonUrl: "https://horizon.stellar.org",
          sorobanUrl: "https://soroban-rpc.mainnet.stellar.gateway.fm"),
    ],
    601: <APIProvider>[
      const StellarAPIProvider(
          identifier: "${defaultidentifierName}601",
          horizonUrl: "https://horizon-testnet.stellar.org",
          sorobanUrl: "https://soroban-testnet.stellar.org"),
    ],
    700: <APIProvider>[
      const MoneroAPIProvider(
          identifier: "${defaultidentifierName}700",
          httpNodeUri: "http://node.tools.rino.io:18081"),
      const MoneroAPIProvider(
          identifier: "${defaultidentifierName}700A",
          httpNodeUri: "http://node.xmr.rocks:18089"),
    ],
    701: <APIProvider>[
      const MoneroAPIProvider(
          identifier: "${defaultidentifierName}701",
          httpNodeUri: "http://stagenet.tools.rino.io:38081"),
      const MoneroAPIProvider(
          identifier: "${defaultidentifierName}702",
          httpNodeUri: "http://singapore.node.xmr.pm:38081"),
      const MoneroAPIProvider(
          identifier: "${defaultidentifierName}703",
          httpNodeUri: "https://stagenet.xmr.ditatompel.com"),
    ],
    1001: <APIProvider>[
      TronAPIProvider(
          identifier: "${defaultidentifierName}60",
          httpNodeUri: "https://api.trongrid.io",
          solidityProvider: EthereumAPIProvider(
            identifier: "${defaultidentifierName}61",
            uri: "https://api.trongrid.io/jsonrpc",
          )),
    ],
    1002: <APIProvider>[
      TronAPIProvider(
          identifier: "${defaultidentifierName}62",
          httpNodeUri: "https://api.shasta.trongrid.io",
          solidityProvider: EthereumAPIProvider(
            identifier: "${defaultidentifierName}63",
            uri: "https://api.shasta.trongrid.io/jsonrpc",
          )),
    ],
    1003: <APIProvider>[
      TronAPIProvider(
          identifier: "${defaultidentifierName}64",
          httpNodeUri: "https://nile.trongrid.io",
          solidityProvider: EthereumAPIProvider(
              identifier: "${defaultidentifierName}65",
              uri: "https://nile.trongrid.io/jsonrpc")),
    ],
    106: <APIProvider>[
      EthereumAPIProvider(
        identifier: "${defaultidentifierName}66",
        uri: "https://api.avax.network/ext/bc/C/rpc",
      ),
    ],
    107: <APIProvider>[
      EthereumAPIProvider(
        identifier: "${defaultidentifierName}68",
        uri: "https://arb1.arbitrum.io/rpc",
      ),
      EthereumAPIProvider(
          identifier: "${defaultidentifierName}69 ",
          uri: "https://arbitrum-one-rpc.publicnode.com"),
    ],
    108: <APIProvider>[
      EthereumAPIProvider(
        identifier: "${defaultidentifierName}70",
        uri: "https://mainnet.base.org",
      )
    ],
    109: <APIProvider>[
      EthereumAPIProvider(
        identifier: "${defaultidentifierName}70",
        uri: "https://mainnet.optimism.io",
      ),
      EthereumAPIProvider(
        identifier: "${defaultidentifierName}71",
        uri: "https://optimism-rpc.publicnode.com",
      )
    ],
    800: <APIProvider>[
      SuiAPIProvider(
          identifier: "${defaultidentifierName}800_1",
          fullNodeUri: "https://fullnode.mainnet.sui.io:443"),
      SuiAPIProvider(
          identifier: "${defaultidentifierName}800_2",
          fullNodeUri: "https://sui-rpc.publicnode.com")
    ],
    801: <APIProvider>[
      SuiAPIProvider(
          identifier: "${defaultidentifierName}801",
          fullNodeUri: "https://fullnode.devnet.sui.io:443")
    ],
    802: <APIProvider>[
      SuiAPIProvider(
          identifier: "${defaultidentifierName}802",
          fullNodeUri: "https://fullnode.testnet.sui.io:443")
    ],
    810: <APIProvider>[
      AptosAPIProvider(
          identifier: "${defaultidentifierName}810_1",
          fullNodeUri: "https://api.mainnet.aptoslabs.com/v1/",
          type: AptosAPIProviderType.fullnode),
      AptosAPIProvider(
          identifier: "${defaultidentifierName}811_1",
          fullNodeUri: "https://api.mainnet.aptoslabs.com/v1/graphql",
          type: AptosAPIProviderType.graphQl),
    ],
    811: <APIProvider>[
      AptosAPIProvider(
          identifier: "${defaultidentifierName}811_1",
          fullNodeUri: "https://api.testnet.aptoslabs.com/v1/",
          type: AptosAPIProviderType.fullnode),
      AptosAPIProvider(
          identifier: "${defaultidentifierName}811_1",
          fullNodeUri: "https://api.testnet.aptoslabs.com/v1/graphql",
          type: AptosAPIProviderType.graphQl),
    ],
    812: <APIProvider>[
      AptosAPIProvider(
          identifier: "${defaultidentifierName}812_1",
          fullNodeUri: "https://api.devnet.aptoslabs.com/v1/",
          type: AptosAPIProviderType.fullnode),
      AptosAPIProvider(
          identifier: "${defaultidentifierName}812_1",
          fullNodeUri: "https://api.devnet.aptoslabs.com/v1/graphql",
          type: AptosAPIProviderType.graphQl),
    ],
  });

  static List<T> getDefaultProvider<T extends APIProvider>(
      WalletNetwork network) {
    final providers = _providers[network.value] ?? [];
    return providers
        .whereType<T>()
        .where((element) =>
            element.protocol.platforms.contains(PlatformInterface.appPlatform))
        .toList();
  }
}
