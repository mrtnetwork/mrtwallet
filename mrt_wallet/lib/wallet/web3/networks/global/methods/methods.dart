import 'package:mrt_wallet/app/utils/list/extension.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/global/constant/constant.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';

class Web3GlobalRequestMethods extends Web3RequestMethods {
  const Web3GlobalRequestMethods._(
      {required super.id,
      required super.name,
      this.needWalletOwnerAction = true});
  static const Web3GlobalRequestMethods disconnect = Web3GlobalRequestMethods._(
      id: Web3GlobalConst.disconnectTag,
      name: "disconnect",
      needWalletOwnerAction: false);

  static const List<Web3GlobalRequestMethods> values = [disconnect];
  static Web3GlobalRequestMethods fromId(int? id) {
    return values.firstWhere((e) => e.id == id,
        orElse: () => throw Web3RequestExceptionConst.methodDoesNotExist);
  }

  static Web3GlobalRequestMethods? fromName(String? name) {
    return values.firstWhereOrNull(
        (e) => e.name == name || e.methodsName.contains(name));
  }

  @override
  NetworkType get network => throw UnimplementedError();

  @override
  final bool needWalletOwnerAction;
}
