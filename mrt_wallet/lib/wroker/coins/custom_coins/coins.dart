import 'package:blockchain_utils/bip/bip/bip32/bip32_key_data.dart';
import 'package:blockchain_utils/bip/bip/conf/bip_coin_conf.dart';
import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'conf.dart';

class CustomCoins extends CryptoCoins {
  CustomCoins._(this.name, this.conf);
  final String name;
  @override
  String get coinName => name;

  @override
  final CoinConfig conf;

  @override
  CryptoProposal get proposal => CustomProposal.cip0019;

  @override
  CryptoCoins get value => this;

  static final CustomCoins byronLegacy =
      CustomCoins._("Byron legacy", CustomCurrencyConf.byronLegacy);
  static final CustomCoins byronLegacyTestnet = CustomCoins._(
      "Byron legacy testnet", CustomCurrencyConf.byronLegacyTestnet);
  static final List<CustomCoins> values = [byronLegacy, byronLegacyTestnet];

  static CryptoCoins? getCoin(String name, CryptoProposal proposal) {
    switch (proposal) {
      case CustomProposal.cip0019:
        return CustomCoins.fromName(name);
      default:
        return CryptoCoins.getCoin(name, proposal);
    }
  }

  static CustomCoins? fromName(String name) {
    try {
      return values.firstWhere((element) => element.name == name);
    } on StateError {
      return null;
    }
  }
}

class CustomProposal implements CryptoProposal {
  static const CustomProposal cip0019 = CustomProposal._("CIP-0019");

  const CustomProposal._(this.name);
  final String name;

  @override
  String get specName => name;
  @override
  CustomProposal get value => this;
  static const String _cip0019OldName = "custom";
  static const List<CryptoProposal> values = [cip0019];

  @override
  Bip32KeyIndex get purpose => Bip32KeyIndex(0);

  static CryptoProposal fromName(String name) {
    try {
      if (name == _cip0019OldName) return CustomProposal.cip0019;
      return values.firstWhere(
        (element) => element.specName == name,
        orElse: () =>
            BipProposal.values.firstWhere((element) => element.name == name),
      );
    } on StateError {
      return CipProposal.values.firstWhere(
        (element) => element.name == name,
        orElse: () => throw WalletException(
            "Unable to locate a proposal with the given name."),
      );
    }
  }
}
