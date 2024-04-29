import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:mrt_wallet/models/wallet_models/address/address.dart';

class BitcoinCashNewAddressParams
    implements NewAccountParams<BitcoinCashNewAddressParams> {
  BitcoinCashNewAddressParams({
    required this.deriveIndex,
    required this.bitcoinAddressType,
  });
  @override
  bool get isMultiSig => false;

  @override
  final AddressDerivationIndex deriveIndex;
  final BitcoinAddressType bitcoinAddressType;
  @override
  CryptoCoins get coin => deriveIndex.currencyCoin;
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
}
