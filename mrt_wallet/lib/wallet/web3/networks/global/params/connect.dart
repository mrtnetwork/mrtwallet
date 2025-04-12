import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/crypto/models/networks.dart' show NetworkType;
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/global/methods/methods.dart';

class Web3ConnectApplication
    extends Web3GlobalRequestParams<List<NetworkType>> {
  final NetworkType? chain;

  Web3ConnectApplication({this.chain});

  factory Web3ConnectApplication.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletGlobalRequest.tag);
    return Web3ConnectApplication(
        chain: values.elemetMybeAs<NetworkType, CborStringValue>(
            1, (e) => NetworkType.fromName(e.value)));
  }

  @override
  Web3GlobalRequestMethods get method => Web3GlobalRequestMethods.connect;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([method.id, chain?.name]), type.tag);
  }

  @override
  Object? toJsWalletResponse(response) {
    return null;
  }
}
