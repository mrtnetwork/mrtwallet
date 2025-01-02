part of 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';

class ADAChain extends Chain<
    CardanoAPIProvider,
    CardanoNetworkParams,
    ADAAddress,
    TokenCore,
    NFTCore,
    ICardanoAddress,
    WalletCardanoNetwork,
    CardanoClient,
    ChainStorageKey,
    DefaultChainConfig,
    WalletTransaction<ADAAddress>> {
  ADAChain._({
    required super.network,
    required super.totalBalance,
    required super.addressIndex,
    required super.id,
    required super.config,
    required super.client,
    required super.contacts,
    required super.addresses,
  }) : super._();
  @override
  ADAChain copyWith({
    WalletCardanoNetwork? network,
    Live<IntegerBalance>? totalBalance,
    List<ICardanoAddress>? addresses,
    List<ContactCore<ADAAddress>>? contacts,
    int? addressIndex,
    CardanoClient? client,
    String? id,
    DefaultChainConfig? config,
  }) {
    return ADAChain._(
        network: network ?? this.network,
        totalBalance: totalBalance ?? this.totalBalance,
        addressIndex: addressIndex ?? _addressIndex,
        addresses: addresses ?? _addresses,
        contacts: contacts ?? _contacts,
        client: client ?? _client,
        id: id ?? this.id,
        config: config ?? this.config);
  }

  factory ADAChain.setup({
    required WalletCardanoNetwork network,
    required String id,
    CardanoClient? client,
  }) {
    return ADAChain._(
        network: network,
        addressIndex: 0,
        id: id,
        totalBalance:
            Live(IntegerBalance.zero(network.coinParam.token.decimal!)),
        client: client,
        addresses: [],
        config: DefaultChainConfig.none,
        contacts: []);
  }

  factory ADAChain.deserialize(
      {required WalletCardanoNetwork network,
      required CborListValue cbor,
      CardanoClient? client}) {
    final int networkId = cbor.elementAt(0);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final List<CborObject> accounts = cbor.elementAt(1) ?? <CborObject>[];
    final List<ICardanoAddress> toAccounts = [];
    for (final i in accounts) {
      final acc = MethodUtils.nullOnException(
          () => CryptoAddress.fromCbor(network, i).cast<ICardanoAddress>());
      if (acc != null) {
        toAccounts.add(acc);
      }
    }
    int addressIndex = (cbor.elementAt(5) ?? 0);
    if (addressIndex >= toAccounts.length) {
      addressIndex = 0;
    }
    List<ContactCore<ADAAddress>> contacts = [];
    final List? cborContacts = cbor.elementAt(3);
    if (cborContacts != null) {
      contacts = cborContacts
          .map((e) =>
              ContactCore.fromCborBytesOrObject<ADAAddress>(network, obj: e))
          .toList();
    }
    final BigInt? totalBalance = cbor.elementAt(4);

    return ADAChain._(
        network: network,
        addresses: toAccounts,
        addressIndex: addressIndex < 0 ? 0 : addressIndex,
        contacts: contacts,
        totalBalance: Live(IntegerBalance(
            totalBalance ?? BigInt.zero, network.coinParam.token.decimal!)),
        client: client,
        id: cbor.elementAt<String>(8),
        config: DefaultChainConfig.none);
  }
}
