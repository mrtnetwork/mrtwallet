import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/app/utils/utils.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/validator/web3_validator_utils.dart';
import 'package:on_chain/ethereum/ethereum.dart';

class Web3EthreumPersonalSign extends Web3EthereumRequestParam<String> {
  final ETHAddress address;
  final String challeng;
  final String? content;

  Web3EthreumPersonalSign(
      {required this.address, required this.challeng, this.content});

  factory Web3EthreumPersonalSign.fromJson(Map<String, dynamic> json) {
    const method = Web3EthereumRequestMethods.sendTransaction;
    String? content =
        StringUtils.tryDecode(BytesUtils.fromHexString(json["challeng"]));
    if (content != null) {
      content = StrUtils.toRawString(content);
    }
    return Web3EthreumPersonalSign(
        address: Web3ValidatorUtils.parseAddress<ETHAddress>(
            onParse: (obj) => ETHAddress(obj),
            key: "address",
            method: method,
            json: json),
        challeng: Web3ValidatorUtils.parseHex<String>(
            key: "challeng", method: method, json: json),
        content: content);
  }

  factory Web3EthreumPersonalSign.deserialize({
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
    return Web3EthreumPersonalSign(
        address: ETHAddress(values.elementAt(1)),
        challeng: BytesUtils.toHexString(challeng, prefix: "0x"),
        content: values.elementAt(3));
  }

  @override
  Web3EthereumRequestMethods get method =>
      Web3EthereumRequestMethods.persoalSign;

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
  ETHAddress? get account => address;
  @override
  Web3EthereumRequest<String, Web3EthreumPersonalSign> toRequest({
    required Web3RequestApplicationInformation request,
    required Web3APPAuthentication authenticated,
    required EthereumChain chain,
  }) {
    return Web3EthereumRequest<String, Web3EthreumPersonalSign>(
      params: this,
      authenticated: authenticated,
      chain: chain,
      info: request,
    );
  }
}
