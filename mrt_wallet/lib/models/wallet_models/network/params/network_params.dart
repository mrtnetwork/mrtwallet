import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/models/wallet_models/network/params/ripple.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';

abstract class NetworkCoinParams {
  abstract final int decimal;
  abstract final String transactionExplorer;
  abstract final String addressExplorer;
  abstract final String logo;
  abstract final Token token;
  abstract final List<ApiProviderService> providers;
  String getAccountExplorer(String address);
  String getTransactionExplorer(String txId);
}

class NetworkCoins {
  static const BitcoinParams bitcoinMainnet = BitcoinParams(
      transactionExplorer: "https://live.blockcypher.com/btc/tx/#txid/",
      addressExplorer: "https://live.blockcypher.com/btc/address/#address/",
      transacationNetwork: BitcoinNetwork.mainnet,
      token: Token(
          name: "Bitcoin",
          symbol: "BTC",
          decimal: 8,
          logo: "assets/image/btc.png"),
      providers: [ApiProviderService.mempool, ApiProviderService.blockCypher]);
  static const BitcoinParams bitcoinTestnet = BitcoinParams(
      transactionExplorer: "https://live.blockcypher.com/btc-testnet/tx/#txid/",
      addressExplorer:
          "https://live.blockcypher.com/btc-testnet/address/#address/",
      transacationNetwork: BitcoinNetwork.testnet,
      token: Token(
          name: "Bitcoin testnet",
          symbol: "tBTC",
          decimal: 8,
          logo: "assets/image/btc.png"),
      providers: [ApiProviderService.mempool, ApiProviderService.blockCypher]);
  static const BitcoinParams litecoinMainnet = BitcoinParams(
      transactionExplorer: "https://live.blockcypher.com/ltc/tx/#txid/",
      addressExplorer: "https://live.blockcypher.com/ltc/address/#address/",
      transacationNetwork: LitecoinNetwork.mainnet,
      token: Token(
          name: "Litecoin",
          symbol: "LTC",
          decimal: 8,
          logo: "assets/image/ltc.png"),
      providers: [ApiProviderService.blockCypher]);
  static const BitcoinParams dogecoinMainnet = BitcoinParams(
      transactionExplorer: "https://live.blockcypher.com/doge/tx/#txid/",
      addressExplorer: "https://live.blockcypher.com/doge/address/#address/",
      transacationNetwork: DogecoinNetwork.mainnet,
      token: Token(
          name: "Dogecoin",
          symbol: "Ɖ",
          decimal: 8,
          logo: "assets/image/doge.png"),
      providers: [ApiProviderService.blockCypher]);
  static const BitcoinParams dashMainnet = BitcoinParams(
      transactionExplorer: "https://live.blockcypher.com/dash/tx/#txid/",
      addressExplorer: "https://live.blockcypher.com/dash/address/#address/",
      token: Token(
          name: "Dash",
          symbol: "DASH",
          decimal: 8,
          logo: "assets/image/dash.png"),
      transacationNetwork: DashNetwork.mainnet,
      providers: [ApiProviderService.blockCypher]);
  static const RippleNetworkParams xrpMainnet = RippleNetworkParams(
      transactionExplorer: "https://livenet.xrpl.org/transactions/#txid",
      addressExplorer: "https://livenet.xrpl.org/accounts/#address",
      token: Token(
          name: "Ripple",
          symbol: "XRP",
          decimal: 6,
          logo: "assets/image/xrp.png"),
      providers: [ApiProviderService.xrpl]);
  static const RippleNetworkParams xrpTestnet = RippleNetworkParams(
      transactionExplorer: "https://testnet.xrpl.org/transactions/#txid",
      addressExplorer: "https://testnet.xrpl.org/accounts/#address",
      token: Token(
          name: "Ripple testnet",
          symbol: "XRP",
          decimal: 6,
          logo: "assets/image/xrp.png"),
      providers: [ApiProviderService.xrpl]);
  static const RippleNetworkParams xrpDevnet = RippleNetworkParams(
      transactionExplorer: "https://devnet.xrpl.org/transactions/#txid",
      addressExplorer: "https://devnet.xrpl.org/accounts/#address",
      token: Token(
          name: "Ripple devnet",
          symbol: "XRP",
          decimal: 6,
          logo: "assets/image/xrp.png"),
      providers: [ApiProviderService.xrpl]);
}
