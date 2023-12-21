import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:bitcoin_base/bitcoin_base.dart' show BitcoinAddressType;
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';

class BitcoinNewAddressParams implements NewAccountParams {
  const BitcoinNewAddressParams(
      {required this.coin,
      required this.deriveIndex,
      required this.bitcoinAddressType});
  @override
  bool get isMultiSig => false;

  @override
  final CryptoCoins coin;

  @override
  final AddressDerivationIndex deriveIndex;

  final BitcoinAddressType bitcoinAddressType;
}

class BitcoinMultiSigNewAddressParams implements BitcoinNewAddressParams {
  BitcoinMultiSigNewAddressParams(
      {required this.coin,
      required this.bitcoinAddressType,
      required this.multiSignatureAddress,
      this.deriveIndex = const MultiSigAddressIndex()});
  @override
  final CryptoCoins coin;
  @override
  final BitcoinAddressType bitcoinAddressType;
  final BitcoinMultiSignatureAddress multiSignatureAddress;

  @override
  AddressDerivationIndex deriveIndex;
  @override
  bool get isMultiSig => true;
}
