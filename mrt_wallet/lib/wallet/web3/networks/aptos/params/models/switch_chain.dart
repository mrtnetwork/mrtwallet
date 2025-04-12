import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/network/params/aptos.dart'
    show AptosChainType;
import 'package:mrt_wallet/wallet/web3/networks/aptos/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/aptos/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';

class Web3AptosSwitchChain extends Web3AptosRequestParam<bool> {
  final AptosChainType chainType;

  Web3AptosSwitchChain({required this.chainType});

  factory Web3AptosSwitchChain.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    return Web3AptosSwitchChain(
        chainType: AptosChainType.fromValue(values.elementAt(1)));
  }
  @override
  Web3AptosRequestMethods get method => Web3AptosRequestMethods.switchNetwork;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([method.tag, chainType.id]), type.tag);
  }
}
