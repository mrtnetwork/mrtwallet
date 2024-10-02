import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/wallet/constant/constant.dart';
import 'package:stellar_dart/stellar_dart.dart';

class StellarUtils {
  static StellarAsset? tryToAssets(AssetType type,
      {String? code, StellarPublicKey? issuer}) {
    if (type == AssetType.native) {
      return StellarAssetNative();
    }
    if (code == null || issuer == null) return null;
    final isValid = StellarHelper.isValidIssueAsset(code: code, type: type);
    if (!isValid) return null;
    if (type == AssetType.poolShare) {
      return StellarAssetPoolShare(BytesUtils.fromHexString(code));
    }
    switch (type) {
      case AssetType.creditAlphanum12:
        return StellarAssetCreditAlphanum12(issuer: issuer, code: code);
      case AssetType.creditAlphanum4:
        return StellarAssetCreditAlphanum4(issuer: issuer, code: code);
      default:
        return null;
    }
  }

  static BigInt? tryRationalNumberToOfferId(BigRational? rational) {
    if (rational == null) return null;
    final toBig = rational.toBigInt();
    if (toBig.isNegative || toBig > StellarConst.maxIssueAmount) return null;
    return toBig;
  }

  static StellarPrivateKey stellarBase32SecretKeyToImportKey(
    String? secretKey,
  ) {
    try {
      return StellarPrivateKey.fromBase32(secretKey!);
    } catch (_) {
      throw WalletExceptionConst.invalidPrivateKey;
    }
  }
}
