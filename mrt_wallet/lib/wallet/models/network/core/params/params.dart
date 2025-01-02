import 'package:blockchain_utils/bip/bip.dart';
import 'package:mrt_wallet/app/models/models/image.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/app/utils/list/extension.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';

import 'package:mrt_wallet/wallet/models/token/token/token.dart';

class NetworkCoinParamsConst {
  static const String txIdArgs = "#txid";
  static const String addrArgs = "#address";
}

abstract class NetworkCoinParams<PROVIDER extends APIProvider>
    with CborSerializable {
  NetworkCoinParams(
      {required this.transactionExplorer,
      required this.addressExplorer,
      required this.token,
      required List<PROVIDER> providers,
      this.chainType = ChainType.mainnet,
      this.bip32CoinType})
      : _providers = List<PROVIDER>.unmodifiable(providers);
  final String? transactionExplorer;
  final String? addressExplorer;
  final Token token;
  List<PROVIDER> _providers;
  List<PROVIDER> get providers => _providers;
  final ChainType chainType;
  bool get mainnet => chainType == ChainType.mainnet;
  bool get isTestNet => chainType == ChainType.testnet;
  int get decimal => token.decimal!;
  final int? bip32CoinType;
  APPImage get logo => token.assetLogo!;
  bool get hasAccountExplorer => addressExplorer != null;
  bool get hasTransactionExplorer => transactionExplorer != null;
  bool get hasMarketUrl => token.market != null;

  Object get identifier;

  String? getAccountExplorer(String address) {
    return addressExplorer?.replaceAll(
        NetworkCoinParamsConst.addrArgs, address);
  }

  String? getTransactionExplorer(String txId) {
    return transactionExplorer?.replaceAll(
        NetworkCoinParamsConst.txIdArgs, txId);
  }

  String? get marketUri {
    return token.marketUri;
  }

  NetworkCoinParams<PROVIDER> updateProviders(List<PROVIDER> updateProviders);

  void addProvider(PROVIDER provider) {
    _providers = [provider, ..._providers].imutable;
  }

  void removeProvider(PROVIDER provider) {}
}
