import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/bitcoin/bitcoin.dart';
import 'package:mrt_wallet/wallet/models/network/core/params/params.dart';

import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';

class BitcoinParams extends NetworkCoinParams<BaseBitcoinAPIProvider> {
  final BasedUtxoNetwork transacationNetwork;
  final String genesis;

  @override
  bool get mainnet => transacationNetwork.isMainnet;

  factory BitcoinParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.bitconNetworkParam);

    return BitcoinParams(
        transactionExplorer: cbor.elementAt(0),
        addressExplorer: cbor.elementAt(1),
        token: Token.fromCborBytesOrObject(obj: cbor.getCborTag(2)),
        transacationNetwork: BasedUtxoNetwork.fromName(cbor.elementAt(3)),
        providers: (cbor.elementAt(4) as List)
            .map((e) => BaseBitcoinAPIProvider.fromCborBytesOrObject(obj: e))
            .toList(),
        genesis: cbor.elementAt(5));
  }
  BitcoinParams({
    required super.transactionExplorer,
    required super.addressExplorer,
    required super.providers,
    required super.token,
    required this.transacationNetwork,
    required this.genesis,
  }) : super(mainnet: transacationNetwork.isMainnet);

  BitcoinParams copyWith(
      {List<BaseBitcoinAPIProvider>? providers,
      String? transactionExplorer,
      String? addressExplorer,
      Token? token,
      BasedUtxoNetwork? transacationNetwork,
      String? genesis}) {
    return BitcoinParams(
        transactionExplorer: transactionExplorer ?? this.transactionExplorer,
        addressExplorer: addressExplorer ?? this.addressExplorer,
        transacationNetwork: transacationNetwork ?? this.transacationNetwork,
        providers: providers ?? this.providers,
        token: token ?? this.token,
        genesis: genesis ?? this.genesis);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          transactionExplorer,
          addressExplorer,
          token.toCbor(),
          transacationNetwork.value,
          CborListValue.fixedLength(providers.map((e) => e.toCbor()).toList()),
          genesis
        ]),
        CborTagsConst.bitconNetworkParam);
  }

  @override
  BitcoinParams updateProviders(List<APIProvider> updateProviders) {
    return BitcoinParams(
        transactionExplorer: transactionExplorer,
        addressExplorer: addressExplorer,
        transacationNetwork: transacationNetwork,
        providers: updateProviders.cast<BaseBitcoinAPIProvider>(),
        token: token,
        genesis: genesis);
  }
}
