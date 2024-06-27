import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/utils/utils.dart';

/// Return the confirmed and unconfirmed balances of a script hash.
/// https://electrumx-spesmilo.readthedocs.io/en/latest/protocol-methods.html
class ElectrumGetScriptHashSumBalance
    extends ElectrumRequest<BigInt, Map<String, dynamic>> {
  ElectrumGetScriptHashSumBalance({required this.scriptHash});

  /// The script hash as a hexadecimal string (BitcoinBaseAddress.pubKeyHash())
  final String scriptHash;

  /// blockchain.scripthash.get_balance
  @override
  String get method => ElectrumRequestMethods.getBalance.method;

  @override
  List toJson() {
    return [scriptHash];
  }

  /// A dictionary with keys confirmed and unconfirmed.
  /// The value of each is the appropriate balance in minimum coin units (satoshis).
  @override
  BigInt onResonse(Map<String, dynamic> result) {
    final confirmed = BigintUtils.parse(result["confirmed"]);
    final unconfirmed = BigintUtils.parse(result["unconfirmed"]);
    return confirmed + unconfirmed;
  }
}
