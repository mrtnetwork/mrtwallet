import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:blockchain_utils/cbor/types/cbor_tag.dart';
import 'package:blockchain_utils/cbor/types/list.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class EVMApiProviderService extends ApiProviderService {
  const EVMApiProviderService(
      {required String serviceName,
      required String websiteUri,
      required this.httpUri})
      : super(serviceName, websiteUri);

  final String httpUri;

  factory EVMApiProviderService.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.evmApiServiceProvider);
    return EVMApiProviderService(
      serviceName: cbor.getIndex(0),
      websiteUri: cbor.getIndex(1),
      httpUri: cbor.getIndex(2),
    );
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([serviceName, websiteUri, httpUri]),
        WalletModelCborTagsConst.evmApiServiceProvider);
  }

  @override
  List get variabels => [serviceName, websiteUri, httpUri];
}
