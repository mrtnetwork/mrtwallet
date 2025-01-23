import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/ripple.dart';
import 'package:blockchain_utils/bip/bip.dart';
import 'package:mrt_wallet/wallet/models/network/core/params/params.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';

class RippleNetworkParams extends NetworkCoinParams<RippleAPIProvider> {
  final int networkId;

  factory RippleNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: CborTagsConst.xrpNetworkParam);
    return RippleNetworkParams(
        token: Token.fromCborBytesOrObject(obj: values.getCborTag(2)),
        providers: values
            .elementAsListOf<CborTagValue>(3)
            .map((e) => RippleAPIProvider.fromCborBytesOrObject(obj: e))
            .toList(),
        chainType: ChainType.fromValue(values.elementAs(4)),
        networkId: values.elementAs(5),
        addressExplorer: values.elementAs(6),
        transactionExplorer: values.elementAs(7));
  }
  RippleNetworkParams(
      {required super.token,
      required super.providers,
      required super.chainType,
      required this.networkId,
      super.addressExplorer,
      super.transactionExplorer});

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          const CborNullValue(),
          const CborNullValue(),
          token.toCbor(),
          CborListValue.fixedLength(providers.map((e) => e.toCbor()).toList()),
          chainType.name,
          networkId,
          addressExplorer,
          transactionExplorer
        ]),
        CborTagsConst.xrpNetworkParam);
  }

  int get identifier => networkId;

  @override
  NetworkCoinParams<RippleAPIProvider> updateParams(
      {List<APIProvider>? updateProviders,
      Token? token,
      String? transactionExplorer,
      String? addressExplorer}) {
    return RippleNetworkParams(
        token: NetworkCoinParams.validateUpdateParams(
            token: this.token, updateToken: token),
        providers: updateProviders?.cast<RippleAPIProvider>() ?? providers,
        chainType: chainType,
        networkId: networkId,
        addressExplorer: addressExplorer,
        transactionExplorer: transactionExplorer);
  }
}
