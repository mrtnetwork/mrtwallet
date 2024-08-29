import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';

enum TronChainType {
  mainnet(id: 1001, genesisBlockNumber: 728126428),
  shasta(id: 1002, genesisBlockNumber: 2494104990),
  nile(id: 1003, genesisBlockNumber: 3448148188);

  const TronChainType({required this.id, required this.genesisBlockNumber});

  final int id;
  final int genesisBlockNumber;

  static TronChainType fromName(String? name) {
    final lower = name?.toLowerCase();
    return values.firstWhere((e) => e.name == lower,
        orElse: () => throw Web3RequestExceptionConst.invalidNetwork);
  }

  static TronChainType fromId(int? id) {
    return values.firstWhere((e) => e.id == id,
        orElse: () => throw Web3RequestExceptionConst.invalidNetwork);
  }

  static TronChainType fromGenesis(int? id) {
    return values.firstWhere((e) => e.genesisBlockNumber == id,
        orElse: () => throw Web3RequestExceptionConst.invalidNetwork);
  }
}
