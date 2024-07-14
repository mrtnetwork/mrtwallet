import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/wroker/constant/const.dart';

class NetworkType {
  final String name;
  final List<int> tag;

  const NetworkType._({required this.name, required this.tag});
  static const NetworkType bitcoinAndForked =
      NetworkType._(name: "Bitcoin", tag: CryptoKeyConst.bitconNetwork);
  static const NetworkType bitcoinCash =
      NetworkType._(name: "Bitcoin", tag: CryptoKeyConst.bitcoinCashNetwork);
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
  static const NetworkType polkadot =
      NetworkType._(name: "Polkadot", tag: CryptoKeyConst.polkadotNetwork);
  static const NetworkType kusama =
      NetworkType._(name: "Kusama", tag: CryptoKeyConst.kusamaNetwork);

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
    polkadot,
    kusama
  ];

  static NetworkType fromTag(List<int>? tag) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(tag, e.tag),
        orElse: () => throw WalletExceptionConst.incorrectNetwork);
  }
}
