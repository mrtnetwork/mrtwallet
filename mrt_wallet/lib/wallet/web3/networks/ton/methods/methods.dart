import 'package:mrt_wallet/app/utils/list/extension.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/constant/constants/constant.dart';

class Web3TonRequestMethods extends Web3RequestMethods {
  const Web3TonRequestMethods._({required super.id, required super.name});

  static const Web3TonRequestMethods requestAccounts = Web3TonRequestMethods._(
    id: Web3TonConst.requestAccountTag,
    name: Web3TonConst.requestAccounts,
  );
  static const Web3TonRequestMethods signMessage = Web3TonRequestMethods._(
      id: Web3TonConst.signMessageV2Tag, name: Web3TonConst.signMessage);

  static const Web3TonRequestMethods sendTransaction = Web3TonRequestMethods._(
      id: Web3TonConst.sendTransactionTag, name: Web3TonConst.sendTransaction);
  @override
  final bool needWalletOwnerAction = true;
  @override
  NetworkType get network => NetworkType.ton;

  static List<Web3TonRequestMethods> values = [
    requestAccounts,
    signMessage,
    sendTransaction
  ];

  static Web3TonRequestMethods fromId(int? id) {
    return values.firstWhere((e) => e.id == id,
        orElse: () => throw Web3RequestExceptionConst.methodDoesNotExist);
  }

  static Web3TonRequestMethods? fromName(String? name) {
    return values.firstWhereOrNull(
        (e) => e.name == name || e.methodsName.contains(name));
  }
}
