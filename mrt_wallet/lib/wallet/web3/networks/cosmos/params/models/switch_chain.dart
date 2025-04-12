import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/cosmos/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/cosmos/params/core/request.dart';

class Web3CosmosSwitchChain extends Web3CosmosRequestParam<bool> {
  final String chainId;
  Web3CosmosSwitchChain({required this.chainId});

  factory Web3CosmosSwitchChain.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    return Web3CosmosSwitchChain(chainId: values.elementAt(1));
  }
  @override
  Web3CosmosRequestMethods get method => Web3CosmosRequestMethods.switchNetwork;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([method.tag, chainId]), type.tag);
  }
}
