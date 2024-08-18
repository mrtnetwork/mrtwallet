import 'package:blockchain_utils/bip/ecc/curve/elliptic_curve_types.dart';
import 'package:blockchain_utils/utils/string/string.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/wallet/constant/constant.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class SubstrateUtils {
  static Map<String, dynamic> buildTransferStruct(
      {required SubstrateAddress destination,
      required BigInt value,
      bool usePallet = false}) {
    final transfer = {
      "transfer_allow_death": {
        "dest": {"Id": destination.toBytes()},
        "value": value
      }
    };
    if (!usePallet) return transfer;
    return {SubstrateConst.balancePalletName: transfer};
  }

  static Map<String, dynamic> buildMethod(List<Map<String, dynamic>> messages) {
    if (messages.isEmpty) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    if (messages.length == 1) {
      return messages[0];
    }
    return {SubstrateConst.utilityBatchVariantName: messages};
  }

  static List<Map<String, dynamic>> buildRemarks(List<String> messages) {
    if (messages.isEmpty) {
      return [];
    }
    return messages
        .map((e) => {
              SubstrateConst.systemPalletName: {
                SubstrateConst.systemRemarkVariantName: StringUtils.toBytes(e)
              }
            })
        .toList();
  }

  static SubstrateAddress toAddress({
    required List<int> publicKey,
    required int ss58Format,
    required EllipticCurveTypes curve,
  }) {
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
}
