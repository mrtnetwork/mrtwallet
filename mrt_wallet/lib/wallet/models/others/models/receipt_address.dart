import 'package:mrt_wallet/app/euqatable/equatable.dart';
import 'package:mrt_wallet/wallet/models/chain/address/core/address.dart';
import 'package:mrt_wallet/wallet/models/contact/core/contract_core.dart';

class ReceiptAddress<NETWORKADDRESS> with Equatable {
  ReceiptAddress(
      {required this.view,
      this.type,
      this.contact,
      this.account,
      required this.networkAddress});
  final ContactCore<NETWORKADDRESS>? contact;
  final NETWORKCHAINACCOUNT<NETWORKADDRESS>? account;
  final NETWORKADDRESS networkAddress;
  final String view;
  final String? type;
  bool get hasContact => contact != null;
  bool get isAccount => account != null;

  @override
  List get variabels => [contact, account, networkAddress];
}
