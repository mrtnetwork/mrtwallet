import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/exception/exception.dart';

class Web3TonExceptionConstant {
  static Web3RequestException get invalidTxMessage =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid transaction messages. Failed to parse or validate transaction messages.");

  static Web3RequestException get invalidMessageAddressNetwork =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid transaction network. message address network does not match the account network.");

  static Web3RequestException get invalidMessageLength =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid transaction messages. one to four message entries are required.");
}
