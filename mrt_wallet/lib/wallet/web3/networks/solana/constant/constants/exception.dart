import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/exception/exception.dart';

class Web3SolanaExceptionConstant {
  static Web3RequestException get invalidTransaction =>
      Web3RequestExceptionConst.invalidParameters(
          "Transaction serialization failed");
  static Web3RequestException get invalidBatchTransactionRequest =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid batch transaction request. The first parameter must be a list of transactions when sending a batch request.");
  static Web3RequestException get emptyTransactionParameters =>
      Web3RequestExceptionConst.invalidParameters(
          "At least one transaction is required for signing.");
  static Web3RequestException get signleRequestInsteadBatchError =>
      Web3RequestExceptionConst.invalidParameters(
          "For multiple requests, please use the signAllTransactions or sendAllTransactions method.");
  static Web3RequestException get invalidTransactionOptionsSigner =>
      Web3RequestExceptionConst.invalidParameters(
          "Signers do not have any effect. Please ensure all signatures are added to the transaction before signing, and remove any unused fields.");
  static Web3RequestException get singTransactionInsteadMessage =>
      Web3RequestExceptionConst.invalidParameters(
          "for signing a transaction using the `solana_signTransaction` method.");
}
