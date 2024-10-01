import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/exception/exception.dart';

class Web3StellarExceptionConstant {
  static Web3RequestException get invalidTransaction =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid transaction. The transaction must be a valid Stellar XDR serialization of either a TransactionV1 or a FeeBumpTransaction in Base64 format.");
  static Web3RequestException get unsuportedTxVersion =>
      Web3RequestExceptionConst.invalidParameters(
          "Unsuported transaction V0. The transaction must be a valid Stellar XDR serialization of either a TransactionV1 or a FeeBumpTransaction in Base64 format.");
  static Web3RequestException get singTransactionInsteadMessage =>
      Web3RequestExceptionConst.invalidParameters(
          "for signing a transaction using the `stellar_signTransaction` method.");
}
