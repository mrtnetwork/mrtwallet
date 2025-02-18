part of 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';

class SuiChain extends Chain<
    SuiAPIProvider,
    SuiNetworkParams,
    SuiAddress,
    SuiToken,
    NFTCore,
    ISuiAddress,
    WalletSuiNetwork,
    SuiClient,
    ChainStorageKey,
    DefaultChainConfig,
    WalletTransaction<SuiAddress>> {
  SuiChain._(
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
  SuiChain copyWith(
      {WalletSuiNetwork? network,
      Live<IntegerBalance>? totalBalance,
      List<ISuiAddress>? addresses,
      List<ContactCore<SuiAddress>>? contacts,
      int? addressIndex,
      SuiClient? client,
      String? id,
      DefaultChainConfig? config,
      WalletChainStatus? status}) {
    return SuiChain._(
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

  factory SuiChain.setup(
      {required WalletSuiNetwork network,
      required String id,
      SuiClient? client}) {
    return SuiChain._(
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

  factory SuiChain.deserialize(
      {required WalletSuiNetwork network,
      required CborListValue cbor,
      SuiClient? client}) {
    final int networkId = cbor.elementAt(0);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final List<CborObject> accounts = cbor.elementAt(1) ?? <CborObject>[];
    final List<ISuiAddress> toAccounts = [];
    for (final i in accounts) {
      final acc = MethodUtils.nullOnException(
          () => CryptoAddress.fromCbor(network, i).cast<ISuiAddress>());
      if (acc != null) {
        toAccounts.add(acc);
      }
    }
    int addressIndex = (cbor.elementAt(5) ?? 0);
    if (addressIndex >= toAccounts.length) {
      addressIndex = 0;
    }
    List<ContactCore<SuiAddress>> contacts = [];
    final List? cborContacts = cbor.elementAt(3);
    if (cborContacts != null) {
      contacts = cborContacts
          .map((e) =>
              ContactCore.fromCborBytesOrObject<SuiAddress>(network, obj: e))
          .toList();
    }
    final BigInt? totalBalance = cbor.elementAt(4);

    return SuiChain._(
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
