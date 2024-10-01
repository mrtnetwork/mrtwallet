import 'package:mrt_wallet/crypto/models/networks.dart';

class Web3Const {
  static const List<NetworkType> supportedWeb3 = [
    NetworkType.ethereum,
    NetworkType.tron,
    NetworkType.solana,
    NetworkType.ton,
    NetworkType.stellar,
  ];
}
