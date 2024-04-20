import 'package:mrt_native_support/platform_interface.dart';
import 'package:mrt_wallet/models/wallet_models/network/core/network.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';

class DefaultNodeProviders {
  static const Map<int, String> gnesisHash = {
    0: "000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f",
    1: "000000000933ea01ad0ee984209779baaec3ced90fa3f408719526f8d77f4943",
    2: "12a765e31ffd4059bada1e25190f6e98c99d9714d334efa41a195a7e7e04bfe2",
    7: "4966625a4b2851d9fdee139e56211a0d88575f59ed816ff5e6a63deb4e3e29a0",
    3: "1a91e3dace36e2be3bf030a65679fe821aa1d6ef92e7c9902eb318182c355691",
    8: "bb0a78264637406b6360aad926284d544d7049f45189db5664f3c4d07350559e",
    9: "000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f",
    4: "00000ffd590b1485b3caadc19b22e6379c733355108f107a430458cdf3407ab6",
    10: "000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f",
    11: "000000001dd410c49a788668ce26751718cc797474d3152a5fc073dd44fd9f7b",
  };
  static final Map<int, List<ApiProviderService>> _providers =
      Map<int, List<ApiProviderService>>.unmodifiable({
    0: <ApiProviderService>[
      ElectrumApiProviderService(
          serviceName: "142.93.6.38:50002",
          websiteUri: "142.93.6.38:50002",
          url: "142.93.6.38:50002",
          protocol: ProviderProtocol.ssl),
      ElectrumApiProviderService(
          serviceName: "aranguren",
          websiteUri: "bitcoin.aranguren.org",
          url: "wss://bitcoin.aranguren.org:50004",
          protocol: ProviderProtocol.websocket),
      ElectrumApiProviderService(
          serviceName: "104.198.149.61",
          websiteUri: "104.198.149.61",
          url: "wss://104.198.149.61:8443",
          protocol: ProviderProtocol.websocket),
      ElectrumApiProviderService(
          serviceName: "104.248.139.211:50002",
          websiteUri: "104.248.139.211:50002",
          url: "104.248.139.211:50002",
          protocol: ProviderProtocol.ssl),
      ApiProviderService.mempool,
      ApiProviderService.blockCypher,
    ],
    1: <ApiProviderService>[
      ElectrumApiProviderService(
          serviceName: "testnet.aranguren.org",
          websiteUri: "aranguren.org",
          url: "wss://testnet.aranguren.org:51004",
          protocol: ProviderProtocol.websocket),
      ElectrumApiProviderService(
          serviceName: "testnet.aranguren.org",
          websiteUri: "aranguren.org",
          url: "testnet.aranguren.org:51002",
          protocol: ProviderProtocol.ssl),
      ElectrumApiProviderService(
          serviceName: "blockstream",
          websiteUri: "blockstream.info",
          url: "blockstream.info:700",
          protocol: ProviderProtocol.ssl),
      ApiProviderService.mempool,
      ApiProviderService.blockCypher,
    ],
    2: <ApiProviderService>[
      ElectrumApiProviderService(
          serviceName: "qortal",
          websiteUri: "electrum.qortal.link",
          url: "wss://electrum.qortal.link:50004",
          protocol: ProviderProtocol.websocket),
      ElectrumApiProviderService(
          serviceName: "46.101.3.154",
          websiteUri: "46.101.3.154",
          url: "wss://46.101.3.154:50004",
          protocol: ProviderProtocol.websocket),
      ElectrumApiProviderService(
          serviceName: "46.101.3.154",
          websiteUri: "46.101.3.154",
          url: "46.101.3.154:50002",
          protocol: ProviderProtocol.ssl),
      ElectrumApiProviderService(
          serviceName: "backup.electrum-ltc.org",
          websiteUri: "backup.electrum-ltc.org",
          url: "backup.electrum-ltc.org:443",
          protocol: ProviderProtocol.ssl),
      ApiProviderService.blockCypher,
    ],
    7: <ApiProviderService>[
      ElectrumApiProviderService(
          serviceName: "electrum-ltc.bysh.me",
          websiteUri: "electrum-ltc.bysh.me",
          url: "electrum-ltc.bysh.me:51002",
          protocol: ProviderProtocol.ssl),
      ElectrumApiProviderService(
          serviceName: "electrum.ltc.xurious.com",
          websiteUri: "electrum.ltc.xurious.com",
          url: "electrum.ltc.xurious.com:51002",
          protocol: ProviderProtocol.ssl),
    ],
    3: <ApiProviderService>[
      ElectrumApiProviderService(
          serviceName: "electrum.qortal.link",
          websiteUri: "electrum.qortal.link",
          url: "electrum.qortal.link:54002",
          protocol: ProviderProtocol.ssl),
      ElectrumApiProviderService(
          serviceName: "qortal",
          websiteUri: "electrum.qortal.link",
          url: "wss://electrum.qortal.link:54004",
          protocol: ProviderProtocol.websocket),
      ApiProviderService.blockCypher
    ],
    8: <ApiProviderService>[],
    9: <ApiProviderService>[
      ElectrumApiProviderService(
          serviceName: "electrumx.bitcoinsv.io",
          websiteUri: "electrumx.bitcoinsv.io",
          url: "electrumx.bitcoinsv.io:50002",
          protocol: ProviderProtocol.ssl),
    ],
    4: <ApiProviderService>[
      ApiProviderService.blockCypher,
    ],
    10: <ApiProviderService>[
      ElectrumApiProviderService(
          serviceName: "electrum.imaginary.cash",
          websiteUri: "electrum.imaginary.cash",
          url: "wss://electrum.imaginary.cash:50004",
          protocol: ProviderProtocol.websocket),
      ElectrumApiProviderService(
          serviceName: "electrum.imaginary.cash",
          websiteUri: "electrum.imaginary.cash",
          url: "electrum.imaginary.cash:50002",
          protocol: ProviderProtocol.ssl),

      ///
      ElectrumApiProviderService(
          serviceName: "bch.loping.net",
          websiteUri: "bch.loping.net",
          url: "wss://bch.loping.net:50004",
          protocol: ProviderProtocol.websocket),
      ElectrumApiProviderService(
          serviceName: "bch.loping.net",
          websiteUri: "bch.loping.net",
          url: "bch.loping.net:50002",
          protocol: ProviderProtocol.ssl),
    ],
    11: <ApiProviderService>[
      ElectrumApiProviderService(
          serviceName: "Chipnet-Websocket",
          websiteUri: "https://chipnet.imaginary.cash",
          url: "wss://chipnet.imaginary.cash:50004",
          protocol: ProviderProtocol.websocket),
      ElectrumApiProviderService(
          serviceName: "Chipnet-ssl",
          websiteUri: "https://chipnet.imaginary.cash",
          url: "chipnet.imaginary.cash:50002",
          protocol: ProviderProtocol.ssl)
    ],
    30: <ApiProviderService>[
      ApiProviderService.xrplWebsocket,
      ApiProviderService.xrpl
    ],
    31: <ApiProviderService>[
      ApiProviderService.xrplWebsocket,
      ApiProviderService.xrpl
    ],
    32: <ApiProviderService>[
      ApiProviderService.xrplWebsocket,
      ApiProviderService.xrpl
    ],
    33: <ApiProviderService>[
      const SolanaApiProviderService(
          httpNodeUri: "https://api.mainnet-beta.solana.com",
          serviceName: "solana",
          websiteUri: "solana.com")
    ],
    34: <ApiProviderService>[
      const SolanaApiProviderService(
          httpNodeUri: "https://api.testnet.solana.com",
          serviceName: "solana",
          websiteUri: "solana.com")
    ],
    50: <ApiProviderService>[
      CardanoAPIProviderService(
          uri: "https://cardano-mainnet.blockfrost.io/api/v0/",
          serviceName: "blockfrost",
          websiteUri: "blockfrost.io",
          projectId: "mainnetolePdeWQLX8TrfG9V6RVaAshQi4pWzbU")
    ],
    51: <ApiProviderService>[
      CardanoAPIProviderService(
          uri: "https://cardano-preprod.blockfrost.io/api/v0/",
          serviceName: "blockfrost",
          websiteUri: "blockfrost.io",
          projectId: "preprodMVwzqm4PuBDBSfEULoMzoj5QZcy5o3z5")
    ],
    100: <ApiProviderService>[
      EVMApiProviderService(
        serviceName: "publicnode",
        websiteUri: "ethereum.publicnode.com",
        uri: "wss://ethereum.publicnode.com",
      ),
      EVMApiProviderService(
        serviceName: "publicnode",
        websiteUri: "ethereum.publicnode.com",
        uri: "wss://ethereum.publicnode.com",
      ),
    ],
    101: <ApiProviderService>[
      EVMApiProviderService(
        serviceName: "publicnode.com",
        websiteUri: "https://ethereum-sepolia.publicnode.com",
        uri: "https://ethereum-sepolia.publicnode.com",
      ),
    ],
    102: <ApiProviderService>[
      EVMApiProviderService(
        serviceName: "publicnode.com",
        websiteUri: "https://polygon-bor.publicnode.com",
        uri: "https://polygon-bor.publicnode.com",
      )
    ],
    103: <ApiProviderService>[
      EVMApiProviderService(
        serviceName: "publicnode.com",
        uri: "https://polygon-mumbai-bor.publicnode.com",
        websiteUri: "https://polygon-mumbai-bor.publicnode.com",
      ),
    ],
    104: <ApiProviderService>[
      EVMApiProviderService(
        serviceName: "publicnode.com",
        uri: "https://bsc.publicnode.com",
        websiteUri: "https://bsc.publicnode.com",
      ),
    ],
    105: <ApiProviderService>[
      EVMApiProviderService(
        serviceName: "publicnode.com",
        websiteUri: "https://bsc-testnet.publicnode.com",
        uri: "https://bsc-testnet.publicnode.com",
      ),
    ],
    200: <ApiProviderService>[
      CosmosAPIProviderService(
          serviceName: "cosmos-rpc.publicnode.com",
          websiteUri: "https://cosmos-rpc.publicnode.com:443",
          uri: "https://cosmos-rpc.publicnode.com:443",
          nodeUri: null),
    ],
    201: <ApiProviderService>[
      CosmosAPIProviderService(
          serviceName: "polypore.xyz",
          websiteUri: "https://rpc.sentry-02.theta-testnet.polypore.xyz",
          uri: "https://rpc.sentry-02.theta-testnet.polypore.xyz",
          nodeUri: null),
    ],
    202: <ApiProviderService>[
      CosmosAPIProviderService(
          serviceName: "mayachain.info",
          websiteUri: "https://tendermint.mayachain.info",
          uri: "https://tendermint.mayachain.info",
          nodeUri: "https://mayanode.mayachain.info/mayachain"),
    ],
    203: <ApiProviderService>[
      CosmosAPIProviderService(
          serviceName: "liquify.com",
          websiteUri: "https://rpc.thorchain.liquify.com",
          uri: "https://rpc.thorchain.liquify.com/",
          nodeUri: "https://thornode.ninerealms.com/thorchain"),
    ],
    204: <ApiProviderService>[
      CosmosAPIProviderService(
          serviceName: "polkachu.com",
          websiteUri: "https://kujira-testnet-rpc.polkachu.com/",
          uri: "https://kujira-testnet-rpc.polkachu.com/",
          nodeUri: "https://kujira-testnet-rpc.polkachu.com/"),
    ],
    205: <ApiProviderService>[
      CosmosAPIProviderService(
          serviceName: "polkachu.com",
          websiteUri: "https://kujira-rpc.polkachu.com/",
          uri: "https://kujira-rpc.polkachu.com/",
          nodeUri: "https://kujira-rpc.polkachu.com/"),
    ],
    1001: <ApiProviderService>[
      const TronApiProviderService(
        serviceName: "trongrid",
        websiteUri: "https://trongrid.io",
        httpNodeUri: "https://api.trongrid.io",
      ),
      EVMApiProviderService(
        serviceName: "https://api.trongrid.io/jsonrpc",
        websiteUri: "trongrid.io",
        uri: "https://api.trongrid.io/jsonrpc",
      ),
    ],
    1002: <ApiProviderService>[
      const TronApiProviderService(
        serviceName: "trongrid",
        websiteUri: "https://trongrid.io",
        httpNodeUri: "https://api.shasta.trongrid.io",
      ),
      EVMApiProviderService(
        serviceName: "https://api.shasta.trongrid.io/jsonrpc",
        websiteUri: "trongrid.io",
        uri: "https://api.shasta.trongrid.io/jsonrpc",
      )
    ],
    1003: <ApiProviderService>[
      const TronApiProviderService(
          serviceName: "trongrid",
          websiteUri: "https://trongrid.io",
          httpNodeUri: "https://nile.trongrid.io"),
      EVMApiProviderService(
          serviceName: "https://nile.trongrid.io/jsonrpc",
          websiteUri: "trongrid.io",
          uri: "https://nile.trongrid.io/jsonrpc"),
    ],
  });

  static ApiProviderService? getDefaultService(AppNetworkImpl network,
      {ApiProviderService? service}) {
    if (_providers[network.value]?.isEmpty ?? true) return null;
    final networkServices = getDefaultServices(network);
    if (networkServices.isEmpty) return null;
    if (service == null) {
      return networkServices.first;
    }
    return networkServices.firstWhere(
      (element) =>
          element.serviceName == service.serviceName &&
          element.protocol == service.protocol,
      orElse: () => networkServices.first,
    );
  }

  static EVMApiProviderService? getEVMService(AppNetworkImpl network,
      {ApiProviderService? service}) {
    if (_providers[network.value]?.isEmpty ?? true) return null;
    final networkServices =
        _providers[network.value]!.whereType<EVMApiProviderService>();
    return networkServices.firstWhere(
      (element) =>
          element.serviceName == service?.serviceName &&
          element.protocol.platforms.contains(PlatformInterface.appPlatform),
      orElse: () => networkServices.first,
    );
  }

  static List<ApiProviderService> getDefaultServices(AppNetworkImpl network) {
    return _providers[network.value]
            ?.where((element) => element.protocol.platforms
                .contains(PlatformInterface.appPlatform))
            .toList() ??
        <ApiProviderService>[];
  }

  static String? getGnesisHash(AppNetworkImpl network) {
    return gnesisHash[network.value];
  }
}
