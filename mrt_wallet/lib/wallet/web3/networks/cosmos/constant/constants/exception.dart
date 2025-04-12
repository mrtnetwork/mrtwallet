import 'package:mrt_wallet/wallet/web3/web3.dart';

class Web3CosmosExceptionConstant {
  static Web3RequestException get mismatchChainId =>
      Web3RequestExceptionConst.invalidParameters(
          "Chain ID mismatch. 'request' chain ID does not match 'signDoc' chain ID.");
  static Web3RequestException get missingBodyBytes =>
      Web3RequestExceptionConst.invalidParameters(
          "Missing transaction bodyBytes.");
  static Web3RequestException get invalidAddNewChain =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid chainId or rpc. The parameters must contain both 'chainId' and 'rpc' as string.");

  static Web3RequestException get feeCoinNotFound =>
      Web3RequestExceptionConst.message(
          "Transaction fee unavailable. Token not found");

  static Web3RequestException get invalidAccountOrTransaction =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid account or transaction data. Parameters must include 'account' as a Uint8Array, and 'transaction' as a Uint8Array encoded either as Amino JSON (UTF-8) or a SignDoc protobuf buffer.");
}
