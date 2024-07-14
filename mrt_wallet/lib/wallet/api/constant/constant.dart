import 'package:mrt_native_support/platform_interface.dart';
import 'package:mrt_wallet/wallet/api/api.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:ton_dart/ton_dart.dart';

class ProvidersConst {
  static final Map<int, List<APIProvider>> _providers =
      Map<int, List<APIProvider>>.unmodifiable({
    0: <APIProvider>[
      ElectrumAPIProvider(
          serviceName: "142.93.6.38:50002",
          websiteUri: "142.93.6.38:50002",
          url: "142.93.6.38:50002",
          protocol: ServiceProtocol.ssl),
      ElectrumAPIProvider(
          serviceName: "aranguren",
          websiteUri: "bitcoin.aranguren.org",
          url: "wss://bitcoin.aranguren.org:50004",
          protocol: ServiceProtocol.websocket),
      ElectrumAPIProvider(
          serviceName: "104.198.149.61",
          websiteUri: "104.198.149.61",
          url: "wss://104.198.149.61:8443",
          protocol: ServiceProtocol.websocket),
      ElectrumAPIProvider(
          serviceName: "104.248.139.211:50002",
          websiteUri: "104.248.139.211:50002",
          url: "104.248.139.211:50002",
          protocol: ServiceProtocol.ssl),
      BitcoinExplorerAPIProviderConst.mempool,
      BitcoinExplorerAPIProviderConst.blockCypher,
    ],
    1: <APIProvider>[
      ElectrumAPIProvider(
          serviceName: "testnet.aranguren.org",
          websiteUri: "aranguren.org",
          url: "wss://testnet.aranguren.org:51004",
          protocol: ServiceProtocol.websocket),
      ElectrumAPIProvider(
          serviceName: "testnet.aranguren.org",
          websiteUri: "aranguren.org",
          url: "testnet.aranguren.org:51002",
          protocol: ServiceProtocol.ssl),
      ElectrumAPIProvider(
          serviceName: "blockstream",
          websiteUri: "blockstream.info",
          url: "blockstream.info:700",
          protocol: ServiceProtocol.ssl),
      BitcoinExplorerAPIProviderConst.mempool,
      BitcoinExplorerAPIProviderConst.blockCypher,
    ],
    2: <APIProvider>[
      ElectrumAPIProvider(
          serviceName: "qortal",
          websiteUri: "electrum.qortal.link",
          url: "wss://electrum.qortal.link:50004",
          protocol: ServiceProtocol.websocket),
      ElectrumAPIProvider(
          serviceName: "46.101.3.154",
          websiteUri: "46.101.3.154",
          url: "wss://46.101.3.154:50004",
          protocol: ServiceProtocol.websocket),
      ElectrumAPIProvider(
          serviceName: "46.101.3.154",
          websiteUri: "46.101.3.154",
          url: "46.101.3.154:50002",
          protocol: ServiceProtocol.ssl),
      ElectrumAPIProvider(
          serviceName: "backup.electrum-ltc.org",
          websiteUri: "backup.electrum-ltc.org",
          url: "backup.electrum-ltc.org:443",
          protocol: ServiceProtocol.ssl),
      BitcoinExplorerAPIProviderConst.blockCypher,
    ],
    7: <APIProvider>[
      ElectrumAPIProvider(
          serviceName: "electrum-ltc.bysh.me",
          websiteUri: "electrum-ltc.bysh.me",
          url: "electrum-ltc.bysh.me:51002",
          protocol: ServiceProtocol.ssl),
      ElectrumAPIProvider(
          serviceName: "electrum.ltc.xurious.com",
          websiteUri: "electrum.ltc.xurious.com",
          url: "electrum.ltc.xurious.com:51002",
          protocol: ServiceProtocol.ssl),
    ],
    3: <APIProvider>[
      ElectrumAPIProvider(
          serviceName: "electrum.qortal.link",
          websiteUri: "electrum.qortal.link",
          url: "electrum.qortal.link:54002",
          protocol: ServiceProtocol.ssl),
      ElectrumAPIProvider(
          serviceName: "qortal",
          websiteUri: "electrum.qortal.link",
          url: "wss://electrum.qortal.link:54004",
          protocol: ServiceProtocol.websocket),
      BitcoinExplorerAPIProviderConst.blockCypher
    ],
    8: <APIProvider>[],
    9: <APIProvider>[
      ElectrumAPIProvider(
          serviceName: "electrumx.bitcoinsv.io",
          websiteUri: "electrumx.bitcoinsv.io",
          url: "electrumx.bitcoinsv.io:50002",
          protocol: ServiceProtocol.ssl),
    ],
    4: <APIProvider>[
      BitcoinExplorerAPIProviderConst.blockCypher,
    ],
    10: <APIProvider>[
      ElectrumAPIProvider(
          serviceName: "electrum.imaginary.cash",
          websiteUri: "electrum.imaginary.cash",
          url: "wss://electrum.imaginary.cash:50004",
          protocol: ServiceProtocol.websocket),
      ElectrumAPIProvider(
          serviceName: "electrum.imaginary.cash",
          websiteUri: "electrum.imaginary.cash",
          url: "electrum.imaginary.cash:50002",
          protocol: ServiceProtocol.ssl),

      ///
      ElectrumAPIProvider(
          serviceName: "bch.loping.net",
          websiteUri: "bch.loping.net",
          url: "wss://bch.loping.net:50004",
          protocol: ServiceProtocol.websocket),
      ElectrumAPIProvider(
          serviceName: "bch.loping.net",
          websiteUri: "bch.loping.net",
          url: "bch.loping.net:50002",
          protocol: ServiceProtocol.ssl),
    ],
    11: <APIProvider>[
      ElectrumAPIProvider(
          serviceName: "Chipnet-Websocket",
          websiteUri: "https://chipnet.imaginary.cash",
          url: "wss://chipnet.imaginary.cash:50004",
          protocol: ServiceProtocol.websocket),
      ElectrumAPIProvider(
          serviceName: "Chipnet-ssl",
          websiteUri: "https://chipnet.imaginary.cash",
          url: "chipnet.imaginary.cash:50002",
          protocol: ServiceProtocol.ssl)
    ],
    12: <APIProvider>[
      ElectrumAPIProvider(
          serviceName: "pepeblocks-ssl",
          websiteUri: "https://mainnet.pepeblocks.com",
          url: "mainnet.pepeblocks.com:50002",
          protocol: ServiceProtocol.ssl),
      ElectrumAPIProvider(
          serviceName: "pepeblocks-tcp",
          websiteUri: "https://mainnet.pepeblocks.com",
          url: "mainnet.pepeblocks.com:50001",
          protocol: ServiceProtocol.tcp),
      ElectrumAPIProvider(
          serviceName: "pepeblocks-wss",
          websiteUri: "mainnet.pepeblocks.com",
          url: "wss://mainnet.pepeblocks.com:50004",
          protocol: ServiceProtocol.websocket),
      ElectrumAPIProvider(
          serviceName: "pepelum-ssl",
          websiteUri: "https://mainnet.pepelum.site",
          url: "mainnet.pepelum.site:50002",
          protocol: ServiceProtocol.ssl),
      ElectrumAPIProvider(
          serviceName: "pepelum-tcp",
          websiteUri: "https://mainnet.pepelum.site",
          url: "mainnet.pepelum.site:50001",
          protocol: ServiceProtocol.tcp),
      ElectrumAPIProvider(
          serviceName: "pepelum-wss",
          websiteUri: "mainnet.pepelum.site",
          url: "wss://mainnet.pepelum.site:50004",
          protocol: ServiceProtocol.websocket)
    ],
    30: <APIProvider>[
      RippleAPIProvider(
          serviceName: "Ripple",
          websiteUri: "https://xrplcluster.com",
          uri: "https://xrplcluster.com/"),
      RippleAPIProvider(
          serviceName: "Ripple-wss",
          websiteUri: "https://xrplcluster.com",
          uri: "wss://xrplcluster.com/"),
    ],
    31: <APIProvider>[
      RippleAPIProvider(
        serviceName: "Ripple",
        websiteUri: "https://rippletest.net",
        uri: "https://s.altnet.rippletest.net:51234/",
      ),
      RippleAPIProvider(
        serviceName: "Ripple",
        websiteUri: "https://rippletest.net",
        uri: "wss://s.altnet.rippletest.net:51233",
      ),
    ],
    32: <APIProvider>[
      RippleAPIProvider(
        serviceName: "Ripple",
        websiteUri: "https://rippletest.net",
        uri: "https://s.devnet.rippletest.net:51234/",
      ),
      RippleAPIProvider(
        serviceName: "Ripple",
        websiteUri: "https://rippletest.net",
        uri: "wss://s.devnet.rippletest.net:51233",
      ),
    ],
    33: <APIProvider>[
      const SolanaAPIProvider(
          httpNodeUri: "https://api.mainnet-beta.solana.com",
          serviceName: "solana",
          websiteUri: "solana.com")
    ],
    34: <APIProvider>[
      const SolanaAPIProvider(
          httpNodeUri: "https://api.testnet.solana.com",
          serviceName: "solana",
          websiteUri: "solana.com")
    ],
    50: <APIProvider>[
      CardanoAPIProvider(
        uri: "https://cardano-mainnet.blockfrost.io/api/v0/",
        serviceName: "blockfrost",
        websiteUri: "blockfrost.io",
        auth: const ProviderAuth(
            type: ProviderAuthType.header,
            key: "project_id",
            value: "mainnetolePdeWQLX8TrfG9V6RVaAshQi4pWzbU"),
      )
    ],
    51: <APIProvider>[
      CardanoAPIProvider(
          uri: "https://cardano-preprod.blockfrost.io/api/v0/",
          serviceName: "blockfrost",
          websiteUri: "blockfrost.io",
          auth: const ProviderAuth(
              type: ProviderAuthType.header,
              key: "project_id",
              value: "preprodMVwzqm4PuBDBSfEULoMzoj5QZcy5o3z5"))
    ],
    100: <APIProvider>[
      EthereumAPIProvider(
        serviceName: "publicnode",
        websiteUri: "ethereum.publicnode.com",
        uri: "wss://ethereum.publicnode.com",
      ),
      EthereumAPIProvider(
        serviceName: "publicnode",
        websiteUri: "ethereum.publicnode.com",
        uri: "wss://ethereum.publicnode.com",
      ),
    ],
    101: <APIProvider>[
      EthereumAPIProvider(
        serviceName: "publicnode.com",
        websiteUri: "https://ethereum-sepolia.publicnode.com",
        uri: "https://ethereum-sepolia.publicnode.com",
      ),
    ],
    102: <APIProvider>[
      EthereumAPIProvider(
        serviceName: "publicnode.com",
        websiteUri: "https://polygon-bor.publicnode.com",
        uri: "https://polygon-bor.publicnode.com",
      )
    ],
    103: <APIProvider>[
      EthereumAPIProvider(
        serviceName: "publicnode.com",
        uri: "https://polygon-mumbai-bor.publicnode.com",
        websiteUri: "https://polygon-mumbai-bor.publicnode.com",
      ),
    ],
    104: <APIProvider>[
      EthereumAPIProvider(
        serviceName: "publicnode.com",
        uri: "https://bsc.publicnode.com",
        websiteUri: "https://bsc.publicnode.com",
      ),
    ],
    105: <APIProvider>[
      EthereumAPIProvider(
        serviceName: "publicnode.com",
        websiteUri: "https://bsc-testnet.publicnode.com",
        uri: "https://bsc-testnet.publicnode.com",
      ),
    ],
    200: <APIProvider>[
      CosmosAPIProvider(
          serviceName: "cosmos-rpc.publicnode.com",
          websiteUri: "https://cosmos-rpc.publicnode.com:443",
          uri: "https://cosmos-rpc.publicnode.com:443",
          nodeUri: null),
    ],
    206: <APIProvider>[
      CosmosAPIProvider(
          serviceName: "osmosis.zone",
          websiteUri: "https://rpc.testnet.osmosis.zone/",
          uri: "https://rpc.testnet.osmosis.zone/",
          nodeUri: null),
    ],
    207: <APIProvider>[
      CosmosAPIProvider(
          serviceName: "osmosis.zone",
          websiteUri: "https://rpc.osmosis.zone",
          uri: "https://rpc.osmosis.zone",
          nodeUri: null),
    ],
    201: <APIProvider>[
      CosmosAPIProvider(
          serviceName: "polypore.xyz",
          websiteUri: "https://rpc.sentry-02.theta-testnet.polypore.xyz",
          uri: "https://rpc.sentry-02.theta-testnet.polypore.xyz",
          nodeUri: null),
    ],
    202: <APIProvider>[
      CosmosAPIProvider(
          serviceName: "mayachain.info",
          websiteUri: "https://tendermint.mayachain.info",
          uri: "https://tendermint.mayachain.info",
          nodeUri: "https://mayanode.mayachain.info/mayachain"),
    ],
    203: <APIProvider>[
      CosmosAPIProvider(
          serviceName: "liquify.com",
          websiteUri: "https://rpc.thorchain.liquify.com",
          uri: "https://rpc.thorchain.liquify.com/",
          nodeUri: "https://thornode.ninerealms.com/thorchain"),
    ],
    204: <APIProvider>[
      CosmosAPIProvider(
          serviceName: "polkachu.com",
          websiteUri: "https://kujira-testnet-rpc.polkachu.com/",
          uri: "https://kujira-testnet-rpc.polkachu.com/",
          nodeUri: "https://kujira-testnet-rpc.polkachu.com/"),
    ],
    205: <APIProvider>[
      CosmosAPIProvider(
          serviceName: "polkachu.com",
          websiteUri: "https://kujira-rpc.polkachu.com/",
          uri: "https://kujira-rpc.polkachu.com/",
          nodeUri: "https://kujira-rpc.polkachu.com/"),
    ],
    300: <APIProvider>[
      TonAPIProvider(
          serviceName: "TonAPI",
          websiteUri: "https://tonapi.io",
          uri: "https://tonapi.io",
          apiType: TonApiType.tonApi),
      TonAPIProvider(
          serviceName: "TonCenter",
          websiteUri: "https://toncenter.io",
          uri: "https://toncenter.com",
          apiType: TonApiType.tonCenter,
          auth: const ProviderAuth(
              type: ProviderAuthType.header,
              key: "X-API-Key",
              value:
                  "cc8597229bb486a012f29743732b56c2331aff7f87c3d2cb84d456a04213b3ac")),
    ],
    301: <APIProvider>[
      TonAPIProvider(
          serviceName: "TonAPI",
          websiteUri: "https://tonapi.io",
          uri: "https://testnet.tonapi.io",
          apiType: TonApiType.tonApi),
      TonAPIProvider(
          serviceName: "TonCenter",
          websiteUri: "https://toncenter.io",
          uri: "https://testnet.toncenter.com",
          apiType: TonApiType.tonCenter,
          auth: const ProviderAuth(
              type: ProviderAuthType.header,
              key: "X-API-Key",
              value:
                  "d3800f756738ac7b39599914b8a84465960ff869f555c2317664c9a62529baf3")),
    ],
    400: <APIProvider>[
      SubstrateAPIProvider(
          serviceName: "Polkadot",
          websiteUri: "https://polkadot.io",
          uri: "https://rpc.polkadot.io"),
    ],
    450: <APIProvider>[
      SubstrateAPIProvider(
          serviceName: "Kusama",
          websiteUri: "https://polkadot.io",
          uri: "https://kusama-rpc.polkadot.io"),
    ],
    451: <APIProvider>[
      SubstrateAPIProvider(
          serviceName: "Westend",
          websiteUri: "https://polkadot.io",
          uri: "https://westend-rpc.polkadot.io"),
    ],
    1001: <APIProvider>[
      TronAPIProvider(
          serviceName: "trongrid",
          websiteUri: "https://trongrid.io",
          httpNodeUri: "https://api.trongrid.io",
          solidityProvider: EthereumAPIProvider(
            serviceName: "https://api.trongrid.io/jsonrpc",
            websiteUri: "trongrid.io",
            uri: "https://api.trongrid.io/jsonrpc",
          )),
    ],
    1002: <APIProvider>[
      TronAPIProvider(
          serviceName: "trongrid",
          websiteUri: "https://trongrid.io",
          httpNodeUri: "https://api.shasta.trongrid.io",
          solidityProvider: EthereumAPIProvider(
            serviceName: "https://api.shasta.trongrid.io/jsonrpc",
            websiteUri: "trongrid.io",
            uri: "https://api.shasta.trongrid.io/jsonrpc",
          )),
    ],
    1003: <APIProvider>[
      TronAPIProvider(
          serviceName: "trongrid",
          websiteUri: "https://trongrid.io",
          httpNodeUri: "https://nile.trongrid.io",
          solidityProvider: EthereumAPIProvider(
              serviceName: "https://nile.trongrid.io/jsonrpc",
              websiteUri: "trongrid.io",
              uri: "https://nile.trongrid.io/jsonrpc")),
    ],
  });

  static APIProvider? getDefaultService(WalletNetwork network,
      {APIProvider? service}) {
    if (!_providers.containsKey(network.value)) return null;
    final networkServices = _providers[network.value]!
        .where((element) =>
            element.protocol.platforms.contains(PlatformInterface.appPlatform))
        .toList();
    if (networkServices.isEmpty) return null;
    if (service == null) {
      return networkServices.first;
    }
    return networkServices.firstWhere(
        (element) =>
            element.serviceName == service.serviceName &&
            element.protocol == service.protocol,
        orElse: () => networkServices.first);
  }

  static List<T> getDefaultProvider<T extends APIProvider>(
      WalletNetwork network) {
    return _providers[network.value]
            ?.whereType<T>()
            .where((element) => element.protocol.platforms
                .contains(PlatformInterface.appPlatform))
            .toList() ??
        <T>[];
  }
}
