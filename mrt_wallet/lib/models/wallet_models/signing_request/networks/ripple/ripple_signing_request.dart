import 'package:mrt_wallet/models/wallet_models/address/address.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/models/wallet_models/signing_request/core/signing_request.dart';
import 'package:xrp_dart/xrp_dart.dart';

class RippleSigningRequest implements SigningRequest {
  RippleSigningRequest(
      {required this.addresses,
      required this.network,
      required this.transaction});
  @override
  final List<IXRPAddress> addresses;
  final XRPTransaction transaction;
  bool get isMultiSig => addresses.first.multiSigAccount;
  @override
  final AppNetworkImpl network;

  @override
  List<AddressDerivationIndex> get signers {
    if (isMultiSig) {
      final MultiSigCryptoAccountAddress addr =
          addresses.first as MultiSigCryptoAccountAddress;
      return addr.keyDetails.map((e) => e.$2).toList();
    }
    return [addresses.first.keyIndex];
  }

  List<String> get publicKeys {
    if (isMultiSig) {
      final MultiSigCryptoAccountAddress addr =
          addresses.first as MultiSigCryptoAccountAddress;
      return addr.keyDetails.map((e) => e.$1).toList();
    }
    return addresses.first.signers;
  }

  bool get needMultiSignature {
    if (isMultiSig) {
      final IXRPMultisigAddress addr = addresses.first as IXRPMultisigAddress;
      return !addr.multiSignatureAccount.isRegular;
    }
    return false;
  }
}
