import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/exception/exception.dart';

class Web3SubstrateExceptionConstant {
  static Web3RequestException get invalidTransaction =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid transaction parameters. ");

  static Web3RequestException get invalidTransactionSpecVersion =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid spec version: The request contains a specVersion that differs from the current wallet network's specVersion.");

  static Web3RequestException get invalidSignMessage =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid sign message request: The request must include an address, type, and data. The data must be valid hexadecimal bytes.");
  static Web3RequestException get invalidSignMessageType =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid sign message request type: Use `signPayload` for signing.");
  static Web3RequestException get invalidProvideMetadataRequest =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid provide metadata request: The request must include the following parameters: chain, genesisHash, ss58Format, specVersion, tokenDecimals, and tokenSymbol.");
  static Web3RequestException get metadataParsingFailed =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid provide metadata request: Failed to parse metadata.");

  static Web3RequestException get unsuportedMetadataVersion =>
      Web3RequestExceptionConst.unsuportedfeatures(
          "Unsuported metadata version.");

  static Web3RequestException get differentRuntimeMetadata =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid provide metadata request: The node returned a different genesis hash or a spec version that does not match your request.");
}
