import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/tron/constant/constant.dart';

class Web3TronRequestMethods extends Web3RequestMethods {
  const Web3TronRequestMethods._(
      {required super.id,
      required super.name,
      super.methodsName,
      this.needWalletOwnerAction = true});

  static const Web3TronRequestMethods requestAccounts =
      Web3TronRequestMethods._(
          id: Web3TronConst.requestAccountTag,
          name: Web3TronConst.requestAccounts);
  @override
  final bool needWalletOwnerAction;
  @override
  NetworkType get network => NetworkType.tron;

  static List<Web3TronRequestMethods> values = [requestAccounts];

  static Web3TronRequestMethods fromId(int? id) {
    return values.firstWhere((e) => e.id == id,
        orElse: () => throw Web3RequestExceptionConst.methodDoesNotExist);
  }
}
