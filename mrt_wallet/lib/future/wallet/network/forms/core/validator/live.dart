import 'package:mrt_wallet/app/core.dart';
import 'transaction_form.dart';

typedef OnChangeForm = void Function();

class LiveTransactionForm<T extends ValidatorForm> extends Live {
  LiveTransactionForm({required this.validator}) : super(validator) {
    validator.onChanged = onChanged;
  }
  final T validator;
  void onChanged() {
    _notifyChangePages();
  }

  void _notifyChangePages() {
    notify();
  }
}
