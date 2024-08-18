import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/keys/models/master_key.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';
import 'package:mrt_wallet/crypto/utils/crypto/utils.dart';

class CryptoRequestReadMasterKey
    implements CryptoRequest<WalletMasterKeys, MessageArgsOneBytes> {
  final int version;
  final List<int> nonce;
  final List<int> walletData;
  final List<int> key;
  CryptoRequestReadMasterKey({
    required this.version,
    required List<int> walletData,
    required List<int> key,
    required List<int> nonce,
  })  : walletData = BytesUtils.toBytes(walletData, unmodifiable: true),
        key = BytesUtils.toBytes(key, unmodifiable: true),
        nonce = BytesUtils.toBytes(nonce, unmodifiable: true);
  factory CryptoRequestReadMasterKey.fromStorage({
    required List<int> encryptedMasterKey,
    required List<int> key,
  }) {
    try {
      final CborListValue values =
          CborSerializable.decode(cborBytes: encryptedMasterKey);
      return CryptoRequestReadMasterKey(
          version: values.elementAt(0),
          nonce: values.elementAt(1),
          walletData: values.elementAt(2),
          key: key);
    } catch (e) {
      throw WalletExceptionConst.incorrectWalletData;
    }
  }

  factory CryptoRequestReadMasterKey.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CryptoRequestMethod.readMasterKey.tag);
    return CryptoRequestReadMasterKey(
        version: values.elementAt(0),
        nonce: values.elementAt(1),
        walletData: values.elementAt(2),
        key: values.elementAt(3));
  }

  static WalletMasterKeys getWalletMasterKeys(
      {required List<int> key,
      required List<int> nonce,
      required List<int> walletData}) {
    final decrypt = WorkerCryptoUtils.decryptChacha(
        key: key, nonce: nonce, data: walletData);
    if (decrypt == null) {
      throw WalletExceptionConst.incorrectPassword;
    }
    return WalletMasterKeys.fromCborBytesOrObject(bytes: decrypt);
  }

  @override
  MessageArgsOneBytes getResult() {
    final masterKey =
        getWalletMasterKeys(key: key, nonce: nonce, walletData: walletData);
    return MessageArgsOneBytes(keyOne: masterKey.toCbor().encode());
  }

  @override
  WalletMasterKeys parsResult(MessageArgsOneBytes result) {
    return WalletMasterKeys.fromCborBytesOrObject(bytes: result.keyOne);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          version,
          CborBytesValue(nonce),
          CborBytesValue(walletData),
          CborBytesValue(key)
        ]),
        method.tag);
  }

  @override
  CryptoRequestMethod get method => CryptoRequestMethod.readMasterKey;

  @override
  WalletMasterKeys result() {
    return getWalletMasterKeys(key: key, nonce: nonce, walletData: walletData);
  }
}
