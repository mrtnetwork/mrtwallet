import 'package:blockchain_utils/base58/base58_base.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:on_chain/on_chain.dart';

class SolanaCryptoUtils {
  static SolanaPrivateKey convertSolanaBase58ToPrivateKey(String? secretKey) {
    try {
      final bytes = Base58Decoder.decode(secretKey!);
      return SolanaPrivateKey.fromBytes(bytes);
    } catch (e) {
      throw WalletExceptionConst.invalidPrivateKey;
    }
  }
}
