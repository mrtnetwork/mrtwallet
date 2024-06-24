import 'package:blockchain_utils/bip/bip/bip32/base/bip32_base.dart';
import 'package:blockchain_utils/bip/bip/bip44/base/bip44_base_ex.dart';
import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class BlockchainUtils {
  static Future<String> restoreBackup(
      {required String backup,
      required String password,
      required SecretWalletEncoding encoding}) async {
    return BytesUtils.toHexString(await SecretStorageCompute.decrypt(
        backup, password,
        encoding: encoding));
  }

  static Bip32Base privteKeyToBip32(List<int> privateKeyBytes, CryptoCoins coin,
      {Bip32KeyNetVersions? keyNetVar}) {
    try {
      if (coin.proposal == CustomProposal.cip0019) {
        return CardanoByronLegacyBip32.fromPrivateKey(
            privateKeyBytes, null, keyNetVar);
      }
      switch (coin.conf.type) {
        case EllipticCurveTypes.secp256k1:
          return Bip32Slip10Secp256k1.fromPrivateKey(privateKeyBytes,
              keyNetVer: keyNetVar);
        case EllipticCurveTypes.ed25519:
          return Bip32Slip10Ed25519.fromPrivateKey(privateKeyBytes,
              keyNetVer: keyNetVar);
        case EllipticCurveTypes.ed25519Kholaw:
          final bool icarus = coin.conf.addrParams["is_icarus"] ?? false;
          if (icarus) {
            return CardanoIcarusBip32.fromPrivateKey(privateKeyBytes,
                keyNetVer: keyNetVar);
          }
          return Bip32KholawEd25519.fromPrivateKey(privateKeyBytes,
              keyNetVer: keyNetVar);
        case EllipticCurveTypes.ed25519Blake2b:
          return Bip32Slip10Ed25519Blake2b.fromPrivateKey(privateKeyBytes,
              keyNetVer: keyNetVar);
        case EllipticCurveTypes.nist256p1:
          return Bip32Slip10Nist256p1.fromPrivateKey(privateKeyBytes,
              keyNetVer: keyNetVar);
        default:
          throw WalletExceptionConst.invalidPrivateKey;
      }
    } catch (e) {
      throw WalletExceptionConst.invalidPrivateKey;
    }
  }

  static Bip32Base extendedKeyToBip32(
      {required String extendedKey, required CryptoCoins coin}) {
    try {
      if (coin.proposal == CustomProposal.cip0019) {
        return CardanoByronLegacyBip32.fromExtendedKey(
            extendedKey, coin.conf.keyNetVer);
      }
      switch (coin.conf.type) {
        case EllipticCurveTypes.secp256k1:
          return Bip32Slip10Secp256k1.fromExtendedKey(
              extendedKey, coin.conf.keyNetVer);
        case EllipticCurveTypes.ed25519:
          return Bip32Slip10Ed25519.fromExtendedKey(
              extendedKey, coin.conf.keyNetVer);
        case EllipticCurveTypes.ed25519Kholaw:
          if (coin.conf.addrParams["is_icarus"] == true) {
            return CardanoIcarusBip32.fromExtendedKey(
                extendedKey, coin.conf.keyNetVer);
          }
          return Bip32KholawEd25519.fromExtendedKey(
              extendedKey, coin.conf.keyNetVer);
        case EllipticCurveTypes.ed25519Blake2b:
          return Bip32Slip10Ed25519Blake2b.fromExtendedKey(
              extendedKey, coin.conf.keyNetVer);
        case EllipticCurveTypes.nist256p1:
          return Bip32Slip10Nist256p1.fromExtendedKey(
              extendedKey, coin.conf.keyNetVer);
        default:
          throw WalletExceptionConst.invalidPrivateKey;
      }
    } catch (e) {
      throw WalletExceptionConst.invalidPrivateKey;
    }
  }

  static Bip32Base wifToBip32(String wifKey, CryptoCoins coin) {
    try {
      final keyBytes =
          WifDecoder.decode(wifKey, netVer: coin.conf.wifNetVer!).item1;
      return privteKeyToBip32(keyBytes, coin);
    } on WalletException {
      rethrow;
    } catch (e) {
      throw WalletExceptionConst.invalidPrivateKey;
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

  static Future<List<int>> mnemonicToSeed(String mnemonic,
      {String passphrase = ""}) async {
    validateMnemonic(mnemonic);
    final seed = await AppCompute.compute(
        Bip39SeedGenerator(Mnemonic.fromString(mnemonic)).generate, passphrase);
    return seed;
  }

  static Bip32Base seedToBip32({
    required List<int> seedBytes,
    required CryptoCoins coin,
  }) {
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
    switch (conf.type) {
      case EllipticCurveTypes.secp256k1:
        bip = Bip32Slip10Secp256k1.fromSeed(seedBytes, conf.keyNetVer);
        break;
      case EllipticCurveTypes.ed25519:
        bip = Bip32Slip10Ed25519.fromSeed(seedBytes, conf.keyNetVer);
        break;
      case EllipticCurveTypes.ed25519Kholaw:
        if (coin.proposal == CustomProposal.cip0019) {
          bip =
              CardanoByronLegacyBip32.fromSeed(seedBytes, coin.conf.keyNetVer);
          break;
        }
        if (conf.addrParams["is_icarus"] == true) {
          bip = CardanoIcarusBip32.fromSeed(seedBytes, conf.keyNetVer);
          break;
        }
        bip = Bip32KholawEd25519.fromSeed(seedBytes, conf.keyNetVer);
        break;
      case EllipticCurveTypes.ed25519Blake2b:
        bip = Bip32Slip10Ed25519Blake2b.fromSeed(seedBytes, conf.keyNetVer);
        break;
      case EllipticCurveTypes.nist256p1:
        bip = Bip32Slip10Nist256p1.fromSeed(seedBytes, conf.keyNetVer);
        break;
      default:
        throw const ArgumentException("invaid type");
    }

    return validate(bip);
  }

  static Bip32AddressIndex generateAccountNextKeyIndex(
      {required CryptoCoins coin,
      required List<Bip32AddressCore> addresses,
      required SeedGenerationType seedGenerationType}) {
    if (coin.proposal == CustomProposal.cip0019) {
      return findNextByronLegacyIndex(coin: coin, addresses: addresses);
    }
    return findNextBip32Index(
        coin: coin,
        addresses: addresses,
        seedGenerationType: seedGenerationType);
  }

  static Bip32AddressIndex findNextBip32Index(
      {required CryptoCoins coin,
      required List<Bip32AddressCore> addresses,
      required SeedGenerationType seedGenerationType}) {
    final List<Bip32AddressIndex> existsIndexes = addresses
        .map((e) => e.keyIndex)
        .whereType<Bip32AddressIndex>()
        .toList();
    final int purposeIndex = coin.proposal.purpose.index;
    final int coinIndex = Bip32KeyIndex.hardenIndex(coin.conf.coinIdx).index;
    final def = Bip32PathParser.parse(coin.conf.defPath);
    if (def.elems.isEmpty) {
      throw WalletException("Invalid_coin_default_path");
    }

    List<int?> indexKeyes = List.from([
      def.elems.elementAtOrNull(0)!.index,
      def.elems.elementAtOrNull(1)?.index,
      def.elems.elementAtOrNull(2)?.index,
    ], growable: false);
    int? getCorrectIndex(int elemIndex, int elemValidIndex, int index) {
      if (elemIndex == elemValidIndex) return index;
      return indexKeyes[elemIndex];
    }

    final validIndex = indexKeyes.lastIndexWhere((element) => element != null);
    final startIndex = def.elems.elementAt(validIndex).index;
    for (int i = startIndex; i < Bip32KeyDataConst.keyIndexMaxVal; i++) {
      final newKeyIndex = Bip32AddressIndex(
        purpose: purposeIndex,
        coin: coinIndex,
        accountLevel: getCorrectIndex(0, validIndex, i),
        changeLevel: getCorrectIndex(1, validIndex, i),
        addressIndex: getCorrectIndex(2, validIndex, i),
        currencyCoin: coin,
        seedGeneration: seedGenerationType,
      );
      if (!existsIndexes.contains(newKeyIndex)) {
        return newKeyIndex;
      }
    }
    throw WalletExceptionConst.tooManyAccounts;
  }

  static Bip32AddressIndex findNextByronLegacyIndex(
      {required CryptoCoins coin, required List<Bip32AddressCore> addresses}) {
    final List<Bip32AddressIndex> addressIndex = addresses
        .map((e) => e.keyIndex)
        .whereType<Bip32AddressIndex>()
        .toList();

    for (int i = 0; i < Bip32KeyDataConst.keyIndexMaxVal; i++) {
      final newKeyIndex = Bip32AddressIndex.byronLegacy(
          firstIndex: 0, secoundIndex: i, currencyCoin: coin);
      if (!addressIndex.contains(newKeyIndex)) {
        return newKeyIndex;
      }
    }
    throw WalletExceptionConst.tooManyAccounts;
  }

  static String createCustomKeyChecksum(Bip32Base bip32) {
    return BytesUtils.toHexString(MD5.hash(<int>[
      ...bip32.publicKey.compressed,
      ...bip32.chainCode.toBytes()
    ]).sublist(0, 8));
  }

  static String validateHdPathKey(String path, {int? maxIndex}) {
    try {
      final parser = Bip32PathParser.parse(path);
      if (maxIndex != null && parser.length() != maxIndex) {
        throw WalletException(
            "hd_wallet_path_max_indeqxes".tr.replaceOne(maxIndex.toString()));
      }
      return path;
    } catch (e) {
      throw WalletException("invalid_hd_wallet_derivation_path");
    }
  }
}
