import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/error/exception.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/api/provider/provider.dart';

import 'package:mrt_wallet/wallet/models/network/core/params/params.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:blockchain_utils/bip/bip.dart';

enum SuiChainType {
  devnet(0),
  testnet(1),
  mainnet(2);

  const SuiChainType(this.value);
  final int value;
  String get identifier => "sui:$name";
  static SuiChainType fromValue(int? value) {
    return values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw WalletExceptionConst.invalidData(
          messsage: "SuiChainType not found."),
    );
  }
}

class SuiNetworkParams extends NetworkCoinParams<SuiAPIProvider> {
  final String identifier;
  final SuiChainType suiChain;

  factory SuiNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.suiNetworkParams);

    return SuiNetworkParams(
        token: Token.fromCborBytesOrObject(obj: values.getCborTag(0)),
        providers: values
            .elementAsListOf<CborTagValue>(1)
            .map((e) => SuiAPIProvider.fromCborBytesOrObject(obj: e))
            .toList(),
        chainType: ChainType.fromValue(values.elementAs(2)),
        identifier: values.elementAs(3),
        addressExplorer: values.elementAs(4),
        transactionExplorer: values.elementAs(5),
        bip32CoinType: values.elementAs(6),
        suiChain: SuiChainType.fromValue(values.elementAs(7)));
  }
  SuiNetworkParams(
      {required super.token,
      required super.providers,
      required super.chainType,
      required this.identifier,
      required this.suiChain,
      super.addressExplorer,
      super.transactionExplorer,
      super.bip32CoinType});

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          token.toCbor(),
          CborListValue.fixedLength(providers.map((e) => e.toCbor()).toList()),
          chainType.name,
          identifier,
          addressExplorer,
          transactionExplorer,
          bip32CoinType,
          suiChain.value
        ]),
        CborTagsConst.suiNetworkParams);
  }

  @override
  NetworkCoinParams<SuiAPIProvider> updateParams(
      {List<APIProvider>? updateProviders,
      Token? token,
      String? transactionExplorer,
      String? addressExplorer,
      int? bip32CoinType}) {
    return SuiNetworkParams(
        token: NetworkCoinParams.validateUpdateParams(
            token: this.token, updateToken: token),
        providers: updateProviders?.cast<SuiAPIProvider>() ?? providers,
        chainType: chainType,
        identifier: identifier,
        addressExplorer: addressExplorer,
        transactionExplorer: transactionExplorer,
        bip32CoinType: bip32CoinType ?? this.bip32CoinType,
        suiChain: suiChain);
  }
}
