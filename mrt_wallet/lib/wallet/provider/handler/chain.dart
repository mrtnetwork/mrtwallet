part of 'package:mrt_wallet/wallet/provider/wallet_provider.dart';

class ChainsHandler with CborSerializable {
  final Map<int, Chain> _networks;
  final String id;
  int _network;
  ChainsHandler._(this._networks, this._network, this.id);

  factory ChainsHandler.deserialize(
      {String? hex, CborObject? obj, List<int>? bytes}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        hex: hex,
        tags: CborTagsConst.chainHandler);
    final String id = values.elementAt(2);
    return ChainsHandler(
        chains: values
            .elementAt<List<dynamic>>(0)
            .map((e) => Chain.deserialize(id: id, obj: e))
            .toList(),
        currentNetwork: values.elementAt(1),
        id: values.elementAt(2));
  }
  factory ChainsHandler(
      {required List<Chain> chains, required String id, int? currentNetwork}) {
    final toMap = {for (final i in chains) i.network.value: i};
    for (final i in ChainConst.defaultCoins.keys) {
      if (toMap.containsKey(i)) {
        continue;
      }
      final network = ChainConst.defaultCoins[i]!;
      final chain = Chain.setup(network: network, id: id);
      toMap.addAll({chain.network.value: chain});
    }
    if (!toMap.containsKey(currentNetwork)) {
      currentNetwork = 0;
    }
    return ChainsHandler._(toMap, currentNetwork ?? 0, id);
  }
  factory ChainsHandler.setup(String id) {
    return ChainsHandler._({}, 0, id);
  }

  bool get hasChain => _networks.isNotEmpty;
  WalletNetwork get network => _networks[_network]!.network;
  Chain get chain => _networks[_network]!;
  List<ChainAccount> get accounts =>
      _networks.values.map((e) => e.addresses).expand((e) => e).toList();
  List<WalletNetwork> networks() =>
      _networks.values.map((e) => e.network).toList();

  List<String> coinIds() {
    final ids = _networks.values
        .map((e) => e.tokens().map((e) => e.token.market?.apiId))
        .expand((e) => e)
        .where((element) => element != null);
    final networkIds = _networks.values
        .map((e) => e.network.token.market?.apiId)
        .where((element) => element != null);
    return List<String>.from([...ids, ...networkIds]);
  }

  List<Chain> chains() => _networks.values.toList();

  bool switchNetwork(int networkId) {
    if (_network == networkId || !_networks.containsKey(networkId)) {
      return false;
    }
    final currentChain = chain;
    _network = networkId;
    currentChain.disposeProvider();
    chain.initProvider();
    return true;
  }

  Chain? fromAddress(ChainAccount adress) {
    final chain = _networks[adress.network];
    if (chain?.addresses.contains(adress) ?? false) {
      return chain;
    }
    return null;
  }

  Chain updateImportNetwork(WalletNetwork network) {
    if (network.coinParam.providers.isEmpty) {
      if (ProvidersConst.getDefaultProvider(network).isEmpty) {
        throw WalletException("invalid_network_information");
      }
    }

    int networkId = network.value;
    if (!network.isWalletNetwork) {
      if (network.type != NetworkType.ethereum) {
        throw WalletException("invalid_network_information");
      }
      if (network.coinParam.token.decimal != EthereumUtils.decimal) {
        throw WalletException("invalid_network_information");
      }
      final evmIds = _networks.values.map((e) => e.network.value).toList();
      networkId = StrUtils.findFirstMissingNumber(evmIds, start: 2000);
      network = network.copyWith(value: networkId);
    } else {
      if (_networks[networkId] == null ||
          _networks[networkId]!.network.type != network.type) {
        throw WalletException("invalid_network_information");
      }
    }
    _networks[networkId] = _networks[networkId]?.copyWith(network: network) ??
        Chain.setup(network: network, id: id);
    return _networks[networkId]!;
  }

  void updateChain(Chain? chain) {
    if (chain == null) return;
    _networks[chain.network.value] = chain;
  }

  void removeChain(Chain removeChain) {
    if (removeChain.id != id) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    final hasDefaultNetwork =
        ChainConst.defaultCoins[removeChain.network.value];
    if (!removeChain.network.isWalletNetwork || hasDefaultNetwork != null) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    if (_network == removeChain.network.value) {
      final changeNetwork = _networks.keys.firstWhere((e) =>
          e != removeChain.network.value &&
          _networks[e]!.network.type == removeChain.network.type);
      switchNetwork(changeNetwork);
    }
    _networks.remove(removeChain.network.value);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(
              _networks.values.map((e) => e.toCbor()).toList()),
          _network,
          id
        ]),
        CborTagsConst.chainHandler);
  }
}
