part of 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';

class TheOpenNetworkChain extends Chain<
    TonAPIProvider,
    TonNetworkParams,
    TonAddress,
    TonJettonToken,
    NFTCore,
    ITonAddress,
    WalletTonNetwork,
    TonClient> {
  TheOpenNetworkChain._(
      {required super.network,
      required super.totalBalance,
      required super.addressIndex,
      required super.id,
      super.client,
      super.contacts,
      super.addresses})
      : super._();
  @override
  TheOpenNetworkChain copyWith({
    WalletTonNetwork? network,
    Live<IntegerBalance>? totalBalance,
    List<ITonAddress>? addresses,
    List<ContactCore<TonAddress>>? contacts,
    int? addressIndex,
    TonClient? client,
    String? id,
  }) {
    return TheOpenNetworkChain._(
        network: network ?? this.network,
        totalBalance: totalBalance ?? this.totalBalance,
        addressIndex: addressIndex ?? _addressIndex,
        addresses: addresses ?? _addresses,
        contacts: contacts ?? _contacts,
        client: client ?? _client,
        id: id ?? this.id);
  }

  factory TheOpenNetworkChain.setup(
      {required WalletTonNetwork network,
      required String id,
      TonClient? client}) {
    return TheOpenNetworkChain._(
        network: network,
        id: id,
        addressIndex: 0,
        totalBalance:
            Live(IntegerBalance.zero(network.coinParam.token.decimal!)),
        client: client);
  }

  factory TheOpenNetworkChain.deserialize(
      {required WalletTonNetwork network,
      required CborListValue cbor,
      required String id,
      TonClient? client}) {
    final int networkId = cbor.elementAt(0);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final List<CborObject> accounts = cbor.elementAt(1) ?? <CborObject>[];
    List<ITonAddress> toAccounts = [];
    for (final i in accounts) {
      final acc = MethodUtils.nullOnException(
          () => CryptoAddress.fromCbor(network, i).cast<ITonAddress>());
      if (acc != null) {
        toAccounts.add(acc);
      }
    }
    int addressIndex = (cbor.elementAt(5) ?? 0);
    if (addressIndex >= toAccounts.length) {
      addressIndex = 0;
    }
    List<ContactCore<TonAddress>> contacts = [];
    final List? cborContacts = cbor.elementAt(3);
    if (cborContacts != null) {
      contacts = cborContacts
          .map((e) =>
              ContactCore.fromCborBytesOrObject<TonAddress>(network, obj: e))
          .toList();
    }
    final BigInt? totalBalance = cbor.elementAt(4);

    return TheOpenNetworkChain._(
      network: network,
      addresses: toAccounts,
      addressIndex: addressIndex < 0 ? 0 : addressIndex,
      contacts: contacts,
      totalBalance: Live(IntegerBalance(
          totalBalance ?? BigInt.zero, network.coinParam.token.decimal!)),
      client: client,
      id: cbor.elementAt<String?>(8) ?? id,
    );
  }
}
