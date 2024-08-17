import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/utils/method/utiils.dart';
import 'package:mrt_wallet/app/utils/string/utils.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/methods/methods.dart';
import 'package:on_chain/solidity/solidity.dart';

class Web3EthereumValidator {
  static const int maximumSymbolAndCurrencyName = 15;
  static const int minimumSymbolAndCurrencyName = 15;
  static bool isValidCurrencyInfo(String name, String symbol) {
    final int symbolLength = symbol.length;
    final int nameLength = name.length;
    if (symbolLength < minimumSymbolAndCurrencyName ||
        nameLength < minimumSymbolAndCurrencyName ||
        symbolLength > maximumSymbolAndCurrencyName ||
        nameLength > maximumSymbolAndCurrencyName) {
      return false;
    }
    return true;
  }

  static EIP712Base parseTypedData({
    required String data,
    required Web3EthereumRequestMethods method,
  }) {
    final parse = MethodUtils.nullOnException(() {
      final Map<String, dynamic> parsedData = StringUtils.toJson(data);
      return EIP712Base.fromJson(parsedData);
    });
    if (parse == null) {
      throw Web3RequestExceptionConst.ethTypedData;
    }
    try {
      parse.encode();
    } on SolidityAbiException catch (e) {
      throw Web3RequestExceptionConst.ethTypedDataMessage(e.message);
    } catch (e) {
      throw Web3RequestExceptionConst.ethTypedData;
    }
    return parse;
  }

  static List<String> validateRpcs(List<String> rpcs) {
    final List<String> validRpcs = [];
    for (final i in rpcs) {
      final isValid =
          StrUtils.validateUri(i, schame: ["http", "https", "ws", "wss"]);
      if (isValid == null) continue;
      validRpcs.add(i);
    }
    if (validRpcs.isEmpty) {
      throw Web3RequestExceptionConst.wrongRpcUrls;
    }
    return validRpcs;
  }
}
