import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/provider/api/core/api_provider.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class BitcoinParams implements NetworkCoinParams {
  static const String _txIdArgs = "#txid";
  static const String _addrArgs = "#address";
  factory BitcoinParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.bitconNetworkParam);

    return BitcoinParams(
        transactionExplorer: cbor.getIndex(0),
        addressExplorer: cbor.getIndex(1),
        token: Token.fromCborBytesOrObject(obj: cbor.getCborTag(2)),
        transacationNetwork: BasedUtxoNetwork.fromName(cbor.getIndex(3)),
        providers: (cbor.getIndex(4) as List)
            .map((e) => ApiProviderService.fromCborBytesOrObject(obj: e))
            .toList());
  }
  const BitcoinParams(
      {required this.transactionExplorer,
      required this.addressExplorer,
      required this.transacationNetwork,
      required this.providers,
      required this.token});
  @override
  final String transactionExplorer;
  @override
  final String addressExplorer;
  @override
  final Token token;
  final BasedUtxoNetwork transacationNetwork;

  @override
  int get decimal => token.decimal!;

  @override
  String get logo => token.assetLogo!;

  @override
  String getAccountExplorer(String address) {
    return addressExplorer.replaceAll(_addrArgs, address);
  }

  @override
  String getTransactionExplorer(String txId) {
    return transactionExplorer.replaceAll(_txIdArgs, txId);
  }

  @override
  final List<ApiProviderService> providers;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          transactionExplorer,
          addressExplorer,
          token.toCbor(),
          transacationNetwork.value,
          CborListValue.fixedLength(providers.map((e) => e.toCbor()).toList())
        ]),
        WalletModelCborTagsConst.bitconNetworkParam);
  }
}
