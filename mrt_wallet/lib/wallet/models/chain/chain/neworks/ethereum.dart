part of 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';

class EthereumChain extends Chain<
    EthereumAPIProvider,
    EthereumNetworkParams,
    ETHAddress,
    ETHERC20Token,
    NFTCore,
    IEthAddress,
    WalletEthereumNetwork,
    EthereumClient,
    ChainStorageKey,
    DefaultChainConfig,
    WalletTransaction<ETHAddress>> {
  EthereumChain._(
      {required super.network,
      required super.totalBalance,
      required super.addressIndex,
      required super.id,
      required super.config,
      required super.contacts,
      required super.addresses,
      required super.client,
      required super.status})
      : super._();
  @override
  EthereumChain copyWith(
      {WalletEthereumNetwork? network,
      Live<IntegerBalance>? totalBalance,
      List<IEthAddress>? addresses,
      List<ContactCore<ETHAddress>>? contacts,
      int? addressIndex,
      EthereumClient? client,
      String? id,
      DefaultChainConfig? config,
      WalletChainStatus? status}) {
    return EthereumChain._(
        network: network ?? this.network,
        totalBalance: totalBalance ?? this.totalBalance,
        addressIndex: addressIndex ?? _addressIndex,
        addresses: addresses ?? _addresses,
        contacts: contacts ?? _contacts,
        client: client ?? _client,
        id: id ?? this.id,
        config: config ?? this.config,
        status: status ?? _chainStatus);
  }

  factory EthereumChain.setup(
      {required WalletEthereumNetwork network,
      required String id,
      EthereumClient? client}) {
    return EthereumChain._(
        network: network,
        id: id,
        addressIndex: 0,
        totalBalance:
            Live(IntegerBalance.zero(network.coinParam.token.decimal!)),
        client: client,
        addresses: [],
        config: DefaultChainConfig.none,
        contacts: [],
        status: WalletChainStatus.ready);
  }

  factory EthereumChain.deserialize(
      {required WalletEthereumNetwork network,
      required CborListValue cbor,
      EthereumClient? client}) {
    final int networkId = cbor.elementAt(0);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final List<CborObject> accounts = cbor.elementAt(1) ?? <CborObject>[];
    final List<IEthAddress> toAccounts = [];
    for (final i in accounts) {
      final acc = MethodUtils.nullOnException(() {
        return CryptoAddress.fromCbor(network, i).cast<IEthAddress>();
      });
      if (acc != null) {
        toAccounts.add(acc);
      }
    }
    int addressIndex = (cbor.elementAt(5) ?? 0);
    if (addressIndex >= toAccounts.length) {
      addressIndex = 0;
    }
    List<ContactCore<ETHAddress>> contacts = [];
    final List? cborContacts = cbor.elementAt(3);
    if (cborContacts != null) {
      contacts = cborContacts
          .map((e) =>
              ContactCore.fromCborBytesOrObject<ETHAddress>(network, obj: e))
          .toList();
    }
    final BigInt? totalBalance = cbor.elementAt(4);
    return EthereumChain._(
        network: network,
        addresses: toAccounts,
        addressIndex: addressIndex < 0 ? 0 : addressIndex,
        contacts: contacts,
        totalBalance: Live(IntegerBalance(
            totalBalance ?? BigInt.zero, network.coinParam.token.decimal!)),
        client: client,
        id: cbor.elementAt<String>(8),
        config: DefaultChainConfig.none,
        status: WalletChainStatus.ready);
  }

  BigInt get chainId => network.coinParam.chainId;
}
