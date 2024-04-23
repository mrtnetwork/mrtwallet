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

  SolanaTransaction _signSolanaTransaction(
      {required SolanaSigningRequest request, required List<int> password}) {
    WalletLogging.print("signers len ${request.signers.length}");
    for (int i = 0; i < request.signers.length; i++) {
      final signier = request.signers.elementAt(i);
      final addr = request.addresses.elementAt(i).networkAddress;
      final bipKey = _getPrivateKey(password, signier);
      final solanaPrivateKey = SolanaPrivateKey.fromSeed(bipKey.privateKey.raw);
      final signature =
          solanaPrivateKey.sign(request.solanaTransaction.serializeMessage());
      request.solanaTransaction.addSignature(addr, signature);
    }

    return request.solanaTransaction;
  }

  List<List<int>> _signCosmosTransaction(
      {required CosmosSigningRequest request, required List<int> password}) {
    final List<List<int>> signatures = [];
    for (int i = 0; i < request.signers.length; i++) {
      final bipKey = _getPrivateKey(password, request.signers.elementAt(i));
      final addr = request.addresses.elementAt(i);
      if (addr.coin.conf.type == EllipticCurveTypes.nist256p1) {
        final solanaPrivateKey =
            CosmosNist256p1PrivateKey.fromBytes(bipKey.privateKey.raw);
        signatures.add(solanaPrivateKey.sign(request.digest));
        continue;
      }
      final solanaPrivateKey =
          CosmosSecp256K1PrivateKey.fromBytes(bipKey.privateKey.raw);
      signatures.add(solanaPrivateKey.sign(request.digest));
    }
    return signatures;
  }

  ADATransaction _signCardanoTransaction(
      {required CardanoSigningRequest request, required List<int> password}) {
    try {
      return request.transaction.signAndBuildTransaction(
        ({required address, required digest}) {
          final signer = request.addresses.indexWhere(
              (element) => element.address.toAddress == address.address);
          if (signer < -1) {
            throw MessageException("Signer account does not found.",
                details: {"address": address.address});
          }
          final ICardanoAddress addr =
              request.addresses.elementAt(signer) as ICardanoAddress;
          final keyIndex = request.signers.elementAt(signer);
          final bipKey = _getPrivateKey(password, keyIndex,
              seedType: addr.addressDetails.seedGeneration);
          final adaPrivateKey = AdaPrivateKey.fromBytes(bipKey.privateKey.raw);
          if (address.addressType == ADAAddressType.byron) {
            return adaPrivateKey.createBootstrapWitness(
                digest: digest,
                address: address as ADAByronAddress,
                chainCode: bipKey.chainCode.toBytes());
          }
          return adaPrivateKey.createSignatureWitness(digest);
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
