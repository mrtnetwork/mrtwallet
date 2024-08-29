import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';

import 'package:mrt_wallet/wallet/models/network/core/params/params.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/ethereum.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';

class EthereumNetworkParams extends NetworkCoinParams<EthereumAPIProvider> {
  final BigInt chainId;
  final bool supportEIP1559;
  final bool defaultNetwork;
  @override
  bool get isTestNet => defaultNetwork && !mainnet;
  EthereumNetworkParams(
      {required super.transactionExplorer,
      required super.addressExplorer,
      required super.token,
      required super.providers,
      required this.chainId,
      required this.supportEIP1559,
      required super.mainnet,
      super.bip32CoinType,
      this.defaultNetwork = true});
  EthereumNetworkParams copyWith(
      {String? transactionExplorer,
      String? addressExplorer,
      Token? token,
      List<EthereumAPIProvider>? providers,
      BigInt? chainId,
      bool? supportEIP1559,
      bool? mainnet,
      bool? defaultNetwork,
      int? bip32CoinType}) {
    return EthereumNetworkParams(
        transactionExplorer: transactionExplorer ?? this.transactionExplorer,
        addressExplorer: addressExplorer ?? this.addressExplorer,
        token: token ?? this.token,
        providers: providers ?? List.from(this.providers),
        chainId: chainId ?? this.chainId,
        supportEIP1559: supportEIP1559 ?? this.supportEIP1559,
        mainnet: mainnet ?? this.mainnet,
        defaultNetwork: defaultNetwork ?? this.defaultNetwork,
        bip32CoinType: bip32CoinType ?? this.bip32CoinType);
  }

  factory EthereumNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.evmNetworkParam);
    final bool? defaultNetwork = cbor.elementAt(7);
    return EthereumNetworkParams(
        chainId: cbor.elementAt(0),
        supportEIP1559: cbor.elementAt(1),
        mainnet: cbor.elementAt(2),
        transactionExplorer: cbor.elementAt(3),
        addressExplorer: cbor.elementAt(4),
        token: Token.fromCborBytesOrObject(obj: cbor.getCborTag(5)),
        providers: (cbor.elementAt(6) as List)
            .map((e) => EthereumAPIProvider.fromCborBytesOrObject(obj: e))
            .toList(),
        defaultNetwork: defaultNetwork ?? true,
        bip32CoinType: cbor.elementAt(8));
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          chainId,
          supportEIP1559,
          mainnet,
          transactionExplorer,
          addressExplorer,
          token.toCbor(),
          CborListValue.fixedLength(providers.map((e) => e.toCbor()).toList()),
          defaultNetwork,
          bip32CoinType
        ]),
        CborTagsConst.evmNetworkParam);
  }

  @override
  EthereumNetworkParams updateProviders(List<APIProvider> updateProviders) {
    return EthereumNetworkParams(
        transactionExplorer: transactionExplorer,
        addressExplorer: addressExplorer,
        token: token,
        providers: updateProviders.cast<EthereumAPIProvider>(),
        chainId: chainId,
        supportEIP1559: supportEIP1559,
        mainnet: mainnet,
        defaultNetwork: defaultNetwork,
        bip32CoinType: bip32CoinType);
  }
}
