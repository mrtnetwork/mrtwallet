import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:mrt_wallet/models/wallet_models/address/core/derivation/address_derivation.dart';
import 'package:mrt_wallet/models/wallet_models/address/core/derivation/multi_sig_address_index.dart';
import 'package:mrt_wallet/models/wallet_models/address/network_address/bitcoin/multisig_address_details.dart';
import 'package:mrt_wallet/models/wallet_models/address/new_address_params/core.dart';

class BitcoinCashNewAddressParams implements NewAccountParams {
  const BitcoinCashNewAddressParams({
    required this.coin,
    required this.deriveIndex,
    required this.bitcoinAddressType,
  });
  @override
  bool get isMultiSig => false;
  @override
  final CryptoCoins coin;
  @override
  final AddressDerivationIndex deriveIndex;
  final BitcoinAddressType bitcoinAddressType;
}

class BitcoinCashMultiSigNewAddressParams
    implements BitcoinCashNewAddressParams {
  const BitcoinCashMultiSigNewAddressParams({
    required this.coin,
    required this.bitcoinAddressType,
    required this.multiSignatureAddress,
  }) : deriveIndex = const MultiSigAddressIndex();

  @override
  final CryptoCoins coin;
  @override
  final BitcoinAddressType bitcoinAddressType;
  final BitcoinMultiSignatureAddress multiSignatureAddress;

  @override
  final AddressDerivationIndex deriveIndex;
  @override
  bool get isMultiSig => true;
}
