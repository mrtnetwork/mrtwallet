import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/models/wallet_models/address/core/derivation/address_derivation.dart';
import 'package:mrt_wallet/models/wallet_models/address/core/derivation/multi_sig_address_index.dart';
import 'package:mrt_wallet/models/wallet_models/address/network_address/xrp/mutlisig_address_details.dart';
import 'package:mrt_wallet/models/wallet_models/address/new_address_params/core.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

class RippleNewAddressParam implements NewAccountParams<RippleNewAddressParam> {
  @override
  bool get isMultiSig => false;

  final EllipticCurveTypes type;
  @override
  final AddressDerivationIndex deriveIndex;

  final int? tag;
  @override
  CryptoCoins get coin => deriveIndex.currencyCoin;

  RippleNewAddressParam({
    required this.deriveIndex,
    this.tag,
    required this.type,
  });
}

class RippleMultisigNewAddressParam implements RippleNewAddressParam {
  const RippleMultisigNewAddressParam(
      {required this.multiSigAccount,
      required this.masterAddress,
      required this.coin,
      this.tag,
      this.deriveIndex = const MultiSigAddressIndex()});
  @override
  bool get isMultiSig => true;

  final XRPAddress masterAddress;

  @override
  final AddressDerivationIndex deriveIndex;

  final RippleMultiSignatureAddress multiSigAccount;

  @override
  final int? tag;

  @override
  EllipticCurveTypes get type => throw UnimplementedError();

  @override
  final CryptoCoins coin;
}
