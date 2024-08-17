part of 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';

class SubstrateChain extends Chain<
    SubstrateAPIProvider,
    SubstrateNetworkParams,
    SubstrateAddress,
    TokenCore,
    NFTCore,
    ISubstrateAddress,
    WalletPolkadotNetwork,
    SubstrateClient> {
  SubstrateChain._(
      {required super.network,
      required super.totalBalance,
      required super.addressIndex,
      required super.id,
      super.client,
      super.contacts,
      super.addresses})
      : super._();
  @override
  SubstrateChain copyWith({
    WalletPolkadotNetwork? network,
    Live<IntegerBalance>? totalBalance,
    List<ISubstrateAddress>? addresses,
    List<ContactCore<SubstrateAddress>>? contacts,
    int? addressIndex,
    SubstrateClient? client,
    String? id,
  }) {
    return SubstrateChain._(
        network: network ?? this.network,
        totalBalance: totalBalance ?? this.totalBalance,
        addressIndex: addressIndex ?? _addressIndex,
        addresses: addresses ?? _addresses,
        contacts: contacts ?? _contacts,
        client: client ?? _client,
        id: id ?? this.id);
  }

  factory SubstrateChain.setup({
    required WalletPolkadotNetwork network,
    required String id,
    SubstrateClient? client,
  }) {
    return SubstrateChain._(
        network: network,
        id: id,
        addressIndex: 0,
        totalBalance:
            Live(IntegerBalance.zero(network.coinParam.token.decimal!)),
        client: client);
  }

  factory SubstrateChain.deserialize(
      {required WalletPolkadotNetwork network,
      required CborListValue cbor,
      required String id,
      SubstrateClient? client}) {
    final int networkId = cbor.elementAt(0);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final List<CborObject> accounts = cbor.elementAt(1) ?? <CborObject>[];
    List<ISubstrateAddress> toAccounts = [];
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
      id: cbor.elementAt<String?>(8) ?? id,
    );
  }
}
