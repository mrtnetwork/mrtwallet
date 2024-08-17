import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/bitcoin/providers/bitcoin.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/bitcoin/providers/electrum.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';

enum BitcoinAPIProviderType { electrum, explorer }

abstract class BaseBitcoinAPIProvider extends APIProvider {
  abstract final BitcoinAPIProviderType type;
  const BaseBitcoinAPIProvider(
      {required super.serviceName,
      required super.websiteUri,
      required super.protocol,
      required super.auth,
      required super.identifier});

  factory BaseBitcoinAPIProvider.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final cborObj = (obj ?? CborObject.fromCbor(bytes!)) as CborTagValue;

    if (BytesUtils.bytesEqual(
        cborObj.tags, CborTagsConst.electrumApiServiceProvider)) {
      return ElectrumAPIProvider.fromCborBytesOrObject(obj: cborObj);
    }
    return BitcoinExplorerAPIProvider.fromCborBytesOrObject(obj: obj);
  }
}
