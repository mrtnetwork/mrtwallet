import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';

class _Web3EncryptedMessageConst {
  static const List<int> encryptedMessageTag = [0, 10, 200, 0];
}

class Web3EncryptedMessage with CborSerializable {
  final List<int> message;
  final List<int> nonce;

  Web3EncryptedMessage({
    required this.message,
    required List<int> nonce,
  }) : nonce = BytesUtils.toBytes(nonce, unmodifiable: true);

  factory Web3EncryptedMessage.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    try {
      final CborListValue values = CborSerializable.cborTagValue(
          cborBytes: bytes,
          object: object,
          hex: hex,
          tags: _Web3EncryptedMessageConst.encryptedMessageTag);

      return Web3EncryptedMessage(
          message: values.elementAt(0), nonce: values.elementAt(1));
    } catch (e) {
      throw Web3RequestExceptionConst.internalError;
    }
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [CborBytesValue(message), CborBytesValue(nonce)]),
        _Web3EncryptedMessageConst.encryptedMessageTag);
  }
}
