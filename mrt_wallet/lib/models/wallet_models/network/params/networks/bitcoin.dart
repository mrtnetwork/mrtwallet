import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/provider/api/core/api_provider.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class BitcoinParams extends NetworkCoinParams {
  final BasedUtxoNetwork transacationNetwork;

  @override
  bool get mainnet => transacationNetwork.isMainnet;

  factory BitcoinParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.bitconNetworkParam);

    return BitcoinParams(
        transactionExplorer: cbor.elementAt(0),
        addressExplorer: cbor.elementAt(1),
        token: Token.fromCborBytesOrObject(obj: cbor.getCborTag(2)),
        transacationNetwork: BasedUtxoNetwork.fromName(cbor.elementAt(3)),
        providers: (cbor.elementAt(4) as List)
            .map((e) => ApiProviderService.fromCborBytesOrObject(obj: e))
            .toList());
  }
  BitcoinParams({
    required super.transactionExplorer,
    required super.addressExplorer,
    required super.providers,
    required super.token,
    required this.transacationNetwork,
  }) : super(mainnet: transacationNetwork.isMainnet);

  BitcoinParams copyWith(
      {List<ApiProviderService>? providers,
      String? transactionExplorer,
      String? addressExplorer,
      Token? token,
      BasedUtxoNetwork? transacationNetwork}) {
    return BitcoinParams(
        transactionExplorer: transactionExplorer ?? this.transactionExplorer,
        addressExplorer: addressExplorer ?? this.addressExplorer,
        transacationNetwork: transacationNetwork ?? this.transacationNetwork,
        providers: providers ?? this.providers,
        token: token ?? this.token);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          transactionExplorer,
          addressExplorer,
          token.toCbor(),
          transacationNetwork.value,
          CborListValue.fixedLength(providers.map((e) => e.toCbor()).toList())
        ]),
        WalletModelCborTagsConst.bitconNetworkParam);
  }

  @override
  BitcoinParams updateProviders(List<ApiProviderService> updateProviders) {
    return BitcoinParams(
        transactionExplorer: transactionExplorer,
        addressExplorer: addressExplorer,
        transacationNetwork: transacationNetwork,
        providers: providers,
        token: token);
  }
}
