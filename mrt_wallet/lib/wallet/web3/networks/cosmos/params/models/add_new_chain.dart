import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/cosmos/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/cosmos/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/utils/web3_validator_utils.dart';

class Web3CosmosAddNewChain extends Web3CosmosRequestParam<bool> {
  final String chainId;
  final String rpc;
  final String? name;
  final CosmosFeeToken? nativeToken;
  final List<CosmosFeeToken>? feeTokens;
  final List<String>? keyAlgorithm;
  final String? hrp;
  Web3CosmosAddNewChain(
      {required this.chainId,
      required this.rpc,
      required this.name,
      required this.nativeToken,
      required List<CosmosFeeToken>? feeTokens,
      required List<String>? keyAlgorithm,
      required this.hrp})
      : feeTokens = feeTokens?.emptyAsNull?.immutable,
        keyAlgorithm = keyAlgorithm?.emptyAsNull?.immutable;
  factory Web3CosmosAddNewChain.fromJson(Map<String, dynamic> json) {
    final Web3NetworkRequestMethods method =
        Web3CosmosRequestMethods.addNewChain;
    return Web3CosmosAddNewChain(
        chainId: Web3ValidatorUtils.parseString(
            key: 'chainId', method: method, json: json),
        rpc: Web3ValidatorUtils.parseString(
            key: 'rpc', method: method, json: json),
        name: Web3ValidatorUtils.parseString(
            key: 'name', method: method, json: json),
        nativeToken: Web3ValidatorUtils.praseObject<CosmosFeeToken?,
                Map<String, dynamic>>(
            onParse: (v) {
              return CosmosFeeToken(
                  token: Token(
                      name: Web3ValidatorUtils.parseString(
                          key: 'name', method: method, json: v),
                      symbol: Web3ValidatorUtils.parseString(
                          key: 'symbol', method: method, json: v),
                      decimal: Web3ValidatorUtils.parseInt<int>(
                          key: 'decimals', method: method, json: v),
                      market: Web3ValidatorUtils.praseObject<CoingeckoCoin?,
                              String>(
                          onParse: (v) => CoingeckoCoin(apiId: v),
                          key: 'coingeckoId',
                          method: method,
                          json: v)),
                  denom: Web3ValidatorUtils.parseString(
                      key: 'denom', method: method, json: v),
                  averageGasPrice: Web3ValidatorUtils.parseDouble<BigRational?>(
                          key: 'average', method: method, json: v) ??
                      CosmosConst.avarageGasPrice,
                  lowGasPrice: Web3ValidatorUtils.parseDouble<BigRational?>(
                      key: 'low', method: method, json: v),
                  highGasPrice: Web3ValidatorUtils.parseDouble<BigRational?>(
                      key: 'high', method: method, json: v));
            },
            key: 'nativeToken',
            method: method,
            json: json),
        keyAlgorithm: Web3ValidatorUtils.parseList<List<String>?, String>(
            key: 'keyAlgos', method: method, json: json),
        hrp: Web3ValidatorUtils.parseString(
            key: 'hrp', method: method, json: json),
        feeTokens: Web3ValidatorUtils.parseList<List<Map<String, dynamic>>?,
                    Map<String, dynamic>>(
                key: 'feeTokens', method: method, json: json)
            ?.map((v) => CosmosFeeToken(
                token: Token(
                  market:
                      Web3ValidatorUtils.praseObject<CoingeckoCoin?, String>(
                          onParse: (v) => CoingeckoCoin(apiId: v),
                          key: 'coingeckoId',
                          method: method,
                          json: v),
                  name: Web3ValidatorUtils.parseString(
                      key: 'name', method: method, json: v),
                  symbol: Web3ValidatorUtils.parseString(
                      key: 'symbol', method: method, json: v),
                  decimal: Web3ValidatorUtils.parseInt<int>(
                      key: 'decimals', method: method, json: v),
                ),
                denom: Web3ValidatorUtils.parseString(
                    key: 'denom', method: method, json: v),
                averageGasPrice: Web3ValidatorUtils.parseDouble<BigRational?>(
                        key: 'average', method: method, json: v) ??
                    CosmosConst.avarageGasPrice,
                lowGasPrice: Web3ValidatorUtils.parseDouble<BigRational?>(
                    key: 'low', method: method, json: v),
                highGasPrice: Web3ValidatorUtils.parseDouble<BigRational?>(
                    key: 'high', method: method, json: v)))
            .toList());
  }

  factory Web3CosmosAddNewChain.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: Web3MessageTypes.walletRequest.tag);
    return Web3CosmosAddNewChain(
        chainId: values.elementAt(1),
        rpc: values.elementAs(2),
        name: values.elementAs(3),
        nativeToken: values.elemetMybeAs<CosmosFeeToken, CborTagValue>(
            4, (e) => CosmosFeeToken.fromCborBytesOrObject(obj: e)),
        feeTokens: values
            .elementAsListOf<CborTagValue>(5)
            .map((e) => CosmosFeeToken.fromCborBytesOrObject(obj: e))
            .toList(),
        keyAlgorithm: values
            .elementAsListOf<CborStringValue>(6)
            .map((e) => e.value)
            .toList(),
        hrp: values.elementAs(7));
  }
  @override
  Web3CosmosRequestMethods get method => Web3CosmosRequestMethods.addNewChain;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          method.tag,
          chainId,
          rpc,
          name,
          nativeToken?.toCbor(),
          CborListValue.fixedLength(
              feeTokens?.map((e) => e.toCbor()).toList() ?? []),
          CborListValue.fixedLength(keyAlgorithm ?? []),
          hrp
        ]),
        type.tag);
  }

  @override
  Web3CosmosRequest<bool, Web3CosmosAddNewChain> toRequest(
      {required Web3RequestApplicationInformation request,
      required Web3APPAuthentication authenticated,
      required List<APPCHAIN> chains}) {
    final CosmosChain chain = super.findRequestChain(
        request: request, authenticated: authenticated, chains: chains);
    return Web3CosmosRequest<bool, Web3CosmosAddNewChain>(
        params: this,
        authenticated: authenticated,
        chain: chain,
        info: request);
  }
}
