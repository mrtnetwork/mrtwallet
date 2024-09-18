import 'package:mrt_wallet/app/utils/list/extension.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/constant/constant.dart';
import 'package:mrt_wallet/wallet/web3/networks/tron/constant/constants/constant.dart';

class Web3TronRequestMethods extends Web3RequestMethods {
  const Web3TronRequestMethods._(
      {required super.id, required super.name, super.methodsName});

  static const Web3TronRequestMethods requestAccounts =
      Web3TronRequestMethods._(
          id: Web3TronConst.requestAccountTag,
          name: Web3TronConst.requestAccounts,
          methodsName: [Web3EthereumConst.requestAccounts]);
  static const Web3TronRequestMethods signMessageV2 = Web3TronRequestMethods._(
      id: Web3TronConst.signMessageV2Tag, name: Web3TronConst.signMessageV2);

  static const Web3TronRequestMethods signTransaction =
      Web3TronRequestMethods._(
          id: Web3TronConst.signTransactionTag,
          name: Web3TronConst.signTransaction);
  @override
  final bool needWalletOwnerAction = true;
  @override
  NetworkType get network => NetworkType.tron;

  static List<Web3TronRequestMethods> values = [
    requestAccounts,
    signTransaction,
    signMessageV2
  ];

  static Web3TronRequestMethods fromId(int? id) {
    return values.firstWhere((e) => e.id == id,
        orElse: () => throw Web3RequestExceptionConst.methodDoesNotExist);
  }

  static Web3TronRequestMethods? fromName(String? name) {
    return values.firstWhereOrNull(
        (e) => e.name == name || e.methodsName.contains(name));
  }
}
