import 'package:blockchain_utils/bip/ecc/curve/elliptic_curve_types.dart';
import 'package:blockchain_utils/crypto/quick_crypto.dart';
import 'package:blockchain_utils/utils/string/string.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/wallet/constant/constant.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class SubstrateUtils {
  static Map<String, dynamic> buildMethod(List<Map<String, dynamic>> messages) {
    if (messages.isEmpty) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    if (messages.length == 1) {
      return messages[0];
    }
    return {APPSubstrateConst.utilityBatchVariantName: messages};
  }

  static List<Map<String, dynamic>> buildRemarks(List<String> messages) {
    if (messages.isEmpty) {
      return [];
    }
    return messages
        .map((e) => {
              APPSubstrateConst.systemPalletName: {
                APPSubstrateConst.systemRemarkVariantName:
                    StringUtils.toBytes(e)
              }
            })
        .toList();
  }

  static BaseSubstrateAddress toAddress({
    required List<int> publicKey,
    required int ss58Format,
    required EllipticCurveTypes curve,
    bool isEthereum = false,
  }) {
    if (isEthereum) {
      if (curve != EllipticCurveTypes.secp256k1) {
        throw WalletExceptionConst.dataVerificationFailed;
      }
      return SubstrateEthereumAddress.fromPublicKey(publicKey);
    }
    switch (curve) {
      case EllipticCurveTypes.ed25519:
        return SubstrateAddress.fromEddsa(publicKey, ss58Format: ss58Format);
      case EllipticCurveTypes.secp256k1:
        return SubstrateAddress.fromEcdsa(publicKey, ss58Format: ss58Format);
      case EllipticCurveTypes.sr25519:
        return SubstrateAddress.fromSr25519(publicKey, ss58Format: ss58Format);
      default:
        throw WalletExceptionConst.dataVerificationFailed;
    }
  }

  static SubstrateMultiSignature buildMultiSignature({
    required EllipticCurveTypes algorithm,
    required List<int> signature,
  }) {
    final SubstrateBaseSignature substrateSignature;
    switch (algorithm) {
      case EllipticCurveTypes.ed25519:
        substrateSignature = SubstrateED25519Signature(signature);
        break;
      case EllipticCurveTypes.secp256k1:
        substrateSignature = SubstrateEcdsaSignature(signature);
        break;
      case EllipticCurveTypes.sr25519:
        substrateSignature = SubstrateSr25519Signature(signature);
        break;

      default:
        throw UnimplementedError("invalid substrate curve type");
    }
    return SubstrateMultiSignature(substrateSignature);
  }

  static Map<String, dynamic> buildMultiSignatureTemplate({
    required EllipticCurveTypes algorithm,
    required List<int> signature,
  }) {
    switch (algorithm) {
      case EllipticCurveTypes.ed25519:
        return {"Ed25519": signature};
      case EllipticCurveTypes.secp256k1:
        return {"Ecdsa": signature};
      case EllipticCurveTypes.sr25519:
        return {"Sr25519": signature};

      default:
        throw UnimplementedError("invalid substrate curve type");
    }
  }

  static List<int> createPayload(List<int> bytes) {
    if (bytes.length > TransactionPalyloadConst.requiredHashDigestLength) {
      return QuickCrypto.blake2b256Hash(bytes);
    } else {
      return bytes;
    }
  }

  static List<int> createFakeSignature(EllipticCurveTypes algorithm) {
    return switch (algorithm) {
      EllipticCurveTypes.secp256k1 =>
        List<int>.filled(SubstrateConstant.ecdsaSignatureLength, 0),
      _ => List<int>.filled(SubstrateConstant.signatureLength, 0)
    };
  }
}
