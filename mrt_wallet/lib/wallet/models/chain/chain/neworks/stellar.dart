part of 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';

class StellarChain extends Chain<
    StellarAPIProvider,
    StellarNetworkParams,
    StellarAddress,
    TokenCore,
    NFTCore,
    IStellarAddress,
    WalletStellarNetwork,
    StellarClient> {
  StellarChain._(
      {required super.network,
      required super.totalBalance,
      required super.addressIndex,
      required super.id,
      super.client,
      super.contacts,
      super.addresses})
      : super._();
  @override
  StellarChain copyWith(
      {WalletStellarNetwork? network,
      Live<IntegerBalance>? totalBalance,
      List<IStellarAddress>? addresses,
      List<ContactCore<StellarAddress>>? contacts,
      int? addressIndex,
      StellarClient? client,
      String? id}) {
    return StellarChain._(
      network: network ?? this.network,
      totalBalance: totalBalance ?? this.totalBalance,
      addressIndex: addressIndex ?? _addressIndex,
      addresses: addresses ?? _addresses,
      contacts: contacts ?? _contacts,
      client: client ?? _client,
      id: id ?? this.id,
    );
  }

  factory StellarChain.setup(
      {required WalletStellarNetwork network,
      required String id,
      StellarClient? client}) {
    return StellarChain._(
        network: network,
        id: id,
        addressIndex: 0,
        totalBalance:
            Live(IntegerBalance.zero(network.coinParam.token.decimal!)),
        client: client);
  }

  factory StellarChain.deserialize(
      {required WalletStellarNetwork network,
      required CborListValue cbor,
      required String id,
      StellarClient? client}) {
    final int networkId = cbor.elementAt(0);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final List<CborObject> accounts = cbor.elementAt(1) ?? <CborObject>[];
    List<IStellarAddress> toAccounts = [];
    for (final i in accounts) {
      final acc = MethodUtils.nullOnException(
          () => CryptoAddress.fromCbor(network, i).cast<IStellarAddress>());
      if (acc != null) {
        toAccounts.add(acc);
      }
    }
    int addressIndex = (cbor.elementAt(5) ?? 0);
    if (addressIndex >= toAccounts.length) {
      addressIndex = 0;
    }
    List<ContactCore<StellarAddress>> contacts = [];
    final List? cborContacts = cbor.elementAt(3);
    if (cborContacts != null) {
      contacts = cborContacts
          .map((e) => ContactCore.fromCborBytesOrObject<StellarAddress>(network,
              obj: e))
          .toList();
    }
    final BigInt? totalBalance = cbor.elementAt(4);

    return StellarChain._(
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
