import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/networks/aptos/aptos.dart';
import 'package:mrt_wallet/wallet/web3/networks/bitcoin/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/cosmos/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/solana/solana.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/stellar.dart';
import 'package:mrt_wallet/wallet/web3/networks/substrate/substrate.dart';
import 'package:mrt_wallet/wallet/web3/networks/sui/methods/methods.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/ton.dart';
import 'package:mrt_wallet/wallet/web3/networks/tron/methods/methods.dart';

abstract class Web3RequestMethods {
  final int id;
  final String name;
  final List<String> methodsName;
  final bool reloadAuthenticated;
  const Web3RequestMethods(
      {required this.id,
      required this.name,
      required this.methodsName,
      required this.reloadAuthenticated});
}

abstract class Web3NetworkRequestMethods extends Web3RequestMethods {
  const Web3NetworkRequestMethods(
      {required super.id,
      required super.name,
      super.methodsName = const [],
      super.reloadAuthenticated = false});
  abstract final NetworkType network;
  List<int> get tag => [...network.tag, id];
  static Web3NetworkRequestMethods fromTag(List<int>? tag) {
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
      case NetworkType.substrate:
        return Web3SubstrateRequestMethods.fromId(tag!.last);
      case NetworkType.aptos:
        return Web3AptosRequestMethods.fromId(tag!.last);
      case NetworkType.sui:
        return Web3SuiRequestMethods.fromId(tag!.last);
      case NetworkType.cosmos:
        return Web3CosmosRequestMethods.fromId(tag!.last);
      case NetworkType.bitcoinAndForked:
        return Web3BitcoinRequestMethods.fromId(tag!.last);
      default:
        throw Web3RequestExceptionConst.invalidNetwork;
    }
  }
}
