import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/constant/const.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/crypto/crypto.dart';
import 'package:mrt_wallet/crypto/requets/messages/wallet/wallet.dart';

class WorkerMessageConst {
  static const List<int> workerMessagResponse = [2, 24, 4, 26];
  static const List<int> encryptedMessage = [0, 1, 2, 3];
  static const List<int> cryptoRequest = [104, 0, 0, 0];
  static const List<int> walletRequest = [105, 0, 0, 0];
}

enum CryptoMessageType {
  cryptoRequest(WorkerMessageConst.cryptoRequest),
  walletRequest(WorkerMessageConst.walletRequest);

  final List<int> tag;
  const CryptoMessageType(this.tag);
  static CryptoMessageType fromTag(List<int> tag) {
    return values.firstWhere(
        (element) => BytesUtils.bytesEqual(tag, element.tag),
        orElse: () => throw WalletExceptionConst.dataVerificationFailed);
  }
}

enum CryptoRequestMethod {
  encryptChacha(CryptoKeyConst.encryptChacha),
  decryptChacha(CryptoKeyConst.decryptChacha),
  generateMnemonic(CryptoKeyConst.generateToneMenemonic),
  tonMnemonicToPrivateKey(CryptoKeyConst.tonMnemonicToPrivateKey),
  generateMasterKey(CryptoKeyConst.generateMasterKey),
  readMasterKey(CryptoKeyConst.readEncryptedMasterKey),
  createMasterKey(CryptoKeyConst.createMasterKey),
  createWallet(CryptoKeyConst.createWallet),
  decodeBackup(CryptoKeyConst.decodeBackup),
  encodeBackup(CryptoKeyConst.encodeBackup),
  generateBip39Mnemonic(CryptoKeyConst.generateBip39Mnemonic),
  walletKey(CryptoKeyConst.walletKey),
  randomGenerator(CryptoKeyConst.randomGenerator),
  hexToBytes(CryptoKeyConst.hexToBytes),
  hashing(CryptoKeyConst.hashing),
  setupMasterKey(CryptoKeyConst.setupMasterKey);

  final List<int> tag;
  const CryptoRequestMethod(this.tag);
  static CryptoRequestMethod fromTag(List<int>? tag) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(e.tag, tag),
        orElse: () => throw WalletExceptionConst.invalidRequest);
  }
}

enum WalletRequestMethod {
  signMessage(CryptoKeyConst.ethereumPersonalSign),
  ethereumTypedDataSign(CryptoKeyConst.ethereumTypedDataSign),
  deriveAddress(CryptoKeyConst.deriveAddress),
  readPublicKeys(CryptoKeyConst.readPublicKeys),
  readPrivateKeys(CryptoKeyConst.readPrivateKeys),
  readImportKey(CryptoKeyConst.readImportKey),
  readMnemonic(CryptoKeyConst.readMnemonic),
  updateWalletKeys(CryptoKeyConst.updateWalletKeys),
  removeWalletKeys(CryptoKeyConst.removeWalletKeys),
  walletBackup(CryptoKeyConst.walletBackup),
  sign(CryptoKeyConst.sign);

  final List<int> tag;
  const WalletRequestMethod(this.tag);
  static WalletRequestMethod fromTag(List<int>? tag) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(e.tag, tag),
        orElse: () => throw WalletExceptionConst.invalidRequest);
  }
}

abstract class CryptoRequest<T, A extends MessageArgs>
    implements MessageArgsCompleter<T, A> {
  abstract final CryptoRequestMethod method;

  factory CryptoRequest.deserialize({List<int>? bytes, CborObject? object}) {
    final CborTagValue decode =
        CborSerializable.decode(cborBytes: bytes, object: object);
    final request = CryptoRequestMethod.fromTag(decode.tags);
    final CryptoRequest args;
    switch (request) {
      case CryptoRequestMethod.encryptChacha:
        args = CryptoRequestEncryptChacha.deserialize(object: decode);
        break;
      case CryptoRequestMethod.decryptChacha:
        args = CryptoRequestDecryptChacha.deserialize(object: decode);
        break;
      case CryptoRequestMethod.generateMnemonic:
        args = TonMenmonicGenerateMessage.deserialize(object: decode);
        break;
      case CryptoRequestMethod.tonMnemonicToPrivateKey:
        args = TonMnemonicToPrivateKeyMessage.deserialize(object: decode);
        break;
      case CryptoRequestMethod.generateMasterKey:
        args = CryptoRequestGenerateMasterKey.deserialize(object: decode);
        break;
      case CryptoRequestMethod.readMasterKey:
        args = CryptoRequestReadMasterKey.deserialize(object: decode);
        break;
      case CryptoRequestMethod.createMasterKey:
        args = CryptoRequestCreateMasterKey.deserialize(object: decode);
        break;
      case CryptoRequestMethod.createWallet:
        args = CryptoRequestCreateHDWallet.deserialize(object: decode);
        break;

      case CryptoRequestMethod.decodeBackup:
        args = CryptoRequestDecodeBackup.deserialize(object: decode);
        break;
      case CryptoRequestMethod.encodeBackup:
        args = CryptoRequestEncodeBackup.deserialize(object: decode);
        break;
      case CryptoRequestMethod.generateBip39Mnemonic:
        args = CryptoRequestGenerateBip39Mnemonic.deserialize(object: decode);
        break;
      case CryptoRequestMethod.walletKey:
        args = CryptoRequestWalletKey.deserialize(object: decode);
        break;
      case CryptoRequestMethod.randomGenerator:
        args = CryptoRequestRandomGenerator.deserialize(object: decode);
        break;
      case CryptoRequestMethod.hexToBytes:
        args = CryptoRequestHexToBytes.deserialize(object: decode);
        break;
      case CryptoRequestMethod.hashing:
        args = CryptoRequestHashing.deserialize(object: decode);
        break;
      case CryptoRequestMethod.setupMasterKey:
        args = CryptoRequestSetupMasterKey.deserialize(object: decode);
        break;
      default:
        throw WalletExceptionConst.invalidRequest;
    }
    if (args is! CryptoRequest<T, A>) {
      throw WalletExceptionConst.invalidArgruments(
          "${CryptoRequest<T, A>}", "${args.runtimeType}");
    }
    return args;
  }
}

abstract class WalletRequest<T, A extends MessageArgs>
    implements WalletMessageArgsCompleter<T, A> {
  abstract final WalletRequestMethod method;

  factory WalletRequest.deserialize({List<int>? bytes, CborObject? object}) {
    final CborTagValue decode =
        CborSerializable.decode(cborBytes: bytes, object: object);
    final request = WalletRequestMethod.fromTag(decode.tags);
    final WalletRequest args;
    switch (request) {
      case WalletRequestMethod.signMessage:
        args = WalletRequestSignMessage.deserialize(object: decode);
        break;
      case WalletRequestMethod.ethereumTypedDataSign:
        args = WalletRequestEthereumTypedDataSign.deserialize(object: decode);
        break;
      case WalletRequestMethod.deriveAddress:
        args = WalletRequestDeriveAddress.deserialize(object: decode);
        break;
      case WalletRequestMethod.readPublicKeys:
        args = WalletRequestReadPublicKeys.deserialize(object: decode);
        break;
      case WalletRequestMethod.readPrivateKeys:
        args = WalletRequestReadPrivateKeys.deserialize(object: decode);
        break;
      case WalletRequestMethod.readMnemonic:
        args = WalletRequestReadMnemonic.deserialize(object: decode);
        break;
      case WalletRequestMethod.updateWalletKeys:
        args = WalletRequestImportNewKey.deserialize(object: decode);
        break;
      case WalletRequestMethod.removeWalletKeys:
        args = WalletRequestRemoveKey.deserialize(object: decode);
        break;
      case WalletRequestMethod.sign:
        args = WalletRequestSign.deserialize(object: decode);
        break;
      case WalletRequestMethod.readImportKey:
        args = WalletRequestReadImportedKey.deserialize(object: decode);
        break;
      case WalletRequestMethod.walletBackup:
        args = WalletRequestBackupWallet.deserialize(object: decode);
        break;
      default:
        throw WalletExceptionConst.invalidRequest;
    }
    if (args is! WalletRequest<T, A>) {
      throw WalletExceptionConst.invalidArgruments(
          "${WalletRequest<T, A>}", "${args.runtimeType}");
    }
    return args;
  }
}
