import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/exception/exception.dart';

class Web3EthereumExceptionConst {
  ///
  static Web3RequestException get mismatchAccountAndTransactionFrom =>
      Web3RequestExceptionConst.message(
          "Invalid transaction from. Mismatch between account and transaction from address.");
  static Web3RequestException get mismatchAccountAndTransactionChainId =>
      Web3RequestExceptionConst.message(
          "Invalid transaction chain id. Mismatch between account and transaction chain ID.");
  static Web3RequestException get invalidWalletStandardSendTransaction =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid account or transaction. The parameters must contain both 'account' and 'transaction' as object.");
  static Web3RequestException get invalidWalletStandardTypeData =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid account or message. The parameters must contain both 'account' and 'typeData' as object.");
  static Web3RequestException get invalidGasArg =>
      Web3RequestExceptionConst.invalidParameters(
          'cannot use both legacy and EIP-1559 gas parameters simultaneously.');
  static Web3RequestException get invalidEIP1559GasArg =>
      Web3RequestExceptionConst.invalidParameters(
          "To use EIP-1559 gas metrics, you must fill both maxFeePerGas and maxPriorityFeePerGas fields.");
  static Web3RequestException get missingRpcUrls =>
      Web3RequestExceptionConst.invalidParameters(
          "At least one valid rpcUrl is required. Each URL must start with a valid scheme: http, https, ws, or wss.");
  static Web3RequestException get invalidAccessListParams =>
      Web3RequestExceptionConst.failedToParse("accessList");
  static Web3RequestException parsignTypedDataFailed(int version) =>
      Web3RequestExceptionConst.failedToParse("typedData");
  static Web3RequestException get missingChainId =>
      Web3RequestExceptionConst.failedToParse("chainId");
  static Web3RequestException get missingChainName =>
      Web3RequestExceptionConst.failedToParse("chainName");
  static Web3RequestException get missingNativeCurrency =>
      Web3RequestExceptionConst.failedToParse("nativeCurrency");
  static Web3RequestException get missingSymbol =>
      Web3RequestExceptionConst.failedToParse("symbol");
  static Web3RequestException get missingTo =>
      Web3RequestExceptionConst.failedToParse("to");
  static Web3RequestException get missingFrom =>
      Web3RequestExceptionConst.failedToParse("from");
  static Web3RequestException get missingName =>
      Web3RequestExceptionConst.failedToParse("name");
  static Web3RequestException get invalidTypeData =>
      Web3RequestExceptionConst.failedToParse("typeData");
  static Web3RequestException get invalidTransactionData =>
      Web3RequestExceptionConst.failedToParse("data");
  static Web3RequestException get invalidSwitchChain =>
      Web3RequestExceptionConst.failedToParse("chainId");
  static Web3RequestException get invalidMessage =>
      Web3RequestExceptionConst.failedToParse("message");
  static Web3RequestException get invalidAddress =>
      Web3RequestExceptionConst.failedToParse("address");
  static Web3RequestException get missingTransactionRequiredFields =>
      Web3RequestExceptionConst.invalidParameters(
          'Some required fields are missing: from, value.');
}
