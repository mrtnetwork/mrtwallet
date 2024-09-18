import 'package:mrt_wallet/app/models/models/typedef.dart';

class TransactionFormField<T> {
  TransactionFormField({
    required this.name,
    this.id,
    this.subject,
    required this.onChangeForm,
    T? value,
    this.optional = true,
  }) : _value = value;
  final String name;
  final String? id;
  final String? subject;
  final bool optional;
  T? _value;
  T? get value => _value;
  bool get hasValue => _value != null;
  bool get isCompleted => optional || _value != null;
  final FuncTResult<T> onChangeForm;
  bool setValue(T? v) {
    if (v == _value) return false;
    if (v == null) {
      _value = null;
    } else {
      final value = onChangeForm(v);
      if (value != null) {
        _value = value;
      } else {
        return false;
      }
    }
    return true;
  }
}

class TransactionListFormField<T> {
  TransactionListFormField({
    required this.name,
    this.id,
    this.subject,
    required this.onChangeForm,
    this.optional = true,
    List<T> values = const [],
  }) : _value = List<T>.from(values);
  final String name;
  final String? id;
  final String? subject;
  final bool optional;
  final List<T> _value;
  List<T> get value => _value;
  bool get hasValue => _value.isNotEmpty;
  bool get isCompleted => optional || _value.isNotEmpty;
  final FuncTResult<T> onChangeForm;
  int get length => value.length;
  bool get isEmpty => value.isEmpty;
  bool get isNotEmpty => value.isNotEmpty;
  bool addValue(T v) {
    if (v == null) return false;
    if (_value.contains(v)) return false;
    final value = onChangeForm(v);
    if (value != null) {
      _value.add(value);
    } else {
      return false;
    }
    return true;
  }

  bool removeValue(T v) {
    return _value.remove(v);
  }
}
