import 'package:blockchain_utils/bip/bip/bip32/base/bip32_base.dart';
import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/bip/mnemonic/mnemonic.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/utility/compute/compute.dart';

class BlockchainUtils {
  static Bip32Base privteKeyToBip32(
      List<int> privateKeyBytes, EllipticCurveTypes curve,
      {bool icarus = false}) {
    try {
      switch (curve) {
        case EllipticCurveTypes.secp256k1:
          return Bip32Slip10Secp256k1.fromPrivateKey(privateKeyBytes);
        case EllipticCurveTypes.ed25519:
          return Bip32Slip10Ed25519.fromPrivateKey(privateKeyBytes);
        case EllipticCurveTypes.ed25519Kholaw:
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

  static Bip32Base extendedKeyToBip32(
      String extendedKey, EllipticCurveTypes curve,
      {bool icarus = false}) {
    try {
      switch (curve) {
        case EllipticCurveTypes.secp256k1:
          return Bip32Slip10Secp256k1.fromExtendedKey(extendedKey);
        case EllipticCurveTypes.ed25519:
          return Bip32Slip10Ed25519.fromExtendedKey(extendedKey);
        case EllipticCurveTypes.ed25519Kholaw:
          if (icarus) {
            return CardanoIcarusBip32.fromExtendedKey(extendedKey);
          }
          return Bip32KholawEd25519.fromExtendedKey(extendedKey);
        case EllipticCurveTypes.ed25519Blake2b:
          return Bip32Slip10Ed25519Blake2b.fromExtendedKey(extendedKey);
        case EllipticCurveTypes.nist256p1:
          return Bip32Slip10Nist256p1.fromExtendedKey(extendedKey);
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
          WifDecoder.decode(wifKey, netVer: coin.conf.wifNetVer!).$1;
      return privteKeyToBip32(keyBytes, coin.conf.type);
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

  static Future<List<int>> mnemonicToSeed(String mnemonic,
      {String passphrase = ""}) async {
    validateMnemonic(mnemonic);
    final seed = await AppCompute.compute(
        Bip39SeedGenerator(Mnemonic.fromString(mnemonic)).generate, passphrase);
    return seed;
  }

  static Bip44Base privateKeyToBip44(String key, CryptoCoins coin) {
    final privateKey = BytesUtils.fromHexString(key);
    switch (coin.proposal) {
      case BipProposal.bip44:
        return Bip44.fromPrivateKey(privateKey, coin as Bip44Coins);
      case BipProposal.bip49:
        return Bip49.fromPrivateKey(privateKey, coin as Bip49Coins);
      case BipProposal.bip84:
        return Bip84.fromPrivateKey(privateKey, coin as Bip84Coins);
      case BipProposal.bip86:
        return Bip86.fromPrivateKey(privateKey, coin as Bip86Coins);
      default:
        throw WalletExceptionConst.invalidPrivateKey;
    }
  }

  static Bip44Base extendedKeyToBip44(String key, CryptoCoins coin) {
    switch (coin.proposal) {
      case BipProposal.bip44:
        return Bip44.fromExtendedKey(key, coin as Bip44Coins);
      case BipProposal.bip49:
        return Bip49.fromExtendedKey(key, coin as Bip49Coins);
      case BipProposal.bip84:
        return Bip84.fromExtendedKey(key, coin as Bip84Coins);
      case BipProposal.bip86:
        return Bip86.fromExtendedKey(key, coin as Bip86Coins);
      default:
        throw WalletExceptionConst.invalidPrivateKey;
    }
  }
}
