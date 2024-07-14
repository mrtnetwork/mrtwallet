import 'package:blockchain_utils/bip/coin_conf/coins_name.dart';
import 'package:blockchain_utils/bip/slip/slip44/slip44.dart';
import 'package:blockchain_utils/blockchain_utils.dart';

class CustomCurrencyConf {
  static BipCoinConfig byronLegacy = BipCoinConfig(
    coinNames: const CoinNames("Byron legacy", "ADA"),
    coinIdx: 0,
    isTestnet: false,
    defPath: "0/0",
    keyNetVer: Bip32Const.kholawKeyNetVersions,
    wifNetVer: null,
    type: EllipticCurveTypes.ed25519Kholaw,
    addressEncoder: ([dynamic kwargs]) => AdaByronLegacyAddrEncoder(),
    addrParams: {"chain_code": true},
  );
  static BipCoinConfig byronLegacyTestnet = BipCoinConfig(
    coinNames: const CoinNames("Byron legacy testnet", "ADA"),
    coinIdx: Slip44.testnet,
    isTestnet: true,
    defPath: "",
    keyNetVer: Bip32Const.kholawKeyNetVersions,
    wifNetVer: null,
    type: EllipticCurveTypes.ed25519Kholaw,
    addressEncoder: ([dynamic kwargs]) => AdaByronLegacyAddrEncoder(),
    addrParams: {"chain_code": true},
  );
}
