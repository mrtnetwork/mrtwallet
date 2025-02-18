import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/aptos/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/aptos/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:on_chain/on_chain.dart';

class Web3AptosSwitchChain extends Web3AptosRequestParam<bool> {
  final int chainId;

  Web3AptosSwitchChain({required this.chainId});

  factory Web3AptosSwitchChain.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    return Web3AptosSwitchChain(chainId: values.elementAt(1));
  }
  @override
  Web3AptosRequestMethods get method => Web3AptosRequestMethods.switchNetwork;

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
  AptosAddress? get account => null;
}
