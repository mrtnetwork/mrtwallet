import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/api/provider/provider.dart';

import 'package:mrt_wallet/wallet/models/network/core/params/params.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:blockchain_utils/bip/bip.dart';

enum AptosChainType {
  devnet(null),
  testnet(2),
  mainnet(1);

  const AptosChainType(this.id);
  final int? id;
  bool get isDevnet => this == devnet;
  String get identifier => "aptos:$name";
  static AptosChainType fromValue(int? value) {
    if (value == null || value > 170) return AptosChainType.devnet;
    return values.firstWhere(
      (e) => e.id == value,
      orElse: () => throw WalletExceptionConst.invalidData(
          messsage: "AptosChainType not found."),
    );
  }
}

class AptosNetworkParams extends NetworkCoinParams<AptosAPIProvider> {
  final AptosChainType aptosChainType;

  factory AptosNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.aptosNetworkParams);

    return AptosNetworkParams(
        token: Token.fromCborBytesOrObject(obj: values.getCborTag(0)),
        providers: values
            .elementAsListOf<CborTagValue>(1)
            .map((e) => AptosAPIProvider.fromCborBytesOrObject(obj: e))
            .toList(),
        aptosChainType: AptosChainType.fromValue(values.elementAs(2)),
        chainType: ChainType.fromValue(values.elementAs(3)),
        addressExplorer: values.elementAs(4),
        transactionExplorer: values.elementAs(5),
        bip32CoinType: values.elementAs(6));
  }
  AptosNetworkParams(
      {required super.token,
      required super.providers,
      required super.chainType,
      required this.aptosChainType,
      super.addressExplorer,
      super.transactionExplorer,
      super.bip32CoinType});

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          token.toCbor(),
          CborListValue.fixedLength(providers.map((e) => e.toCbor()).toList()),
          aptosChainType.id,
          chainType.name,
          addressExplorer,
          transactionExplorer,
          bip32CoinType
        ]),
        CborTagsConst.aptosNetworkParams);
  }

  @override
  NetworkCoinParams<AptosAPIProvider> updateParams(
      {List<APIProvider>? updateProviders,
      Token? token,
      String? transactionExplorer,
      String? addressExplorer,
      int? bip32CoinType}) {
    return AptosNetworkParams(
        token: NetworkCoinParams.validateUpdateParams(
            token: this.token, updateToken: token),
        providers: updateProviders?.cast<AptosAPIProvider>() ?? providers,
        chainType: chainType,
        aptosChainType: aptosChainType,
        addressExplorer: addressExplorer,
        transactionExplorer: transactionExplorer,
        bip32CoinType: bip32CoinType ?? this.bip32CoinType);
  }
}
