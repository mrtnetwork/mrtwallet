import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/exception/exception.dart';

class Web3AptosExceptionConstant {
  static Web3RequestException get invalidTransaction =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid Aptos transaction. The transaction must be a valid Aptos transaction and include a method like bcsToBytes.");
  static Web3RequestException get invalidAptosSigningMessage =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid Aptos sign message. Must include 'message', and 'nonce' fields");
  static Web3RequestException get invalidTransactionChainId =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid transaction Chain id. Wallet connected to the wrong network.");
  static Web3RequestException get invalidChainId =>
      Web3RequestExceptionConst.failedToParse("chainId");
}
