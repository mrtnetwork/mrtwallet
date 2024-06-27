import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:mrt_wallet/wallet/models/account/address/core/address.dart';
import 'package:mrt_wallet/wallet/models/account/address/derivation/derivation.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';

abstract class NewAccountParams {
  const NewAccountParams();
  abstract final CryptoCoins coin;
  abstract final AddressDerivationIndex deriveIndex;
  bool get isMultiSig;
  Bip32AddressCore toAccount(WalletNetwork network, List<int> publicKey);
}
