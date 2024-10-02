import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/crypto/coins/custom_coins/coins.dart';
import 'package:mrt_wallet/crypto/keys/keys.dart';
import 'package:xrpl_dart/xrpl_dart.dart';
import 'dart:math' as math;

class BlockchainUtils {
  static List<int> privateKeyToBytes(
      {required String privateKey, required CryptoCoins coin}) {
    return IPrivateKey.fromBytes(
            BytesUtils.fromHexString(privateKey), coin.conf.type)
        .raw;
  }

  static List<int> _toSecretKeyBytes(
      {required List<int> keypair, required EllipticCurveTypes type}) {
    const int ed25519KeyPairLength =
        Ed25519KeysConst.privKeyByteLen + Ed25519KeysConst.pubKeyByteLen;
    if (keypair.length != ed25519KeyPairLength) return keypair;
    switch (type) {
      case EllipticCurveTypes.ed25519:
      case EllipticCurveTypes.ed25519Blake2b:
        return keypair.sublist(0, Ed25519KeysConst.privKeyByteLen);
      default:
        return keypair;
    }
  }

  static ImportedKeyStorage extendeKeyToStorage(
      {required String extendedKey,
      required CryptoCoins coin,
      String? keyName}) {
    if (coin.conf is! BipCoinConfig) {
      throw WalletExceptionConst.invalidCoin;
    }
    final key = extendedKeyToBip32Key(extendedKey: extendedKey, coin: coin);
    return ImportedKeyStorage(
      checksum: _createCustomKeyChecksum(
          pubkeyBytes: key.publicKey.compressed,
          chainCode: key.chainCode.toBytes(),
          coin: coin),
      extendedPrivateKey: key.privateKey.toExtended,
      coin: coin,
      publicKey: key.publicKey.toHex(),
      name: keyName,
      keyType: CustomKeyType.extendedKey,
    );
  }

  static PrivateKeyData seedToPrivateKeyData(
      {required List<int> seedBytes,
      required CryptoCoins coin,
      required String keyName}) {
    if (coin.conf is! BipCoinConfig) {
      throw WalletExceptionConst.invalidCoin;
    }
    final key = seedToBipKey(coin: coin as BipCoins, seedBytes: seedBytes);
    return PrivateKeyData.fromBip32(account: key, coin: coin, keyName: keyName);
  }

  static ImportedKeyStorage privateKeyToStorage(
      {required String privateKey,
      required CryptoCoins coin,
      String? keyName}) {
    return _privateKeyToStorage(
        keyBytes: BytesUtils.fromHexString(privateKey),
        coin: coin,
        keyName: keyName);
  }

  static List<int> privateKeyToKeypairBytes(
      {required List<int> privateKey, required CryptoCoins coin}) {
    try {
      final ripplePrivateKey = XRPPrivateKey.fromBytes(privateKey,
          algorithm: coin.conf.type == EllipticCurveTypes.ed25519
              ? XRPKeyAlgorithm.ed25519
              : XRPKeyAlgorithm.secp256k1);

      return ripplePrivateKey.toBytes();
    } catch (e) {
      throw WalletExceptionConst.invalidPrivateKey;
    }
  }

  static IPrivateKey _validatePrivateKey(
      {required List<int> keyBytes, required CryptoCoins coin}) {
    switch (coin) {
      case Bip44Coins.ripple:
      case Bip44Coins.rippleEd25519:
      case Bip44Coins.rippleTestnet:
      case Bip44Coins.rippleTestnetED25519:
        keyBytes = privateKeyToKeypairBytes(coin: coin, privateKey: keyBytes);
        break;
      default:
        break;
    }
    return IPrivateKey.fromBytes(keyBytes, coin.conf.type);
  }

  static ImportedKeyStorage _privateKeyToStorage(
      {required List<int> keyBytes,
      required CryptoCoins coin,
      String? keyName}) {
    final secretKeyBytes =
        _toSecretKeyBytes(keypair: keyBytes, type: coin.conf.type);
    final key = _validatePrivateKey(keyBytes: secretKeyBytes, coin: coin);
    return ImportedKeyStorage(
        checksum: _createCustomKeyChecksum(
            pubkeyBytes: key.publicKey.compressed, coin: coin),
        extendedPrivateKey: key.toHex(),
        coin: coin,
        publicKey: key.publicKey.toHex(),
        name: keyName,
        keyType: CustomKeyType.privateKey);
  }

  static ImportedKeyStorage wifToStorage(
      {required String wifKey, required CryptoCoins coin, String? keyName}) {
    if (!coin.conf.hasWif) {
      throw WalletExceptionConst.invalidCoin;
    }
    try {
      final keyBytes =
          WifDecoder.decode(wifKey, netVer: coin.conf.wifNetVer!).item1;
      return _privateKeyToStorage(
          keyBytes: keyBytes, coin: coin, keyName: keyName);
    } catch (e) {
      throw WalletExceptionConst.invalidWifKey;
    }
  }

  static Bip32Base privteKeyToBip32(
      {required String privateKey, required CryptoCoins coin}) {
    try {
      if (coin.conf is! BipCoins) {
        throw WalletExceptionConst.invalidCoin;
      }
      final privateKeyBytes = BytesUtils.fromHexString(privateKey);
      if (coin.proposal == CustomProposal.cip0019) {
        return CardanoByronLegacyBip32.fromPrivateKey(privateKeyBytes);
      }
      switch (coin.conf.type) {
        case EllipticCurveTypes.secp256k1:
          return Bip32Slip10Secp256k1.fromPrivateKey(privateKeyBytes);
        case EllipticCurveTypes.ed25519:
          return Bip32Slip10Ed25519.fromPrivateKey(privateKeyBytes);
        case EllipticCurveTypes.ed25519Kholaw:
          final bool icarus = coin.conf.addrParams["is_icarus"] ?? false;
          if (icarus) {
            return CardanoIcarusBip32.fromPrivateKey(privateKeyBytes);
          }
          return Bip32KholawEd25519.fromPrivateKey(privateKeyBytes);
        case EllipticCurveTypes.ed25519Blake2b:
          return Bip32Slip10Ed25519Blake2b.fromPrivateKey(privateKeyBytes);
        case EllipticCurveTypes.nist256p1:
          return Bip32Slip10Nist256p1.fromPrivateKey(privateKeyBytes);
        default:
          throw WalletExceptionConst.invalidPrivateKey;
      }
    } catch (e) {
      throw WalletExceptionConst.invalidPrivateKey;
    }
  }

  static Bip32Base extendedKeyToBip32Key(
      {required String extendedKey, required CryptoCoins coin}) {
    try {
      final conf = coin.conf;
      if (!coin.conf.hasExtendedKeys) {
        throw WalletExceptionConst.invalidExtendedKey;
      }
      if (coin.proposal == CustomProposal.cip0019) {
        return CardanoByronLegacyBip32.fromExtendedKey(
            extendedKey, conf.keyNetVer);
      }
      switch (conf.type) {
        case EllipticCurveTypes.secp256k1:
          return Bip32Slip10Secp256k1.fromExtendedKey(
              extendedKey, conf.keyNetVer);
        case EllipticCurveTypes.ed25519:
          return Bip32Slip10Ed25519.fromExtendedKey(
              extendedKey, conf.keyNetVer);
        case EllipticCurveTypes.ed25519Kholaw:
          if (conf.addrParams["is_icarus"] == true) {
            return CardanoIcarusBip32.fromExtendedKey(
                extendedKey, conf.keyNetVer);
          }
          return Bip32KholawEd25519.fromExtendedKey(
              extendedKey, conf.keyNetVer);
        case EllipticCurveTypes.ed25519Blake2b:
          return Bip32Slip10Ed25519Blake2b.fromExtendedKey(
              extendedKey, conf.keyNetVer);
        case EllipticCurveTypes.nist256p1:
          return Bip32Slip10Nist256p1.fromExtendedKey(
              extendedKey, conf.keyNetVer);
        default:
          throw WalletExceptionConst.invalidExtendedKey;
      }
    } catch (e) {
      throw WalletExceptionConst.invalidExtendedKey;
    }
  }

  static void validateMnemonic(String mnemonic) {
    try {
      final isValid = Bip39MnemonicValidator();
      if (!isValid.isValid(mnemonic)) {
        throw WalletExceptionConst.invalidMnemonic;
      }
    } catch (e) {
      throw WalletExceptionConst.invalidMnemonic;
    }
  }

  static void validateMnemonicWords(List<String> mnemonic) {
    try {
      final isValid = Bip39MnemonicValidator();
      if (!isValid.validateWords(mnemonic.join(" "))) {
        throw WalletExceptionConst.invalidBip39MnemonicWords;
      }
    } catch (e) {
      throw WalletExceptionConst.invalidBip39MnemonicWords;
    }
  }

  static List<String> normalizeMnemonic(String mnemonic) {
    return mnemonic
        .replaceAll(RegExp(r'\s+'), " ")
        .split(" ")
        .where((element) => element.isNotEmpty)
        .toList();
  }

  static Bip32Base seedToBipKey(
      {required List<int> seedBytes, required BipCoins coin}) {
    Bip32Base validate(Bip32Base bip32Obj) {
      int depth = bip32Obj.depth.depth;
      if (bip32Obj.isPublicOnly) {
        if (depth < Bip44Levels.account.value ||
            depth > Bip44Levels.addressIndex.value) {
          throw Bip44DepthError(
              "Depth of the public-only Bip object ($depth) is below account level or beyond address index level");
        }
      } else {
        if (depth < 0 || depth > Bip44Levels.addressIndex.value) {
          throw Bip44DepthError(
              "Depth of the Bip object ($depth) is invalid or beyond address index level");
        }
      }

      return bip32Obj;
    }

    Bip32Base bip;
    final conf = coin.conf;
    Bip32KeyNetVersions? keyNetVar;
    bool isIcarus = false;
    keyNetVar = coin.conf.keyNetVer;
    isIcarus = coin.conf.addrParams["is_icarus"] ?? false;
    switch (conf.type) {
      case EllipticCurveTypes.secp256k1:
        bip = Bip32Slip10Secp256k1.fromSeed(seedBytes, keyNetVar);
        break;
      case EllipticCurveTypes.ed25519:
        bip = Bip32Slip10Ed25519.fromSeed(seedBytes, keyNetVar);
        break;
      case EllipticCurveTypes.ed25519Kholaw:
        if (coin.proposal == CustomProposal.cip0019) {
          bip = CardanoByronLegacyBip32.fromSeed(seedBytes, keyNetVar);
          break;
        }
        if (isIcarus) {
          bip = CardanoIcarusBip32.fromSeed(seedBytes, keyNetVar);
          break;
        }
        bip = Bip32KholawEd25519.fromSeed(seedBytes, keyNetVar);
        break;
      case EllipticCurveTypes.ed25519Blake2b:
        bip = Bip32Slip10Ed25519Blake2b.fromSeed(seedBytes, keyNetVar);
        break;
      case EllipticCurveTypes.nist256p1:
        bip = Bip32Slip10Nist256p1.fromSeed(seedBytes, keyNetVar);
        break;
      default:
        throw const ArgumentException("invaid type");
    }

    return validate(bip);
  }

  static IPrivateKey seedToSubstratePrivateKey(
      {required List<int> seedBytes, required CryptoCoins coin}) {
    if (coin.proposal != SubstratePropoosal.substrate) {
      throw WalletExceptionConst.invalidCoin;
    }
    final substrate = Substrate.fromSeed(seedBytes, coin as SubstrateCoins);
    return substrate.priveKey.privKey;
  }

  static String _createCustomKeyChecksum(
      {required List<int> pubkeyBytes,
      List<int>? chainCode,
      required CryptoCoins coin}) {
    chainCode ??= List<int>.filled(32, 0);
    return BytesUtils.toHexString(MD5.hash(<int>[
      ...pubkeyBytes,
      ...chainCode,
      ...coin.proposal.specName.codeUnits,
      ...coin.coinName.codeUnits
    ]));
  }

  static String? validateHdPathKey(String path, {int? maxIndex}) {
    try {
      final parser = Bip32PathParser.parse(path);
      if (maxIndex != null && parser.length() != maxIndex) {
        return null;
      }
      return path;
    } catch (e) {
      return null;
    }
  }

  static String? toWif(
      {required List<int> privateKey, required CryptoCoins coin}) {
    if (coin is BipCoins) {
      final wif = coin.conf.wifNetVer;
      if (wif != null) {
        return WifEncoder.encode(privateKey, netVer: wif);
      }
    }
    return null;
  }

  static String generateRandomString(int length) {
    const String chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    math.Random random = math.Random();

    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join('');
  }
}
