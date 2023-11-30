import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';

abstract class NetworkCoinParams {
  abstract final int decimal;
  abstract final String transactionExplorer;
  abstract final String addressExplorer;
  abstract final String logo;

  abstract final String coinName;
  abstract final String coinSymbol;
  abstract final List<ApiProviderService> providers;

  String getAccountExplorer(String address);
  String getTransactionExplorer(String txId);
}

class NetworkCoins {
  static const BitcoinParams bitcoinMainnet = BitcoinParams(
      transactionExplorer: "https://live.blockcypher.com/btc/tx/#txid/",
      addressExplorer: "https://live.blockcypher.com/btc/address/#address/",
      coinName: "Bitcoin",
      coinSymbol: "BTC",
      decimal: 8,
      logo: "assets/image/btc.png",
      transacationNetwork: BitcoinNetwork.mainnet,
      providers: [ApiProviderService.blockCypher, ApiProviderService.mempool]);
  static const BitcoinParams bitcoinTestnet = BitcoinParams(
      transactionExplorer: "https://live.blockcypher.com/btc-testnet/tx/#txid/",
      addressExplorer:
          "https://live.blockcypher.com/btc-testnet/address/#address/",
      coinName: "Bitcoin Testnet",
      coinSymbol: "tBTC",
      decimal: 8,
      logo: "assets/image/btc.png",
      transacationNetwork: BitcoinNetwork.testnet,
      providers: [ApiProviderService.blockCypher, ApiProviderService.mempool]);
}
