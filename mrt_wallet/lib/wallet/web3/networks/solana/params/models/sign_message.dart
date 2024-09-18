import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/app/utils/utils.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/solana/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/solana/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/validator/web3_validator_utils.dart';
import 'package:on_chain/solana/solana.dart';

class Web3SolanaSignMessageResponse {
  final SolAddress address;
  final List<int> signature;
  Web3SolanaSignMessageResponse(
      {required this.address, required List<int> signature})
      : signature = BytesUtils.toBytes(signature, unmodifiable: true);
  factory Web3SolanaSignMessageResponse.fromJson(Map<String, dynamic> json) {
    return Web3SolanaSignMessageResponse(
        address: SolAddress(json["signer"]),
        signature: (json["signature"] as List).cast());
  }
  Map<String, dynamic> toJson() {
    return {
      "signer": address.address,
      "signerAddressBytes": address.toBytes(),
      "signature": signature,
    };
  }
}

class Web3SolanaSignMessage
    extends Web3SolanaRequestParam<Web3SolanaSignMessageResponse> {
  final SolAddress address;
  final String challeng;
  final String? content;

  Web3SolanaSignMessage(
      {required this.address, required this.challeng, this.content});

  factory Web3SolanaSignMessage.fromJson(Map<String, dynamic> json) {
    const method = Web3SolanaRequestMethods.signMessage;
    String? content =
        StringUtils.tryDecode(BytesUtils.fromHexString(json["challeng"]));
    if (content != null) {
      content = StrUtils.toRawString(content);
    }
    return Web3SolanaSignMessage(
        address: Web3ValidatorUtils.parseAddress<SolAddress>(
            onParse: (obj) => SolAddress(obj),
            key: "address",
            method: method,
            json: json),
        challeng: Web3ValidatorUtils.parseHex<String>(
            key: "challeng", method: method, json: json),
        content: content);
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
      tags: Web3MessageTypes.walletRequest.tag,
    );
    final List<int> challeng = values.elementAt(2);
    return Web3SolanaSignMessage(
        address: SolAddress(values.elementAt(1)),
        challeng: BytesUtils.toHexString(challeng, prefix: "0x"),
        content: values.elementAt(3));
  }

  @override
  Web3SolanaRequestMethods get method => Web3SolanaRequestMethods.signMessage;

  @override
  Object? toJsWalletResponse(Web3SolanaSignMessageResponse response) {
    return response.toJson();
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          method.tag,
          address.address,
          CborBytesValue(BytesUtils.fromHexString(challeng)),
          content
        ]),
        type.tag);
  }

  @override
  Map<String, dynamic> toJson() {
    return {"address": address.address, "challeng": challeng};
  }

  List<int> chalengBytes() {
    return BytesUtils.fromHexString(challeng);
  }

  @override
  SolAddress? get account => address;
  @override
  Web3SolanaRequest<Web3SolanaSignMessageResponse, Web3SolanaSignMessage>
      toRequest({
    required Web3RequestApplicationInformation request,
    required Web3APPAuthentication authenticated,
    required SolanaChain chain,
  }) {
    return Web3SolanaRequest<Web3SolanaSignMessageResponse,
        Web3SolanaSignMessage>(
      params: this,
      authenticated: authenticated,
      chain: chain,
      info: request,
    );
  }
}
