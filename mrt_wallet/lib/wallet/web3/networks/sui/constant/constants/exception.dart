import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/exception/exception.dart';

class Web3SuiExceptionConstant {
  static Web3RequestException retrieveObjectFailed(String? msg) =>
      Web3RequestExceptionConst.message(
          "Invalid tranaction object: Failed to retrieve the object.${msg != null ? ' Error message: $msg.' : ''}");
  static final Web3RequestException mismatchMoveCallArguments =
      Web3RequestExceptionConst.message(
          "Invalid tranaction Move call arguments. Mismatch in parameter and argument lengths.");
  static Web3RequestException fialedToParseTransactionObject(String objectId) =>
      Web3RequestExceptionConst.message(
          "Invalid tranaction: Failed to parse transaction object $objectId");
  static Web3RequestException get unsuportedTransactionVersion =>
      Web3RequestExceptionConst.unsuportedfeatures(
          "Unknow transaction version.");
}
