import 'package:mrt_wallet/models/app/app_image.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';

class _NetworkCoinParamsConst {
  static const String txIdArgs = "#txid";
  static const String addrArgs = "#address";
}

abstract class NetworkCoinParams<PROVIDER extends ApiProviderService>
    with CborSerializable {
  NetworkCoinParams(
      {required this.transactionExplorer,
      required this.addressExplorer,
      required this.token,
      required List<PROVIDER> providers,
      required this.mainnet})
      : providers = List<PROVIDER>.unmodifiable(providers);
  final String? transactionExplorer;
  final String? addressExplorer;
  final Token token;
  final List<PROVIDER> providers;
  final bool mainnet;
  int get decimal => token.decimal!;
  AppImage get logo => token.assetLogo!;

  bool get hasAccountExplorer => addressExplorer != null;
  bool get hasTransactionExplorer => transactionExplorer != null;
  bool get hasMarketUrl => token.market != null;

  String? getAccountExplorer(String address) {
    return addressExplorer?.replaceAll(
        _NetworkCoinParamsConst.addrArgs, address);
  }

  String? getTransactionExplorer(String txId) {
    return transactionExplorer?.replaceAll(
        _NetworkCoinParamsConst.txIdArgs, txId);
  }

  String? get marketUri {
    return token.marketUri;
  }

  NetworkCoinParams updateProviders(List<PROVIDER> updateProviders);
}
