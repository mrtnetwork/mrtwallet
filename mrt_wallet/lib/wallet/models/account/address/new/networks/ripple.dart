import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/wallet/models/account/address/core/address.dart';
import 'package:mrt_wallet/wallet/models/account/address/derivation/core/derivation.dart';
import 'package:mrt_wallet/wallet/models/account/address/derivation/derivation/multisig.dart';
import 'package:mrt_wallet/wallet/models/account/address/networks/xrp/addresses/multisig.dart';
import 'package:mrt_wallet/wallet/models/account/address/networks/xrp/addresses/xrp.dart';
import 'package:mrt_wallet/wallet/models/account/address/new/core/core.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

class RippleNewAddressParam implements NewAccountParams {
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
  Bip32AddressCore toAccount(WalletNetwork network, List<int> publicKey) {
    return IXRPAddress.newAccount(
        accountParams: this,
        publicKey: publicKey,
        network: network as WalletXRPNetwork);
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
  IXRPMultisigAddress toAccount(WalletNetwork network, List<int> publicKey) {
    return IXRPMultisigAddress.newAccount(
        accountParams: this, network: network as WalletXRPNetwork);
  }

  @override
  EllipticCurveTypes get type => throw UnimplementedError();

  @override
  final CryptoCoins coin;
}
