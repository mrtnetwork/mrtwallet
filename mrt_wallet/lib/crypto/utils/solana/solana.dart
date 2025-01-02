import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:on_chain/on_chain.dart';

class SolanaCryptoUtils {
  static SolanaPrivateKey convertSolanaBase58ToPrivateKey(String? b58Key) {
    try {
      return SolanaPrivateKey.fromBase58(b58Key!);
    } catch (e) {
      throw WalletExceptionConst.invalidPrivateKey;
    }
  }
}
