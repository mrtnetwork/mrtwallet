part of 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';

class TronChain extends Chain<TronAPIProvider, TronNetworkParams, TronAddress,
    TronToken, NFTCore, ITronAddress, WalletTronNetwork, TronClient> {
  TronChain._({
    required super.network,
    required super.totalBalance,
    required super.addressIndex,
    required super.id,
    super.client,
    super.contacts,
    super.addresses,
  }) : super._();
  @override
  TronChain copyWith({
    WalletTronNetwork? network,
    Live<IntegerBalance>? totalBalance,
    List<ITronAddress>? addresses,
    List<ContactCore<TronAddress>>? contacts,
    int? addressIndex,
    TronClient? client,
    String? id,
  }) {
    return TronChain._(
        network: network ?? this.network,
        totalBalance: totalBalance ?? this.totalBalance,
        addressIndex: addressIndex ?? _addressIndex,
        addresses: addresses ?? _addresses,
        contacts: contacts ?? _contacts,
        client: client ?? _client,
        id: id ?? this.id);
  }

  factory TronChain.setup(
      {required WalletTronNetwork network,
      required String id,
      TronClient? client}) {
    return TronChain._(
        network: network,
        addressIndex: 0,
        id: id,
        totalBalance:
            Live(IntegerBalance.zero(network.coinParam.token.decimal!)),
        client: client);
  }
  factory TronChain.deserialize(
      {required WalletTronNetwork network,
      required CborListValue cbor,
      required String id,
      TronClient? client}) {
    final int networkId = cbor.elementAt(0);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final List<CborObject> accounts = cbor.elementAt(1) ?? <CborObject>[];
    List<ITronAddress> toAccounts = [];
    for (final i in accounts) {
      final acc = MethodUtils.nullOnException(
          () => CryptoAddress.fromCbor(network, i).cast<ITronAddress>());
      if (acc != null) {
        toAccounts.add(acc);
      }
    }
    int addressIndex = (cbor.elementAt(5) ?? 0);
    if (addressIndex >= toAccounts.length) {
      addressIndex = 0;
    }
    List<ContactCore<TronAddress>> contacts = [];
    final List? cborContacts = cbor.elementAt(3);
    if (cborContacts != null) {
      contacts = cborContacts
          .map((e) =>
              ContactCore.fromCborBytesOrObject<TronAddress>(network, obj: e))
          .toList();
    }
    final BigInt? totalBalance = cbor.elementAt(4);

    return TronChain._(
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
