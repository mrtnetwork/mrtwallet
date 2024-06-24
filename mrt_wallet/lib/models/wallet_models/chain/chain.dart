import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/account/account.dart';
import 'package:mrt_wallet/models/wallet_models/address/core/address.dart';
import 'package:mrt_wallet/models/wallet_models/chain/defauilt_node_providers.dart';
import 'package:mrt_wallet/models/wallet_models/chain/utils.dart';
import 'package:mrt_wallet/models/wallet_models/network/core/network.dart';
import 'package:mrt_wallet/provider/api/core/api_provider.dart';

import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class AppChain with CborSerializable {
  AppChain._(this.network, this._networkApiProvider, this.account)
      : assert(network.value == account.network.value, "invalid account");
  final AppNetworkImpl network;
  final NetworkAccountCore account;
  bool get haveAddress => account.haveAddress;
  NetworkApiProvider? _networkApiProvider;
  late final List<String> services = List.unmodifiable(_services(network));
  static List<String> _services(AppNetworkImpl network) {
    switch (network.type) {
      case NetworkType.xrpl:
        return ["services", "tokens"];
      case NetworkType.tron:
        return ["services", "trc20_tokens", "trc10_tokens"];
      case NetworkType.ethereum:
        return ["tokens"];
      case NetworkType.solana:
        return ["services", "tokens"];
      case NetworkType.ton:
        return ["services", "jettons"];
      default:
        return ["services"];
    }
  }

  factory AppChain.fromAccount(NetworkAccountCore account) {
    return AppChain._(
        account.network, ChainUtils.buildApiProvider(account.network), account);
  }

  T? provider<T extends NetworkApiProvider>([ApiProviderService? service]) {
    return _networkApiProvider as T?;
  }

  void setProvider(ApiProviderService service) {
    final currentProvider = _networkApiProvider;
    _networkApiProvider =
        ChainUtils.buildApiProvider(network, service: service);
    currentProvider?.serviceProvider.notify();
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.dynamicLength([
          network.toCbor(),
          _networkApiProvider?.serviceProvider.provider.toCbor(),
          account.toCbor()
        ]),
        WalletModelCborTagsConst.network);
  }

  factory AppChain.fromHex(String hex) {
    return AppChain.fromCborBytesOrObject(bytes: BytesUtils.fromHexString(hex));
  }

  factory AppChain.fromCborBytesOrObject({List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.network);
    final network =
        AppNetworkImpl.fromCborBytesOrObject(obj: cbor.getCborTag(0));
    final provider = cbor.getCborTag(1) == null
        ? null
        : ApiProviderService.fromCborBytesOrObject(obj: cbor.getCborTag(1));
    final apiProvider = ChainUtils.buildApiProvider(network, service: provider);
    return AppChain._(
        network, apiProvider, ChainUtils.account(network, cbor.getCborTag(2)));
  }
}

class AppChains {
  AppChains._(this.networks, this._network);
  final Map<int, AppChain> networks;
  int _network;
  AppNetworkImpl get network => networks[_network]!.network;
  AppChain get chain => networks[_network]!;
  factory AppChains.setup() {
    return AppChains._({
      for (final i in ChainUtils.defaultCoins.values)
        i.value: AppChain._(i, ChainUtils.buildApiProvider(i),
            ChainUtils.createNetworkAccount(i))
    }, 0);
  }

  factory AppChains(List<AppChain> chains, {int? currentNetwork}) {
    final toMap = {for (final i in chains) i.network.value: i};
    for (final i in ChainUtils.defaultCoins.keys) {
      if (toMap.containsKey(i)) {
        continue;
      }
      final network = ChainUtils.defaultCoins[i]!;
      toMap.addAll({
        network.value: AppChain._(network, ChainUtils.buildApiProvider(network),
            ChainUtils.createNetworkAccount(network))
      });
    }
    if (!toMap.containsKey(currentNetwork)) {
      currentNetwork = 0;
    }
    return AppChains._(toMap, currentNetwork ?? 0);
  }

  void setNetwork(int networkId) {
    if (_network == networkId || !networks.containsKey(networkId)) return;
    final currentChain = chain;
    _network = networkId;
    currentChain._networkApiProvider?.serviceProvider.notify();
    chain._networkApiProvider?.serviceProvider.notify();
  }

  AppChain fromAccount(NetworkAccountCore account) =>
      networks[account.network.value]!;
  AppChain fromAddress(CryptoAccountAddress adresss) =>
      networks[adresss.network]!;
  AppChain updateImportNetwork(AppNetworkImpl network) {
    if (network.coinParam.providers.isEmpty) {
      if (DefaultNodeProviders.getDefaultServices(network).isEmpty) {
        throw WalletException("invalid_network_information");
      }
    }

    int networkId = network.value;
    if (networkId == 0) {
      if (network is! APPEVMNetwork) {
        throw WalletException("invalid_network_information");
      }
      if (network.coinParam.token.decimal != EthereumUtils.decimal) {
        throw WalletException("invalid_network_information");
      }
      final evmIds = networks.values.map((e) => e.network.value).toList();
      networkId = AppStringUtility.findFirstMissingNumber(evmIds, start: 100);
      network = network.copyWith(value: networkId);
    } else {
      if (networks[networkId] == null ||
          networks[networkId]!.network.runtimeType != network.runtimeType ||
          network.value != _network) {
        throw WalletException("invalid_network_information");
      }
    }
    final currentChain = chain;
    final updateChain = AppChain._(
        network,
        ChainUtils.buildApiProvider(network),
        networks[networkId]?.account ??
            ChainUtils.createNetworkAccount(network));
    networks[networkId] = updateChain;
    currentChain._networkApiProvider?.serviceProvider.notify();
    return chain;
  }
}
