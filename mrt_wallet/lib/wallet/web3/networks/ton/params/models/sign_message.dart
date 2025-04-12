import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/permission/models/account.dart';

class Web3TonSignMessage extends Web3TonRequestParam<List<int>> {
  @override
  final Web3TonChainAccount account;
  final String challeng;
  final String? content;

  Web3TonSignMessage(
      {required this.account, required this.challeng, this.content});

  factory Web3TonSignMessage.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
      cborBytes: bytes,
      object: object,
      hex: hex,
      tags: Web3MessageTypes.walletRequest.tag,
    );
    final List<int> challeng = values.elementAt(2);
    return Web3TonSignMessage(
        account: Web3TonChainAccount.deserialize(
            object: values.elementAs<CborTagValue>(1)),
        challeng: BytesUtils.toHexString(challeng, prefix: "0x"),
        content: values.elementAt(3));
  }

  @override
  Web3TonRequestMethods get method => Web3TonRequestMethods.signMessage;

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
  Web3TonRequest<List<int>, Web3TonSignMessage> toRequest(
      {required Web3RequestApplicationInformation request,
      required Web3APPAuthentication authenticated,
      required List<APPCHAIN> chains}) {
    final TheOpenNetworkChain chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3TonRequest<List<int>, Web3TonSignMessage>(
      params: this,
      authenticated: authenticated,
      chain: chain,
      info: request,
    );
  }
}
