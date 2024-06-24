import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/app/app_image.dart';
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
        transactionExplorer: cbor.elementAt(0),
        addressExplorer: cbor.elementAt(1),
        token: Token.fromCborBytesOrObject(obj: cbor.getCborTag(2)),
        transacationNetwork: BasedUtxoNetwork.fromName(cbor.elementAt(3)),
        providers: (cbor.elementAt(4) as List)
            .map((e) => ApiProviderService.fromCborBytesOrObject(obj: e))
            .toList());
  }
  BitcoinParams(
      {required this.transactionExplorer,
      required this.addressExplorer,
      required this.transacationNetwork,
      required List<ApiProviderService> providers,
      required this.token})
      : providers = List<ApiProviderService>.unmodifiable(providers);

  BitcoinParams copyWith(
      {List<ApiProviderService>? providers,
      String? transactionExplorer,
      String? addressExplorer,
      Token? token,
      BasedUtxoNetwork? transacationNetwork}) {
    return BitcoinParams(
        transactionExplorer: transactionExplorer ?? this.transactionExplorer,
        addressExplorer: addressExplorer ?? this.addressExplorer,
        transacationNetwork: transacationNetwork ?? this.transacationNetwork,
        providers: providers ?? this.providers,
        token: token ?? this.token);
  }

  @override
  final List<ApiProviderService> providers;
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
  AppImage get logo => token.assetLogo!;

  @override
  String getAccountExplorer(String address) {
    return addressExplorer.replaceAll(_addrArgs, address);
  }

  @override
  String getTransactionExplorer(String txId) {
    return transactionExplorer.replaceAll(_txIdArgs, txId);
  }

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

  @override
  bool get mainnet => transacationNetwork.isMainnet;
}
