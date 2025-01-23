import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/tron/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/tron/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/validator/web3_validator_utils.dart';
import 'package:on_chain/tron/tron.dart';

class Web3TronSwitchChain extends Web3TronRequestParam<String> {
  final BigInt chainId;

  Web3TronSwitchChain({required this.chainId});

  factory Web3TronSwitchChain.fromJson(Map<String, dynamic> json) {
    return Web3TronSwitchChain(
      chainId: Web3ValidatorUtils.parseBigInt<BigInt>(
          key: "chainId",
          json: json,
          method: Web3EthereumRequestMethods.switchEthereumChain),
    );
  }

  factory Web3TronSwitchChain.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    return Web3TronSwitchChain(chainId: values.elementAt(1));
  }
  @override
  Web3TronRequestMethods get method => Web3TronRequestMethods.switchTronChain;

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
  TronAddress? get account => null;
}
