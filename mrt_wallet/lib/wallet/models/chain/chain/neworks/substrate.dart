part of 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';

class SubstrateChain extends Chain<
    SubstrateAPIProvider,
    SubstrateNetworkParams,
    BaseSubstrateAddress,
    TokenCore,
    NFTCore,
    ISubstrateAddress,
    WalletSubstrateNetwork,
    SubstrateClient,
    ChainStorageKey,
    DefaultChainConfig,
    WalletTransaction<SubstrateAddress>> {
  SubstrateChain._(
      {required super.network,
      required super.totalBalance,
      required super.addressIndex,
      required super.id,
      required super.config,
      required super.client,
      required super.contacts,
      required super.addresses,
      required super.status})
      : super._();
  @override
  SubstrateChain copyWith(
      {WalletSubstrateNetwork? network,
      Live<IntegerBalance>? totalBalance,
      List<ISubstrateAddress>? addresses,
      List<ContactCore<BaseSubstrateAddress>>? contacts,
      int? addressIndex,
      SubstrateClient? client,
      String? id,
      DefaultChainConfig? config,
      WalletChainStatus? status}) {
    return SubstrateChain._(
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

  factory SubstrateChain.setup({
    required WalletSubstrateNetwork network,
    required String id,
    SubstrateClient? client,
  }) {
    return SubstrateChain._(
        network: network,
        id: id,
        addressIndex: 0,
        totalBalance:
            Live(IntegerBalance.zero(network.coinParam.token.decimal!)),
        client: client,
        config: DefaultChainConfig.none,
        addresses: [],
        contacts: [],
        status: WalletChainStatus.ready);
  }

  factory SubstrateChain.deserialize(
      {required WalletSubstrateNetwork network,
      required CborListValue cbor,
      SubstrateClient? client}) {
    final int networkId = cbor.elementAt(0);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final List<CborObject> accounts = cbor.elementAt(1) ?? <CborObject>[];
    final List<ISubstrateAddress> toAccounts = [];
    for (final i in accounts) {
      final acc = MethodUtils.nullOnException(
          () => CryptoAddress.fromCbor(network, i).cast<ISubstrateAddress>());
      if (acc != null) {
        toAccounts.add(acc);
      }
    }
    int addressIndex = (cbor.elementAt(5) ?? 0);
    if (addressIndex >= toAccounts.length) {
      addressIndex = 0;
    }
    List<ContactCore<SubstrateAddress>> contacts = [];
    final List? cborContacts = cbor.elementAt(3);
    if (cborContacts != null) {
      contacts = cborContacts
          .map((e) => ContactCore.fromCborBytesOrObject<SubstrateAddress>(
              network,
              obj: e))
          .toList();
    }
    final BigInt? totalBalance = cbor.elementAt(4);

    return SubstrateChain._(
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
}
