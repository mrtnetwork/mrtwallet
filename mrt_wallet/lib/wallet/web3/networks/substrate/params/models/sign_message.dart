import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/substrate/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/substrate/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/networks/substrate/permission/models/account.dart';

class Web3SubstrateSignMessage
    extends Web3SubstrateRequestParam<Map<String, dynamic>> {
  @override
  final Web3SubstrateChainAccount account;
  final String challeng;
  final String? content;

  Web3SubstrateSignMessage(
      {required this.account, required this.challeng, this.content});

  factory Web3SubstrateSignMessage.deserialize({
    List<int>? bytes,
    CborObject? object,
    String? hex,
  }) {
    final CborListValue values = CborSerializable.cborTagValue(
      cborBytes: bytes,
      object: object,
      hex: hex,
      tags: Web3MessageTypes.walletRequest.tag,
    );
    final List<int> challeng = values.elementAt(2);
    return Web3SubstrateSignMessage(
        account: Web3SubstrateChainAccount.deserialize(
            object: values.elementAs<CborTagValue>(1)),
        challeng: BytesUtils.toHexString(challeng, prefix: "0x"),
        content: values.elementAt(3));
  }

  @override
  Web3SubstrateRequestMethods get method =>
      Web3SubstrateRequestMethods.signMessage;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          method.tag,
          account.toCbor(),
          CborBytesValue(BytesUtils.fromHexString(challeng)),
          content
        ]),
        type.tag);
  }

  List<int> chalengBytes() {
    return BytesUtils.fromHexString(challeng);
  }

  @override
  Web3SubstrateRequest<Map<String, dynamic>, Web3SubstrateSignMessage>
      toRequest(
          {required Web3RequestApplicationInformation request,
          required Web3APPAuthentication authenticated,
          required List<APPCHAIN> chains}) {
    final SubstrateChain chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3SubstrateRequest<Map<String, dynamic>, Web3SubstrateSignMessage>(
      params: this,
      authenticated: authenticated,
      chain: chain,
      info: request,
    );
  }
}
