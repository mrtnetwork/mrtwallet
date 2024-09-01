import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/exception/exception.dart';

class Web3SolanaExceptionConstant {
  static Web3RequestException get invalidTransaction =>
      Web3RequestExceptionConst.invalidParameters(
          "Transaction serialization failed");
  static Web3RequestException get emptyTransactionParameters =>
      Web3RequestExceptionConst.invalidParameters(
          "At least one transaction is required for signing.");
  static Web3RequestException get invalidTransactionOptionsSigner =>
      Web3RequestExceptionConst.invalidParameters(
          "Signers do not have any effect. Please ensure all signatures are added to the transaction before signing, and remove any unused fields.");
  static Web3RequestException get invalidSignMessageData =>
      Web3RequestExceptionConst.invalidParameters(
          "for signing a transaction using the signTransaction method.");
}
