import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:blockchain_utils/signer/cosmos/cosmos_nist256r1_signer.dart';
import 'package:blockchain_utils/signer/cosmos/cosmos_signer.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/keys/access/key_data.dart';
import 'package:mrt_wallet/crypto/keys/access/key_request.dart';
import 'package:mrt_wallet/crypto/keys/models/master_key.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/core/message.dart';
import 'package:mrt_wallet/crypto/requets/messages/models/models/signing.dart';
import 'package:mrt_wallet/crypto/requets/messages/models/models/signing_response.dart';

class WalletRequestSign
    implements WalletRequest<GlobalSignResponse, MessageArgsOneBytes> {
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

  static GlobalSignResponse sign(
      {required CryptoPrivateKeyData key, required SignRequest request}) {
    final keyBytes = key.privateKeyBytes();
    List<int> signature;
    final List<int> digest = request.digest;
    final index = request.index;
    switch (request.network) {
      case SigningRequestNetwork.bitcoin:
        final BitcoinSigning bitcoinRequest = request as BitcoinSigning;
        // List<int> signature;
        final btcSigner = BitcoinSigner.fromKeyBytes(key.privateKeyBytes());
        if (bitcoinRequest.useTaproot) {
          List<int> sig = btcSigner.signSchnorrTransaction(digest,
              tapScripts: [], tweak: true);
          if (bitcoinRequest.sighash != 0x00) {
            sig = <int>[...sig, bitcoinRequest.sighash];
          }
          signature = sig;
        }
        final sig = btcSigner.signTransaction(digest);
        signature = [...sig, bitcoinRequest.sighash];
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
      case SigningRequestNetwork.cosmos:
        if (request.index.currencyCoin.conf.type ==
            EllipticCurveTypes.nist256p1) {
          final signer = CosmosNist256p1Signer.fromKeyBytes(keyBytes);
          signature = signer.sign(digest);
          break;
        }
        final signer = CosmosSigner.fromKeyBytes(keyBytes);
        signature = signer.sign(digest);
        break;
      case SigningRequestNetwork.eth:
        final ethsigner = ETHSigner.fromKeyBytes(keyBytes);
        signature = ethsigner.sign(digest).toBytes();
        break;
      case SigningRequestNetwork.stellar:
      case SigningRequestNetwork.ton:
      case SigningRequestNetwork.solana:
        final solanaSigner = SolanaSigner.fromKeyBytes(keyBytes);
        signature = solanaSigner.sign(digest);
        break;
      case SigningRequestNetwork.cardano:
        final cardaoSigner = CardanoSigner.fromKeyBytes(keyBytes);
        signature = cardaoSigner.sign(digest);
        break;
      case SigningRequestNetwork.substrate:
        final cardaoSigner =
            SubstrateSigner.fromBytes(keyBytes, key.coin.conf.type);
        signature = cardaoSigner.sign(digest);
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
    final key =
        wallet.readKeys([AccessCryptoPrivateKeyRequest(index: request.index)]);
    return sign(key: key.first, request: request);
  }
}
