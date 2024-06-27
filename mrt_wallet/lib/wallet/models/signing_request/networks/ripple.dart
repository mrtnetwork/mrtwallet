import 'package:mrt_wallet/wallet/models/account/account.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/signing_request/core/signing_request.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

class RippleSigningRequest extends SigningRequest<XRPTransaction> {
  RippleSigningRequest(
      {required this.addresses,
      required this.network,
      required this.transaction});
  @override
  final List<IXRPAddress> addresses;
  final XRPTransaction transaction;
  bool get isMultiSig => addresses.first.multiSigAccount;
  @override
  final WalletNetwork network;

  @override
  List<AddressDerivationIndex> get signers {
    if (isMultiSig) {
      final MultiSigCryptoAccountAddress addr =
          addresses.first as MultiSigCryptoAccountAddress;
      return addr.keyDetails.map((e) => e.$2).toList();
    }
    return [addresses.first.keyIndex];
  }

  bool get needMultiSignature {
    if (isMultiSig) {
      final IXRPMultisigAddress addr = addresses.first as IXRPMultisigAddress;
      return !addr.multiSignatureAccount.isRegular;
    }
    return false;
  }
}
