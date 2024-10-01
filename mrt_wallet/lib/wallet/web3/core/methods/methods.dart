import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/methods/methods.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/networks/solana/solana.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/stellar.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/ton.dart';
import 'package:mrt_wallet/wallet/web3/networks/tron/methods/methods.dart';

abstract class Web3RequestMethods {
  const Web3RequestMethods(
      {required this.id, required this.name, this.methodsName = const []});
  final int id;
  final String name;
  final List<String> methodsName;
  bool get needWalletOwnerAction;
  abstract final NetworkType network;
  List<int> get tag => [...network.tag, id];
  static Web3RequestMethods fromTag(List<int>? tag) {
    final network = NetworkType.fromTag(tag);
    switch (network) {
      case NetworkType.ethereum:
        return Web3EthereumRequestMethods.fromId(tag!.last);
      case NetworkType.tron:
        return Web3TronRequestMethods.fromId(tag!.last);
      case NetworkType.solana:
        return Web3SolanaRequestMethods.fromId(tag!.last);
      case NetworkType.ton:
        return Web3TonRequestMethods.fromId(tag!.last);
      case NetworkType.stellar:
        return Web3StellarRequestMethods.fromId(tag!.last);
      default:
        throw Web3RequestExceptionConst.networkNotSupported;
    }
  }
}
