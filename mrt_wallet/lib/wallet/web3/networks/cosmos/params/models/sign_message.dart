import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/cosmos/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/cosmos/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/networks/cosmos/permission/models/account.dart';

class Web3CosmosSignMessageResponse {
  final List<int> messageBytes;
  final List<int> signature;
  Web3CosmosSignMessageResponse(
      {required List<int> messageBytes, required List<int> signature})
      : messageBytes = messageBytes.asImmutableBytes,
        signature = signature.asImmutableBytes;
  factory Web3CosmosSignMessageResponse.fromJson(Map<String, dynamic> json) {
    return Web3CosmosSignMessageResponse(
        messageBytes: (json["messageBytes"] as List).cast(),
        signature: (json["signature"] as List).cast());
  }
  Map<String, dynamic> toJson() {
    return {"messageBytes": messageBytes, "signature": signature};
  }
}

class Web3CosmosSignMessage
    extends Web3CosmosRequestParam<Web3CosmosSignMessageResponse> {
  final String challeng;
  final String? content;
  Web3CosmosSignMessage._({
    required this.account,
    required this.challeng,
    required this.content,
  });
  factory Web3CosmosSignMessage({
    required Web3CosmosChainAccount account,
    required String challeng,
    String? content,
  }) {
    return Web3CosmosSignMessage._(
        account: account, challeng: challeng, content: content);
  }

  factory Web3CosmosSignMessage.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);

    return Web3CosmosSignMessage(
        account: Web3CosmosChainAccount.deserialize(
            object: values.elementAs<CborTagValue>(1)),
        challeng: values.elementAs(2),
        content: values.elementAs(3));
  }

  @override
  Web3CosmosRequestMethods get method => Web3CosmosRequestMethods.signMessage;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [method.tag, account.toCbor(), challeng, content]),
        type.tag);
  }

  @override
  final Web3CosmosChainAccount account;
  @override
  Web3CosmosRequest<Web3CosmosSignMessageResponse, Web3CosmosSignMessage>
      toRequest(
          {required Web3RequestApplicationInformation request,
          required Web3APPAuthentication authenticated,
          required List<APPCHAIN> chains}) {
    final CosmosChain chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3CosmosRequest<Web3CosmosSignMessageResponse,
            Web3CosmosSignMessage>(
        params: this,
        authenticated: authenticated,
        chain: chain,
        info: request);
  }

  @override
  Object? toJsWalletResponse(Web3CosmosSignMessageResponse response) {
    return response.toJson();
  }
}
