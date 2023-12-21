import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/provider/api/core/api_provider.dart';

class BitcoinParams implements NetworkCoinParams {
  static const String _txIdArgs = "#txid";
  static const String _addrArgs = "#address";
  const BitcoinParams(
      {required this.transactionExplorer,
      required this.addressExplorer,
      required this.transacationNetwork,
      required this.providers,
      required this.token});
  @override
  final String transactionExplorer;
  @override
  final Token token;

  @override
  final String addressExplorer;

  @override
  int get decimal => token.decimal!;

  @override
  String get logo => token.logo!;
  final BasedUtxoNetwork transacationNetwork;

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
