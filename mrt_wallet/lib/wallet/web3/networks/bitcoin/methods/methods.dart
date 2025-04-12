import 'package:mrt_wallet/app/utils/list/extension.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/bitcoin/constant/constants/constant.dart';
import 'package:mrt_wallet/wallet/web3/networks/ethereum/constant/constant.dart';

class Web3BitcoinRequestMethods extends Web3NetworkRequestMethods {
  const Web3BitcoinRequestMethods._(
      {required super.id, required super.name, super.methodsName});

  static const Web3BitcoinRequestMethods requestAccounts =
      Web3BitcoinRequestMethods._(
          id: Web3BitcoinConst.requestAccountTag,
          name: Web3BitcoinConst.requestAccounts,
          methodsName: [Web3EthereumConst.requestAccounts]);

  static const Web3BitcoinRequestMethods signPersonalMessage =
      Web3BitcoinRequestMethods._(
          id: Web3BitcoinConst.signPersonalMessagTag,
          name: Web3BitcoinConst.signPersonalMessage);

  static const Web3BitcoinRequestMethods signTransaction =
      Web3BitcoinRequestMethods._(
          id: Web3BitcoinConst.signTransactionTag,
          name: Web3BitcoinConst.signTransaction);

  static const Web3BitcoinRequestMethods sendTransaction =
      Web3BitcoinRequestMethods._(
          id: Web3BitcoinConst.sendTransactionTag,
          name: Web3BitcoinConst.sendTransaction);

  @override
  NetworkType get network => NetworkType.bitcoinAndForked;

  static List<Web3BitcoinRequestMethods> values = [
    requestAccounts,
    signTransaction,
    signPersonalMessage,
    sendTransaction
  ];

  static Web3BitcoinRequestMethods fromId(int? id) {
    return values.firstWhere((e) => e.id == id,
        orElse: () => throw Web3RequestExceptionConst.methodDoesNotExist);
  }

  static Web3BitcoinRequestMethods? fromName(String? name) {
    return values.firstWhereOrNull(
        (e) => e.name == name || e.methodsName.contains(name));
  }
}
