import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wroker/keys/models/encrypted_master.dart';
import 'package:mrt_wallet/wroker/keys/models/master_key.dart';
import 'package:mrt_wallet/wroker/requets/argruments/argruments.dart';
import 'package:mrt_wallet/wroker/requets/messages/core/message.dart';
import 'package:mrt_wallet/wroker/requets/messages/crypto/requests/generate_master_key.dart';
import 'package:mrt_wallet/wroker/requets/messages/models/models/generate_master_key.dart';

class CryptoRequestSetupMasterKey
    implements
        CryptoRequest<CryptoGenerateMasterKeyResponse, MessageArgsTwoBytes> {
  final WalletMasterKeys masterKey;
  final List<int> key;
  CryptoRequestSetupMasterKey({required this.masterKey, required List<int> key})
      : key = BytesUtils.toBytes(key, unmodifiable: true);

  factory CryptoRequestSetupMasterKey.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CryptoRequestMethod.setupMasterKey.tag);
    return CryptoRequestSetupMasterKey(
        masterKey:
            WalletMasterKeys.fromCborBytesOrObject(obj: values.getCborTag(0)),
        key: values.elementAt(1));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([masterKey.toCbor(), CborBytesValue(key)]),
        method.tag);
  }

  @override
  CryptoRequestMethod get method => CryptoRequestMethod.setupMasterKey;

  @override
  MessageArgsTwoBytes getResult() {
    final encrypt = CryptoRequestGenerateMasterKey.encryptedMasterKey(
        masterKey: masterKey, key: key);
    return MessageArgsTwoBytes(
        keyOne: encrypt.$1.toCbor().encode(), keyTwo: encrypt.$2);
  }

  @override
  CryptoGenerateMasterKeyResponse parsResult(MessageArgsTwoBytes result) {
    return CryptoGenerateMasterKeyResponse(
        masterKey:
            EncryptedMasterKey.fromCborBytesOrObject(bytes: result.keyOne),
        storageData:
            StringUtils.decode(result.keyTwo, type: StringEncoding.base64));
  }

  @override
  CryptoGenerateMasterKeyResponse result() {
    final encrypt = CryptoRequestGenerateMasterKey.encryptedMasterKey(
        masterKey: masterKey, key: key);
    return CryptoGenerateMasterKeyResponse(
        masterKey: encrypt.$1,
        storageData:
            StringUtils.decode(encrypt.$2, type: StringEncoding.base64));
  }
}
