part of 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';

class SolanaChain extends Chain<
    SolanaAPIProvider,
    SolanaNetworkParams,
    SolAddress,
    SolanaSPLToken,
    NFTCore,
    ISolanaAddress,
    WalletSolanaNetwork,
    SolanaClient,
    ChainStorageKey,
    DefaultChainConfig,
    WalletTransaction<SolAddress>> {
  SolanaChain._(
      {required super.network,
      required super.totalBalance,
      required super.addressIndex,
      required super.id,
      required super.config,
      required super.client,
      required super.contacts,
      required super.addresses})
      : super._();
  @override
  SolanaChain copyWith(
      {WalletSolanaNetwork? network,
      Live<IntegerBalance>? totalBalance,
      List<ISolanaAddress>? addresses,
      List<ContactCore<SolAddress>>? contacts,
      int? addressIndex,
      SolanaClient? client,
      String? id,
      DefaultChainConfig? config}) {
    return SolanaChain._(
        network: network ?? this.network,
        totalBalance: totalBalance ?? this.totalBalance,
        addressIndex: addressIndex ?? _addressIndex,
        addresses: addresses ?? _addresses,
        contacts: contacts ?? _contacts,
        client: client ?? _client,
        id: id ?? this.id,
        config: config ?? this.config);
  }

  factory SolanaChain.setup(
      {required WalletSolanaNetwork network,
      required String id,
      SolanaClient? client}) {
    return SolanaChain._(
        network: network,
        id: id,
        addressIndex: 0,
        totalBalance:
            Live(IntegerBalance.zero(network.coinParam.token.decimal!)),
        client: client,
        addresses: [],
        config: DefaultChainConfig.none,
        contacts: []);
  }

  factory SolanaChain.deserialize(
      {required WalletSolanaNetwork network,
      required CborListValue cbor,
      SolanaClient? client}) {
    final int networkId = cbor.elementAt(0);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final List<CborObject> accounts = cbor.elementAt(1) ?? <CborObject>[];
    final List<ISolanaAddress> toAccounts = [];
    for (final i in accounts) {
      final acc = MethodUtils.nullOnException(
          () => CryptoAddress.fromCbor(network, i).cast<ISolanaAddress>());
      if (acc != null) {
        toAccounts.add(acc);
      }
    }
    int addressIndex = (cbor.elementAt(5) ?? 0);
    if (addressIndex >= toAccounts.length) {
      addressIndex = 0;
    }
    List<ContactCore<SolAddress>> contacts = [];
    final List? cborContacts = cbor.elementAt(3);
    if (cborContacts != null) {
      contacts = cborContacts
          .map((e) =>
              ContactCore.fromCborBytesOrObject<SolAddress>(network, obj: e))
          .toList();
    }
    final BigInt? totalBalance = cbor.elementAt(4);

    return SolanaChain._(
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
