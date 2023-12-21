import 'package:blockchain_utils/bip/bip/bip32/base/bip32_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/constant/network_constant/ripple_const.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/utility/bytes_utils/quick_bytes.dart';
import 'package:mrt_wallet/models/wallet_models/address/network_address/xrp/xrp_account.dart';
import 'package:xrp_dart/xrp_dart.dart';
import 'blockchaain_utils.dart';

class RippleUtils {
  static List<XRPLMemo> toXrplMemos(List<XRPLMemo> memos) {
    List<XRPLMemo> hexMemoms = [];
    for (final i in memos) {
      String? memoData;
      String? memoFormat;
      String? memoType;
      if (i.memoData != null) {
        memoData = QuickBytesUtils.ensureIsHex(i.memoData!);
      }
      if (i.memoFormat != null) {
        memoFormat = QuickBytesUtils.ensureIsHex(i.memoFormat!);
      }
      if (i.memoType != null) {
        memoType = QuickBytesUtils.ensureIsHex(i.memoType!);
      }
      hexMemoms.add(XRPLMemo(
          memoData: memoData, memoFormat: memoFormat, memoType: memoType));
    }
    return hexMemoms;
  }

  static Payment createPayment({
    required CurrencyAmount amount,
    required IXRPAddress account,
    required String destination,
    required BigInt fee,
    List<XRPLMemo> memos = const [],
  }) {
    return Payment(
      amount: amount,
      destination: destination,
      account: account.networkAddress.toString(),
      memos: memos.isEmpty ? null : toXrplMemos(memos),
      signingPubKey: BytesUtils.toHexString(account.publicKey),
      fee: fee,
    );
  }

  static TrustSet createTrustSet(
      {required IssuedCurrencyAmount limitAmount,
      required IXRPAddress account,
      required BigInt fee,
      List<XRPLMemo> memos = const [],
      TrustSetFlag? flag,
      int? qualityIn,
      int? qualityOut}) {
    return TrustSet(
        account: account.networkAddress.toString(),
        flags: flag?.value ?? 0,
        signingPubKey: BytesUtils.toHexString(account.publicKey),
        limitAmount: limitAmount,
        fee: fee,
        memos: memos.isEmpty ? null : toXrplMemos(memos),
        qualityIn: qualityIn,
        qualityOut: qualityOut);
  }

  static AccountSet createAccountSet({
    required IXRPAddress account,
    required BigInt fee,
    List<XRPLMemo> memos = const [],
    AccountSetAsfFlag? setFlag,
    AccountSetAsfFlag? clearFlag,
    String? domain,
    String? emailHash,
    String? messageKey,
    String? nftTokenMinter,
    BigRational? transferRate,
    BigRational? tickSize,
  }) {
    return AccountSet(
      account: account.networkAddress.toString(),
      setFlag: setFlag,
      clearFlag: clearFlag,
      signingPubKey: BytesUtils.toHexString(account.publicKey),
      domain: domain == null ? null : QuickBytesUtils.ensureIsHex(domain),
      emailHash: emailHash == null
          ? null
          : QuickBytesUtils.ensureHexWithLength(
              emailHash, RippleConst.maxEmailHashLength),
      fee: fee,
      memos: memos.isEmpty ? null : toXrplMemos(memos),
      messageKey: messageKey,
      nftTokenMinter: nftTokenMinter,
      tickSize: tickSize?.toBigInt().toInt(),
      transferRate: transferRate?.toBigInt().toInt(),
    );
  }

  static BigRational? validateQuilityInOutTrustSet(BigRational? val) {
    if (val == null ||
        val.isNegative ||
        val.isDecimal ||
        val > RippleConst.max32UnsignedRational) {
      return null;
    }
    return val;
  }

  static BigRational? validateTrustSetLimit(BigRational? val) {
    if (val == null || val.precision > RippleConst.maxIouPrecision) {
      return null;
    }
    return val;
  }

  static String? validateCurrencyCode(String? val) {
    if (val == null || !RippleConst.currencyCodeRegex.hasMatch(val)) {
      return null;
    }
    return val;
  }

  static BigRational? validateAccoutSetTransferRate(BigRational? val) {
    if (val == null) return null;
    if (val == BigRational.zero) return val;
    if (val.isNegative || val.isDecimal) return null;
    if (val >= RippleConst.rippleAccountTransferRateMin &&
        val <= RippleConst.rippleAccountTransferRateMax) {
      return val;
    }
    return null;
  }

  static BigRational? validateAccoutSetTickSize(BigRational? val) {
    if (val == null) return null;
    if (val == BigRational.zero) return val;
    if (val.isNegative || val.isDecimal) return null;
    if (val >= RippleConst.rippleAccountSetTickSizeMin &&
        val <= RippleConst.rippleAccountSetTickSizeMax) {
      return val;
    }
    return null;
  }

  static String? validateRipplePublicKey(String? val) {
    if (val == null) return null;
    try {
      final keyBytes = BytesUtils.fromHexString(val);
      if (keyBytes.length != RippleKeyConst.publicKeyLength) return null;
      if (Secp256k1PublicKeyEcdsa.isValidBytes(keyBytes)) {
        return val;
      } else if (Ed25519PublicKey.isValidBytes(keyBytes)) {
        return val;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static BigInt calculateFee(int netFee, XRPLTransactionType transactionType,
      {String? fulfillment, int multiSigners = 0}) {
    int baseFee = netFee;

    /// Check if the transaction type is ESCROW_FINISH.
    if (transactionType == XRPLTransactionType.escrowFinish) {
      /// Cast the transaction as an EscrowFinish to access specific properties.

      if (fulfillment != null) {
        /// Calculate the length of the fulfillment in bytes.
        int fulfillmentBytesLength = fulfillment.codeUnits.length;

        /// Adjust the base fee based on the fulfillment length.
        baseFee = (netFee * (33 + (fulfillmentBytesLength / 16)).ceil()).ceil();
      }
    }

    // /// Adjust the base fee if the transaction involves multi-signers.
    if (multiSigners > 0) {
      baseFee += netFee * (1 + multiSigners);
    }
    return BigInt.from(baseFee);
  }

  static String? ensureIsRippleAddress(String? address) {
    try {
      if (address == null) return null;
      XRPAddressUtils.ensureClassicAddress(address);
      return address;
    } catch (e) {
      return null;
    }
  }

  static String ensureClassicAddress(String address) {
    return XRPAddressUtils.ensureClassicAddress(address);
  }

  static XRPKeyAlgorithm? findXRPPrivateKeyAlgorithm(String keyHex) {
    try {
      return XRPPrivateKey.findAlgorithm(BytesUtils.fromHexString(keyHex));
    } catch (e) {
      return null;
    }
  }

  static XRPKeyAlgorithm? findXrpSeedAlgorithm(String seed) {
    try {
      return XrpSeedUtils.decodeSeed(seed).item2;
    } catch (e) {
      return null;
    }
  }

  static Bip32Base rippleSeedToBip32(String seed) {
    try {
      final ripplePrivateKey = XRPPrivateKey.fromSeed(seed);
      return BlockchainUtils.privteKeyToBip32(
          ripplePrivateKey.toBytes(), ripplePrivateKey.algorithm.curveType);
    } on WalletException {
      rethrow;
    } catch (e) {
      throw WalletExceptionConst.invalidPrivateKey;
    }
  }

  static Bip32Base ripplePrivateKeyToBip32(
      String privateKey, XRPKeyAlgorithm algorithm) {
    try {
      final ripplePrivateKey = XRPPrivateKey.fromBytes(
          BytesUtils.fromHexString(privateKey),
          algorithm: algorithm);
      return BlockchainUtils.privteKeyToBip32(
          ripplePrivateKey.toBytes(), ripplePrivateKey.algorithm.curveType);
    } on WalletException {
      rethrow;
    } catch (e) {
      throw WalletExceptionConst.invalidPrivateKey;
    }
  }

  static Bip32Base rippleEntropyToBip32(
      String entropy, XRPKeyAlgorithm algorithm) {
    try {
      final ripplePrivateKey =
          XRPPrivateKey.fromEntropy(entropy, algorithm: algorithm);
      return BlockchainUtils.privteKeyToBip32(
          ripplePrivateKey.toBytes(), ripplePrivateKey.algorithm.curveType);
    } on WalletException {
      rethrow;
    } catch (e) {
      throw WalletExceptionConst.invalidPrivateKey;
    }
  }

  static XRPAddress publicKeyToRippleAddress(List<int> keyBytes,
      [XRPKeyAlgorithm? algorithm]) {
    final publicKey = XRPPublicKey.fromBytes(keyBytes, algorithm: algorithm);
    return publicKey.toAddress();
  }

  static XRPAddress strPublicKeyToRippleAddress(String keyHex) {
    final publicKey = XRPPublicKey.fromHex(keyHex);
    return publicKey.toAddress();
  }

  static String toRipplePublicKey(String bip32PublicKey) {
    final keyBytes = XRPPublicKey.fromHex(bip32PublicKey);
    return keyBytes.toHex();
  }
}
