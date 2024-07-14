import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/models/account/address/core/address.dart';
import 'package:mrt_wallet/wallet/models/contact/core/contract_core.dart';

class ReceiptAddress<T> with Equatable {
  ReceiptAddress(
      {required this.view,
      required this.type,
      this.contact,
      this.account,
      required this.networkAddress});
  final ContactCore? contact;
  final CryptoAddress? account;
  final T networkAddress;
  final String view;
  final String? type;
  bool get hasContact => contact != null;
  bool get isAccount => account != null;

  @override
  List get variabels => [contact, account, networkAddress];
}
