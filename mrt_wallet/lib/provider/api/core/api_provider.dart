import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/api/api_provider_tracker.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class ApiProviderService with Equatable, CborSerializable {
  static const ApiProviderService blockCypher =
      ApiProviderService("BlockCypher", "https://www.blockcypher.com/");
  static const ApiProviderService mempool =
      ApiProviderService("Mempool", "https://mempool.space/");
  static const ApiProviderService xrpl =
      ApiProviderService("XRPL", "https://xrpl.org");

  final String serviceName;
  final String websiteUri;
  const ApiProviderService(this.serviceName, this.websiteUri);

  @override
  List get variabels => [serviceName, websiteUri];

  factory ApiProviderService.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    try {
      final cborObj = (obj ?? CborObject.fromCbor(bytes!)) as CborTagValue;
      if (bytesEqual(
          cborObj.tags, WalletModelCborTagsConst.evmApiServiceProvider)) {
        return EVMApiProviderService.fromCborBytesOrObject(obj: cborObj);
      } else if (bytesEqual(
          cborObj.tags, WalletModelCborTagsConst.tronApiServiceProvider)) {
        return TronApiProviderService.fromCborBytesOrObject(obj: cborObj);
      }

      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, WalletModelCborTagsConst.apiServiceProvider);
      return ApiProviderService(cbor.getIndex(0), cbor.getIndex(1));
    } catch (e) {
      throw WalletExceptionConst.incorrectNetwork;
    }
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([serviceName, websiteUri]),
        WalletModelCborTagsConst.apiServiceProvider);
  }
}

abstract class NetworkApiProvider<T> {
  Future<void> updateBalance(T account);
  abstract final ApiProviderTracker serviceProvider;
}
