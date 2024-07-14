import 'package:mrt_wallet/future/wallet/network/forms/core/validator/live.dart';
import 'field.dart';

typedef OnChageFormField<T> = void Function(TransactionFormField<T>, T?);

abstract class TransactionForm {
  String? validateError();
  String get name;
  OnChangeForm? onChanged;
}
