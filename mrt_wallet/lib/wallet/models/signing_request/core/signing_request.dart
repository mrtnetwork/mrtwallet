import 'package:mrt_wallet/wallet/models/account/address/core/address.dart';
import 'package:mrt_wallet/wallet/models/account/address/derivation/core/derivation.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';

abstract class SigningRequest<T> {
  abstract final List<CryptoAddress> addresses;
  abstract final List<AddressDerivationIndex> signers;
  abstract final WalletNetwork network;
}
