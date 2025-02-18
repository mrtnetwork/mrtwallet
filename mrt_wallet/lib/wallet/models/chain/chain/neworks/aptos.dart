part of 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';

class AptosChain extends Chain<
    AptosAPIProvider,
    AptosNetworkParams,
    AptosAddress,
    AptosFATokens,
    NFTCore,
    IAptosAddress,
    WalletAptosNetwork,
    AptosClient,
    ChainStorageKey,
    DefaultChainConfig,
    WalletTransaction<AptosAddress>> {
  AptosChain._(
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
  AptosChain copyWith(
      {WalletAptosNetwork? network,
      Live<IntegerBalance>? totalBalance,
      List<IAptosAddress>? addresses,
      List<ContactCore<AptosAddress>>? contacts,
      int? addressIndex,
      AptosClient? client,
      String? id,
      DefaultChainConfig? config,
      WalletChainStatus? status}) {
    return AptosChain._(
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

  factory AptosChain.setup(
      {required WalletAptosNetwork network,
      required String id,
      AptosClient? client}) {
    return AptosChain._(
        network: network,
        id: id,
        addressIndex: 0,
        totalBalance:
            Live(IntegerBalance.zero(network.coinParam.token.decimal!)),
        client: client,
        addresses: [],
        config: DefaultChainConfig.none,
        contacts: [],
        status: WalletChainStatus.ready);
  }

  factory AptosChain.deserialize(
      {required WalletAptosNetwork network,
      required CborListValue cbor,
      AptosClient? client}) {
    final int networkId = cbor.elementAt(0);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final List<CborObject> accounts = cbor.elementAt(1) ?? <CborObject>[];
    final List<IAptosAddress> toAccounts = [];
    for (final i in accounts) {
      final acc = MethodUtils.nullOnException(
          () => CryptoAddress.fromCbor(network, i).cast<IAptosAddress>());
      if (acc != null) {
        toAccounts.add(acc);
      }
    }
    int addressIndex = (cbor.elementAt(5) ?? 0);
    if (addressIndex >= toAccounts.length) {
      addressIndex = 0;
    }
    List<ContactCore<AptosAddress>> contacts = [];
    final List? cborContacts = cbor.elementAt(3);
    if (cborContacts != null) {
      contacts = cborContacts
          .map((e) =>
              ContactCore.fromCborBytesOrObject<AptosAddress>(network, obj: e))
          .toList();
    }
    final BigInt? totalBalance = cbor.elementAt(4);

    return AptosChain._(
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
