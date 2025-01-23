import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/crypto/constant/tags.dart';

class NetworkType {
  final String name;
  final List<int> tag;
  static const int tagLength = 3;

  const NetworkType._({required this.name, required this.tag});
  static const NetworkType bitcoinAndForked =
      NetworkType._(name: "Bitcoin", tag: CryptoKeyConst.bitconNetwork);
  static const NetworkType bitcoinCash = NetworkType._(
      name: "BitcoinCash", tag: CryptoKeyConst.bitcoinCashNetwork);
  static const NetworkType xrpl =
      NetworkType._(name: "XRPL", tag: CryptoKeyConst.xrpNetwork);
  static const NetworkType ethereum =
      NetworkType._(name: "Ethereum", tag: CryptoKeyConst.evmNetwork);
  static const NetworkType tron =
      NetworkType._(name: "Tron", tag: CryptoKeyConst.tvmNetwork);
  static const NetworkType solana =
      NetworkType._(name: "Solana", tag: CryptoKeyConst.solanaNetwork);
  static const NetworkType cardano =
      NetworkType._(name: "Cardano", tag: CryptoKeyConst.cardanoNetwork);
  static const NetworkType cosmos =
      NetworkType._(name: "Cosmos", tag: CryptoKeyConst.cosmosNetwork);
  static const NetworkType ton =
      NetworkType._(name: "TON", tag: CryptoKeyConst.tonNetwork);
  static const NetworkType substrate =
      NetworkType._(name: "Substrate", tag: CryptoKeyConst.substrateNetwork);
  static const NetworkType stellar =
      NetworkType._(name: "Stellar", tag: CryptoKeyConst.stellar);
  static const NetworkType monero =
      NetworkType._(name: "Monero", tag: CryptoKeyConst.monero);

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
    monero
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
