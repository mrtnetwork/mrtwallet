import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';
import 'package:mrt_wallet/wallet/models/networks/monero/monero.dart';

class CryptoRequestTestLarge<T> extends NoneEncryptedCryptoRequest<
    MoneroChainTrackerResponse, MessageArgsOneBytes> {
  final List<int> data;
  CryptoRequestTestLarge({required this.data});
  factory CryptoRequestTestLarge.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NoneEncryptedCryptoRequestMethod.test.tag);
    return CryptoRequestTestLarge(data: values.elementAs(0));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborBytesValue(data),
        ]),
        method.tag);
  }

  @override
  NoneEncryptedCryptoRequestMethod get method =>
      NoneEncryptedCryptoRequestMethod.test;
  @override
  Future<MessageArgsOneBytes> getResult({List<int>? encryptedPart}) async {
    final result = await this.result(encryptedPart: encryptedPart);
    return MessageArgsOneBytes(keyOne: result.toCbor().encode());
  }

  @override
  Future<MoneroChainTrackerResponse> result({List<int>? encryptedPart}) {
    throw UnimplementedError();
  }

  @override
  MoneroChainTrackerResponse parsResult(MessageArgsOneBytes result) {
    throw UnimplementedError();
  }
}
