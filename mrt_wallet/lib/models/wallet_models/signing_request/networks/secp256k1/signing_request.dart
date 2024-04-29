import 'package:mrt_wallet/models/wallet_models/address/address.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/models/wallet_models/signing_request/core/signing_request.dart';

class Secp256k1SigningRequest implements SigningRequest {
  Secp256k1SigningRequest(
      {required this.address,
      required this.network,
      required List<int> transactionDigest})
      : transactionDigest = List<int>.unmodifiable(transactionDigest);

  final Bip32AddressCore address;
  final List<int> transactionDigest;
  bool get isMultiSig => address.multiSigAccount;
  @override
  final AppNetworkImpl network;

  @override
  List<CryptoAccountAddress> get addresses => [address];

  @override
  List<AddressDerivationIndex> get signers {
    if (isMultiSig) {
      final MultiSigCryptoAccountAddress addr =
          addresses.first as MultiSigCryptoAccountAddress;
      return addr.keyDetails.map((e) => e.$2).toList();
    }
    return [addresses.first.keyIndex];
  }
}
