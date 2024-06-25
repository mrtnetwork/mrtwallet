import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/network/params/core/network_params.dart';
import 'package:mrt_wallet/models/wallet_models/network/params/core/token.dart';
import 'package:mrt_wallet/provider/api/networks/ton/api_provider/service.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class TonNetworkParams extends NetworkCoinParams<TonAPIProviderService> {
  final int workchain;

  TonNetworkParams(
      {required super.transactionExplorer,
      required super.addressExplorer,
      required super.token,
      required super.providers,
      required this.workchain,
      required super.mainnet});
  TonNetworkParams copyWith(
      {String? transactionExplorer,
      String? addressExplorer,
      Token? token,
      List<TonAPIProviderService>? providers,
      int? workchain,
      bool? supportEIP1559,
      bool? mainnet,
      bool? defaultNetwork}) {
    return TonNetworkParams(
        transactionExplorer: transactionExplorer ?? this.transactionExplorer,
        addressExplorer: addressExplorer ?? this.addressExplorer,
        token: token ?? this.token,
        providers: providers ?? List.from(this.providers),
        workchain: workchain ?? this.workchain,
        mainnet: mainnet ?? this.mainnet);
  }

  factory TonNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.tonNetworkParam);
    return TonNetworkParams(
        workchain: cbor.elementAt(0),
        mainnet: cbor.elementAt(1),
        transactionExplorer: cbor.elementAt(2),
        addressExplorer: cbor.elementAt(3),
        token: Token.fromCborBytesOrObject(obj: cbor.getCborTag(4)),
        providers: (cbor.elementAt(5) as List)
            .map((e) => TonAPIProviderService.fromCborBytesOrObject(obj: e))
            .toList());
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          workchain,
          mainnet,
          transactionExplorer,
          addressExplorer,
          token.toCbor(),
          CborListValue.fixedLength(providers.map((e) => e.toCbor()).toList()),
        ]),
        WalletModelCborTagsConst.tonNetworkParam);
  }

  @override
  NetworkCoinParams<TonAPIProviderService> updateProviders(
      List<TonAPIProviderService> updateProviders) {
    return TonNetworkParams(
        transactionExplorer: transactionExplorer,
        addressExplorer: addressExplorer,
        token: token,
        providers: providers,
        workchain: workchain,
        mainnet: mainnet);
  }
}
