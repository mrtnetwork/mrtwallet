import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/provider/api/core/api_provider.dart';

class BitcoinParams implements NetworkCoinParams {
  static const String _txIdArgs = "#txid";
  static const String _addrArgs = "#address";
  const BitcoinParams(
      {required this.transactionExplorer,
      required this.addressExplorer,
      required this.coinName,
      required this.coinSymbol,
      required this.decimal,
      required this.logo,
      required this.transacationNetwork,
      required this.providers});
  @override
  final String transactionExplorer;

  @override
  final String addressExplorer;

  @override
  final String coinName;

  @override
  final String coinSymbol;

  @override
  final int decimal;

  @override
  final String logo;
  final BitcoinNetwork transacationNetwork;
  // BitcoinNetwork get transacationNetwork {
  //   switch (this) {
  //     case AppBitcoinNetwork.bitcoinMainnet:
  //       return BitcoinNetwork.mainnet;
  //     default:
  //       return BitcoinNetwork.testnet;
  //   }
  // }

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
