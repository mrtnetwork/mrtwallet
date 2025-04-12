import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/crypto/constant/tags.dart';

class NetworkType {
  final String name;
  final List<int> tag;
  final int mainNetworkId;
  static const int tagLength = 3;
  bool get isBitcoin =>
      this == NetworkType.bitcoinAndForked || this == NetworkType.bitcoinCash;

  const NetworkType._(
      {required this.name, required this.tag, required this.mainNetworkId});
  static const NetworkType bitcoinAndForked = NetworkType._(
      name: "Bitcoin", tag: CryptoKeyConst.bitconNetwork, mainNetworkId: 0);
  static const NetworkType bitcoinCash = NetworkType._(
      name: "BitcoinCash",
      tag: CryptoKeyConst.bitcoinCashNetwork,
      mainNetworkId: 0);
  static const NetworkType xrpl = NetworkType._(
      name: "XRPL", tag: CryptoKeyConst.xrpNetwork, mainNetworkId: 30);
  static const NetworkType ethereum = NetworkType._(
      name: "Ethereum", tag: CryptoKeyConst.evmNetwork, mainNetworkId: 100);
  static const NetworkType tron = NetworkType._(
      name: "Tron", tag: CryptoKeyConst.tvmNetwork, mainNetworkId: 1001);
  static const NetworkType solana = NetworkType._(
      name: "Solana", tag: CryptoKeyConst.solanaNetwork, mainNetworkId: 33);
  static const NetworkType cardano = NetworkType._(
      name: "Cardano", tag: CryptoKeyConst.cardanoNetwork, mainNetworkId: 50);
  static const NetworkType cosmos = NetworkType._(
      name: "Cosmos", tag: CryptoKeyConst.cosmosNetwork, mainNetworkId: 200);
  static const NetworkType ton = NetworkType._(
      name: "TON", tag: CryptoKeyConst.tonNetwork, mainNetworkId: 300);
  static const NetworkType substrate = NetworkType._(
      name: "Substrate",
      tag: CryptoKeyConst.substrateNetwork,
      mainNetworkId: 400);
  static const NetworkType stellar = NetworkType._(
      name: "Stellar", tag: CryptoKeyConst.stellar, mainNetworkId: 600);
  static const NetworkType monero = NetworkType._(
      name: "Monero", tag: CryptoKeyConst.monero, mainNetworkId: 700);
  static const NetworkType aptos = NetworkType._(
      name: "Aptos", tag: CryptoKeyConst.aptos, mainNetworkId: 810);

  static const NetworkType sui =
      NetworkType._(name: "Sui", tag: CryptoKeyConst.sui, mainNetworkId: 800);

  static const List<NetworkType> values = [
    bitcoinAndForked,
    bitcoinCash,
    xrpl,
    ethereum,
    tron,
    solana,
    cardano,
    ton,
    cosmos,
    substrate,
    stellar,
    monero,
    aptos,
    sui
  ];

  static NetworkType fromTag(List<int>? tag) {
    if (tag != null && tag.length > tagLength) {
      tag = tag.sublist(0, tagLength);
    }
    return values.firstWhere((e) => BytesUtils.bytesEqual(tag, e.tag),
        orElse: () => throw WalletExceptionConst.incorrectNetwork);
  }

  static NetworkType fromName(String? name) {
    return values.firstWhere((e) => e.name == name,
        orElse: () => throw WalletExceptionConst.incorrectNetwork);
  }

  @override
  String toString() {
    return "NetworkType.$name";
  }
}
