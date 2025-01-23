part of 'package:mrt_wallet/wallet/provider/wallet_provider.dart';

class ChainsHandler with CborSerializable {
  final Map<int, Chain> _networks;
  final String id;
  int _network;
  ChainsHandler._(this._networks, this._network, this.id);

  factory ChainsHandler.fromWeb3(
      {String? hex, CborObject? obj, List<int>? bytes}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        hex: hex,
        tags: CborTagsConst.chainHandler);
    final String id = values.elementAs(2);
    final chains = values
        .elementAsListOf<CborObject>(0)
        .map((e) => Chain.deserialize(obj: e))
        .toList();
    return ChainsHandler.__(
        chains: chains, currentNetwork: values.elementAs(1), id: id);
  }
  factory ChainsHandler(
      {required List<Chain> chains, required String id, int? currentNetwork}) {
    for (final i in chains) {
      if (i.id != id) {
        throw WalletExceptionConst.invalidData(
            messsage: "Invalid chain data. different wallet ids detected.");
      }
    }
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
  factory ChainsHandler.__(
      {required List<Chain> chains, required String id, int? currentNetwork}) {
    final toMap = {for (final i in chains) i.network.value: i};
    if (!toMap.containsKey(currentNetwork)) {
      currentNetwork = 0;
    }
    for (final i in chains) {
      if (i.id != id) {
        throw WalletExceptionConst.invalidData(
            messsage: "Invalid chain data. different wallet ids detected.");
      }
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

  Future<bool> switchNetwork(int networkId) async {
    if (_network == networkId || !_networks.containsKey(networkId)) {
      return false;
    }
    final currentChain = chain;
    _network = networkId;
    currentChain.disposeProvider();
    await chain.init();
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
    int networkId = network.value;
    if (!network.isWalletNetwork) {
      if (!network.supportImportNetwork) {
        throw const WalletException("invalid_network_information");
      }
      if (_networks.values.any((e) =>
          e.network.type == network.type &&
          e.network.identifier == network.identifier)) {
        throw const WalletException("network_chain_id_already_exist");
      }
      final ids = _networks.values.map((e) => e.network.value).toList();
      networkId = StrUtils.findFirstMissingNumber(ids,
          start: ChainConst.importedNetworkStartId);
      network = network.copyWith(value: networkId);
    } else {
      if (_networks[networkId] == null ||
          _networks[networkId]!.network.type != network.type) {
        throw const WalletException("invalid_network_information");
      }
    }
    _networks[networkId] = _networks[networkId]?.copyWith(network: network) ??
        Chain.setup(network: network, id: id);
    return _networks[networkId]!;
  }

  Future<void> removeChain(Chain removeChain) async {
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
      await switchNetwork(changeNetwork);
    }
    _networks.remove(removeChain.network.value);
  }

  @override
  CborTagValue toCbor({bool onlyWeb3Chains = false}) {
    return CborTagValue(
        CborListValue.fixedLength([
          if (onlyWeb3Chains)
            CborListValue.fixedLength(_networks.values
                .where((e) => e.network.supportWeb3)
                .map((e) => e.toCbor())
                .toList())
          else
            CborListValue.fixedLength(
                _networks.values.map((e) => e.toCbor()).toList()),
          _network,
          id
        ]),
        CborTagsConst.chainHandler);
  }

  List<Web3ChainNetworkData> getWeb3NetworkData() {
    return _networks.values
        .where((e) => e.network.supportWeb3)
        .map((e) {
          return switch (e.network.type) {
            NetworkType.ethereum => Web3ChainNetworkData<WalletEthereumNetwork>(
                network: e.network.toNetwork(),
                serviceIdentifier:
                    e.clientNullable?.service.provider.identifier),
            NetworkType.tron => Web3ChainNetworkData<WalletTronNetwork>(
                network: e.network.toNetwork(),
                serviceIdentifier:
                    e.clientNullable?.service.provider.identifier),
            NetworkType.solana => Web3ChainNetworkData<WalletSolanaNetwork>(
                network: e.network.toNetwork(),
                serviceIdentifier:
                    e.clientNullable?.service.provider.identifier),
            NetworkType.stellar => Web3ChainNetworkData<WalletStellarNetwork>(
                network: e.network.toNetwork(),
                serviceIdentifier:
                    e.clientNullable?.service.provider.identifier),
            NetworkType.ton => Web3ChainNetworkData<WalletTonNetwork>(
                network: e.network.toNetwork(),
                serviceIdentifier:
                    e.clientNullable?.service.provider.identifier),
            NetworkType.substrate =>
              Web3ChainNetworkData<WalletSubstrateNetwork>(
                  network: e.network.toNetwork(),
                  serviceIdentifier:
                      e.clientNullable?.service.provider.identifier),
            _ => throw UnimplementedError()
          };
        })
        .toList()
        .cast();
  }
}
