import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';

class LiveTransactionValidator<T extends TransactionValidator> extends Live {
  LiveTransactionValidator({required this.validator}) : super(validator) {
    validator.onChanged = onChanged;
  }
  final T validator;

  void onChanged() {
    notify();
  }
}
