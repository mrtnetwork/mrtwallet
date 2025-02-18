import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/models/models/typedef.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'field.dart';

typedef OnChageFormField<T> = void Function(TransactionFormField<T>, T?);

abstract class ValidatorForm {
  String get name;
  OnChangeForm? onChanged;
}

abstract class TransactionForm implements ValidatorForm {
  bool get enableSwitchAccount => true;
  String? validateError();
  @override
  String get name;
  @override
  OnChangeForm? onChanged;
  T cast<T extends TransactionForm>() {
    if (this is! T) {
      throw WalletException.invalidArgruments(["$T", runtimeType.toString()]);
    }
    return this as T;
  }

  void close() {}
}

abstract class Web3Form<
    NETWORKADDRESS,
    CHAIN extends APPCHAINNETWORK<NETWORKADDRESS>,
    CHAINACCOUNT extends Web3ChainAccount<NETWORKADDRESS>,
    WEB3CHAIN extends Web3Chain<NETWORKADDRESS, CHAIN, CHAINACCOUNT,
        WalletNetwork>,
    PARAMS extends Web3RequestParams<dynamic, NETWORKADDRESS, CHAIN,
        CHAINACCOUNT, WEB3CHAIN>> implements ValidatorForm {
  @override
  String get name;
  @override
  OnChangeForm? onChanged;
  abstract final Web3Request<dynamic, NETWORKADDRESS, CHAIN, CHAINACCOUNT,
      WEB3CHAIN, PARAMS> request;
  ObjectVoid? onCompleteForm;

  void close() {}
}
