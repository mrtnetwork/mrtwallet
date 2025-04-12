import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/exception/exception.dart';

class Web3SubstrateExceptionConstant {
  static Web3RequestException get invalidSignMessage =>
      Web3RequestExceptionConst.invalidParameters(
          "Invalid address, type or data. The parameters must contain both 'address', type and 'data' as hexadecimal for signing.");
  static Web3RequestException get invalidSignMessageType =>
      Web3RequestExceptionConst.message(
          "Unsupported type. use 'bytes' for sign message.");
  static Web3RequestException get metadataParsingFailed =>
      Web3RequestExceptionConst.message(
          "Invalid metadata: Failed to parse or validate the metadata parameters.");
  static Web3RequestException get unsuportedMetadataVersion =>
      Web3RequestExceptionConst.message("Unsuported metadata version.");
  static Web3RequestException get differentRuntimeMetadata =>
      Web3RequestExceptionConst.message(
          "Invalid runtime information: The node returned a different genesis hash or a spec version that does not match your request.");
}
