import 'package:mrt_wallet/wallet/models/chain/address/networks/ton/ton.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';
import 'package:mrt_wallet/app/models/models/typedef.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/ton.dart';
import 'package:ton_dart/ton_dart.dart' as ton_dart;

enum TonTransactionType { ton, jetton }

abstract class TonTransactionForm implements TransactionForm {
  TonTransactionForm();
  BigInt get callValue;

  @override
  String? validateError({ITonAddress? account});
  StringVoid? onReadyField;
  List<ton_dart.MessageRelaxed> toMessages(ton_dart.TonAddress account);

  @override
  OnChangeForm? onChanged;
}

abstract class TonWeb3Form<PARAMS extends Web3TonRequestParam>
    implements
        Web3Form<ton_dart.TonAddress, TheOpenNetworkChain, Web3TonChainAccount,
            Web3TonChain, PARAMS> {
  @override
  abstract final Web3TonRequest<dynamic, PARAMS> request;

  DynamicVoid? onStimateChanged;
  @override
  ObjectVoid? onCompeleteForm;

  @override
  String get name => request.params.method.name;

  void confirmRequest({Object? response}) {
    onCompeleteForm?.call(response);
  }
}
