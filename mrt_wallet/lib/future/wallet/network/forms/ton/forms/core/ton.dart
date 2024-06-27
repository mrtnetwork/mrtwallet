import 'package:mrt_wallet/wallet/models/account/address/networks/ton/ton.dart';
import 'package:mrt_wallet/future/wallet/network/forms/core/core.dart';
import 'package:mrt_wallet/app/models/models/typedef.dart';
import 'package:ton_dart/ton_dart.dart';

enum TonTransactionType { ton, jetton }

abstract class TonTransactionForm implements TransactionForm {
  TonTransactionForm();
  BigInt get callValue;

  @override
  String? validateError({ITonAddress? account});
  StringVoid? onReadyField;
  List<MessageRelaxed> toMessages(TonAddress account);

  @override
  OnChangeForm? onChanged;
}
