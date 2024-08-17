import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/validator/web3_validator_utils.dart';
import 'package:on_chain/ethereum/src/address/evm_address.dart';

class Web3EthreumSwitchChain extends Web3EthereumRequestParam<String> {
  final BigInt chainId;

  Web3EthreumSwitchChain({required this.chainId});

  factory Web3EthreumSwitchChain.fromJson(Map<String, dynamic> json) {
    return Web3EthreumSwitchChain(
      chainId: Web3ValidatorUtils.parseBigInt<BigInt>(
          key: "chainId",
          json: json,
          method: Web3EthereumRequestMethods.switchEthereumChain),
    );
  }

  factory Web3EthreumSwitchChain.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
      cborBytes: bytes,
      object: object,
      hex: hex,
      tags: Web3MessageTypes.walletRequest.tag,
    );
    return Web3EthreumSwitchChain(chainId: values.elementAt(1));
  }

  @override
  Web3EthereumRequestMethods get method =>
      Web3EthereumRequestMethods.switchEthereumChain;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([method.tag, chainId]), type.tag);
  }

  @override
  Map<String, dynamic> toJson() {
    return {"chainId": chainId.toRadix16};
  }

  @override
  ETHAddress? get account => null;
}
