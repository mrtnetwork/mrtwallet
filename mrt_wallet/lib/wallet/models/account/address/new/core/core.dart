import 'package:blockchain_utils/bip/bip/bip.dart';
import 'package:mrt_wallet/wallet/models/account/address/core/address.dart';
import 'package:mrt_wallet/wroker/derivation/derivation.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';

abstract class NewAccountParams {
  const NewAccountParams();
  abstract final CryptoCoins coin;
  abstract final AddressDerivationIndex deriveIndex;
  bool get isMultiSig;
  CryptoAddress toAccount(WalletNetwork network, List<int> publicKey);
}
