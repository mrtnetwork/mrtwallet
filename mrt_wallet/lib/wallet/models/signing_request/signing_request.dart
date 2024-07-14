import 'package:mrt_wallet/wallet/models/account/address/core/address.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wroker/messages/request/requests/signing.dart';

typedef TestSigning<T> = Future<T> Function(OnSignRequest generateSignature);

class SigningRequest<T> {
  final List<CryptoAddress> addresses;
  final WalletNetwork network;
  final TestSigning<T> sign;
  const SigningRequest._(
      {required this.addresses, required this.network, required this.sign});
  factory SigningRequest(
      {required List<CryptoAddress> addresses,
      required WalletNetwork network,
      required TestSigning<T> sign}) {
    return SigningRequest._(addresses: addresses, network: network, sign: sign);
  }
}
