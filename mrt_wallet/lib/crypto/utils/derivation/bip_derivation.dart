import 'package:blockchain_utils/bip/bip/bip.dart';
import 'package:blockchain_utils/bip/substrate/conf/substrate_coins.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/wallet/models/chain/address/core/address.dart';
import 'package:mrt_wallet/crypto/coins/custom_coins/coins.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:mrt_wallet/crypto/keys/models/seed.dart';

class BipDerivationUtils {
  static const String substrateBaseAccount = "//44//60//0/0/";
  static AddressDerivationIndex generateAccountNextKeyIndex(
      {required CryptoCoins coin,
      required List<ChainAccount> addresses,
      required SeedTypes seedGenerationType,
      int? coinType}) {
    if (coin.proposal == SubstratePropoosal.substrate) {
      return findNextSubstratePath(
          coin: coin as SubstrateCoins, addresses: addresses);
    }
    if (coin.proposal == CustomProposal.cip0019) {
      return findNextByronLegacyIndex(coin: coin, addresses: addresses);
    }
    return findNextBip32Index(
        coin: coin as BipCoins,
        addresses: addresses,
        seedGenerationType: seedGenerationType,
        coinType: coinType);
  }

  static Bip32AddressIndex findNextBip32Index(
      {required BipCoins coin,
      required List<ChainAccount> addresses,
      required SeedTypes seedGenerationType,
      int? coinType}) {
    final List<Bip32AddressIndex> existsIndexes = addresses
        .map((e) => e.keyIndex)
        .whereType<Bip32AddressIndex>()
        .toList();
    final int purposeIndex = coin.proposal.purpose.index;
    final int coinIndex =
        Bip32KeyIndex.hardenIndex(coinType ?? coin.conf.coinIdx).index;
    final def = Bip32PathParser.parse(coin.conf.defPath);
    if (def.elems.isEmpty) {
      throw WalletException("Invalid_coin_default_path");
    }

    List<int?> indexKeyes = List.from([
      def.elems.elementAtOrNull(0)!.index,
      def.elems.elementAtOrNull(1)?.index,
      def.elems.elementAtOrNull(2)?.index,
    ], growable: false);
    int? getCorrectIndex(int elemIndex, int elemValidIndex, int index) {
      if (elemIndex == elemValidIndex) return index;
      return indexKeyes[elemIndex];
    }

    final validIndex = indexKeyes.lastIndexWhere((element) => element != null);
    final startIndex = def.elems.elementAt(validIndex).index;
    for (int i = startIndex; i < Bip32KeyDataConst.keyIndexMaxVal; i++) {
      final newKeyIndex = Bip32AddressIndex(
          purpose: purposeIndex,
          coin: coinIndex,
          accountLevel: getCorrectIndex(0, validIndex, i),
          changeLevel: getCorrectIndex(1, validIndex, i),
          addressIndex: getCorrectIndex(2, validIndex, i),
          currencyCoin: coin,
          seedGeneration: seedGenerationType);
      if (!existsIndexes.contains(newKeyIndex)) {
        return newKeyIndex;
      }
    }
    throw WalletExceptionConst.tooManyAccounts;
  }

  static Bip32AddressIndex findNextByronLegacyIndex({
    required CryptoCoins coin,
    required List<ChainAccount> addresses,
  }) {
    final List<Bip32AddressIndex> addressIndex = addresses
        .map((e) => e.keyIndex)
        .whereType<Bip32AddressIndex>()
        .toList();

    for (int i = 0; i < Bip32KeyDataConst.keyIndexMaxVal; i++) {
      final newKeyIndex = Bip32AddressIndex.byronLegacy(
          firstIndex: 0, secoundIndex: i, currencyCoin: coin);
      if (!addressIndex.contains(newKeyIndex)) {
        return newKeyIndex;
      }
    }
    throw WalletExceptionConst.tooManyAccounts;
  }

  static SubstrateAddressIndex findNextSubstratePath({
    required SubstrateCoins coin,
    required List<ChainAccount> addresses,
  }) {
    final List<SubstrateAddressIndex> addressIndex = addresses
        .map((e) => e.keyIndex)
        .whereType<SubstrateAddressIndex>()
        .toList();

    for (int i = 0; i < Bip32KeyDataConst.keyIndexMaxVal; i++) {
      final newKeyIndex = SubstrateAddressIndex(
          currencyCoin: coin, substratePath: "$substrateBaseAccount$i");
      if (!addressIndex.contains(newKeyIndex)) {
        return newKeyIndex;
      }
    }
    throw WalletExceptionConst.tooManyAccounts;
  }
}
