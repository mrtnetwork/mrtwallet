import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';

class CryptoRequestDecodeBackup
    implements CryptoRequest<List<int>, MessageArgsOneBytes> {
  final String password;
  final String backup;
  final SecretWalletEncoding encoding;
  CryptoRequestDecodeBackup(
      {required this.password, required this.backup, required this.encoding});
  factory CryptoRequestDecodeBackup.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CryptoRequestMethod.decodeBackup.tag);
    final encoding = SecretWalletEncoding.values.firstWhere(
        (element) => element.name == values.elementAt<String>(2),
        orElse: () => throw WalletExceptionConst.dataVerificationFailed);
    return CryptoRequestDecodeBackup(
        password: values.elementAt(0),
        backup: values.elementAt(1),
        encoding: encoding);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([password, backup, encoding.name]),
        method.tag);
  }

  @override
  CryptoRequestMethod get method => CryptoRequestMethod.decodeBackup;

  @override
  MessageArgsOneBytes getResult() {
    final decode = Web3SecretStorageDefinationV3.decode(backup, password,
        encoding: encoding);
    return MessageArgsOneBytes(keyOne: decode.data);
  }

  @override
  List<int> parsResult(MessageArgsOneBytes result) {
    return result.keyOne;
  }

  @override
  List<int> result() {
    final decode = Web3SecretStorageDefinationV3.decode(backup, password,
        encoding: encoding);
    return decode.data;
  }
}
