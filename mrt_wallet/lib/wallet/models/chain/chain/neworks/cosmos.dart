part of 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';

class CosmosChain extends Chain<
    CosmosAPIProvider,
    CosmosNetworkParams,
    CosmosBaseAddress,
    TokenCore,
    NFTCore,
    ICosmosAddress,
    WalletCosmosNetwork,
    CosmosClient> {
  CosmosChain._({
    required super.network,
    required super.totalBalance,
    required super.addressIndex,
    required super.id,
    super.client,
    super.contacts,
    super.addresses,
  }) : super._();
  @override
  CosmosChain copyWith(
      {WalletCosmosNetwork? network,
      Live<IntegerBalance>? totalBalance,
      List<ICosmosAddress>? addresses,
      List<ContactCore<CosmosBaseAddress>>? contacts,
      int? addressIndex,
      CosmosClient? client,
      String? id}) {
    return CosmosChain._(
      network: network ?? this.network,
      totalBalance: totalBalance ?? this.totalBalance,
      addressIndex: addressIndex ?? _addressIndex,
      addresses: addresses ?? _addresses,
      contacts: contacts ?? _contacts,
      client: client ?? _client,
      id: id ?? this.id,
    );
  }

  factory CosmosChain.setup(
      {required WalletCosmosNetwork network,
      required String id,
      CosmosClient? client}) {
    return CosmosChain._(
        network: network,
        id: id,
        addressIndex: 0,
        totalBalance:
            Live(IntegerBalance.zero(network.coinParam.token.decimal!)),
        client: client);
  }
  factory CosmosChain.deserialize(
      {required WalletCosmosNetwork network,
      required CborListValue cbor,
      required String id,
      CosmosClient? client}) {
    final int networkId = cbor.elementAt(0);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final List<CborObject> accounts = cbor.elementAt(1) ?? <CborObject>[];
    List<ICosmosAddress> toAccounts = [];
    for (final i in accounts) {
      final acc = MethodUtils.nullOnException(
          () => CryptoAddress.fromCbor(network, i).cast<ICosmosAddress>());
      if (acc != null) {
        toAccounts.add(acc);
      }
    }
    int addressIndex = (cbor.elementAt(5) ?? 0);
    if (addressIndex >= toAccounts.length) {
      addressIndex = 0;
    }
    List<ContactCore<CosmosBaseAddress>> contacts = [];
    final List? cborContacts = cbor.elementAt(3);
    if (cborContacts != null) {
      contacts = cborContacts
          .map((e) => ContactCore.fromCborBytesOrObject<CosmosBaseAddress>(
              network,
              obj: e))
          .toList();
    }
    final BigInt? totalBalance = cbor.elementAt(4);

    return CosmosChain._(
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
