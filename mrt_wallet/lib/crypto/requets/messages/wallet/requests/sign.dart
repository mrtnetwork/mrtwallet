import 'package:bitcoin_base/bitcoin_base.dart' show TaprootUtils;
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:monero_dart/monero_dart.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/crypto/keys/access/key_data.dart';
import 'package:mrt_wallet/crypto/keys/access/key_request.dart';
import 'package:mrt_wallet/crypto/keys/access/monero_private_key.dart';
import 'package:mrt_wallet/crypto/keys/models/master_key.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';
import 'package:mrt_wallet/crypto/requets/messages/models/models/signing.dart';
import 'package:mrt_wallet/crypto/requets/messages/models/models/signing_response.dart';
import 'package:mrt_wallet/wallet/models/networks/monero/monero.dart';

class WalletRequestSign
    extends WalletRequest<GlobalSignResponse, MessageArgsOneBytes> {
  final SignRequest request;
  WalletRequestSign(this.request);

  factory WalletRequestSign.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: WalletRequestMethod.sign.tag);
    return WalletRequestSign(
        SignRequest.deserialize(object: values.getCborTag(0)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([request.toCbor()]), method.tag);
  }

  @override
  WalletRequestMethod get method => WalletRequestMethod.sign;
  static GlobalSignResponse cosmosSigning(
      {required CryptoPrivateKeyData key,
      required CosmosSigningRequest request}) {
    final signer = CosmosPrivateKey.fromBytes(
        algorithm: request.alg, keyBytes: key.privateKeyBytes());
    final signature = signer.sign(request.digest);
    return GlobalSignResponse(
        signature: signature,
        index: request.index,
        signerPubKey: key.publicKey);
  }

  static GlobalSignResponse moneroSigning(
      {required CryptoPrivateKeyData key,
      required MoneroSigningRequest request}) {
    final MoneroPrivateKeyData moneroKey = key.cast();
    final indexes = request.getAccountsIndexes();
    final moneroKeys = MoneroAccountKeys(
        account: moneroKey.toMoneroAccount(),
        network: MoneroNetwork.stagenet,
        indexes: indexes);
    final spendablePayment = request.utxos.map((e) {
      final unlockedPayment = MoneroTransactionHelper.toUnlockPayment(
          account: moneroKeys, lockedOut: e.payment);
      if (unlockedPayment == null) {
        throw const WalletException("failed_to_unlock_output");
      }
      return e.updatePayment(unlockedPayment);
    }).toList();
    final tx = MoneroRctTxBuilder(
        account: moneroKeys,
        destinations: request.destinations,
        sources: spendablePayment,
        fee: request.fee,
        change: request.change);
    final ser = tx.serialize();
    final decode = MoneroRctTxBuilder.deserialize(ser);
    assert(tx.serializeHex() == decode.serializeHex(), "failed deserialize tx");
    final List<MoneroTxDestination> currentDestinations = [
      ...tx.destinations,
    ];
    final signingResponse = MoneroSigningTxResponse(
        txData: MoneroSignedTxData(
            txID: tx.txId,
            txKeys: tx.destinationKeys.allTxKeys,
            indexes: indexes),
        proofs: currentDestinations.map((e) {
          return MoneroTxDestinationWithProof(
              address: e.address,
              amount: e.amount,
              proof: tx
                  .generateProof(receiverAddress: e.address, message: null)
                  .toBase58());
        }).toList(),
        txHex: tx.transaction.serializeHex());
    return GlobalSignResponse(
        signature: signingResponse.toCbor().encode(),
        index: request.index,
        signerPubKey: moneroKey.publicKey);
  }

  static GlobalSignResponse globalSigning(
      {required CryptoPrivateKeyData key, required GlobalSignRequest request}) {
    final keyBytes = key.privateKeyBytes();
    List<int> signature;
    final List<int> digest = request.digest;
    final index = request.index;
    switch (request.network) {
      case SigningRequestNetwork.bitcoinCash:
        final BitcoinSigning bitcoinRequest = request.cast();
        final btcSigner = BitcoinKeySigner.fromKeyBytes(key.privateKeyBytes());
        List<int> sig;
        if (bitcoinRequest.useBchSchnorr) {
          sig = btcSigner.signSchnorr(digest);
        } else {
          sig = btcSigner.signECDSADer(digest);
        }
        signature = [...sig, bitcoinRequest.sighash];
        return GlobalSignResponse(
            signature: signature, index: index, signerPubKey: key.publicKey);
      case SigningRequestNetwork.bitcoin:
        final BitcoinSigning bitcoinRequest = request.cast();
        final btcSigner = BitcoinKeySigner.fromKeyBytes(key.privateKeyBytes());
        if (bitcoinRequest.useTaproot) {
          final taptweak = TaprootUtils.calculateTweek(
              btcSigner.verifierKey.publicKeyPoint().toXonly());
          List<int> schnorrSignature =
              btcSigner.signBip340(digest: digest, tapTweakHash: taptweak);
          if (bitcoinRequest.sighash != 0x00) {
            schnorrSignature = [...schnorrSignature, bitcoinRequest.sighash];
          }
          signature = schnorrSignature;
        } else {
          final sig = btcSigner.signECDSADer(digest);
          signature = [...sig, bitcoinRequest.sighash];
        }
        return GlobalSignResponse(
            signature: signature, index: index, signerPubKey: key.publicKey);
      case SigningRequestNetwork.tron:
        final signer = TronSigner.fromKeyBytes(keyBytes);
        signature = signer.sign(digest);
        break;
      case SigningRequestNetwork.ripple:
        final signer = XrpSigner.fromKeyBytes(
            keyBytes, request.index.currencyCoin.conf.type);
        signature = signer.sign(digest);
        break;

      case SigningRequestNetwork.eth:
        final ethsigner = ETHSigner.fromKeyBytes(keyBytes);
        signature = ethsigner.sign(digest).toBytes();
        break;
      case SigningRequestNetwork.aptos:
        switch (key.coin) {
          case Bip44Coins.aptos:
          case Bip44Coins.aptosEd25519SingleKey:
            final ed25519Signer = Ed25519Signer.fromKeyBytes(keyBytes);
            signature = ed25519Signer.sign(digest);
            break;
          case Bip44Coins.aptosSecp256k1SingleKey:
            final digestHash = QuickCrypto.sha3256Hash(digest);
            final secp256k1Signer = Secp256k1Signer.fromKeyBytes(keyBytes);
            signature = secp256k1Signer.sign(digestHash, hashMessage: false);
            break;
          default:
            throw WalletExceptionConst.invalidCoin;
        }
        break;
      case SigningRequestNetwork.sui:
        switch (key.coin) {
          case Bip44Coins.sui:
            final ed25519signer = Ed25519Signer.fromKeyBytes(keyBytes);
            signature = ed25519signer.sign(digest);
            break;
          case Bip44Coins.suiSecp256k1:
            final secp256k1Signer = Secp256k1Signer.fromKeyBytes(keyBytes);
            signature = secp256k1Signer.sign(digest);
            break;
          case Bip44Coins.suiSecp256r1:
            final secp256r1Signer = Nist256p1Signer.fromKeyBytes(keyBytes);
            signature = secp256r1Signer.sign(digest);
            break;
          default:
            throw WalletExceptionConst.invalidCoin;
        }
        break;
      case SigningRequestNetwork.stellar:
      case SigningRequestNetwork.ton:
      case SigningRequestNetwork.solana:
        final solanaSigner = Ed25519Signer.fromKeyBytes(keyBytes);
        signature = solanaSigner.sign(digest);
        break;
      case SigningRequestNetwork.cardano:
        final cardanoSigner = CardanoSigner.fromKeyBytes(keyBytes);
        signature = cardanoSigner.sign(digest);
        break;
      case SigningRequestNetwork.substrate:
        switch (key.coin) {
          case Bip44Coins.ethereum:
          case Bip44Coins.ethereumTestnet:
            final signer = ETHSigner.fromKeyBytes(keyBytes);
            signature = signer.sign(digest).toBytes();
            break;
          default:
            final substrateSigner =
                SubstrateSigner.fromBytes(keyBytes, key.coin.conf.type);
            signature = substrateSigner.sign(digest);
            break;
        }
        break;
      default:
        throw WalletExceptionConst.dataVerificationFailed;
    }
    return GlobalSignResponse(
        signature: signature, index: index, signerPubKey: key.publicKey);
  }

  @override
  MessageArgsOneBytes getResult(
      {required WalletMasterKeys wallet, required List<int> key}) {
    final sign = result(wallet: wallet, key: key);
    return MessageArgsOneBytes(keyOne: sign.toCbor().encode());
  }

  @override
  GlobalSignResponse parsResult(MessageArgsOneBytes result) {
    return GlobalSignResponse.deserialize(result.keyOne);
  }

  @override
  GlobalSignResponse result(
      {required WalletMasterKeys wallet, required List<int> key}) {
    final key = wallet
        .readKeys([AccessCryptoPrivateKeyRequest(index: request.index)]).first;
    return switch (request.network) {
      SigningRequestNetwork.monero =>
        moneroSigning(key: key, request: request.cast()),
      SigningRequestNetwork.cosmos =>
        cosmosSigning(key: key, request: request.cast()),
      _ => globalSigning(key: key, request: request.cast())
    };
  }
}
