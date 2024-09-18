import 'package:mrt_wallet/app/utils/list/extension.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/constant/constant.dart';
import 'package:mrt_wallet/wallet/web3/networks/solana/constant/constants/constant.dart';

class Web3SolanaRequestMethods extends Web3RequestMethods {
  const Web3SolanaRequestMethods._(
      {required super.id, required super.name, super.methodsName});

  static const Web3SolanaRequestMethods requestAccounts =
      Web3SolanaRequestMethods._(
          id: Web3SolanaConst.requestAccountTag,
          name: Web3SolanaConst.requestAccounts,
          methodsName: [Web3EthereumConst.requestAccounts]);
  static const Web3SolanaRequestMethods signMessage =
      Web3SolanaRequestMethods._(
          id: Web3SolanaConst.signMessageV2Tag,
          name: Web3SolanaConst.signMessage);

  static const Web3SolanaRequestMethods signTransaction =
      Web3SolanaRequestMethods._(
          id: Web3SolanaConst.signTransactionTag,
          name: Web3SolanaConst.signTransaction);
  static const Web3SolanaRequestMethods signAllTransactions =
      Web3SolanaRequestMethods._(
          id: Web3SolanaConst.signAllTransactionsTag,
          name: Web3SolanaConst.signAllTransactions);

  static const Web3SolanaRequestMethods sendTransaction =
      Web3SolanaRequestMethods._(
          id: Web3SolanaConst.sendTransactionTag,
          name: Web3SolanaConst.sendTransaction);

  static const Web3SolanaRequestMethods sendAllTransactions =
      Web3SolanaRequestMethods._(
          id: Web3SolanaConst.sendAllTransactionsTag,
          name: Web3SolanaConst.sendAllTransactions);
  @override
  final bool needWalletOwnerAction = true;
  @override
  NetworkType get network => NetworkType.solana;

  static List<Web3SolanaRequestMethods> values = [
    requestAccounts,
    signTransaction,
    signAllTransactions,
    sendTransaction,
    sendAllTransactions,
    signMessage
  ];

  static Web3SolanaRequestMethods fromId(int? id) {
    return values.firstWhere((e) => e.id == id,
        orElse: () => throw Web3RequestExceptionConst.methodDoesNotExist);
  }

  static Web3SolanaRequestMethods? fromName(String? name) {
    return values.firstWhereOrNull(
        (e) => e.name == name || e.methodsName.contains(name));
  }
}
