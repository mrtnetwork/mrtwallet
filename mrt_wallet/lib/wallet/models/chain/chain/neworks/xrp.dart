part of 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';

class RippleChain extends Chain<
    RippleAPIProvider,
    RippleNetworkParams,
    XRPAddress,
    RippleIssueToken,
    RippleNFToken,
    IXRPAddress,
    WalletXRPNetwork,
    RippleClient> {
  RippleChain._(
      {required super.network,
      required super.totalBalance,
      required super.addressIndex,
      required super.id,
      super.client,
      super.contacts,
      super.addresses})
      : super._();
  @override
  RippleChain copyWith({
    WalletXRPNetwork? network,
    Live<IntegerBalance>? totalBalance,
    List<IXRPAddress>? addresses,
    List<ContactCore<XRPAddress>>? contacts,
    int? addressIndex,
    RippleClient? client,
    String? id,
  }) {
    return RippleChain._(
        network: network ?? this.network,
        totalBalance: totalBalance ?? this.totalBalance,
        addressIndex: addressIndex ?? _addressIndex,
        addresses: addresses ?? _addresses,
        contacts: contacts ?? _contacts,
        client: client ?? _client,
        id: id ?? this.id);
  }

  factory RippleChain.setup(
      {required WalletXRPNetwork network,
      required String id,
      RippleClient? client}) {
    return RippleChain._(
        network: network,
        id: id,
        addressIndex: 0,
        totalBalance:
            Live(IntegerBalance.zero(network.coinParam.token.decimal!)),
        client: client);
  }

  factory RippleChain.deserialize(
      {required WalletXRPNetwork network,
      required CborListValue cbor,
      required String id,
      RippleClient? client}) {
    final int networkId = cbor.elementAt(0);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final List<CborObject> accounts = cbor.elementAt(1) ?? <CborObject>[];
    List<IXRPAddress> toAccounts = [];
    for (final i in accounts) {
      final acc = MethodUtils.nullOnException(
          () => CryptoAddress.fromCbor(network, i).cast<IXRPAddress>());
      if (acc != null) {
        toAccounts.add(acc);
      }
    }
    int addressIndex = (cbor.elementAt(5) ?? 0);
    if (addressIndex >= toAccounts.length) {
      addressIndex = 0;
    }
    List<ContactCore<XRPAddress>> contacts = [];
    final List? cborContacts = cbor.elementAt(3);
    if (cborContacts != null) {
      contacts = cborContacts
          .map((e) =>
              ContactCore.fromCborBytesOrObject<XRPAddress>(network, obj: e))
          .toList();
    }
    final BigInt? totalBalance = cbor.elementAt(4);
    return RippleChain._(
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
