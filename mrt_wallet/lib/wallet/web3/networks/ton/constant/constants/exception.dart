import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/exception/exception.dart';

class Web3TonExceptionConstant {
  static Web3RequestException get invalidTransaction =>
      Web3RequestExceptionConst.invalidParameters(
          "Transaction serialization failed");
  static Web3RequestException get incrorectTransactionWorkchainAddress =>
      Web3RequestExceptionConst.invalidParameters(
          "Transaction serialization failed: Some addresses belong to a different workchain than the current network workchain.");
}
