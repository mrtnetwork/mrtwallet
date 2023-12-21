import 'package:mrt_wallet/models/wallet_models/address/core/address.dart';
import 'package:mrt_wallet/models/wallet_models/address/core/derivation/address_derivation.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';

abstract class SigningRequest {
  abstract final List<CryptoAccountAddress> addresses;
  abstract final List<AddressDerivationIndex> signers;
  abstract final AppNetworkImpl network;
}
