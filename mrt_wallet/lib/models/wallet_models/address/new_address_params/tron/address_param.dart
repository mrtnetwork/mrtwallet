import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:on_chain/on_chain.dart';

class TronNewAddressParam implements NewAccountParams {
  const TronNewAddressParam({required this.coin, required this.deriveIndex});
  @override
  bool get isMultiSig => false;
  @override
  final CryptoCoins coin;

  @override
  final AddressDerivationIndex deriveIndex;
}

class TronMultisigNewAddressParam implements TronNewAddressParam {
  const TronMultisigNewAddressParam(
      {required this.coin,
      required this.multiSigAccount,
      required this.masterAddress,
      this.deriveIndex = const MultiSigAddressIndex()});
  @override
  bool get isMultiSig => true;

  final TronAddress masterAddress;
  @override
  final CryptoCoins coin;
  @override
  final AddressDerivationIndex deriveIndex;

  final TronMultiSignatureAddress multiSigAccount;
}
