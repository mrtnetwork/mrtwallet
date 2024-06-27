import 'package:bitcoin_base/bitcoin_base.dart' show BitcoinAddressType;
import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:mrt_wallet/wallet/models/account/address/derivation/derivation.dart';
import 'package:mrt_wallet/wallet/models/account/address/networks/bitcoin/bitcoin.dart';
import 'package:mrt_wallet/wallet/models/account/address/new/core/core.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';

class BitcoinNewAddressParams implements NewAccountParams {
  @override
  bool get isMultiSig => false;
  @override
  final AddressDerivationIndex deriveIndex;
  final BitcoinAddressType bitcoinAddressType;
  @override
  final CryptoCoins coin;

  const BitcoinNewAddressParams({
    required this.deriveIndex,
    required this.bitcoinAddressType,
    required this.coin,
  });

  @override
  IBitcoinAddress toAccount(WalletNetwork network, List<int> publicKey) {
    return IBitcoinAddress.newAccount(
        accountParams: this,
        publicKey: publicKey,
        network: network as WalletBitcoinNetwork);
  }
}

class BitcoinMultiSigNewAddressParams implements BitcoinNewAddressParams {
  const BitcoinMultiSigNewAddressParams({
    required this.bitcoinAddressType,
    required this.multiSignatureAddress,
    required this.coin,
  }) : deriveIndex = const MultiSigAddressIndex();

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
  IBitcoinAddress toAccount(WalletNetwork network, List<int> publicKey) {
    return IBitcoinMultiSigAddress.newAccount(
        accountParam: this, network: network as WalletBitcoinNetwork);
  }
}
