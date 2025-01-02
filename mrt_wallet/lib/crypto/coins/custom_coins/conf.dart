import 'package:blockchain_utils/blockchain_utils.dart';

class CustomCurrencyConf {
  static BipCoinConfig byronLegacy = BipCoinConfig(
    coinNames: const CoinNames("Byron legacy", "ADA"),
    coinIdx: 0,
    chainType: ChainType.mainnet,
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
    chainType: ChainType.testnet,
    defPath: "",
    keyNetVer: Bip32Const.kholawKeyNetVersions,
    wifNetVer: null,
    type: EllipticCurveTypes.ed25519Kholaw,
    addressEncoder: ([dynamic kwargs]) => AdaByronLegacyAddrEncoder(),
    addrParams: {"chain_code": true},
  );
}
