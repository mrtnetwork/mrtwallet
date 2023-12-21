import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/models/wallet_models/address/core/address.dart';
import 'package:mrt_wallet/models/wallet_models/address/core/derivation/address_derivation.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/models/wallet_models/signing_request/core/signing_request.dart';

class GlobalSigningReguest implements SigningRequest {
  GlobalSigningReguest({required this.addresses, required this.network});
  @override
  final List<CryptoAccountAddress> addresses;

  @override
  final AppNetworkImpl network;

  @override
  List<AddressDerivationIndex> get signers {
    if (network is AppXRPNetwork) {
      try {
        final MultiSigCryptoAccountAddress addr =
            addresses.first as MultiSigCryptoAccountAddress;
        return addr.keyDetails.map((e) => e.$2).toList();
      } catch (e) {
        throw WalletExceptionConst.invalidAccountDetails;
      }
    }
    throw UnimplementedError();
  }
}
