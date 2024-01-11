import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/types/typedef.dart';
import 'transaction_validator_core.dart';

typedef OnChangeValidator = void Function([bool?]);

class LiveTransactionValidator<T extends TransactionValidator> extends Live {
  LiveTransactionValidator({required this.validator}) : super(validator) {
    validator.onChanged = onChanged;
  }
  final T validator;
  final Set<DynamicVoid> _notifyListener = {};

  void onChanged([bool? n]) {
    _notifyChangePages(n ?? true);
  }

  void addPageChangedListener(DynamicVoid f) {
    _notifyListener.add(f);
  }

  void removePageChangedListener(DynamicVoid f) {
    _notifyListener.remove(f);
  }

  void _notifyChangePages(bool notifyPageListener) {
    notify();
    if (notifyPageListener) {
      for (final i in [..._notifyListener]) {
        i();
      }
    }
  }
}
