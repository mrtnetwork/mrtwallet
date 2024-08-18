import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/keys/models/encrypted_imported.dart';
import 'package:mrt_wallet/crypto/keys/models/encrypted_master.dart';
import 'package:mrt_wallet/crypto/keys/models/master_key.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';
import 'package:mrt_wallet/crypto/requets/messages/models/models/generate_master_key.dart';
import 'package:mrt_wallet/crypto/utils/crypto/utils.dart';

class CryptoRequestGenerateMasterKey
    implements
        CryptoRequest<CryptoGenerateMasterKeyResponse, MessageArgsThreeBytes> {
  final List<int> walletData;
  final int version;
  final List<int>? key;
  final List<int>? newKey;
  final List<int>? keyString;
  final List<int>? keyChecksum;
  CryptoRequestGenerateMasterKey._({
    required this.version,
    required List<int> walletData,
    List<int>? key,
    List<int>? keyString,
    List<int>? keyChecksum,
    List<int>? newKey,
  })  : walletData = BytesUtils.toBytes(walletData, unmodifiable: true),
        key = BytesUtils.tryToBytes(key, unmodifiable: true),
        newKey = BytesUtils.tryToBytes(newKey, unmodifiable: true),
        keyString = BytesUtils.tryToBytes(keyString, unmodifiable: true),
        keyChecksum = BytesUtils.tryToBytes(keyChecksum, unmodifiable: true);
  factory CryptoRequestGenerateMasterKey.fromStorage(
      {required String storageData,
      required List<int> key,
      List<int>? newKey}) {
    try {
      final dataBytes = List<int>.unmodifiable(
          StringUtils.encode(storageData, type: StringEncoding.base64));
      final CborListValue values =
          CborSerializable.decode(cborBytes: dataBytes);
      return CryptoRequestGenerateMasterKey._(
          version: values.elementAt(0),
          walletData: values.elementAt(1),
          key: key,
          newKey: newKey);
    } catch (e) {
      throw WalletExceptionConst.incorrectWalletData;
    }
  }
  factory CryptoRequestGenerateMasterKey.fromStorageWithStringKey(
      {required String storageData,
      required String key,
      required String checksum,
      List<int>? newKey}) {
    try {
      final dataBytes = List<int>.unmodifiable(
          StringUtils.encode(storageData, type: StringEncoding.base64));
      final CborListValue values =
          CborSerializable.decode(cborBytes: dataBytes);
      return CryptoRequestGenerateMasterKey._(
          version: values.elementAt(0),
          walletData: values.elementAt(1),
          newKey: newKey,
          keyString: StringUtils.encode(key),
          keyChecksum: BytesUtils.fromHexString(checksum));
    } catch (e) {
      throw WalletExceptionConst.incorrectWalletData;
    }
  }

  factory CryptoRequestGenerateMasterKey.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CryptoRequestMethod.generateMasterKey.tag);
    return CryptoRequestGenerateMasterKey._(
      version: values.elementAt(0),
      walletData: values.elementAt(1),
      key: values.elementAt(2),
      newKey: values.elementAt(3),
      keyString: values.elementAt(4),
      keyChecksum: values.elementAt(5),
    );
  }

  /// encrypted master key, storage encrypted wallet
  static (EncryptedMasterKey, List<int>) generateMasterKey(
      {required List<int> key,
      required List<int> walletData,
      required List<int>? newKey}) {
    final nonce = WorkerCryptoUtils.generateNonce(key);
    final decrypt = WorkerCryptoUtils.decryptChacha(
        key: key, nonce: nonce, data: walletData);
    if (decrypt == null) {
      throw WalletExceptionConst.incorrectPassword;
    }
    final masterKey = WalletMasterKeys.fromCborBytesOrObject(bytes: decrypt);
    return encryptedMasterKey(masterKey: masterKey, key: newKey ?? key);
  }

  @override
  MessageArgsThreeBytes getResult() {
    List<int> walletKey = key ??
        WorkerCryptoUtils.hashKey(key: keyString!, checksum: keyChecksum!);
    final data = generateMasterKey(
        key: walletKey, walletData: walletData, newKey: newKey);
    return MessageArgsThreeBytes(
        keyOne: data.$1.toCbor().encode(),
        keyTwo: data.$2,
        keyThree: walletKey);
  }

  static (EncryptedMasterKey, List<int>) encryptedMasterKey(
      {required WalletMasterKeys masterKey, required List<int> key}) {
    final memoryStorageBytes =
        toMemoryStorage(walletData: masterKey.toCbor().encode(), key: key);
    final bip32 = Bip32Slip10Secp256k1.fromSeed(masterKey.seed);
    final encryptedMasterKey = EncryptedMasterKey(
        checksum: bip32.publicKey.fingerPrint.toHex(),
        keyBytes: memoryStorageBytes,
        customKeys: masterKey.customKeys
            .map((e) => EncryptedCustomKey(
                publicKey: e.publicKey,
                coin: e.coin,
                id: e.checksum,
                created: e.created,
                name: e.name,
                keyType: e.keyType))
            .toList());
    final storageBytes = toStorage(masterKey: masterKey, key: key);
    return (encryptedMasterKey, storageBytes);
  }

  static List<int> toStorage(
      {required WalletMasterKeys masterKey,
      required List<int> key,
      int version = 1}) {
    final List<int> nonce = WorkerCryptoUtils.generateNonce(key);
    final encrypt = WorkerCryptoUtils.encryptChacha(
        key: key, nonce: nonce, data: masterKey.toCbor().encode());
    final toCbor = CborListValue.dynamicLength([
      CborIntValue(version),
      CborBytesValue(encrypt),
    ]);
    return toCbor.encode();
  }

  static List<int> toMemoryStorage({
    required List<int> walletData,
    required List<int> key,
    int version = 1,
  }) {
    final List<int> nonce = QuickCrypto.generateRandom(12);
    final List<int> encrypt = WorkerCryptoUtils.encryptChacha(
        key: key, nonce: nonce, data: walletData);
    final toCbor = CborListValue.dynamicLength([
      CborIntValue(version),
      CborBytesValue(nonce),
      CborBytesValue(encrypt)
    ]);
    return toCbor.encode();
  }

  @override
  CryptoGenerateMasterKeyResponse parsResult(MessageArgsThreeBytes result) {
    return CryptoGenerateMasterKeyResponse(
        masterKey:
            EncryptedMasterKey.fromCborBytesOrObject(bytes: result.keyOne),
        storageData:
            StringUtils.decode(result.keyTwo, type: StringEncoding.base64),
        walletKey: result.keyThree);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          version,
          CborBytesValue(walletData),
          key == null ? const CborNullValue() : CborBytesValue(key!),
          newKey == null ? const CborNullValue() : CborBytesValue(newKey!),
          keyString == null
              ? const CborNullValue()
              : CborBytesValue(keyString!),
          keyChecksum == null
              ? const CborNullValue()
              : CborBytesValue(keyChecksum!),
        ]),
        method.tag);
  }

  @override
  CryptoRequestMethod get method => CryptoRequestMethod.generateMasterKey;

  @override
  CryptoGenerateMasterKeyResponse result() {
    List<int> walletKey = key ??
        WorkerCryptoUtils.hashKey(key: keyString!, checksum: keyChecksum!);
    final data = generateMasterKey(
        key: walletKey, walletData: walletData, newKey: newKey);
    return CryptoGenerateMasterKeyResponse(
        masterKey: data.$1,
        storageData: StringUtils.decode(data.$2, type: StringEncoding.base64),
        walletKey: walletKey);
  }
}
