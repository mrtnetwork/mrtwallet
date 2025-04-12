import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/global/methods/methods.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';

class Web3DisconnectApplication
    extends Web3GlobalRequestParams<List<NetworkType>> {
  final NetworkType chain;
  Web3DisconnectApplication({required this.chain});

  factory Web3DisconnectApplication.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletGlobalRequest.tag);
    return Web3DisconnectApplication(
        chain: NetworkType.fromName(values.elementAt(1)));
  }

  @override
  Web3GlobalRequestMethods get method => Web3GlobalRequestMethods.disconnect;

  @override
  Object? toJsWalletResponse(response) {
    return null;
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([method.id, chain.name]), type.tag);
  }
}
