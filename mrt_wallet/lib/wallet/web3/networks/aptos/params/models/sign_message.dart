import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/helper/helper.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/aptos/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/aptos/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/networks/aptos/permission/models/account.dart'
    show Web3AptosChainAccount;

class Web3AptosSignMessageResponse {
  final String? message;
  final String? nonce;
  final int? chainId;
  final String? address;
  final String? application;
  final String? prefix;
  final String? fullMessage;
  final List<int> signature;

  Web3AptosSignMessageResponse._(
      {this.address,
      this.message,
      this.nonce,
      this.chainId,
      this.application,
      this.prefix,
      this.fullMessage,
      required List<int> signature})
      : signature = signature.asImmutableBytes;
  factory Web3AptosSignMessageResponse.aptos({
    String? address,
    required String message,
    required String nonce,
    required String fullMessage,
    required String prefix,
    int? chainId,
    String? application,
    required List<int> signature,
  }) {
    return Web3AptosSignMessageResponse._(
        address: address,
        message: message,
        nonce: nonce,
        chainId: chainId,
        application: application,
        signature: signature,
        fullMessage: fullMessage,
        prefix: prefix);
  }
  factory Web3AptosSignMessageResponse.wallet({required List<int> signature}) {
    return Web3AptosSignMessageResponse._(signature: signature);
  }
  factory Web3AptosSignMessageResponse.fromJson(Map<String, dynamic> json) {
    return Web3AptosSignMessageResponse._(
        signature: (json["signature"] as List).cast(),
        nonce: json["nonce"],
        chainId: json["chainId"],
        address: json["address"],
        application: json["application"],
        prefix: json["prefix"],
        fullMessage: json["fullMessage"],
        message: json["message"]);
  }
  Map<String, dynamic> toJson() {
    return {
      "message": message,
      "nonce": nonce,
      "chainId": chainId,
      "address": address,
      "application": application,
      "prefix": prefix,
      "fullMessage": fullMessage,
      "signature": signature
    };
  }
}

class Web3AptosSignMessage
    extends Web3AptosRequestParam<Web3AptosSignMessageResponse> {
  final String? message;
  final String? nonce;
  final bool? chainId;
  final bool? address;
  final bool? application;
  final String? messageBytes;
  Web3AptosSignMessage._(
      {required this.account,
      this.message,
      this.nonce,
      this.chainId,
      this.address,
      this.application,
      this.messageBytes});
  factory Web3AptosSignMessage.aptos(
      {required Web3AptosChainAccount account,
      required String message,
      required String nonce,
      bool? chainId,
      bool? address,
      bool? application}) {
    return Web3AptosSignMessage._(
        account: account,
        message: message,
        nonce: nonce,
        chainId: chainId,
        address: address,
        application: application);
  }
  factory Web3AptosSignMessage.wallet(
      {required Web3AptosChainAccount account, required String message}) {
    return Web3AptosSignMessage._(account: account, messageBytes: message);
  }

  factory Web3AptosSignMessage.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
      cborBytes: bytes,
      object: object,
      hex: hex,
      tags: Web3MessageTypes.walletRequest.tag,
    );
    return Web3AptosSignMessage._(
        account: Web3AptosChainAccount.deserialize(
            object: values.elementAs<CborTagValue>(1)),
        message: values.elementAs(2),
        address: values.elementAs(3),
        application: values.elementAs(4),
        chainId: values.elementAs(5),
        nonce: values.elementAs(6),
        messageBytes: values.elementAs(7));
  }

  @override
  Web3AptosRequestMethods get method => Web3AptosRequestMethods.signMessage;

  @override
  Object? toJsWalletResponse(Web3AptosSignMessageResponse response) {
    return response.toJson();
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          method.tag,
          account.toCbor(),
          message,
          address,
          application,
          chainId,
          nonce,
          messageBytes
        ]),
        type.tag);
  }

  @override
  final Web3AptosChainAccount account;
  @override
  Web3AptosRequest<Web3AptosSignMessageResponse, Web3AptosSignMessage>
      toRequest(
          {required Web3RequestApplicationInformation request,
          required Web3APPAuthentication authenticated,
          required List<APPCHAIN> chains}) {
    final AptosChain chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3AptosRequest<Web3AptosSignMessageResponse, Web3AptosSignMessage>(
        params: this,
        authenticated: authenticated,
        chain: chain,
        info: request);
  }
}
