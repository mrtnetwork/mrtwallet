import 'package:blockchain_utils/bip/bip.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/models/models/image.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';

import 'package:mrt_wallet/wallet/models/token/token/token.dart';

class NetworkCoinParamsConst {
  static const String txIdArgs = "#txid";
  static const String addrArgs = "#address";
}

abstract class NetworkCoinParams<PROVIDER extends APIProvider>
    with CborSerializable {
  NetworkCoinParams(
      {required this.token,
      required List<PROVIDER> providers,
      this.chainType = ChainType.mainnet,
      this.bip32CoinType,
      this.transactionExplorer,
      this.addressExplorer})
      : providers = List<PROVIDER>.unmodifiable(providers);
  static Token validateUpdateParams(
      {required Token token, required Token? updateToken}) {
    if (updateToken == null) return token;
    if (updateToken.decimal != token.decimal ||
        updateToken.name.trim().isEmpty ||
        updateToken.symbol.trim().isEmpty) {
      throw WalletExceptionConst.invalidTokenInformation;
    }
    return updateToken;
  }

  final String? transactionExplorer;
  final String? addressExplorer;
  final Token token;
  final List<PROVIDER> providers;
  final ChainType chainType;
  bool get mainnet => chainType == ChainType.mainnet;
  bool get isTestNet => chainType == ChainType.testnet;
  int get decimal => token.decimal!;
  final int? bip32CoinType;
  APPImage get logo => token.assetLogo!;
  bool get hasMarketUrl => token.market != null;
  String? get marketUri {
    return token.marketUri;
  }

  NetworkCoinParams<PROVIDER> updateParams(
      {List<APIProvider>? updateProviders,
      Token? token,
      String? transactionExplorer,
      String? addressExplorer,
      int? bip32CoinType});
}
