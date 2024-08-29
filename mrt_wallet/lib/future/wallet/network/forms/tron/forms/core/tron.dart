import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/app/models/models/typedef.dart';
import 'package:mrt_wallet/wallet/web3/networks/tron/params/core/request.dart';
import 'package:mrt_wallet/wallet/web3/networks/tron/permission/models/account.dart';
import 'package:mrt_wallet/wallet/web3/networks/tron/permission/models/permission.dart';
import 'package:on_chain/on_chain.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';

abstract class TronTransactionForm implements TransactionForm {
  BigInt get callValue;
  BigInt get tokenValue;
  @override
  String? validateError({ITronAddress? account});
  TransactionContractType get type;
  DynamicVoid? onStimateChanged;
  TronAddress? get destinationAccount;
  TronAddress? get smartContractAddress;
  Future<void> init(
      {required TronClient provider,
      required ITronAddress address,
      required TronChain account});

  TronBaseContract toContract({required ITronAddress owner});
}

abstract class TronWeb3Form<PARAMS extends Web3TronRequestParam>
    implements
        Web3Form<TronAddress, TronChain, Web3TronChainAccount, Web3TronChain,
            PARAMS> {
  @override
  abstract final Web3TronRequest<dynamic, PARAMS> request;

  DynamicVoid? onStimateChanged;
  @override
  ObjectVoid? onCompeleteForm;

  @override
  String get name => request.params.method.name;

  void confirmRequest({Object? response}) {
    onCompeleteForm?.call(response);
  }
}
