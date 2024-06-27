import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:bitcoin_base/bitcoin_base.dart' show APIType;

enum BitcoinExplorerProviderType {
  blockcypher,
  mempool;

  static BitcoinExplorerProviderType fromName(String? name) {
    return values.firstWhere((element) => element.name == name,
        orElse: () => throw WalletExceptionConst.invalidProviderInformation);
  }

  APIType get type {
    if (this == blockcypher) return APIType.blockCypher;
    return APIType.mempool;
  }

  bool get isBlockCypher => this == BitcoinExplorerProviderType.blockcypher;
}
