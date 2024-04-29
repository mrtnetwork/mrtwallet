import 'package:bitcoin_base/bitcoin_base.dart' show BitcoinAddressType;
import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class BitcoinNewAddressParams
    implements NewAccountParams<BitcoinNewAddressParams> {
  @override
  bool get isMultiSig => false;
  @override
  final AddressDerivationIndex deriveIndex;
  final BitcoinAddressType bitcoinAddressType;
  @override
  CryptoCoins get coin => deriveIndex.currencyCoin;

  BitcoinNewAddressParams({
    required this.deriveIndex,
    required this.bitcoinAddressType,
  });
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
}
