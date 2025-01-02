import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';

class QuickCryptoValidator {
  static String asValidHexBytes(String hex, {int? lengthInBytes}) {
    if (lengthInBytes == null) {
      if (StringUtils.isHexBytes(hex)) {
        return hex;
      }
    } else {
      const r = r'^(0x)?[0-9a-fA-F]{#}$';
      final RegExp isHex = RegExp(r.replaceAll("#", "${lengthInBytes * 2}"));
      if (isHex.hasMatch(hex)) {
        return hex;
      }
    }
    throw WalletException("invalid_hex_bytes_string");
  }
}
