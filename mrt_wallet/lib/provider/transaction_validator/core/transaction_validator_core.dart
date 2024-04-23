import 'package:mrt_wallet/provider/transaction_validator/core/live_validator.dart';
import 'validator_fields.dart';

typedef OnChageValidatorField<T> = void Function(ValidatorField<T>, T?);

abstract class TransactionValidator {
  String? validateError();
  String get name;
  List<ValidatorField> get fields;
  OnChangeValidator? onChanged;
  void setValue<T>(ValidatorField<T>? field, T? value);
}
