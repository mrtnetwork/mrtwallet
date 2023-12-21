import 'package:mrt_wallet/types/typedef.dart';

import 'validator_fields.dart';

typedef OnChageValidatorField<T> = void Function(ValidatorField<T>, T?);

abstract class TransactionValidator {
  String? validateError();
  bool get isValid;
  String get helperUri;
  String get subject;
  String get name;
  String get fieldsName;
  List<ValidatorField> get fields;
  DynamicVoid? onChanged;
  void setValue<T>(ValidatorField<T>? field, T? value);
  void setListValue<T>(ValidatorField<List<T>> field, T? value);
  void removeIndex<T>(ValidatorField<List<T>> field, int index);
}
