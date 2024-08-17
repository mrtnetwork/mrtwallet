part of 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';

class BitcoinChain extends Chain<
    BaseBitcoinAPIProvider,
    BitcoinParams,
    BitcoinBaseAddress,
    TokenCore,
    NFTCore,
    IBitcoinAddress,
    WalletBitcoinNetwork,
    BitcoinClient> {
  BitcoinChain._({
    required super.network,
    required super.totalBalance,
    required super.addressIndex,
    required super.id,
    super.client,
    super.contacts,
    super.addresses,
  }) : super._();
  @override
  BitcoinChain copyWith(
      {WalletBitcoinNetwork? network,
      Live<IntegerBalance>? totalBalance,
      List<IBitcoinAddress>? addresses,
      List<ContactCore<BitcoinBaseAddress>>? contacts,
      int? addressIndex,
      BitcoinClient? client,
      String? id}) {
    return BitcoinChain._(
      network: network ?? this.network,
      totalBalance: totalBalance ?? this.totalBalance,
      addressIndex: addressIndex ?? _addressIndex,
      addresses: addresses ?? _addresses,
      contacts: contacts ?? _contacts,
      client: client ?? _client,
      id: id ?? this.id,
    );
  }

  factory BitcoinChain.setup(
      {required WalletBitcoinNetwork network,
      required String id,
      BitcoinClient? client}) {
    return BitcoinChain._(
        network: network,
        addressIndex: 0,
        id: id,
        totalBalance:
            Live(IntegerBalance.zero(network.coinParam.token.decimal!)),
        client: client);
  }

  factory BitcoinChain.deserialize(
      {required WalletBitcoinNetwork network,
      required CborListValue cbor,
      required String id,
      BitcoinClient? client}) {
    final int networkId = cbor.elementAt(0);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final List<CborObject> accounts = cbor.elementAt(1) ?? <CborObject>[];
    List<IBitcoinAddress> toAccounts = [];
    for (final i in accounts) {
      final acc = MethodUtils.nullOnException(
          () => CryptoAddress.fromCbor(network, i).cast<IBitcoinAddress>());
      if (acc != null) {
        toAccounts.add(acc);
      }
    }
    int addressIndex = (cbor.elementAt(5) ?? 0);
    if (addressIndex >= toAccounts.length) {
      addressIndex = 0;
    }
    List<ContactCore<BitcoinBaseAddress>> contacts = [];
    final List? cborContacts = cbor.elementAt(3);
    if (cborContacts != null) {
      contacts = cborContacts
          .map((e) => ContactCore.fromCborBytesOrObject<BitcoinBaseAddress>(
              network,
              obj: e))
          .toList();
    }
    final BigInt? totalBalance = cbor.elementAt(4);

    return BitcoinChain._(
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
