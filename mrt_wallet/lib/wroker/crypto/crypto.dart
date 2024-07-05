import 'package:blockchain_utils/bip/bip/bip32/base/bip32_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:blockchain_utils/signer/cosmos/cosmos_nist256r1_signer.dart';
import 'package:blockchain_utils/signer/cosmos/cosmos_signer.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wroker/coins/coins.dart';
import 'package:mrt_wallet/wroker/keys/keys.dart';
import 'package:mrt_wallet/wroker/models/bytes.dart';
import 'package:mrt_wallet/wroker/models/message_type.dart';
import 'package:mrt_wallet/wroker/models/request_message.dart';
import 'package:mrt_wallet/wroker/models/response_message.dart';
import 'package:mrt_wallet/wroker/models/signing_models/bitcoin.dart';
import 'package:mrt_wallet/wroker/utils/global/utils.dart';

class WalletCrypto {
  const WalletCrypto();
  static const ExceptionArg verificationFailed =
      ExceptionArg("data_verification_failed");
  static const List<String> methodNames = [
    "decryptChacha",
    "encryptChaha",
    "generateNonce",
    "generateMemoryStorage",
    "fromStroage",
    "masterKeyfromMemoryStorage",
    "restoreBackup",
    "createBackup",
    "createWalletSeed",
  ];

  List<int> decryptChacha(List<int> key, List<int> sealed, {List<int>? nonce}) {
    final ChaCha20Poly1305 chacha = ChaCha20Poly1305(key);
    try {
      nonce ??= generateNonce(key);
      final decrypt = chacha.decrypt(nonce, sealed);
      if (decrypt == null) {
        throw WalletExceptionConst.incorrectPassword;
      }
      return decrypt;
    } finally {
      chacha.clean();
    }
  }

  List<int> encryptChaha(List<int> key, List<int> data) {
    final ChaCha20Poly1305 chacha = ChaCha20Poly1305(key);
    try {
      final List<int> nonce = generateNonce(key);
      final List<int> encrypt = chacha.encrypt(nonce, data);
      final toCbor = CborListValue.dynamicLength([
        const CborIntValue(1),
        CborBytesValue(encrypt),
      ]);
      return toCbor.encode();
    } finally {
      chacha.clean();
    }
  }

  List<int> generateNonce(List<int> seed) {
    final hasher = SHAKE128();
    final digest = List<int>.unmodifiable(hasher.update(seed).digest(12));
    hasher.clean();
    return digest;
  }

  List<int> generateMemoryStorage(List<int> key, List<int> data) {
    final ChaCha20Poly1305 chacha = ChaCha20Poly1305(key);
    try {
      final List<int> nonce = QuickCrypto.generateRandom(12);
      final List<int> encrypt = chacha.encrypt(nonce, data);
      final toCbor = CborListValue.dynamicLength([
        const CborIntValue(1),
        CborBytesValue(nonce),
        CborBytesValue(encrypt)
      ]);
      return toCbor.encode();
    } finally {
      chacha.clean();
    }
  }

  static (int, List<int>)? _validateStorageCbor(List<int> toCborBytes) {
    final toCborObject = CborObject.fromCbor(toCborBytes);

    if (toCborObject is! CborListValue) return null;
    try {
      final int version = toCborObject.value[0].value;
      final List<int> walletData = toCborObject.value[1].value;
      return (version, walletData);
    } catch (e) {
      return null;
    }
  }

  List<int> fromStroage(List<int> encrypted, List<int> key) {
    try {
      final data = _validateStorageCbor(encrypted);

      if (data == null) {
        throw WalletExceptionConst.incorrectWalletData;
      }
      return decryptChacha(key, data.$2);
    } catch (e) {
      throw WalletExceptionConst.incorrectPassword;
    }
  }

  List<int> masterKeyfromMemoryStorage(List<int> key, List<int> data) {
    final CborListValue values = CborSerializable.decode(data);
    return decryptChacha(key, values.elementAt(2), nonce: values.elementAt(1));
  }

  List<int> restoreBackup(
      {required String backup,
      required String password,
      required SecretWalletEncoding encoding}) {
    final decode = Web3SecretStorageDefinationV3.decode(backup, password,
        encoding: encoding);
    return decode.data;
  }

  String createBackup(
      List<int> backup, String password, SecretWalletEncoding encoding) {
    final wallet = Web3SecretStorageDefinationV3.encode(backup, password);
    return wallet.encrypt(encoding: encoding);
  }

  WalletMasterKeys createWalletSeed(String mnemonic, String passphrase) {
    final seed =
        Bip39SeedGenerator(Mnemonic.fromString(mnemonic)).generate(passphrase);
    final icarus = CardanoIcarusSeedGenerator(mnemonic).generate();
    final cardanoLegacy = CardanoByronLegacySeedGenerator(mnemonic).generate();
    final List<int> checksum = QuickCrypto.sha3256Hash(
        [...seed, ...icarus, ...cardanoLegacy, ...passphrase.codeUnits]);

    return WalletMasterKeys.setup(
        mnemonic: mnemonic,
        seed: seed,
        icarus: icarus,
        cardanoLegacy: cardanoLegacy,
        checksum: checksum);
  }

  WalletMasterKeys _importCustomKey(
      {required ImportedKeyStorage newKey,
      required List<int> data,
      required List<int> key}) {
    final keys = WalletMasterKeys.fromCborBytesOrObject(
        bytes: masterKeyfromMemoryStorage(key, data));
    final Bip32Base bip32 = newKey.toKey(null).toKey();
    final checkshum = BlockchainUtils.createCustomKeyChecksum(bip32);
    final publicKey = bip32.publicKey.toHex();
    if (checkshum != newKey.checksum || newKey.publicKey != publicKey) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    if (keys.customKeys.contains(newKey)) {
      throw WalletExceptionConst.keyAlreadyExist;
    }
    return keys.addKey([newKey]);
  }

  (EncryptedMasterKey, List<int>) importCustomKey({
    required ImportedKeyStorage newKey,
    required List<int> key,
    required List<int> encryptedWallet,
  }) {
    final masterKey =
        _importCustomKey(newKey: newKey, data: encryptedWallet, key: key);
    final encrypt = encryptChaha(key, masterKey.toCbor().encode());
    final encryptedMasterKey =
        _toEncryptionMasterKey(masterKey.toCbor().encode(), key);
    return (encryptedMasterKey, encrypt);
  }

  WalletMasterKeys _removeCustomKey(
      {required String keyId,
      required List<int> data,
      required List<int> key}) {
    final keys = WalletMasterKeys.fromCborBytesOrObject(
        bytes: masterKeyfromMemoryStorage(key, data));
    final newWallet = keys.removeKey(keyId);
    return newWallet;
  }

  (EncryptedMasterKey, List<int>) removeMasterKey({
    required String keyId,
    required List<int> key,
    required List<int> encryptedWallet,
  }) {
    final masterKey =
        _removeCustomKey(keyId: keyId, data: encryptedWallet, key: key);
    final encrypt = encryptChaha(key, masterKey.toCbor().encode());
    final encryptedMasterKey =
        _toEncryptionMasterKey(masterKey.toCbor().encode(), key);
    return (encryptedMasterKey, encrypt);
  }

  int version() => 0;
  static T toArgs<T extends ArgsBytes>(ArgsBytes args) {
    if (args is! T) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    return args;
  }

  static T toSignignRequest<T extends SignRequest>(SignRequest args) {
    if (args is! T) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    return args;
  }

  EncryptedMasterKey _toEncryptionMasterKey(
    List<int> masterKeyBytes,
    List<int> key,
  ) {
    final encrypted = generateMemoryStorage(key, masterKeyBytes);
    final mn = WalletMasterKeys.fromCborBytesOrObject(bytes: masterKeyBytes);
    final bip32 = Bip32Slip10Secp256k1.fromSeed(mn.seed);
    return EncryptedMasterKey(
        checksum: bip32.publicKey.fingerPrint.toHex(),
        keyBytes: encrypted,
        customKeys: mn.customKeys
            .map((e) => EncryptedCustomKey(
                publicKey: e.publicKey,
                coin: e.coin,
                id: e.checksum,
                created: e.created,
                name: e.name,
                keyType: e.keyType))
            .toList());
  }

  List<CryptoPrivateKeyData> readKeys(
      {required List<int> key,
      required List<int> encryptedWallet,
      required List<AccessCryptoPrivateKeyRequest> requestKeys}) {
    final masterKey = WalletMasterKeys.fromCborBytesOrObject(
        bytes: masterKeyfromMemoryStorage(key, encryptedWallet));
    final List<CryptoPrivateKeyData> keys = [];
    for (final i in requestKeys) {
      final key =
          masterKey.toKey(i.index, maxLevel: Bip44Levels.fromInt(i.maxLevel));
      keys.add(key);
    }
    return keys;
  }

  GlobalSignResponse sign(
      {required List<int> key,
      required List<int> encryptedWallet,
      required SignRequest request}) {
    final responseKeys = readPrivateKeys(
            keyIndexes: [AccessCryptoPrivateKeyRequest(index: request.index)],
            key: key,
            encryptedWallet: encryptedWallet)
        .first;
    final bipKey = responseKeys.toKey();
    final keyBytes = bipKey.privateKey.raw;
    final List<int> signature;
    switch (request.network) {
      case SigningRequestNetwork.tron:
        final signer = TronSigner.fromKeyBytes(keyBytes);
        signature = signer.sign(request.digest);

        break;
      case SigningRequestNetwork.ripple:
        final signer = XrpSigner.fromKeyBytes(
            keyBytes, request.index.currencyCoin.conf.type);
        signature = signer.sign(request.digest);

        break;
      case SigningRequestNetwork.cosmos:
        if (request.index.currencyCoin.conf.type ==
            EllipticCurveTypes.nist256p1) {
          final signer = CosmosNist256p1Signer.fromKeyBytes(keyBytes);
          signature = signer.sign(request.digest);
          break;
        }
        final signer = CosmosSigner.fromKeyBytes(keyBytes);
        signature = signer.sign(request.digest);
        break;
      case SigningRequestNetwork.eth:
        final ethsigner = ETHSigner.fromKeyBytes(keyBytes);
        signature = ethsigner.sign(request.digest).toBytes();
        break;
      case SigningRequestNetwork.bitcoin:
        final btcSigner = BitcoinSigner.fromKeyBytes(keyBytes);
        final bitcoinRequest = toSignignRequest<BitcoinSigning>(request);
        if (bitcoinRequest.useTaproot) {
          List<int> sig = btcSigner.signSchnorrTransaction(request.digest,
              tapScripts: [], tweak: true);
          if (bitcoinRequest.sighash != 0x00) {
            sig = <int>[...sig, bitcoinRequest.sighash];
          }
          signature = sig;
          break;
        }
        final sig = btcSigner.signTransaction(request.digest);
        signature = [...sig, bitcoinRequest.sighash];
        break;
      case SigningRequestNetwork.ton:
      case SigningRequestNetwork.solana:
        final solanaSigner = SolanaSigner.fromKeyBytes(keyBytes);
        signature = solanaSigner.sign(request.digest);
        break;
      case SigningRequestNetwork.cardano:
        final cardaoSigner = CardanoSigner.fromKeyBytes(keyBytes);
        signature = cardaoSigner.sign(request.digest);
        break;
    }
    final pubKey =
        PublicKeyData.fromBip32(account: bipKey, keyName: request.index.name);
    return GlobalSignResponse(
        index: request.index, signature: signature, signerPubKey: pubKey);
  }

  List<CryptoPublicKeyData> readPublicKeys(
      {required List<int> key,
      required List<int> encryptedWallet,
      required List<AccessCryptoPrivateKeyRequest> requestKeys}) {
    final masterKey = WalletMasterKeys.fromCborBytesOrObject(
        bytes: masterKeyfromMemoryStorage(key, encryptedWallet));

    final List<CryptoPublicKeyData> pubKeys = [];
    for (final i in requestKeys) {
      final bool byronLegacy =
          i.index.currencyCoin.proposal == CustomProposal.cip0019;
      final PrivateKeyData privateKey = masterKey.toKey(i.index,
          maxLevel:
              byronLegacy ? Bip44Levels.master : Bip44Levels.addressIndex);
      Bip32Base bipKey = privateKey.toKey();
      if (byronLegacy) {
        final legacy = CardanoByronLegacy.fromBip32(bipKey);
        if (i.index.hdPath != null) {
          bipKey = legacy.bip32.derivePath(i.index.hdPath!);
        }
        pubKeys.add(AdaLegacyPublicKeyData.fromBip32(
            account: bipKey,
            keyName: privateKey.keyName,
            hdPathKey: legacy.hdPathKey));
        continue;
      }
      pubKeys.add(PublicKeyData.fromBip32(
          account: bipKey, keyName: privateKey.keyName));
    }
    return pubKeys;
  }

  (EncryptedMasterKey, List<int>) generateMasterKey(
      List<int> data, List<int> key) {
    final masterKeyBytes = fromStroage(data, key);
    final encryptedMasterKey = _toEncryptionMasterKey(masterKeyBytes, key);
    return (encryptedMasterKey, data);
  }

  (EncryptedMasterKey, List<int>) changePassword({
    required List<int> newPassword,
    required List<int> key,
    required List<int> encryptedWallet,
  }) {
    final masterKey = WalletMasterKeys.fromCborBytesOrObject(
        bytes: masterKeyfromMemoryStorage(key, encryptedWallet));
    final encrypt = encryptChaha(newPassword, masterKey.toCbor().encode());
    final encryptedMasterKey =
        _toEncryptionMasterKey(masterKey.toCbor().encode(), newPassword);
    return (encryptedMasterKey, encrypt);
  }

  (EncryptedMasterKey, List<int>) setup(
      {required WalletMasterKeys masterKey, required List<int> key}) {
    final encrypt = encryptChaha(key, masterKey.toCbor().encode());
    final encryptedMasterKey =
        _toEncryptionMasterKey(masterKey.toCbor().encode(), key);
    return (encryptedMasterKey, encrypt);
  }

  PrivateKeyData getImportedKey({
    required String keyId,
    required List<int> key,
    required List<int> encryptedWallet,
  }) {
    WalletMasterKeys masterKey = WalletMasterKeys.fromCborBytesOrObject(
        bytes: masterKeyfromMemoryStorage(key, encryptedWallet));
    final importedKey = masterKey.getKeyById(keyId);
    if (importedKey == null) {
      throw WalletExceptionConst.privateKeyIsNotAvailable;
    }
    final keyInfo = importedKey.toKey(null);
    return keyInfo;
  }

  List<CryptoPrivateKeyData> readPrivateKeys({
    required List<AccessCryptoPrivateKeyRequest> keyIndexes,
    required List<int> key,
    required List<int> encryptedWallet,
  }) {
    final keys = readKeys(
        key: key, encryptedWallet: encryptedWallet, requestKeys: keyIndexes);
    return keys;
  }

  AccessMnemonicResponse readMnemonic(
      {required List<int> key, required List<int> encryptedWallet}) {
    final masterKey = WalletMasterKeys.fromCborBytesOrObject(
        bytes: masterKeyfromMemoryStorage(key, encryptedWallet));
    return AccessMnemonicResponse(masterKey.mnemonic);
  }

  WorkerMessageResponse handleMessage(List<int> message) {
    int? id;
    ArgsBytes result;
    try {
      final workerMessage = WorkerMessageRequest.deserialize(message);
      final type = workerMessage.message.message;

      id = workerMessage.id;
      switch (type) {
        case CryptoMessageType.decryptChacha:
          final TwoArgsBytes msg = toArgs(workerMessage.message.args);
          final decrypt = decryptChacha(msg.keyOne, msg.keyTwo);
          result = OneArgBytes(keyOne: decrypt);
          break;
        case CryptoMessageType.encryptChacha:
          final TwoArgsBytes msg = toArgs(workerMessage.message.args);
          final encrypt = encryptChaha(msg.keyOne, msg.keyTwo);
          result = OneArgBytes(keyOne: encrypt);
          break;
        case CryptoMessageType.generateMasterKey:
          final TwoArgsBytes msg = toArgs(workerMessage.message.args);
          final masterKey = generateMasterKey(msg.keyTwo, msg.keyOne);
          result = TwoArgsBytes(
              keyOne: masterKey.$1.toCbor().encode(), keyTwo: masterKey.$2);
          break;
        case CryptoMessageType.readMasterKey:
          final TwoArgsBytes msg = toArgs(workerMessage.message.args);
          final decrypt = fromStroage(msg.keyTwo, msg.keyOne);
          result = OneArgBytes(keyOne: decrypt);
          break;
        case CryptoMessageType.readMasterKeyFromMemoryStorage:
          final TwoArgsBytes msg = toArgs(workerMessage.message.args);
          final decrypt = masterKeyfromMemoryStorage(msg.keyOne, msg.keyTwo);
          result = OneArgBytes(keyOne: decrypt);
          break;
        case CryptoMessageType.restoreBackup:
          final ThreeArgsBytes msg = toArgs(workerMessage.message.args);
          final String password = StringUtils.decode(msg.keyOne);
          final String backup = StringUtils.decode(msg.keyTwo);
          final String encoding = StringUtils.decode(msg.keyThree);
          final enc = SecretWalletEncoding.values.firstWhere(
              (element) => element.name == encoding,
              orElse: () => throw WalletExceptionConst.dataVerificationFailed);
          final decrypt =
              restoreBackup(backup: backup, password: password, encoding: enc);
          result = OneArgBytes(keyOne: decrypt);
          break;
        case CryptoMessageType.createBackup:
          final ThreeArgsBytes msg = toArgs(workerMessage.message.args);
          final String password = StringUtils.decode(msg.keyOne);
          final String encoding = StringUtils.decode(msg.keyThree);
          final enc = SecretWalletEncoding.values.firstWhere(
              (element) => element.name == encoding,
              orElse: () => throw WalletExceptionConst.dataVerificationFailed);
          final backup = createBackup(msg.keyTwo, password, enc);
          result = OneArgBytes(keyOne: StringUtils.encode(backup));
          break;
        case CryptoMessageType.sign:
          final ThreeArgsBytes msg = toArgs(workerMessage.message.args);
          final signResponse = sign(
              encryptedWallet: msg.keyThree,
              key: msg.keyOne,
              request: SignRequest.deserialize(msg.keyTwo));
          result = OneArgBytes(keyOne: signResponse.toCbor().encode());
          break;
        case CryptoMessageType.createWalletSeed:
          final TwoArgsBytes msg = toArgs(workerMessage.message.args);
          final String mnemonic = StringUtils.decode(msg.keyTwo);
          final String passphrase =
              msg.keyOne.isEmpty ? '' : StringUtils.decode(msg.keyOne);
          final masterKey = createWalletSeed(mnemonic, passphrase);
          result = OneArgBytes(keyOne: masterKey.toCbor().encode());
          break;
        case CryptoMessageType.importNewKey:
          final ThreeArgsBytes msg = toArgs(workerMessage.message.args);
          final masterKey = importCustomKey(
              newKey:
                  ImportedKeyStorage.fromCborBytesOrObject(bytes: msg.keyTwo),
              encryptedWallet: msg.keyThree,
              key: msg.keyOne);
          result = TwoArgsBytes(
              keyOne: masterKey.$1.toCbor().encode(), keyTwo: masterKey.$2);
          break;
        case CryptoMessageType.removeKey:
          final ThreeArgsBytes msg = toArgs(workerMessage.message.args);
          final masterKey = removeMasterKey(
              keyId: BytesUtils.toHexString(msg.keyTwo),
              encryptedWallet: msg.keyThree,
              key: msg.keyOne);
          result = TwoArgsBytes(
              keyOne: masterKey.$1.toCbor().encode(), keyTwo: masterKey.$2);
          break;
        case CryptoMessageType.changePassword:
          final ThreeArgsBytes msg = toArgs(workerMessage.message.args);
          final encryptedMasterKey = changePassword(
              newPassword: msg.keyTwo,
              key: msg.keyOne,
              encryptedWallet: msg.keyThree);
          result = TwoArgsBytes(
              keyOne: encryptedMasterKey.$1.toCbor().encode(),
              keyTwo: encryptedMasterKey.$2);
          break;
        case CryptoMessageType.readImportKey:
          final ThreeArgsBytes msg = toArgs(workerMessage.message.args);
          final keyInfo = getImportedKey(
              keyId: BytesUtils.toHexString(msg.keyTwo),
              key: msg.keyOne,
              encryptedWallet: msg.keyThree);
          result = OneArgBytes(keyOne: keyInfo.toCbor().encode());
          break;
        case CryptoMessageType.readMnemonic:
          final TwoArgsBytes msg = toArgs(workerMessage.message.args);
          final mnemonic =
              readMnemonic(key: msg.keyOne, encryptedWallet: msg.keyTwo);
          result = OneArgBytes(keyOne: mnemonic.toCbor().encode());
          break;
        case CryptoMessageType.readPrivateKeys:
          final ThreeArgsBytes msg = toArgs(workerMessage.message.args);
          final AccessCryptoPrivateKeysRequest request =
              AccessCryptoPrivateKeysRequest.fromCborBytesOrObject(
                  bytes: msg.keyTwo);
          final keys = readPrivateKeys(
              keyIndexes: request.indexes,
              key: msg.keyOne,
              encryptedWallet: msg.keyThree);
          final response = CryptoPrivateKeysResponse(keys);
          result = OneArgBytes(keyOne: response.toCbor().encode());
          break;
        case CryptoMessageType.readPrivateKey:
          final ThreeArgsBytes msg = toArgs(workerMessage.message.args);
          final AccessCryptoPrivateKeyRequest request =
              AccessCryptoPrivateKeyRequest.fromCborBytesOrObject(
                  bytes: msg.keyTwo);
          final keys = readPrivateKeys(
              keyIndexes: [request],
              key: msg.keyOne,
              encryptedWallet: msg.keyThree);
          final response = CryptoPrivateKeyResponse(keys.first);
          result = OneArgBytes(keyOne: response.toCbor().encode());
          break;
        case CryptoMessageType.readPublicKey:
          final ThreeArgsBytes msg = toArgs(workerMessage.message.args);
          final AccessCryptoPrivateKeyRequest request =
              AccessCryptoPrivateKeyRequest.fromCborBytesOrObject(
                  bytes: msg.keyTwo);
          final key = readPublicKeys(
              key: msg.keyOne,
              encryptedWallet: msg.keyThree,
              requestKeys: [request]);
          final response = CryptoPublicKeyResponse(key.first);
          result = OneArgBytes(keyOne: response.toCbor().encode());
          break;
        case CryptoMessageType.readPublicKeys:
          final ThreeArgsBytes msg = toArgs(workerMessage.message.args);
          final AccessCryptoPrivateKeysRequest request =
              AccessCryptoPrivateKeysRequest.fromCborBytesOrObject(
                  bytes: msg.keyTwo);
          final keys = readPublicKeys(
              key: msg.keyOne,
              encryptedWallet: msg.keyThree,
              requestKeys: request.indexes);
          final response = CryptoPublicKeysResponse(keys);
          result = OneArgBytes(keyOne: response.toCbor().encode());
          break;
        case CryptoMessageType.setup:
          final TwoArgsBytes msg = toArgs(workerMessage.message.args);
          final masterKey =
              WalletMasterKeys.fromCborBytesOrObject(bytes: msg.keyTwo);
          final encryptedMasterKey =
              setup(masterKey: masterKey, key: msg.keyOne);
          result = TwoArgsBytes(
              keyOne: encryptedMasterKey.$1.toCbor().encode(),
              keyTwo: encryptedMasterKey.$2);
          break;
        default:
          result = verificationFailed;
          break;
      }
    } on WalletException catch (e) {
      result = ExceptionArg(e.message);
    } catch (e) {
      result = verificationFailed;
    }
    return WorkerMessageResponse(args: result, id: id ?? -1);
  }
}
