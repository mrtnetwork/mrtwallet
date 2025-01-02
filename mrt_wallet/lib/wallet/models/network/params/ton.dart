import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';

import 'package:mrt_wallet/wallet/models/network/core/params/params.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/ton.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:ton_dart/ton_dart.dart' as ton;

class TonNetworkParams extends NetworkCoinParams<TonAPIProvider> {
  final int workchain;
  ton.TonChain get chain => ton.TonChain.fromWorkchain(workchain);
  TonNetworkParams(
      {required super.transactionExplorer,
      required super.addressExplorer,
      required super.token,
      required super.providers,
      required this.workchain,
      required super.chainType});
  TonNetworkParams copyWith(
      {String? transactionExplorer,
      String? addressExplorer,
      Token? token,
      List<TonAPIProvider>? providers,
      int? workchain,
      bool? supportEIP1559,
      ChainType? chainType,
      bool? defaultNetwork}) {
    return TonNetworkParams(
        transactionExplorer: transactionExplorer ?? this.transactionExplorer,
        addressExplorer: addressExplorer ?? this.addressExplorer,
        token: token ?? this.token,
        providers: providers ?? List.from(this.providers),
        workchain: workchain ?? this.workchain,
        chainType: chainType ?? this.chainType);
  }

  factory TonNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.tonNetworkParam);
    return TonNetworkParams(
        workchain: cbor.elementAt(0),
        chainType: ChainType.fromValue(cbor.elementAt(1)),
        transactionExplorer: cbor.elementAt(2),
        addressExplorer: cbor.elementAt(3),
        token: Token.fromCborBytesOrObject(obj: cbor.getCborTag(4)),
        providers: (cbor.elementAt(5) as List)
            .map((e) => TonAPIProvider.fromCborBytesOrObject(obj: e))
            .toList());
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          workchain,
          chainType.name,
          transactionExplorer,
          addressExplorer,
          token.toCbor(),
          CborListValue.fixedLength(providers.map((e) => e.toCbor()).toList()),
        ]),
        CborTagsConst.tonNetworkParam);
  }

  @override
  NetworkCoinParams<TonAPIProvider> updateProviders(
      List<APIProvider> updateProviders) {
    return TonNetworkParams(
        transactionExplorer: transactionExplorer,
        addressExplorer: addressExplorer,
        token: token,
        providers: updateProviders.cast<TonAPIProvider>(),
        workchain: workchain,
        chainType: chainType);
  }

  @override
  int get identifier => workchain;
}
