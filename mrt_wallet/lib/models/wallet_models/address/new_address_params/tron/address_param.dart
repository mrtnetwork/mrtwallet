import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:on_chain/on_chain.dart';

class TronNewAddressParam implements NewAccountParams<SolanaNewAddressParam> {
  TronNewAddressParam({required this.deriveIndex, List<int>? publicKey});

  @override
  bool get isMultiSig => false;

  @override
  final AddressDerivationIndex deriveIndex;
  @override
  CryptoCoins get coin => deriveIndex.currencyCoin;
}

class TronMultisigNewAddressParam implements TronNewAddressParam {
  const TronMultisigNewAddressParam(
      {required this.multiSigAccount,
      required this.masterAddress,
      required this.coin,
      this.deriveIndex = const MultiSigAddressIndex()});
  @override
  bool get isMultiSig => true;

  final TronAddress masterAddress;

  @override
  final AddressDerivationIndex deriveIndex;

  final TronMultiSignatureAddress multiSigAccount;
  @override
  final CryptoCoins coin;
}
