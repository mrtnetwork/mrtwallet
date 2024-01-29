part of 'package:mrt_wallet/provider/wallet/wallet_provider.dart';

mixin Signer on MasterKeyImpl {
  BtcTransaction _signBitcoin(
      {required BitcoinSigningRequest request, required List<int> password}) {
    try {
      return request.transaction
          .buildTransaction((trDigest, utxo, publicKey, sighash) {
        try {
          final account = request.addresses
              .whereType<IBitcoinAddress>()
              .firstWhere((element) {
            return element.signers.contains(publicKey);
          });
          AddressDerivationIndex keyIndex = account.keyIndex;
          if (account.multiSigAccount) {
            final multiSignatureAddress =
                (account as BitcoinMultiSigBase).multiSignatureAddress;
            final correctSigner = multiSignatureAddress.signers
                .firstWhere((element) => element.publicKey == publicKey);
            keyIndex = correctSigner.keyIndex;
          }
          final prv = _getPrivateKey(password, keyIndex);
          final btcPrivateKey = ECPrivate.fromBytes(prv.privateKey.raw);
          if (utxo.utxo.isP2tr()) {
            return btcPrivateKey.signTapRoot(trDigest, sighash: sighash);
          }
          return btcPrivateKey.signInput(trDigest, sigHash: sighash);
        } on StateError {
          throw WalletExceptionConst.accountDoesNotFound;
        } catch (e) {
          rethrow;
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  void _signRipple(
      {required RippleSigningRequest request, required List<int> password}) {
    if (!request.needMultiSignature) {
      final keyIndex = request.signers.first;
      request.transaction.signingPubKey =
          RippleUtils.toRipplePublicKey(request.publicKeys.first);
      final prv = _getPrivateKey(password, keyIndex);
      final xrpPrivateKey = XRPPrivateKey.fromBytes(prv.privateKey.raw,
          algorithm: XRPKeyAlgorithm.values
              .firstWhere((element) => element.curveType == prv.curveType));
      final sig = xrpPrivateKey.sign(request.transaction.toBlob());
      request.transaction.setSignature(sig);
    } else {
      final multiSigAddress = request.addresses.first as IXRPMultisigAddress;
      final List<String> addressSigners = multiSigAddress.keyDetails
          .map((e) => RippleUtils.strPublicKeyToRippleAddress(e.$1).address)
          .toList();
      request.transaction.multiSigSigners = addressSigners;
      final List<XRPLSigners> signerSignatures = [];
      int threshHold = 0;
      for (final i in multiSigAddress.multiSignatureAccount.signers) {
        final address =
            RippleUtils.strPublicKeyToRippleAddress(i.publicKey).address;
        final blob = request.transaction.toMultisigBlob(address);
        try {
          final prv = _getPrivateKey(password, i.keyIndex);
          final xrpPrivateKey = XRPPrivateKey.fromBytes(prv.privateKey.raw,
              algorithm: XRPKeyAlgorithm.values
                  .firstWhere((element) => element.curveType == prv.curveType));
          final sig = xrpPrivateKey.sign(blob);
          signerSignatures.add(XRPLSigners(
              account: address,
              signingPubKey: xrpPrivateKey.getPublic().toHex(),
              txnSignature: sig));
          threshHold += i.weight;
          if (threshHold >= multiSigAddress.multiSignatureAccount.threshold) {
            break;
          }
        } catch (e) {
          continue;
        }
      }
      if (threshHold < multiSigAddress.multiSignatureAccount.threshold) {
        throw WalletExceptionConst.privateKeyIsNotAvailable;
      }

      request.transaction.setMultiSigSignature(signerSignatures);
    }
  }

  ETHSignature _signEthTransaction(
      {required Secp256k1SigningRequest request, required List<int> password}) {
    final bipKey = _getPrivateKey(password, request.signers.first);
    final ethPrivateKey = ETHPrivateKey.fromBytes(bipKey.privateKey.raw);
    return ethPrivateKey.sign(request.transactionDigest);
  }

  List<List<int>> _signTronTransaction(
      {required Secp256k1SigningRequest request, required List<int> password}) {
    if (request.isMultiSig) {
      final multiSigAddress = request.addresses.first as ITronMultisigAddress;
      final List<List<int>> signerSignatures = [];
      BigInt threshHold = BigInt.zero;
      for (final i in multiSigAddress.multiSignatureAccount.signers) {
        try {
          final bipKey = _getPrivateKey(password, i.keyIndex);
          final tronPrivateKey =
              TronPrivateKey.fromBytes(bipKey.privateKey.raw);
          final sig = tronPrivateKey.sign(request.transactionDigest);
          signerSignatures.add(List<int>.unmodifiable(sig));
          threshHold += i.weight;
          if (threshHold >= multiSigAddress.multiSignatureAccount.threshold) {
            break;
          }
        } catch (e) {
          continue;
        }
      }
      if (threshHold < multiSigAddress.multiSignatureAccount.threshold) {
        throw WalletExceptionConst.privateKeyIsNotAvailable;
      }
      return signerSignatures;
    }
    final bipKey = _getPrivateKey(password, request.signers.first);
    final tronPrivateKey = TronPrivateKey.fromBytes(bipKey.privateKey.raw);
    return [tronPrivateKey.sign(request.transactionDigest)];
  }
}
