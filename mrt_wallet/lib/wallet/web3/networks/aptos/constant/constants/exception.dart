import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/exception/exception.dart';

class Web3AptosExceptionConstant {
  static Web3RequestException get invalidTransaction =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid Aptos transaction. The transaction must be a valid Aptos transaction and include a method like bcsToBytes.");
  static Web3RequestException get invalidAptosSigningMessage =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid Aptos signing message. Must include 'message', and 'nonce' fields");
  static Web3RequestException get invalidSigningMessage =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid message. Message must be a valid Uint8Array.");
  static Web3RequestException get singTransactionInsteadMessage =>
      Web3RequestExceptionConst.invalidParameters(
          "for signing a transaction using the `aptos_signTransaction` method.");
  static Web3RequestException get invalidSwitchChain =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid Aptos switch chain params. params must include 'chainId', and 'name' fields");
  static Web3RequestException get invalidTransactionChainId =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid transaction: Chain ID mismatch. Wallet connected to the wrong network.");
  static const Web3RequestException aptosNetworkDoesNotExist =
      Web3RequestException(
          message: "Invalid method parameters.",
          data: "The specified aptos network does not exist.",
          walletCode: "WEB3-5080",
          code: -32600);
}
