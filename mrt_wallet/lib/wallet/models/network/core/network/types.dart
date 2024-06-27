class NetworkType {
  final String name;
  const NetworkType._(this.name);
  static const NetworkType bitcoinAndForked = NetworkType._("Bitcoin");
  static const NetworkType xrpl = NetworkType._("XRPL");
  static const NetworkType ethereum = NetworkType._("Ethereum");
  static const NetworkType tron = NetworkType._("Tron");
  static const NetworkType solana = NetworkType._("Solana");
  static const NetworkType cardano = NetworkType._("Cardano");
  static const NetworkType cosmos = NetworkType._("Cosmos");
  static const NetworkType ton = NetworkType._("TON");
}
