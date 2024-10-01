import 'package:mrt_wallet/app/utils/list/extension.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/constant/constant.dart';

class Web3StellarRequestMethods extends Web3RequestMethods {
  const Web3StellarRequestMethods._({required super.id, required super.name});

  static const Web3StellarRequestMethods requestAccounts =
      Web3StellarRequestMethods._(
    id: Web3StellarConst.requestAccountTag,
    name: Web3StellarConst.requestAccounts,
  );
  static const Web3StellarRequestMethods signMessage =
      Web3StellarRequestMethods._(
          id: Web3StellarConst.signMessageV2Tag,
          name: Web3StellarConst.signMessage);

  static const Web3StellarRequestMethods sendTransaction =
      Web3StellarRequestMethods._(
          id: Web3StellarConst.sendTransactionTag,
          name: Web3StellarConst.sendTransaction);

  static const Web3StellarRequestMethods signTransaction =
      Web3StellarRequestMethods._(
          id: Web3StellarConst.signTransactionTag,
          name: Web3StellarConst.signTransaction);
  @override
  final bool needWalletOwnerAction = true;
  @override
  NetworkType get network => NetworkType.stellar;

  static List<Web3StellarRequestMethods> values = [
    requestAccounts,
    signMessage,
    sendTransaction,
    signTransaction
  ];

  static Web3StellarRequestMethods fromId(int? id) {
    return values.firstWhere((e) => e.id == id,
        orElse: () => throw Web3RequestExceptionConst.methodDoesNotExist);
  }

  static Web3StellarRequestMethods? fromName(String? name) {
    return values.firstWhereOrNull(
        (e) => e.name == name || e.methodsName.contains(name));
  }
}
