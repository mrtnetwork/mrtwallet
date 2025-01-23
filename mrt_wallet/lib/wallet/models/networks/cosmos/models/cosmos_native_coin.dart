import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/cosmos.dart';
import 'package:mrt_wallet/wallet/constant/networks/cosmos.dart';

import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';

import 'network_types.dart';

class CosmosFeeToken with CborSerializable {
  final Token token;
  final String denom;
  final BigRational? lowGasPrice;
  final BigRational? averageGasPrice;
  final BigRational? highGasPrice;
  BigRational? getFee() {
    return averageGasPrice ?? lowGasPrice ?? highGasPrice;
  }

  const CosmosFeeToken._(
      {required this.token,
      required this.denom,
      required this.lowGasPrice,
      required this.averageGasPrice,
      required this.highGasPrice});
  factory CosmosFeeToken(
      {required Token token,
      required String denom,
      BigRational? lowGasPrice,
      BigRational? averageGasPrice,
      BigRational? highGasPrice}) {
    final e = token.decimal;
    if (e == null || e.isNegative || e > CosmosConst.maxTokenExponent) {
      throw WalletException("invalid_token_exponent");
    }
    return CosmosFeeToken._(
        token: token,
        denom: denom,
        lowGasPrice: lowGasPrice,
        averageGasPrice: averageGasPrice,
        highGasPrice: highGasPrice);
  }
  factory CosmosFeeToken.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.cosmosNativeToken);
    return CosmosFeeToken(
      token: Token.fromCborBytesOrObject(obj: values.getCborTag(0)),
      denom: values.elementAs(1),
      lowGasPrice: values.elemetMybeAs<BigRational, String>(
          2, (e) => BigRational.parseDecimal(e)),
      averageGasPrice: values.elemetMybeAs<BigRational, String>(
          3, (e) => BigRational.parseDecimal(e)),
      highGasPrice: values.elemetMybeAs<BigRational, String>(
          4, (e) => BigRational.parseDecimal(e)),
    );
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          token.toCbor(),
          CborStringValue(denom),
          lowGasPrice?.toDecimal(),
          averageGasPrice?.toDecimal(),
          highGasPrice?.toDecimal()
        ]),
        CborTagsConst.cosmosNativeToken);
  }
}

class CosmosNetworkInfo {
  final String? transactionExplorer;
  final String? addressExplorer;
  final String? networkName;
  final List<CosmosAPIProvider> providers;
  final CosmosFeeToken? nativeToken;
  final int slip44;
  final String? hrp;
  final CosmosNetworkTypes networkType;
  final String? chainId;
  final List<CosmosKeysAlgs> keysAlgs;
  final List<CosmosFeeToken> feeTokens;

  CosmosNetworkInfo({
    this.transactionExplorer,
    this.addressExplorer,
    required this.nativeToken,
    required this.providers,
    this.hrp,
    required this.feeTokens,
    required this.networkType,
    required this.chainId,
    required this.keysAlgs,
    required this.slip44,
    required this.networkName,
  });
}
