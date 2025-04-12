import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/substrate/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/substrate/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/utils/web3_validator_utils.dart';

class Web3SubstrateAddNewChain extends Web3SubstrateRequestParam<bool> {
  final String chain;
  final String genesisHash;
  final int ss58Format;
  final String? chainType;
  final int specVersion;
  final int tokenDecimals;
  final String tokenSymbol;
  Web3SubstrateAddNewChain(
      {required this.chain,
      required this.genesisHash,
      required this.ss58Format,
      required this.chainType,
      required this.specVersion,
      required this.tokenDecimals,
      required this.tokenSymbol});

  factory Web3SubstrateAddNewChain.fromJson(Map<String, dynamic> json) {
    const method = Web3SubstrateRequestMethods.addSubstrateChain;
    return Web3SubstrateAddNewChain(
        chain: Web3ValidatorUtils.parseString<String>(
            key: "chain", method: method, json: json),
        genesisHash: Web3ValidatorUtils.parseHex<String>(
            key: "genesisHash", method: method, json: json),
        ss58Format: Web3ValidatorUtils.parseInt<int>(
            key: "ss58Format", method: method, json: json, sign: false),
        chainType: Web3ValidatorUtils.parseString<String?>(
            key: "chainType", method: method, json: json),
        specVersion: Web3ValidatorUtils.parseInt<int>(
            key: "specVersion", method: method, json: json, sign: false),
        tokenDecimals: Web3ValidatorUtils.parseInt<int>(
            key: "tokenDecimals", method: method, json: json, sign: false),
        tokenSymbol: Web3ValidatorUtils.parseString<String>(
            key: "tokenSymbol", method: method, json: json));
  }

  factory Web3SubstrateAddNewChain.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    return Web3SubstrateAddNewChain(
        chain: values.elementAs(1),
        chainType: values.elementAs(2),
        genesisHash: values.elementAs(3),
        specVersion: values.elementAs(4),
        ss58Format: values.elementAs(5),
        tokenDecimals: values.elementAs(6),
        tokenSymbol: values.elementAs(7));
  }

  @override
  Web3SubstrateRequestMethods get method =>
      Web3SubstrateRequestMethods.addSubstrateChain;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          method.tag,
          chain,
          chainType,
          genesisHash,
          specVersion,
          ss58Format,
          tokenDecimals,
          tokenSymbol
        ]),
        type.tag);
  }

  @override
  Web3SubstrateRequest<bool, Web3SubstrateAddNewChain> toRequest(
      {required Web3RequestApplicationInformation request,
      required Web3APPAuthentication authenticated,
      required List<APPCHAIN> chains}) {
    final SubstrateChain chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3SubstrateRequest<bool, Web3SubstrateAddNewChain>(
      params: this,
      authenticated: authenticated,
      chain: chain,
      info: request,
    );
  }
}
