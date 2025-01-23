part of 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';

class MoneroChain extends Chain<
    MoneroAPIProvider,
    MoneroNetworkParams,
    MoneroAddress,
    TokenCore,
    NFTCore,
    IMoneroAddress,
    WalletMoneroNetwork,
    MoneroClient,
    MoneroChainStorage,
    MoneroChainConfig,
    MoneroWalletTransaction> with MoneroChainRepository, MoneroChainController {
  MoneroChain._(
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
  MoneroChain copyWith(
      {WalletMoneroNetwork? network,
      Live<IntegerBalance>? totalBalance,
      List<IMoneroAddress>? addresses,
      List<ContactCore<MoneroAddress>>? contacts,
      int? addressIndex,
      MoneroClient? client,
      String? id,
      MoneroChainConfig? config,
      List<MoneroAccountBlocksTracker>? syncRequests,
      MoneroAccountBlocksTracker? defaultTracker,
      WalletChainStatus? status}) {
    return MoneroChain._(
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

  factory MoneroChain.setup({
    required WalletMoneroNetwork network,
    required String id,
    MoneroClient? client,
  }) {
    return MoneroChain._(
        network: network,
        addressIndex: 0,
        id: id,
        totalBalance:
            Live(IntegerBalance.zero(network.coinParam.token.decimal!)),
        client: client,
        config: MoneroChainConfig(),
        addresses: [],
        contacts: [],
        status: WalletChainStatus.ready);
  }

  factory MoneroChain.deserialize(
      {required WalletMoneroNetwork network,
      required CborListValue cbor,
      MoneroClient? client}) {
    final int networkId = cbor.elementAs(0);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final List<CborObject> accounts = cbor.elementAsListOf<CborObject>(1);
    final List<IMoneroAddress> toAccounts = [];
    for (final i in accounts) {
      final acc = MethodUtils.nullOnException(() {
        return CryptoAddress.fromCbor(network, i).cast<IMoneroAddress>();
      });
      if (acc != null) {
        toAccounts.add(acc);
      }
    }
    int addressIndex = cbor.elementAs<int?>(5) ?? 0;
    if (addressIndex >= toAccounts.length) {
      addressIndex = 0;
    }

    final cborContacts = cbor.elementAsListOf<CborObject>(3);
    final contacts = cborContacts
        .map((e) =>
            ContactCore.fromCborBytesOrObject<MoneroAddress>(network, obj: e))
        .toList();
    final BigInt? totalBalance = cbor.elementAs(4);

    return MoneroChain._(
        network: network,
        addresses: toAccounts,
        addressIndex: addressIndex < 0 ? 0 : addressIndex,
        contacts: contacts,
        totalBalance: Live(IntegerBalance(
            totalBalance ?? BigInt.zero, network.coinParam.token.decimal!)),
        client: client,
        id: cbor.elementAs<String>(8),
        config: cbor.elemetMybeAs<MoneroChainConfig, CborObject>(
                9, (e) => MoneroChainConfig.deserialize(object: e)) ??
            MoneroChainConfig(),
        status: WalletChainStatus.ready);
  }
}
