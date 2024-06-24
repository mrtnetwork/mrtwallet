import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/transaction_validator/core/validator.dart';
import 'package:mrt_wallet/types/typedef.dart';
import 'package:ton_dart/ton_dart.dart';

enum TonTransactionType { ton, jetton }

abstract class TonTransactionValidator implements TransactionValidator {
  TonTransactionValidator();
  BigInt get callValue;

  @override
  String? validateError({ITonAddress? account});
  StringVoid? onReadyField;
  List<MessageRelaxed> toMessages(TonAddress account);

  @override
  OnChangeValidator? onChanged;
}
