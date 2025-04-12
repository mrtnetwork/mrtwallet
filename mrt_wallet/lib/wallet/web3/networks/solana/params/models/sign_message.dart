import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/solana/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/solana/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/networks/solana/permission/models/account.dart';
import 'package:on_chain/ethereum/src/eip_4361/eip_4361.dart';
import 'package:on_chain/solana/solana.dart';

class Web3SolanaSignInParams extends Web3SolanaSignParams {
  final EIP4631 message;
  @override
  late final String content = message.toMessage();
  Web3SolanaSignInParams({required this.message, required super.account})
      : super(data: message.toHex());
  factory Web3SolanaSignInParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CborTagsConst.web3SolanaSignInParams);
    return Web3SolanaSignInParams(
      account: Web3SolanaChainAccount.deserialize(
          object: values.elementAs<CborTagValue>(0)),
      message: EIP4631.fromJson(StringUtils.toJson(values.elementAs(1))),
    );
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          account.toCbor(),
          CborStringValue(StringUtils.fromJson(message.toJson())),
        ]),
        CborTagsConst.web3SolanaSignInParams);
  }
}

class Web3SolanaSignMessageResponse {
  final SolAddress address;
  final List<int> signature;
  final List<int> signedMessage;
  Web3SolanaSignMessageResponse(
      {required this.address,
      required List<int> signature,
      required List<int> signedMessage})
      : signature = signature.asImmutableBytes,
        signedMessage = signedMessage.asImmutableBytes;
  factory Web3SolanaSignMessageResponse.fromJson(Map<String, dynamic> json) {
    return Web3SolanaSignMessageResponse(
      address: SolAddress(json["signer"]),
      signature: (json["signature"] as List).cast(),
      signedMessage: (json["signedMessage"] as List).cast(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "signer": address.address,
      "signerAddressBytes": address.toBytes(),
      "signature": signature,
      "signedMessage": signedMessage
    };
  }
}

abstract class Web3SolanaSignParams with CborSerializable {
  final Web3SolanaChainAccount account;
  final String data;
  String? get content;

  List<int> dataBytes() {
    return BytesUtils.fromHexString(data).asImmutableBytes;
  }

  const Web3SolanaSignParams({required this.account, required this.data});
}

class Web3SolanaSignMessageParams extends Web3SolanaSignParams {
  @override
  final String? content;
  Web3SolanaSignMessageParams(
      {required super.data, required super.account, required this.content});
  factory Web3SolanaSignMessageParams.deserialize({
    List<int>? bytes,
    CborObject? object,
    String? hex,
  }) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: CborTagsConst.web3SolanaSignMessageParams);
    return Web3SolanaSignMessageParams(
        account: Web3SolanaChainAccount.deserialize(
            object: values.elementAs<CborTagValue>(0)),
        data: values.elementAs(1),
        content: values.elementAs(2));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          account.toCbor(),
          data,
          content,
        ]),
        CborTagsConst.web3SolanaSignMessageParams);
  }
}

class Web3SolanaSignMessage
    extends Web3SolanaRequestParam<List<Web3SolanaSignMessageResponse>> {
  final List<Web3SolanaSignParams> messages;
  Web3SolanaSignMessage._(
      {required List<Web3SolanaSignParams> messages, required this.method})
      : messages = messages.immutable;
  factory Web3SolanaSignMessage(
      {required List<Web3SolanaSignParams> messages,
      required Web3SolanaRequestMethods method}) {
    switch (method) {
      case Web3SolanaRequestMethods.signMessage:
      case Web3SolanaRequestMethods.signIn:
        break;
      default:
        throw Web3RequestExceptionConst.internalError;
    }
    if (messages.isEmpty) {
      throw Web3RequestExceptionConst.invalidWalletStandardSignMessage;
    }
    return Web3SolanaSignMessage._(messages: messages, method: method);
  }

  factory Web3SolanaSignMessage.deserialize({
    List<int>? bytes,
    CborObject? object,
    String? hex,
  }) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    final method = Web3NetworkRequestMethods.fromTag(values.elementAs(0));
    switch (method) {
      case Web3SolanaRequestMethods.signMessage:
        return Web3SolanaSignMessage(
            messages: values
                .elementAsListOf<CborTagValue>(1)
                .map((e) => Web3SolanaSignMessageParams.deserialize(object: e))
                .toList(),
            method: method as Web3SolanaRequestMethods);
      case Web3SolanaRequestMethods.signIn:
        return Web3SolanaSignMessage(
            messages: values
                .elementAsListOf<CborTagValue>(1)
                .map((e) => Web3SolanaSignInParams.deserialize(object: e))
                .toList(),
            method: method as Web3SolanaRequestMethods);
      default:
        throw Web3RequestExceptionConst.internalError;
    }
  }

  @override
  final Web3SolanaRequestMethods method;

  @override
  Object? toJsWalletResponse(List<Web3SolanaSignMessageResponse> response) {
    return response.map((e) => e.toJson()).toList();
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          method.tag,
          CborListValue.fixedLength(messages.map((e) => e.toCbor()).toList()),
        ]),
        type.tag);
  }

  @override
  Web3SolanaChainAccount? get account => messages.first.account;
  @override
  Web3SolanaRequest<List<Web3SolanaSignMessageResponse>, Web3SolanaSignMessage>
      toRequest(
          {required Web3RequestApplicationInformation request,
          required Web3APPAuthentication authenticated,
          required List<APPCHAIN> chains}) {
    final SolanaChain chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3SolanaRequest<List<Web3SolanaSignMessageResponse>,
            Web3SolanaSignMessage>(
        params: this,
        authenticated: authenticated,
        chain: chain,
        info: request);
  }
}
