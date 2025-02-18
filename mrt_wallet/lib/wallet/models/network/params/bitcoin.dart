import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/bitcoin/bitcoin.dart';
import 'package:mrt_wallet/wallet/models/network/core/params/params.dart';
import 'package:blockchain_utils/bip/bip.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';

class BitcoinParams extends NetworkCoinParams<BaseBitcoinAPIProvider> {
  final BasedUtxoNetwork transacationNetwork;

  factory BitcoinParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: CborTagsConst.bitconNetworkParam);

    return BitcoinParams(
        token: Token.fromCborBytesOrObject(obj: values.getCborTag(2)),
        transacationNetwork: BasedUtxoNetwork.fromName(values.elementAs(3)),
        providers: values
            .elementAsListOf<CborTagValue>(4)
            .map((e) => BaseBitcoinAPIProvider.fromCborBytesOrObject(obj: e))
            .toList(),
        addressExplorer: values.elementAs(6),
        transactionExplorer: values.elementAs(7));
  }
  BitcoinParams({
    required super.providers,
    required super.token,
    required this.transacationNetwork,
    super.addressExplorer,
    super.transactionExplorer,
  }) : super(
            chainType: transacationNetwork.isMainnet
                ? ChainType.mainnet
                : ChainType.testnet);

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          const CborNullValue(),
          const CborNullValue(),
          token.toCbor(),
          transacationNetwork.value,
          CborListValue.fixedLength(providers.map((e) => e.toCbor()).toList()),
          const CborNullValue(),
          addressExplorer,
          transactionExplorer,
        ]),
        CborTagsConst.bitconNetworkParam);
  }

  @override
  NetworkCoinParams<BaseBitcoinAPIProvider> updateParams(
      {List<APIProvider>? updateProviders,
      Token? token,
      String? transactionExplorer,
      String? addressExplorer,
      int? bip32CoinType}) {
    return BitcoinParams(
        providers: updateProviders?.cast<BaseBitcoinAPIProvider>() ?? providers,
        token: NetworkCoinParams.validateUpdateParams(
            token: this.token, updateToken: token),
        addressExplorer: addressExplorer,
        transactionExplorer: transactionExplorer,
        transacationNetwork: transacationNetwork);
  }
}
