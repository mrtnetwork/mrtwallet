part of 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';

class EthereumChain extends Chain<
    EthereumAPIProvider,
    EthereumNetworkParams,
    ETHAddress,
    ETHERC20Token,
    NFTCore,
    IEthAddress,
    WalletEthereumNetwork,
    EthereumClient> {
  EthereumChain._({
    required super.network,
    required super.totalBalance,
    required super.addressIndex,
    required super.id,
    super.contacts,
    super.addresses,
    super.client,
  }) : super._();
  @override
  EthereumChain copyWith(
      {WalletEthereumNetwork? network,
      Live<IntegerBalance>? totalBalance,
      List<IEthAddress>? addresses,
      List<ContactCore<ETHAddress>>? contacts,
      int? addressIndex,
      EthereumClient? client,
      String? id}) {
    return EthereumChain._(
      network: network ?? this.network,
      totalBalance: totalBalance ?? this.totalBalance,
      addressIndex: addressIndex ?? _addressIndex,
      addresses: addresses ?? _addresses,
      contacts: contacts ?? _contacts,
      client: client ?? _client,
      id: id ?? this.id,
    );
  }

  factory EthereumChain.setup(
      {required WalletEthereumNetwork network,
      required String id,
      EthereumClient? client}) {
    return EthereumChain._(
        network: network,
        id: id,
        addressIndex: 0,
        totalBalance:
            Live(IntegerBalance.zero(network.coinParam.token.decimal!)),
        client: client);
  }

  factory EthereumChain.deserialize(
      {required WalletEthereumNetwork network,
      required CborListValue cbor,
      required String id,
      EthereumClient? client}) {
    final int networkId = cbor.elementAt(0);
    if (networkId != network.value) {
      throw WalletExceptionConst.incorrectNetwork;
    }
    final List<CborObject> accounts = cbor.elementAt(1) ?? <CborObject>[];
    List<IEthAddress> toAccounts = [];
    for (final i in accounts) {
      final acc = MethodUtils.nullOnException(() {
        return CryptoAddress.fromCbor(network, i).cast<IEthAddress>();
      });
      if (acc != null) {
        toAccounts.add(acc);
      }
    }
    int addressIndex = (cbor.elementAt(5) ?? 0);
    if (addressIndex >= toAccounts.length) {
      addressIndex = 0;
    }
    List<ContactCore<ETHAddress>> contacts = [];
    final List? cborContacts = cbor.elementAt(3);
    if (cborContacts != null) {
      contacts = cborContacts
          .map((e) =>
              ContactCore.fromCborBytesOrObject<ETHAddress>(network, obj: e))
          .toList();
    }
    final BigInt? totalBalance = cbor.elementAt(4);
    return EthereumChain._(
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

  BigInt get chainId => network.coinParam.chainId;

  // @override
  // Web3Request<Web3EthereumRequestParam> getOrCreatePermission(
  //     {required Web3RequestInfo<Web3EthereumRequestParam> params,
  //     required String url,
  //     String? title,
  //     APPImage? faviIcon}) {
  //   final permission = getPermission(
  //       params: params, url: url, faviIcon: faviIcon, title: title);
  //   return params.params.toRequest(
  //       permission: permission ??
  //           Web3EthereumPermission(
  //               ,
  //               url: url,
  //               activities: const [],
  //               chainId: network.coinParam.chainId),
  //       url: url,
  //       image: faviIcon);
  // }
}
