import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/crypto/utils/solidity/solidity.dart';
import 'package:on_chain/on_chain.dart';
import 'package:on_chain/solidity/address/core.dart';

class RPCERC20Decimal extends EthereumRequest<int?, String> {
  RPCERC20Decimal(this.contractAddress, {BlockTagOrNumber? blockNumber})
      : super(blockNumber: blockNumber ?? BlockTagOrNumber.latest);

  @override
  String get method => EthereumMethods.call.value;

  final SolidityAddress contractAddress;

  final AbiFunctionFragment _function = SolidityContractUtils.erc20Decimal;

  @override
  int? onResonse(result) {
    if (result == "0x") return null;
    return EthereumRequest.onIntResponse(result);
  }

  @override
  List<dynamic> toJson() {
    return [
      {
        "to": contractAddress.toHex(),
        "data": BytesUtils.toHexString(_function.encode([]), prefix: "0x"),
      },
      blockNumber
    ];
  }
}
