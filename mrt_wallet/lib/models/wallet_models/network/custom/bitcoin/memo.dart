import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:mrt_wallet/app/core.dart';

class BitcoinMemo {
  factory BitcoinMemo(String memo) {
    return BitcoinMemo._(
        memo,
        BitcoinScriptOutput(
            script: BitcoinUtils.toOpreturn([memo]), value: BigInt.zero),
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
