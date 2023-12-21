import 'package:mrt_wallet/models/wallet_models/network/params/network_params.dart';
import 'package:mrt_wallet/models/wallet_models/network/params/token.dart';
import 'package:mrt_wallet/provider/api/core/api_provider.dart';

class RippleNetworkParams implements NetworkCoinParams {
  static const String _txIdArgs = "#txid";
  static const String _addrArgs = "#address";
  const RippleNetworkParams(
      {required this.transactionExplorer,
      required this.addressExplorer,
      required this.token,
      required this.providers});
  @override
  final String transactionExplorer;

  @override
  final String addressExplorer;

  @override
  int get decimal => token.decimal!;

  @override
  String get logo => token.logo!;

  @override
  final Token token;

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
}
