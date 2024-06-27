import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:mrt_wallet/wallet/models/account/address/derivation/derivation.dart';
import 'package:mrt_wallet/wallet/models/account/address/networks/networks.dart';
import 'package:mrt_wallet/wallet/models/account/address/new/core/core.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';

class BitcoinCashNewAddressParams implements NewAccountParams {
  BitcoinCashNewAddressParams(
      {required this.deriveIndex,
      required this.bitcoinAddressType,
      required this.coin});
  @override
  bool get isMultiSig => false;

  @override
  final AddressDerivationIndex deriveIndex;
  final BitcoinAddressType bitcoinAddressType;
  @override
  final CryptoCoins coin;

  @override
  IBitcoinCashAddress toAccount(WalletNetwork network, List<int> publicKey) {
    return IBitcoinCashAddress.newAccount(
        accountParams: this,
        publicKey: publicKey,
        network: network as WalletBitcoinNetwork);
  }
}

class BitcoinCashMultiSigNewAddressParams
    implements BitcoinCashNewAddressParams {
  const BitcoinCashMultiSigNewAddressParams(
      {required this.bitcoinAddressType,
      required this.multiSignatureAddress,
      required this.coin})
      : deriveIndex = const MultiSigAddressIndex();

  @override
  final BitcoinAddressType bitcoinAddressType;
  final BitcoinMultiSignatureAddress multiSignatureAddress;

  @override
  final AddressDerivationIndex deriveIndex;
  @override
  bool get isMultiSig => true;

  @override
  final CryptoCoins coin;

  @override
  IBitcoinCashAddress toAccount(WalletNetwork network, List<int> publicKey) {
    return IBitcoinCashMultiSigAddress.newAccount(
        accountParam: this, network: network as WalletBitcoinNetwork);
  }
}
