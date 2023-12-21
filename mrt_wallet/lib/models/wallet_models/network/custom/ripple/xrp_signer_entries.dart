import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/models/wallet_models/address/address/crypto_address.dart';

class XRPSignerEntries {
  const XRPSignerEntries(
      {required this.address, required this.weight, this.walletLocator});
  final ReceiptAddress address;
  final BigRational weight;
  final String? walletLocator;
}
