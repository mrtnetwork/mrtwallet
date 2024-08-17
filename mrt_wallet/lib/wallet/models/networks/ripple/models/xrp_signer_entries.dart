import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/wallet/models/others/models/receipt_address.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

class XRPSignerEntries {
  const XRPSignerEntries(
      {required this.address, required this.weight, this.walletLocator});
  final ReceiptAddress<XRPAddress> address;
  final BigRational weight;
  final String? walletLocator;
}
