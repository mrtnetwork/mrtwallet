import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/models/wallet_models/address/core/bip/bip32_address_core.dart';
import 'package:mrt_wallet/models/wallet_models/address/core/derivation/address_derivation.dart';
import 'package:mrt_wallet/models/wallet_models/address/core/derivation/multi_sig_address_index.dart';
import 'package:mrt_wallet/models/wallet_models/address/network_address/xrp/mutlisig_address_details.dart';
import 'package:mrt_wallet/models/wallet_models/address/network_address/xrp/xrp_account.dart';
import 'package:mrt_wallet/models/wallet_models/address/new_address_params/core.dart';
import 'package:mrt_wallet/models/wallet_models/network/core/network.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

class RippleNewAddressParam implements NewAccountParams<RippleNewAddressParam> {
  @override
  bool get isMultiSig => false;

  EllipticCurveTypes get type => coin.conf.type;
  @override
  final AddressDerivationIndex deriveIndex;

  final int? tag;
  @override
  final CryptoCoins coin;
  const RippleNewAddressParam(
      {required this.deriveIndex, required this.coin, this.tag});

  @override
  Bip32AddressCore toAccount(AppNetworkImpl network, List<int> publicKey) {
    return IXRPAddress.newAccount(
        accountParams: this,
        publicKey: publicKey,
        network: network as AppXRPNetwork);
  }
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
  Bip32AddressCore toAccount(AppNetworkImpl network, List<int> publicKey) {
    return IXRPMultisigAddress.newAccount(
        accountParams: this, network: network as AppXRPNetwork);
  }

  @override
  EllipticCurveTypes get type => throw UnimplementedError();

  @override
  final CryptoCoins coin;
}
