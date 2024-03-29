import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/utility/blockchin_utils/ethereum/ethereum_abi_constant.dart';
import 'package:on_chain/address/core.dart';
import 'package:on_chain/on_chain.dart';

class RPCERC20TokenBalance extends ETHRPCRequest<BigInt> {
  RPCERC20TokenBalance(
    this.contractAddress,
    this.accountAddress, {
    BlockTagOrNumber? blockNumber,
  }) : super(blockNumber: blockNumber ?? BlockTagOrNumber.latest);

  @override
  EthereumMethods get method => EthereumMethods.call;

  final String contractAddress;
  final BaseHexAddress accountAddress;

  final AbiFunctionFragment _function = ETHAbiConstant.erc20Balance;

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
