import 'package:mrt_wallet/app/utils/list/extension.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/constant/constant.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';

class Web3EthereumRequestMethods extends Web3RequestMethods {
  const Web3EthereumRequestMethods._(
      {required super.id,
      required super.name,
      super.methodsName,
      this.needWalletOwnerAction = true});
  static const Web3EthereumRequestMethods sendTransaction =
      Web3EthereumRequestMethods._(
          id: Web3EthereumConst.sendTransactionTag,
          name: Web3EthereumConst.sendTransaction);
  static const Web3EthereumRequestMethods persoalSign =
      Web3EthereumRequestMethods._(
          id: Web3EthereumConst.personalSignTag,
          name: Web3EthereumConst.personalSign);
  static const Web3EthereumRequestMethods typedData =
      Web3EthereumRequestMethods._(
          id: Web3EthereumConst.typedDataTag,
          name: Web3EthereumConst.typedData,
          methodsName: [
        Web3EthereumConst.typedDataV3,
        Web3EthereumConst.typedDataV4
      ]);
  static const Web3EthereumRequestMethods addEthereumChain =
      Web3EthereumRequestMethods._(
          id: Web3EthereumConst.addChainTag, name: Web3EthereumConst.addChain);
  static const Web3EthereumRequestMethods switchEthereumChain =
      Web3EthereumRequestMethods._(
          id: Web3EthereumConst.switchEthereumChainTag,
          name: Web3EthereumConst.switchEthereumChain,
          needWalletOwnerAction: false);

  static const Web3EthereumRequestMethods requestAccounts =
      Web3EthereumRequestMethods._(
          id: Web3EthereumConst.requestAccountTag,
          name: Web3EthereumConst.requestAccounts);
  static const Web3EthereumRequestMethods ethAccounts =
      Web3EthereumRequestMethods._(
          id: Web3EthereumConst.ethAccountsTag,
          name: Web3EthereumConst.ethAccounts);
  static const Web3EthereumRequestMethods ethChainId =
      Web3EthereumRequestMethods._(
          id: Web3EthereumConst.ethChainIdTag,
          name: Web3EthereumConst.ethChinId);
  static const List<Web3EthereumRequestMethods> values = [
    sendTransaction,
    persoalSign,
    typedData,
    addEthereumChain,
    switchEthereumChain,
    requestAccounts,
    ethAccounts,
    ethChainId
  ];
  static Web3EthereumRequestMethods fromId(int? id) {
    return values.firstWhere((e) => e.id == id,
        orElse: () => throw Web3RequestExceptionConst.methodDoesNotExist);
  }

  static Web3EthereumRequestMethods? fromName(String? name) {
    return values.firstWhereOrNull(
        (e) => e.name == name || e.methodsName.contains(name));
  }

  @override
  NetworkType get network => NetworkType.ethereum;

  @override
  final bool needWalletOwnerAction;
}
