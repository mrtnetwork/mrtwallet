import 'package:mrt_wallet/wallet/models/account/address/core/address.dart';
import 'package:mrt_wallet/wallet/models/account/address/derivation/core/derivation.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/signing_request/core/signing_request.dart';

class Secp256k1SigningRequest<T> extends SigningRequest<T> {
  Secp256k1SigningRequest(
      {required this.address,
      required this.network,
      required List<int> transactionDigest})
      : transactionDigest = List<int>.unmodifiable(transactionDigest);

  final Bip32AddressCore address;
  final List<int> transactionDigest;
  bool get isMultiSig => address.multiSigAccount;
  @override
  final WalletNetwork network;

  @override
  List<CryptoAddress> get addresses => [address];

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
