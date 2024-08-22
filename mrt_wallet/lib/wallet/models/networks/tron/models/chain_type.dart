import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';

enum TronChainType {
  mainnet(1001),
  shasta(1002),
  nile(1003);

  const TronChainType(this.id);

  final int id;

  static TronChainType fromName(String name) {
    final lower = name.toLowerCase();
    return values.firstWhere((e) => e.name == lower,
        orElse: () => throw Web3RequestExceptionConst.invalidNetwork);
  }

  static TronChainType fromId(int id) {
    return values.firstWhere((e) => e.id == id,
        orElse: () => throw Web3RequestExceptionConst.invalidNetwork);
  }
}
