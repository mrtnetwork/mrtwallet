import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:mrt_wallet/crypto/utils/bitcoin/bitcoin.dart';

class BitcoinMemo {
  factory BitcoinMemo(String memo) {
    return BitcoinMemo._(
        memo,
        BitcoinScriptOutput(
            script: BTCUtils.toOpreturn([memo]), value: BigInt.zero),
        true);
  }
  BitcoinMemo._(this.memo, this.script, this.removable);
  factory BitcoinMemo.fromScript(BitcoinScriptOutput script, String memo) {
    return BitcoinMemo._(memo, script, false);
  }
  final String memo;
  final BitcoinScriptOutput script;
  final bool removable;
}
