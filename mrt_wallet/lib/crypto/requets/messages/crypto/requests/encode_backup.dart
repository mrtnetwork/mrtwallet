import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';

class CryptoRequestEncodeBackup
    implements CryptoRequest<String, MessageArgsOneBytes> {
  final String password;
  final List<int> backup;
  final SecretWalletEncoding encoding;
  CryptoRequestEncodeBackup(
      {required this.password,
      required List<int> backup,
      required this.encoding})
      : backup = BytesUtils.toBytes(backup, unmodifiable: true);
  factory CryptoRequestEncodeBackup.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CryptoRequestMethod.encodeBackup.tag);
    final encoding = SecretWalletEncoding.values.firstWhere(
        (element) => element.name == values.elementAt<String>(2),
        orElse: () => throw WalletExceptionConst.dataVerificationFailed);
    return CryptoRequestEncodeBackup(
        password: values.elementAt(0),
        backup: values.elementAt(1),
        encoding: encoding);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [password, CborBytesValue(backup), encoding.name]),
        method.tag);
  }

  @override
  CryptoRequestMethod get method => CryptoRequestMethod.encodeBackup;

  @override
  MessageArgsOneBytes getResult() {
    final web3SD = Web3SecretStorageDefinationV3.encode(backup, password);
    return MessageArgsOneBytes(
        keyOne: StringUtils.encode(web3SD.encrypt(encoding: encoding)));
  }

  @override
  String parsResult(MessageArgsOneBytes result) {
    return StringUtils.decode(result.keyOne);
  }

  @override
  String result() {
    final web3SD = Web3SecretStorageDefinationV3.encode(backup, password);
    return web3SD.encrypt(encoding: encoding);
  }
}
