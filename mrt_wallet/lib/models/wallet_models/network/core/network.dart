import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';

import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/provider/api/core/api_provider.dart';

abstract class AppNetworkImpl {
  abstract final int value;
  abstract final NetworkCoinParams coinParam;
  List<CryptoCoins> get coins;

  static AppBitcoinNetwork fromValue(int value) {
    return AppBitcoinNetwork.fromValue(value);
  }

  ApiProviderService getProvider([ApiProviderService? selectProvider]);
}

enum AppBitcoinNetwork implements AppNetworkImpl {
  bitcoinMainnet(0, NetworkCoins.bitcoinMainnet),
  bitcoinTestnet(1, NetworkCoins.bitcoinTestnet),
  litecoinMainnet(2, NetworkCoins.litecoinMainnet),
  dogecoinMainnet(3, NetworkCoins.dogecoinMainnet),
  dashMainnet(4, NetworkCoins.dashMainnet);

  @override
  final int value;
  @override
  final BitcoinParams coinParam;

  @override
  ApiProviderService getProvider([ApiProviderService? selectProvider]) {
    if (coinParam.providers.contains(selectProvider)) {
      return selectProvider!;
    }
    return coinParam.providers[0];
  }

  const AppBitcoinNetwork(this.value, this.coinParam);
  bool get isBitcoin => true;

  static AppBitcoinNetwork fromValue(int value) {
    return values.firstWhere((element) => element.value == value);
  }

  @override
  List<CryptoCoins> get coins {
    switch (this) {
      case AppBitcoinNetwork.bitcoinMainnet:
        return [
          Bip44Coins.bitcoin,
          Bip49Coins.bitcoin,
          Bip84Coins.bitcoin,
          Bip86Coins.bitcoin,
        ];
      case AppBitcoinNetwork.bitcoinTestnet:
        return [
          Bip44Coins.bitcoinTestnet,
          Bip49Coins.bitcoinTestnet,
          Bip84Coins.bitcoinTestnet,
          Bip86Coins.bitcoinTestnet,
        ];
      case AppBitcoinNetwork.litecoinMainnet:
        return [Bip44Coins.litecoin, Bip49Coins.litecoin, Bip84Coins.litecoin];
      case AppBitcoinNetwork.dogecoinMainnet:
        return [Bip44Coins.dogecoin, Bip49Coins.dogecoin];
      case AppBitcoinNetwork.dashMainnet:
        return [Bip44Coins.dash, Bip49Coins.dash];
      default:
        throw UnimplementedError();
    }
  }

  CryptoCoins findCOinFromBitcoinAddressType(BitcoinAddressType type) {
    switch (type) {
      case BitcoinAddressType.p2pkh:
      case BitcoinAddressType.p2pk:
        return coins
            .firstWhere((element) => element.proposal == BipProposal.bip44);
      case BitcoinAddressType.p2wsh:
      case BitcoinAddressType.p2wpkh:
        return coins
            .firstWhere((element) => element.proposal == BipProposal.bip84);
      case BitcoinAddressType.p2pkInP2sh:
      case BitcoinAddressType.p2pkhInP2sh:
      case BitcoinAddressType.p2wpkhInP2sh:
      case BitcoinAddressType.p2wshInP2sh:
        return coins
            .firstWhere((element) => element.proposal == BipProposal.bip49);
      default:
        return coins
            .firstWhere((element) => element.proposal == BipProposal.bip86);
    }
  }
}
