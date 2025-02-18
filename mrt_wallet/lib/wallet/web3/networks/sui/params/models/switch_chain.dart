import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/sui/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/sui/params/core/request.dart';
import 'package:on_chain/on_chain.dart';

class Web3SuiSwitchChain extends Web3SuiRequestParam<bool> {
  final SuiChainType chainType;

  Web3SuiSwitchChain({required this.chainType});

  factory Web3SuiSwitchChain.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    return Web3SuiSwitchChain(
        chainType: SuiChainType.fromValue(values.elementAt(1)));
  }
  @override
  Web3SuiRequestMethods get method => Web3SuiRequestMethods.switchNetwork;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([method.tag, chainType.value]), type.tag);
  }

  @override
  Map<String, dynamic> toJson() {
    return {"chainType": chainType.name};
  }

  @override
  SuiAddress? get account => null;
}
