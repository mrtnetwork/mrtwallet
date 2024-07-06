import 'dart:async';
import 'package:blockchain_utils/secret_wallet/web3_storage_defination.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:blockchain_utils/utils/string/string.dart';
import 'package:mrt_wallet/wroker/cross/exception.dart';
import 'package:mrt_wallet/wroker/crypto/crypto.dart';
import 'package:mrt_wallet/wroker/keys/keys.dart';
import 'package:mrt_wallet/wroker/models/signing_models/bitcoin.dart';
import '../cross/cross.dart'
    if (dart.library.html) '../cross/web.dart'
    if (dart.library.io) '../cross/io.dart';
import 'package:mrt_wallet/wroker/models/bytes.dart';
import 'package:mrt_wallet/wroker/models/message_type.dart';
import 'package:mrt_wallet/wroker/models/request_message.dart';

abstract class IsolateCryptoWoker {
  const IsolateCryptoWoker.parent();
  factory IsolateCryptoWoker() {
    return getCryptoWorker();
  }
  static const WalletCrypto _crypto = WalletCrypto();
  bool get hasIsolate;
  Future<T> _call<T>(
      {required Future<T> Function() onIsolate,
      required Future<T> Function() onMain}) async {
    if (!hasIsolate) {
      return await Future.microtask(() => onMain());
    }
    try {
      final result = await onIsolate();

      return result;
    } on FailedIsolateInitialization {
      final result = await Future.microtask(() => onMain());
      return result;
    }
  }

  Future<T> getResult<T extends ArgsBytes>(WorkerMessageBytes message);

  Future<List<int>> decryptChacha(List<int> key, List<int> sealed) async {
    return _call(onIsolate: () async {
      final args = TwoArgsBytes(keyOne: key, keyTwo: sealed);
      final request = WorkerMessageBytes(
          args: args, message: CryptoMessageType.decryptChacha);
      final OneArgBytes response = await getResult(request);

      return response.keyOne;
    }, onMain: () async {
      return _crypto.decryptChacha(key, sealed);
    });
  }

  Future<List<int>> encryptChaha(List<int> key, List<int> data) async {
    return _call(onIsolate: () async {
      final args = TwoArgsBytes(keyOne: key, keyTwo: data);
      final request = WorkerMessageBytes(
          args: args, message: CryptoMessageType.encryptChacha);
      final OneArgBytes response = await getResult(request);
      return response.keyOne;
    }, onMain: () async {
      return _crypto.encryptChaha(key, data);
    });
  }

  Future<(EncryptedMasterKey, String)> generateMasterKey(
      String data, List<int> password) async {
    final dataBytes = List<int>.unmodifiable(
        StringUtils.encode(data, type: StringEncoding.base64));
    return _call(onIsolate: () async {
      final args = TwoArgsBytes(keyOne: password, keyTwo: dataBytes);
      final request = WorkerMessageBytes(
          args: args, message: CryptoMessageType.generateMasterKey);
      final TwoArgsBytes response = await getResult(request);
      final encryptedStorageKey =
          EncryptedMasterKey.fromCborBytesOrObject(bytes: response.keyOne);
      final String encryptedString =
          StringUtils.decode(response.keyTwo, type: StringEncoding.base64);
      return (encryptedStorageKey, encryptedString);
    }, onMain: () async {
      final decode = _crypto.generateMasterKey(dataBytes, password);
      final String encryptedString =
          StringUtils.decode(decode.$2, type: StringEncoding.base64);
      return (decode.$1, encryptedString);
    });
  }

  Future<WalletMasterKeys> masterKeyfromMemoryStorage(
      List<int> key, List<int> data) async {
    return _call(onIsolate: () async {
      final args = TwoArgsBytes(keyOne: key, keyTwo: data);
      final request = WorkerMessageBytes(
          args: args,
          message: CryptoMessageType.readMasterKeyFromMemoryStorage);
      final OneArgBytes response = await getResult(request);
      return WalletMasterKeys.fromCborBytesOrObject(bytes: response.keyOne);
    }, onMain: () async {
      return WalletMasterKeys.fromCborBytesOrObject(
          bytes: _crypto.masterKeyfromMemoryStorage(key, data));
    });
  }

  Future<List<int>> decodeBackup(
      {required String backup,
      required String password,
      required SecretWalletEncoding encoding}) async {
    return _call(onIsolate: () async {
      final args = ThreeArgsBytes(
          keyOne: StringUtils.encode(password),
          keyTwo: StringUtils.encode(backup),
          keyThree: StringUtils.encode(encoding.name));
      final request = WorkerMessageBytes(
          args: args, message: CryptoMessageType.restoreBackup);
      final OneArgBytes response = await getResult(request);
      return response.keyOne;
    }, onMain: () async {
      return _crypto.restoreBackup(
          backup: backup, password: password, encoding: encoding);
    });
  }

  Future<String> createBackup(
      {required String backup,
      required String password,
      required SecretWalletEncoding encoding}) async {
    final backupBytes = List<int>.unmodifiable(StringUtils.toBytes(backup));
    return _call(onIsolate: () async {
      final args = ThreeArgsBytes(
          keyOne: StringUtils.encode(password),
          keyTwo: backupBytes,
          keyThree: StringUtils.encode(encoding.name));
      final request = WorkerMessageBytes(
          args: args, message: CryptoMessageType.createBackup);
      final OneArgBytes response = await getResult(request);
      return StringUtils.decode(response.keyOne);
    }, onMain: () async {
      return _crypto.createBackup(backupBytes, password, encoding);
    });
  }

  Future<String> createBackup2(
      {required List<int> backup,
      required String password,
      required SecretWalletEncoding encoding}) async {
    final backupBytes = List<int>.unmodifiable(backup);
    return _call(onIsolate: () async {
      final args = ThreeArgsBytes(
          keyOne: StringUtils.encode(password),
          keyTwo: backupBytes,
          keyThree: StringUtils.encode(encoding.name));
      final request = WorkerMessageBytes(
          args: args, message: CryptoMessageType.createBackup);
      final OneArgBytes response = await getResult(request);
      return StringUtils.decode(response.keyOne);
    }, onMain: () async {
      return _crypto.createBackup(backupBytes, password, encoding);
    });
  }

  Future<WalletMasterKeys> generateWalletSeeds(
      String mnemonic, String? passphrase) async {
    return _call(onIsolate: () async {
      final args = TwoArgsBytes(
          keyOne: passphrase == null ? <int>[] : StringUtils.encode(passphrase),
          keyTwo: StringUtils.toBytes(mnemonic));
      final request = WorkerMessageBytes(
          args: args, message: CryptoMessageType.createWalletSeed);
      final OneArgBytes response = await getResult(request);
      return WalletMasterKeys.fromCborBytesOrObject(bytes: response.keyOne);
    }, onMain: () async {
      return _crypto.createWalletSeed(mnemonic, passphrase ?? '');
    });
  }

  Future<(EncryptedMasterKey, String)> importCustomKey({
    required ImportedKeyStorage newKey,
    required List<int> key,
    required List<int> encryptedWallet,
  }) async {
    return _call(onIsolate: () async {
      final args = ThreeArgsBytes(
          keyOne: key,
          keyTwo: newKey.toCbor().encode(),
          keyThree: encryptedWallet);
      final request = WorkerMessageBytes(
          args: args, message: CryptoMessageType.importNewKey);
      final TwoArgsBytes response = await getResult(request);
      final encryptedStorageKey =
          EncryptedMasterKey.fromCborBytesOrObject(bytes: response.keyOne);
      final String encryptedString =
          StringUtils.decode(response.keyTwo, type: StringEncoding.base64);
      return (encryptedStorageKey, encryptedString);
    }, onMain: () async {
      final encrypt = _crypto.importCustomKey(
          newKey: newKey, key: key, encryptedWallet: encryptedWallet);
      final String encryptedString =
          StringUtils.decode(encrypt.$2, type: StringEncoding.base64);
      return (encrypt.$1, encryptedString);
    });
  }

  Future<(EncryptedMasterKey, String)> removeMasterKey(
      {required EncryptedCustomKey removeKey,
      required List<int> key,
      required List<int> encryptedWallet}) async {
    return _call(onIsolate: () async {
      final args = ThreeArgsBytes(
          keyOne: key,
          keyTwo: BytesUtils.fromHexString(removeKey.id),
          keyThree: encryptedWallet);
      final request =
          WorkerMessageBytes(args: args, message: CryptoMessageType.removeKey);
      final TwoArgsBytes response = await getResult(request);
      final encryptedStorageKey =
          EncryptedMasterKey.fromCborBytesOrObject(bytes: response.keyOne);
      final String encryptedString =
          StringUtils.decode(response.keyTwo, type: StringEncoding.base64);
      return (encryptedStorageKey, encryptedString);
    }, onMain: () async {
      final encrypt = _crypto.removeMasterKey(
          keyId: removeKey.id, key: key, encryptedWallet: encryptedWallet);
      final String encryptedString =
          StringUtils.decode(encrypt.$2, type: StringEncoding.base64);
      return (encrypt.$1, encryptedString);
    });
  }

  Future<(EncryptedMasterKey, String)> changePassword({
    required List<int> newPassword,
    required List<int> key,
    required List<int> encryptedWallet,
  }) async {
    return _call(onIsolate: () async {
      final args = ThreeArgsBytes(
          keyOne: key, keyTwo: newPassword, keyThree: encryptedWallet);
      final request = WorkerMessageBytes(
          args: args, message: CryptoMessageType.changePassword);
      final TwoArgsBytes response = await getResult(request);
      final encryptedStorageKey =
          EncryptedMasterKey.fromCborBytesOrObject(bytes: response.keyOne);
      final String encryptedString =
          StringUtils.decode(response.keyTwo, type: StringEncoding.base64);
      return (encryptedStorageKey, encryptedString);
    }, onMain: () async {
      final encrypt = _crypto.changePassword(
          newPassword: newPassword, key: key, encryptedWallet: encryptedWallet);
      final String encryptedString =
          StringUtils.decode(encrypt.$2, type: StringEncoding.base64);
      return (encrypt.$1, encryptedString);
    });
  }

  Future<(EncryptedMasterKey, String)> setup(
      {required WalletMasterKeys masterKey, required List<int> key}) async {
    return _call(onIsolate: () async {
      final args =
          TwoArgsBytes(keyOne: key, keyTwo: masterKey.toCbor().encode());
      final request =
          WorkerMessageBytes(args: args, message: CryptoMessageType.setup);
      final TwoArgsBytes response = await getResult(request);
      final encryptedStorageKey =
          EncryptedMasterKey.fromCborBytesOrObject(bytes: response.keyOne);
      final String encryptedString =
          StringUtils.decode(response.keyTwo, type: StringEncoding.base64);
      return (encryptedStorageKey, encryptedString);
    }, onMain: () async {
      final setup = _crypto.setup(masterKey: masterKey, key: key);
      final String encryptedString =
          StringUtils.decode(setup.$2, type: StringEncoding.base64);
      return (setup.$1, encryptedString);
    });
  }

  Future<PrivateKeyData> getImportedKey({
    required String keyId,
    required List<int> key,
    required List<int> encryptedWallet,
  }) async {
    return _call(onIsolate: () async {
      final args = ThreeArgsBytes(
          keyOne: key,
          keyTwo: BytesUtils.fromHexString(keyId),
          keyThree: encryptedWallet);
      final request = WorkerMessageBytes(
          args: args, message: CryptoMessageType.readImportKey);
      final OneArgBytes response = await getResult(request);
      return PrivateKeyData.fromCborBytesOrObject(bytes: response.keyOne);
    }, onMain: () async {
      return _crypto.getImportedKey(
          keyId: keyId, key: key, encryptedWallet: encryptedWallet);
    });
  }

  Future<List<CryptoPrivateKeyData>> readPrivateKeys({
    required AccessCryptoPrivateKeysRequest keysRequest,
    required List<int> key,
    required List<int> encryptedWallet,
  }) async {
    return _call(onIsolate: () async {
      final args = ThreeArgsBytes(
          keyOne: key,
          keyTwo: keysRequest.toCbor().encode(),
          keyThree: encryptedWallet);
      final request = WorkerMessageBytes(
          args: args, message: CryptoMessageType.readPrivateKeys);
      final OneArgBytes response = await getResult(request);
      final responseKeys = CryptoPrivateKeysResponse.fromCborBytesOrObject(
          bytes: response.keyOne);
      return responseKeys.keys;
    }, onMain: () async {
      final responseKeys = _crypto.readPrivateKeys(
          keyIndexes: keysRequest.indexes,
          key: key,
          encryptedWallet: encryptedWallet);
      return responseKeys;
    });
  }

  Future<CryptoPrivateKeyData> readPrivateKey({
    required AccessCryptoPrivateKeyRequest keyRequest,
    required List<int> key,
    required List<int> encryptedWallet,
  }) async {
    return _call(onIsolate: () async {
      final args = ThreeArgsBytes(
          keyOne: key,
          keyTwo: keyRequest.toCbor().encode(),
          keyThree: encryptedWallet);
      final request = WorkerMessageBytes(
          args: args, message: CryptoMessageType.readPrivateKey);
      final OneArgBytes response = await getResult(request);
      final responseKey = CryptoPrivateKeyResponse.fromCborBytesOrObject(
          bytes: response.keyOne);
      return responseKey.key;
    }, onMain: () async {
      final responseKeys = _crypto.readPrivateKeys(
          keyIndexes: [keyRequest], key: key, encryptedWallet: encryptedWallet);
      return responseKeys.first;
    });
  }

  Future<GlobalSignResponse> sign(
      {required List<int> key,
      required List<int> encryptedWallet,
      required SignRequest signingRequest}) {
    return _call(onIsolate: () async {
      final args = ThreeArgsBytes(
          keyOne: key,
          keyTwo: signingRequest.toCbor().encode(),
          keyThree: encryptedWallet);
      final request =
          WorkerMessageBytes(args: args, message: CryptoMessageType.sign);
      final OneArgBytes response = await getResult(request);
      return GlobalSignResponse.deserialize(response.keyOne);
    }, onMain: () async {
      return _crypto.sign(
          key: key, encryptedWallet: encryptedWallet, request: signingRequest);
    });
  }

  Future<CryptoPublicKeyData> readPublicKey({
    required AccessCryptoPrivateKeyRequest keyRequest,
    required List<int> key,
    required List<int> encryptedWallet,
  }) async {
    return _call(onIsolate: () async {
      final args = ThreeArgsBytes(
          keyOne: key,
          keyTwo: keyRequest.toCbor().encode(),
          keyThree: encryptedWallet);
      final request = WorkerMessageBytes(
          args: args, message: CryptoMessageType.readPublicKey);
      final OneArgBytes response = await getResult(request);

      final CryptoPublicKeyResponse responseKey =
          CryptoPublicKeyResponse.fromCborBytesOrObject(bytes: response.keyOne);
      return responseKey.key;
    }, onMain: () async {
      final responseKeys = _crypto.readPublicKeys(
          key: key,
          encryptedWallet: encryptedWallet,
          requestKeys: [keyRequest]);
      return responseKeys.first;
    });
  }

  Future<List<CryptoPublicKeyData>> readPublicKeys(
      {required AccessCryptoPrivateKeysRequest keysRequest,
      required List<int> key,
      required List<int> encryptedWallet}) async {
    return _call(onIsolate: () async {
      final args = ThreeArgsBytes(
          keyOne: key,
          keyTwo: keysRequest.toCbor().encode(),
          keyThree: encryptedWallet);
      final request = WorkerMessageBytes(
          args: args, message: CryptoMessageType.readPublicKeys);
      final OneArgBytes response = await getResult(request);
      final CryptoPublicKeysResponse responseKey =
          CryptoPublicKeysResponse.fromCborBytesOrObject(
              bytes: response.keyOne);
      return responseKey.keys;
    }, onMain: () async {
      final responseKeys = _crypto.readPublicKeys(
          key: key,
          encryptedWallet: encryptedWallet,
          requestKeys: keysRequest.indexes);
      return responseKeys;
    });
  }

  /// checked
  Future<AccessMnemonicResponse> readMnemonic(
      {required List<int> key, required List<int> encryptedWallet}) async {
    return _call(onIsolate: () async {
      final args = TwoArgsBytes(keyOne: key, keyTwo: encryptedWallet);
      final request = WorkerMessageBytes(
          args: args, message: CryptoMessageType.readMnemonic);
      final OneArgBytes response = await getResult(request);
      return AccessMnemonicResponse.fromCborBytesOrObject(
          bytes: response.keyOne);
    }, onMain: () async {
      return _crypto.readMnemonic(key: key, encryptedWallet: encryptedWallet);
    });
  }
}
