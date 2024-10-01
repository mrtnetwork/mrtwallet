import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/app/utils/utils.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/validator/web3_validator_utils.dart';
import 'package:stellar_dart/stellar_dart.dart';

class Web3StellarSignMessage extends Web3StellarRequestParam<List<int>> {
  final StellarAddress address;
  final String challeng;
  final String? content;

  Web3StellarSignMessage(
      {required this.address, required this.challeng, this.content});

  factory Web3StellarSignMessage.fromJson(Map<String, dynamic> json) {
    const method = Web3StellarRequestMethods.signMessage;
    String? content =
        StringUtils.tryDecode(BytesUtils.fromHexString(json["challeng"]));
    if (content != null) {
      content = StrUtils.toRawString(content);
    }
    return Web3StellarSignMessage(
        address: Web3ValidatorUtils.parseAddress<StellarAddress>(
            onParse: (obj) => StellarAddress.fromBase32Addr(obj),
            key: "address",
            method: method,
            json: json),
        challeng: Web3ValidatorUtils.parseHex<String>(
            key: "challeng", method: method, json: json),
        content: content);
  }

  factory Web3StellarSignMessage.deserialize({
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
    return Web3StellarSignMessage(
        address: StellarAddress.fromBase32Addr(values.elementAt(1)),
        challeng: BytesUtils.toHexString(challeng, prefix: "0x"),
        content: values.elementAt(3));
  }

  @override
  Web3StellarRequestMethods get method => Web3StellarRequestMethods.signMessage;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          method.tag,
          address.toString(),
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
  StellarAddress? get account => address;
  @override
  Web3StellarRequest<List<int>, Web3StellarSignMessage> toRequest({
    required Web3RequestApplicationInformation request,
    required Web3APPAuthentication authenticated,
    required StellarChain chain,
  }) {
    return Web3StellarRequest<List<int>, Web3StellarSignMessage>(
      params: this,
      authenticated: authenticated,
      chain: chain,
      info: request,
    );
  }
}
