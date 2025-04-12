import 'package:mrt_wallet/app/utils/list/extension.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/cosmos/constant/constants/constant.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/constant/constant.dart';

class Web3CosmosRequestMethods extends Web3NetworkRequestMethods {
  const Web3CosmosRequestMethods._(
      {required super.id,
      required super.name,
      super.methodsName,
      super.reloadAuthenticated});

  static const Web3CosmosRequestMethods requestAccounts =
      Web3CosmosRequestMethods._(
          id: Web3CosmosConst.requestAccountTag,
          name: Web3CosmosConst.requestAccounts,
          methodsName: [Web3EthereumConst.requestAccounts]);
  static const Web3CosmosRequestMethods addNewChain =
      Web3CosmosRequestMethods._(
          id: Web3CosmosConst.addNewChainTag,
          name: Web3CosmosConst.addNewChain,
          reloadAuthenticated: true);

  static const Web3CosmosRequestMethods signMessage =
      Web3CosmosRequestMethods._(
          id: Web3CosmosConst.signMessagTag, name: Web3CosmosConst.signMessage);

  static const Web3CosmosRequestMethods sendTransaction =
      Web3CosmosRequestMethods._(
          id: Web3CosmosConst.sendTransactionTag,
          name: Web3CosmosConst.sendTransaction);

  static const Web3CosmosRequestMethods switchNetwork =
      Web3CosmosRequestMethods._(
          id: Web3CosmosConst.changeNetworkTag,
          name: Web3CosmosConst.switchNetwork,
          reloadAuthenticated: true);

  static const Web3CosmosRequestMethods signTransactionAmino =
      Web3CosmosRequestMethods._(
          id: Web3CosmosConst.signTransactionAminoTag,
          name: Web3CosmosConst.signTransactionAmino);
  static const Web3CosmosRequestMethods signTransactionDirect =
      Web3CosmosRequestMethods._(
          id: Web3CosmosConst.signTransactionDirectTag,
          name: Web3CosmosConst.signTransactionDirect);

  static const Web3CosmosRequestMethods signTransaction =
      Web3CosmosRequestMethods._(
          id: Web3CosmosConst.signTransactionTag,
          name: Web3CosmosConst.signTransaction);

  @override
  NetworkType get network => NetworkType.cosmos;

  static List<Web3CosmosRequestMethods> values = [
    requestAccounts,
    signTransactionAmino,
    signTransactionDirect,
    signMessage,
    addNewChain,
    switchNetwork,
    signTransaction,
    sendTransaction
  ];

  static Web3CosmosRequestMethods fromId(int? id) {
    return values.firstWhere((e) => e.id == id,
        orElse: () => throw Web3RequestExceptionConst.methodDoesNotExist);
  }

  static Web3CosmosRequestMethods? fromName(String? name) {
    return values.firstWhereOrNull(
        (e) => e.name == name || e.methodsName.contains(name));
  }
}
