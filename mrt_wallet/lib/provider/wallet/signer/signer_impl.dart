part of 'package:mrt_wallet/provider/wallet/wallet_provider.dart';

mixin Signer on MasterKeyImpl {
  BtcTransaction _signBitcoin(
      {required BitcoinTransactionBuilder builder,
      required List<Bip32AddressCore> accouts,
      required List<int> password}) {
    return builder.buildTransaction((trDigest, utxo, publicKey) {
      try {
        final account =
            accouts.whereType<IBitcoinAddress>().firstWhere((element) {
          return element.signers.contains(publicKey);
        });
        AddressDerivationIndex keyIndex = account.keyIndex;
        if (account.isMultiSigAccounts) {
          account as IBitcoinMultiSigAddress;
          final correctSigner = account.multiSignatureAddress.signers
              .firstWhere((element) => element.publicKey == publicKey);
          keyIndex = correctSigner.keyIndex;
        }
        final prv = _getPrivateKey(password, keyIndex);
        final btcPrivateKey = ECPrivate.fromBytes(prv);
        if (utxo.utxo.isP2tr()) {
          return btcPrivateKey.signTapRoot(trDigest);
        }
        return btcPrivateKey.signInput(trDigest);
      } on StateError {
        throw WalletExceptionConst.accountDoesNotFound;
      } catch (e) {
        rethrow;
      }
    });
  }
}
