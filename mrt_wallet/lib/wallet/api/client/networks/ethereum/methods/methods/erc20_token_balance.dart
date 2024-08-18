import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/crypto/utils/solidity/solidity.dart';
import 'package:on_chain/on_chain.dart';
import 'package:on_chain/solidity/address/core.dart';

class RPCERC20TokenBalance extends ETHRPCRequest<BigInt> {
  RPCERC20TokenBalance(
    this.contractAddress,
    this.accountAddress, {
    BlockTagOrNumber? blockNumber,
  }) : super(blockNumber: blockNumber ?? BlockTagOrNumber.latest);

  @override
  EthereumMethods get method => EthereumMethods.call;

  final String contractAddress;
  final SolidityAddress accountAddress;

  final AbiFunctionFragment _function = SolidityContractUtils.erc20Balance;

  @override
  BigInt onResonse(result) {
    return ETHRPCRequest.onBigintResponse(result);
  }

  @override
  List<dynamic> toJson() {
    return [
      {
        "to": contractAddress,
        "data": BytesUtils.toHexString(_function.encode([accountAddress]),
            prefix: "0x"),
      },
      blockNumber
    ];
  }
}
