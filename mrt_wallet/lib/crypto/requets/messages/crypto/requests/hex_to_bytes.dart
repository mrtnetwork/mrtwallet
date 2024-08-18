import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';

class CryptoRequestHexToBytes<T>
    implements CryptoRequest<List<int>, MessageArgsOneBytes> {
  final String hex;
  CryptoRequestHexToBytes({required this.hex});
  factory CryptoRequestHexToBytes.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CryptoRequestMethod.hexToBytes.tag);
    return CryptoRequestHexToBytes(hex: values.elementAt(0));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([hex]), method.tag);
  }

  @override
  CryptoRequestMethod get method => CryptoRequestMethod.hexToBytes;

  @override
  MessageArgsOneBytes getResult() {
    return MessageArgsOneBytes(keyOne: BytesUtils.fromHexString(hex));
  }

  @override
  List<int> parsResult(MessageArgsOneBytes result) {
    return result.keyOne;
  }

  @override
  List<int> result() {
    return BytesUtils.fromHexString(hex);
  }
}
