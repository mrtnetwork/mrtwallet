import 'package:blockchain_utils/bip/bip/bip32/base/bip32_base.dart';
import 'package:blockchain_utils/bip/bip/bip44/base/bip44_base_ex.dart';
import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/bip/mnemonic/mnemonic.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/utility/blockchin_utils/ripple/ripple_utils.dart';
import 'package:mrt_wallet/app/utility/compute/compute.dart';
import 'package:mrt_wallet/models/wallet_models/address/core/core.dart';
import 'package:mrt_wallet/models/wallet_models/keys/keys.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

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
          WifDecoder.decode(wifKey, netVer: coin.conf.wifNetVer!).item1;
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
      case CipProposal.cip1852:
        return Cip1852.fromPrivateKey(privateKey, coin as Cip1852Coins);
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

  static String exportPrivateKey(String privateKey, CryptoCoins coin) {
    switch (coin) {
      case Bip44Coins.rippleEd25519:
      case Bip44Coins.ripple:
      case Bip44Coins.rippleTestnet:
      case Bip44Coins.rippleTestnetED25519:
        final prv = XRPPrivateKey.fromHex(privateKey,
            algorithm: XRPKeyAlgorithm.values
                .firstWhere((element) => element.curveType == coin.conf.type));
        return prv.toHex();
      default:
        return privateKey;
    }
  }

  static String extendedKeyToPrivateKey(String privateKey, CryptoCoins coin) {
    final bip32 = extendedKeyToBip32(privateKey, coin.conf.type);
    return BytesUtils.toHexString(bip32.privateKey.raw);
  }

  static ExportedPublicKey? exportPublicKey(
      List<int> pubkeyBytes, CryptoCoins coin, AppNetworkImpl network) {
    final Bip44Base account;
    try {
      switch (coin.proposal) {
        case BipProposal.bip44:
          account = Bip44.fromPublicKey(pubkeyBytes, coin as Bip44Coins);
          break;
        case BipProposal.bip49:
          account = Bip49.fromPublicKey(pubkeyBytes, coin as Bip49Coins);
          break;
        case BipProposal.bip84:
          account = Bip84.fromPublicKey(pubkeyBytes, coin as Bip84Coins);
          break;
        case BipProposal.bip86:
          account = Bip86.fromPublicKey(pubkeyBytes, coin as Bip86Coins);
          break;
        case CipProposal.cip1852:
          account = Cip1852.fromPublicKey(pubkeyBytes, coin as Cip1852Coins);
          break;
        default:
          return null;
      }
    } catch (e) {
      return null;
    }
    String extendedKey = account.publicKey.toExtended;
    List<int> comprossed = account.publicKey.compressed;
    List<int>? unComprossed = account.publicKey.uncompressed;
    String pubKey;
    String? unComprossedPubKey;
    if (network is AppXRPNetwork) {
      pubKey =
          RippleUtils.toRipplePublicKey(BytesUtils.toHexString(comprossed));
    } else {
      pubKey = BytesUtils.toHexString(comprossed);
    }
    if (!bytesEqual(unComprossed, comprossed)) {
      unComprossedPubKey = BytesUtils.toHexString(unComprossed);
    }
    return ExportedPublicKey(
        extendedKey: extendedKey,
        comprossed: pubKey,
        uncomprossed: unComprossedPubKey);
  }

  static Bip32Base extendedToBip32(
    String exKeyStr, {
    CryptoCoins? coin,
    EllipticCurveTypes? type,
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
    final conf = coin?.conf;
    switch (conf?.type ?? type) {
      case EllipticCurveTypes.secp256k1:
        bip = Bip32Slip10Secp256k1.fromExtendedKey(exKeyStr, conf?.keyNetVer);
        break;
      case EllipticCurveTypes.ed25519:
        bip = Bip32Slip10Ed25519.fromExtendedKey(exKeyStr, conf?.keyNetVer);
        break;
      case EllipticCurveTypes.ed25519Kholaw:
        if (conf?.addrParams["is_icarus"] == true) {
          bip = CardanoIcarusBip32.fromExtendedKey(exKeyStr, conf?.keyNetVer);
          break;
        }
        bip = Bip32KholawEd25519.fromExtendedKey(exKeyStr, conf?.keyNetVer);
        break;
      case EllipticCurveTypes.ed25519Blake2b:
        bip = Bip32Slip10Ed25519Blake2b.fromExtendedKey(
            exKeyStr, conf?.keyNetVer);
        break;
      case EllipticCurveTypes.nist256p1:
        bip = Bip32Slip10Nist256p1.fromExtendedKey(exKeyStr, conf?.keyNetVer);
        break;
      default:
        throw const ArgumentException("invaid type");
    }
    return validate(bip);
  }

  static Bip32Base seedToBip32(
    List<int> seedBytes, {
    CryptoCoins? coin,
    EllipticCurveTypes? type,
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
    final conf = coin?.conf;
    switch (conf?.type ?? type) {
      case EllipticCurveTypes.secp256k1:
        bip = Bip32Slip10Secp256k1.fromSeed(seedBytes, conf?.keyNetVer);
        break;
      case EllipticCurveTypes.ed25519:
        bip = Bip32Slip10Ed25519.fromSeed(seedBytes, conf?.keyNetVer);
        break;
      case EllipticCurveTypes.ed25519Kholaw:
        if (conf?.addrParams["is_icarus"] == true) {
          bip = CardanoIcarusBip32.fromSeed(seedBytes, conf?.keyNetVer);
          break;
        }
        bip = Bip32KholawEd25519.fromSeed(seedBytes, conf?.keyNetVer);
        break;
      case EllipticCurveTypes.ed25519Blake2b:
        bip = Bip32Slip10Ed25519Blake2b.fromSeed(seedBytes, conf?.keyNetVer);
        break;
      case EllipticCurveTypes.nist256p1:
        bip = Bip32Slip10Nist256p1.fromSeed(seedBytes, conf?.keyNetVer);
        break;
      default:
        throw const ArgumentException("invaid type");
    }

    return validate(bip);
  }

  static Bip32AddressIndex findNextBip32Index(
      {required CryptoCoins coin,
      required List<Bip32AddressCore> addresses,
      required SeedGenerationType seedGenerationType}) {
    final List<Bip32AddressIndex> addressIndex = addresses
        .map((e) => e.keyIndex)
        .whereType<Bip32AddressIndex>()
        .toList();
    final int purposeIndex = coin.proposal.purpose.index;
    final int coinIndex = Bip32KeyIndex.hardenIndex(coin.conf.coinIdx).index;
    final int accountLevel = coin.conf.type == EllipticCurveTypes.ed25519
        ? Bip32KeyIndex.hardenIndex(0).index
        : 0;

    for (int i = accountLevel; i < Bip32KeyDataConst.keyIndexMaxVal; i++) {
      final newKeyIndex = Bip32AddressIndex(
          purpose: purposeIndex,
          coin: coinIndex,
          accountLevel: accountLevel,
          changeLevel: accountLevel,
          addressIndex: i,
          currencyCoin: coin,
          seedGeneration: seedGenerationType);
      if (!addressIndex.contains(newKeyIndex)) {
        return newKeyIndex;
      }
    }
    throw WalletExceptionConst.tooManyAccounts;
  }

  static ByronLegacyAddressIndex findNextByronLegacyIndex(
      {required CryptoCoins coin, required List<Bip32AddressCore> addresses}) {
    final List<ByronLegacyAddressIndex> addressIndex = addresses
        .map((e) => e.keyIndex)
        .whereType<ByronLegacyAddressIndex>()
        .toList();

    for (int i = 0; i < Bip32KeyDataConst.keyIndexMaxVal; i++) {
      final newKeyIndex = ByronLegacyAddressIndex(
          firstIndex: 0, secondIndex: i, currencyCoin: coin);
      if (!addressIndex.contains(newKeyIndex)) {
        return newKeyIndex;
      }
    }
    throw WalletExceptionConst.tooManyAccounts;
  }
}
