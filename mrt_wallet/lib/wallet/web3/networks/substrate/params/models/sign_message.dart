import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/app/utils/utils.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/substrate/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/substrate/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/validator/web3_validator_utils.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class Web3SubstrateSignMessage
    extends Web3SubstrateRequestParam<Map<String, dynamic>> {
  final BaseSubstrateAddress address;
  final String challeng;
  final String? content;

  Web3SubstrateSignMessage(
      {required this.address, required this.challeng, this.content});

  factory Web3SubstrateSignMessage.fromJson(Map<String, dynamic> json) {
    const method = Web3SubstrateRequestMethods.signMessage;
    String? content =
        StringUtils.tryDecode(BytesUtils.fromHexString(json["challeng"]));
    if (content != null) {
      content = StrUtils.toRawString(content);
    }
    return Web3SubstrateSignMessage(
        address: Web3ValidatorUtils.parseAddress<BaseSubstrateAddress>(
            onParse: (obj) => BaseSubstrateAddress(obj),
            key: "address",
            method: method,
            json: json),
        challeng: Web3ValidatorUtils.parseHex<String>(
            key: "challeng", method: method, json: json),
        content: content);
  }

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
        address: BaseSubstrateAddress(values.elementAt(1)),
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
          address.address,
          CborBytesValue(BytesUtils.fromHexString(challeng)),
          content
        ]),
        type.tag);
  }

  @override
  Map<String, dynamic> toJson() {
    return {"address": address.toString(), "challeng": challeng};
  }

  List<int> chalengBytes() {
    return BytesUtils.fromHexString(challeng);
  }

  @override
  BaseSubstrateAddress? get account => address;
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
