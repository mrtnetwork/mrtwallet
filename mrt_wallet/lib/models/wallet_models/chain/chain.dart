import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/account/account.dart';
import 'package:mrt_wallet/models/wallet_models/address/core/address.dart';
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
  NetworkApiProvider _networkApiProvider;

  factory AppChain.fromAccount(NetworkAccountCore account) {
    return AppChain._(
        account.network, ChainUtils.buildApiProvider(account.network), account);
  }

  T provider<T extends NetworkApiProvider>([ApiProviderService? service]) {
    return _networkApiProvider as T;
  }

  T providerFromService<T extends NetworkApiProvider>(
      ApiProviderService? service) {
    if (service == null ||
        _networkApiProvider.serviceProvider.provider.serviceName ==
            service.serviceName) {
      return _networkApiProvider as T;
    }
    return ChainUtils.buildApiProvider(network, service: service) as T;
  }

  void setProvider(ApiProviderService service) {
    _networkApiProvider =
        ChainUtils.buildApiProvider(network, service: service);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.dynamicLength([
          network.toCbor(),
          _networkApiProvider.serviceProvider.provider.toCbor(),
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
    final provider =
        ApiProviderService.fromCborBytesOrObject(obj: cbor.getCborTag(1));
    return AppChain._(
        network,
        ChainUtils.buildApiProvider(network, service: provider),
        ChainUtils.account(network, cbor.getCborTag(2)));
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
      if (toMap.containsKey(i)) continue;
      final network = ChainUtils.defaultCoins[i]!;
      toMap.addAll({
        network.value: AppChain._(network, ChainUtils.buildApiProvider(network),
            Bip32NetworkAccount.setup(network))
      });
    }
    if (!toMap.containsKey(currentNetwork)) {
      currentNetwork = 0;
    }
    return AppChains._(toMap, currentNetwork ?? 0);
  }

  void setNetwork(int networkId) {
    if (_network == networkId || !networks.containsKey(networkId)) return;
    _network = networkId;
  }

  T provider<T extends NetworkApiProvider>(int networkId,
      [ApiProviderService? service]) {
    return networks[networkId]!.providerFromService(service);
  }

  AppChain fromAccount(NetworkAccountCore account) =>
      networks[account.network.value]!;
  AppChain fromAddress(CryptoAccountAddress adresss) =>
      networks[adresss.network]!;
  AppChain importEvmNetwork(APPEVMNetwork network) {
    if (network.coinParam.providers.isEmpty) {
      throw WalletException("invalid_network_information");
    }
    if (network.coinParam.token.decimal != EthereumUtils.decimal) {
      throw WalletException("invalid_network_information");
    }
    int networkId = network.value;
    if (networkId == 0) {
      final evmIds = networks.values.map((e) => e.network.value).toList();
      networkId = AppStringUtility.findFirstMissingNumber(evmIds, start: 100);
      network = network.copyWith(value: networkId);
    } else {
      if (networks[networkId] == null ||
          networks[networkId]!.network is! APPEVMNetwork) {
        throw WalletException("invalid_network_information");
      }
    }
    final chain = AppChain._(
        network,
        ChainUtils.buildApiProvider(network),
        networks[networkId]?.account ??
            ChainUtils.createNetworkAccount(network));
    networks[networkId] = chain;
    return chain;
  }
}
