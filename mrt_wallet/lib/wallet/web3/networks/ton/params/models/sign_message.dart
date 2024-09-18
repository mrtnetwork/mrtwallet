import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/app/utils/utils.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/validator/web3_validator_utils.dart';
import 'package:ton_dart/ton_dart.dart';

class Web3TonSignMessage extends Web3TonRequestParam<List<int>> {
  final TonAddress address;
  final String challeng;
  final String? content;

  Web3TonSignMessage(
      {required this.address, required this.challeng, this.content});

  factory Web3TonSignMessage.fromJson(Map<String, dynamic> json) {
    const method = Web3TonRequestMethods.signMessage;
    String? content =
        StringUtils.tryDecode(BytesUtils.fromHexString(json["challeng"]));
    if (content != null) {
      content = StrUtils.toRawString(content);
    }
    return Web3TonSignMessage(
        address: Web3ValidatorUtils.parseAddress<TonAddress>(
            onParse: (obj) => TonAddress(obj),
            key: "address",
            method: method,
            json: json),
        challeng: Web3ValidatorUtils.parseHex<String>(
            key: "challeng", method: method, json: json),
        content: content);
  }

  factory Web3TonSignMessage.deserialize({
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
    return Web3TonSignMessage(
        address: TonAddress(values.elementAt(1)),
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
          address.toFriendlyAddress(),
          CborBytesValue(BytesUtils.fromHexString(challeng)),
          content
        ]),
        type.tag);
  }

  @override
  Map<String, dynamic> toJson() {
    return {"address": address.toFriendlyAddress(), "challeng": challeng};
  }

  List<int> chalengBytes() {
    return BytesUtils.fromHexString(challeng);
  }

  @override
  TonAddress? get account => address;
  @override
  Web3TonRequest<List<int>, Web3TonSignMessage> toRequest({
    required Web3RequestApplicationInformation request,
    required Web3APPAuthentication authenticated,
    required TheOpenNetworkChain chain,
  }) {
    return Web3TonRequest<List<int>, Web3TonSignMessage>(
      params: this,
      authenticated: authenticated,
      chain: chain,
      info: request,
    );
  }
}
