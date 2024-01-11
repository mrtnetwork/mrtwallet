import 'package:mrt_wallet/models/wallet_models/address/address.dart';
import 'package:mrt_wallet/models/wallet_models/contact/contract_core.dart';

class ReceiptAddress<T> {
  ReceiptAddress(
      {required this.view,
      required this.type,
      this.contact,
      this.account,
      required this.networkAddress});
  final ContactCore? contact;
  final CryptoAccountAddress? account;
  final T networkAddress;
  final String view;
  final String? type;
  bool get hasContact => contact != null;
  bool get isAccount => account != null;
}
