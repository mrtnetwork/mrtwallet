import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/app/utils/utils.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/tron/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/tron/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/validator/web3_validator_utils.dart';
import 'package:on_chain/tron/src/address/tron_address.dart';

class Web3TronSignMessageV2 extends Web3TronRequestParam<String> {
  final TronAddress address;
  final String challeng;
  final String? content;

  Web3TronSignMessageV2(
      {required this.address, required this.challeng, this.content});

  factory Web3TronSignMessageV2.fromJson(Map<String, dynamic> json) {
    const method = Web3TronRequestMethods.signMessageV2;
    String? content =
        StringUtils.tryDecode(BytesUtils.fromHexString(json["challeng"]));
    if (content != null) {
      content = StrUtils.toRawString(content);
    }
    return Web3TronSignMessageV2(
        address: Web3ValidatorUtils.parseAddress<TronAddress>(
            onParse: (obj) => TronAddress(obj),
            key: "address",
            method: method,
            json: json),
        challeng: Web3ValidatorUtils.parseHex<String>(
            key: "challeng", method: method, json: json),
        content: content);
  }

  factory Web3TronSignMessageV2.deserialize({
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
    return Web3TronSignMessageV2(
        address: TronAddress(values.elementAt(1)),
        challeng: BytesUtils.toHexString(challeng, prefix: "0x"),
        content: values.elementAt(3));
  }

  @override
  Web3TronRequestMethods get method => Web3TronRequestMethods.signMessageV2;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          method.tag,
          address.toAddress(),
          CborBytesValue(BytesUtils.fromHexString(challeng)),
          content
        ]),
        type.tag);
  }

  @override
  Map<String, dynamic> toJson() {
    return {"address": address.toAddress(), "challeng": challeng};
  }

  List<int> chalengBytes() {
    return BytesUtils.fromHexString(challeng);
  }

  @override
  TronAddress? get account => address;
  @override
  Web3TronRequest<String, Web3TronSignMessageV2> toRequest({
    required Web3RequestApplicationInformation request,
    required Web3APPAuthentication authenticated,
    required TronChain chain,
  }) {
    return Web3TronRequest<String, Web3TronSignMessageV2>(
      params: this,
      authenticated: authenticated,
      chain: chain,
      info: request,
    );
  }
}
