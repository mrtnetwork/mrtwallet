import 'dart:async';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/constant/tags.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/messages/crypto/crypto.dart';
import 'package:mrt_wallet/crypto/requets/messages/non_encrypted/requests.dart';
import 'package:mrt_wallet/crypto/requets/messages/non_encrypted/requests/test.dart';
import 'package:mrt_wallet/crypto/requets/messages/stream/requests/monero_block_tracking.dart';
import 'package:mrt_wallet/crypto/requets/messages/stream/stream.dart';
import 'package:mrt_wallet/crypto/requets/messages/wallet/wallet.dart';

class WorkerMessageConst {
  static const List<int> workerMessagResponse = [2, 24, 4, 26];
  static const List<int> encryptedMessage = [0, 1, 2, 3];
  static const List<int> workerMessageRequest = [104, 0, 0, 0];
  static const List<int> noneEncryptedMessage = [0, 3, 2, 1];
  static const List<int> cborMessage = [0, 3, 2, 2];
}

enum CryptoRequestMethod {
  encryptChacha(CryptoKeyConst.encryptChacha),
  decryptChacha(CryptoKeyConst.decryptChacha),
  generateMnemonic(CryptoKeyConst.generateToneMenemonic),
  tonMnemonicToPrivateKey(CryptoKeyConst.tonMnemonicToPrivateKey),
  generateMoneroMnemonic(CryptoKeyConst.generateMoneroMnemonic),
  moneroMnemonicToPrivateKey(CryptoKeyConst.moneroMnemonicToPrivateKey),
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
  setupMasterKey(CryptoKeyConst.setupMasterKey),

  moneroAccountTxesTracker(CryptoKeyConst.moneroAccountTexesTracker);

  final List<int> _tag;
  const CryptoRequestMethod(this._tag);
  List<int> get tag => [...ArgsType.crypto.tag, ..._tag];
  static CryptoRequestMethod fromTag(List<int>? tag) {
    return values.firstWhere(
        (e) => BytesUtils.bytesEqual(e._tag, tag?.sublist(ArgsType.tagLength)),
        orElse: () => throw WalletExceptionConst.invalidRequest);
  }
}

enum NoneEncryptedCryptoRequestMethod {
  moneroFakeTx(CryptoKeyConst.moneroFakeTx),
  generateRingOutput(CryptoKeyConst.moneroGenerateRingOutput),
  hexToBytes(CryptoKeyConst.hexToBytes),
  hashing(CryptoKeyConst.hashing),
  moneroGenerateProof(CryptoKeyConst.moneroGenerateProof),
  moneroVerifyProof(CryptoKeyConst.moneroVerifyProof),
  cbor(CryptoKeyConst.cbor),
  substrateReadApi(CryptoKeyConst.substrateReadApi),

  test([0, 0, 0, 1]);

  final List<int> _tag;
  List<int> get tag => [...ArgsType.nonEncrypted.tag, ..._tag];
  const NoneEncryptedCryptoRequestMethod(this._tag);
  static NoneEncryptedCryptoRequestMethod fromTag(List<int>? tag) {
    return values.firstWhere(
        (e) => BytesUtils.bytesEqual(e._tag, tag?.sublist(ArgsType.tagLength)),
        orElse: () => throw WalletExceptionConst.invalidRequest);
  }
}

enum StreamIsolateMethod {
  moneroAccountTracker(CryptoKeyConst.moneroAccountTracker),
  test([0, 0, 0, 1]);

  final List<int> _tag;
  List<int> get tag => [...ArgsType.streamRequest.tag, ..._tag];
  const StreamIsolateMethod(this._tag);
  static StreamIsolateMethod fromTag(List<int>? tag) {
    return values.firstWhere(
        (e) => BytesUtils.bytesEqual(e._tag, tag?.sublist(ArgsType.tagLength)),
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
  sign(CryptoKeyConst.sign),
  moneroOutputUnlocker(CryptoKeyConst.moneroOutputUnlocker);

  final List<int> tag;
  const WalletRequestMethod(this.tag);
  static WalletRequestMethod fromTag(List<int>? tag) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(e.tag, tag),
        orElse: () => throw WalletExceptionConst.invalidRequest);
  }
}

abstract class CryptoRequest<T, A extends CborMessageArgs>
    extends CryptoArgsCompleter<T, A> {
  const CryptoRequest();
  abstract final CryptoRequestMethod method;

  @override
  ArgsType get type => ArgsType.crypto;

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
      case CryptoRequestMethod.generateMoneroMnemonic:
        args = MoneroMenmonicGenerateMessage.deserialize(object: decode);
        break;
      case CryptoRequestMethod.moneroMnemonicToPrivateKey:
        args = MoneroMnemonicToPrivateKeyMessage.deserialize(object: decode);
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

abstract class WalletRequest<T, A extends CborMessageArgs>
    extends WalletArgsCompleter<T, A> {
  abstract final WalletRequestMethod method;
  const WalletRequest();

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
      case WalletRequestMethod.moneroOutputUnlocker:
        args = WalletRequestMoneroOutputUnlocker.deserialize(object: decode);
        break;
    }
    if (args is! WalletRequest<T, A>) {
      throw WalletExceptionConst.invalidArgruments(
          "${WalletRequest<T, A>}", "${args.runtimeType}");
    }
    return args;
  }
}

abstract class NoneEncryptedCryptoRequest<T, A extends CborMessageArgs>
    extends NoneEncryptedArgsCompleter<T, A> {
  abstract final NoneEncryptedCryptoRequestMethod method;
  const NoneEncryptedCryptoRequest();
  factory NoneEncryptedCryptoRequest.deserialize(
      {List<int>? bytes, CborObject? object}) {
    final CborTagValue decode =
        CborSerializable.decode(cborBytes: bytes, object: object);
    final request = NoneEncryptedCryptoRequestMethod.fromTag(decode.tags);
    final NoneEncryptedCryptoRequest args;
    switch (request) {
      case NoneEncryptedCryptoRequestMethod.moneroFakeTx:
        args = NoneEncryptedRequestFakeMoneroTx.deserialize(object: decode);
        break;
      case NoneEncryptedCryptoRequestMethod.generateRingOutput:
        args =
            NoneEncryptedRequestGenerateRingOutput.deserialize(object: decode);
        break;
      case NoneEncryptedCryptoRequestMethod.moneroGenerateProof:
        args = NoneEncryptedRequestMoneroGenerateTxProof.deserialize(
            object: decode);
        break;
      case NoneEncryptedCryptoRequestMethod.moneroVerifyProof:
        args =
            NoneEncryptedRequestMoneroVerifyTxProof.deserialize(object: decode);
        break;
      case NoneEncryptedCryptoRequestMethod.cbor:
        args = NoneEncryptedRequestDecodeCbor.deserialize(object: decode);
        break;
      case NoneEncryptedCryptoRequestMethod.hexToBytes:
        args = NoneEncryptedRequestHexToBytes.deserialize(object: decode);
        break;
      case NoneEncryptedCryptoRequestMethod.test:
        args = CryptoRequestTestLarge.deserialize(object: decode);
        break;
      case NoneEncryptedCryptoRequestMethod.hashing:
        args = NoneEncryptedRequestHashing.deserialize(object: decode);
        break;
      case NoneEncryptedCryptoRequestMethod.substrateReadApi:
        args = NoneEncryptedRequestSubstrateGetAPI.deserialize(object: decode);
        break;
    }
    if (args is! NoneEncryptedCryptoRequest<T, A>) {
      throw WalletExceptionConst.invalidArgruments(
          "${NoneEncryptedCryptoRequest<T, A>}", "${args.runtimeType}");
    }
    return args;
  }

  @override
  ArgsType get type => ArgsType.nonEncrypted;
}

abstract class IsolateStreamRequest<T, S>
    extends StreamArgsCompleter<T, MessageArgsStream, S> {
  StreamController<S>? _streamController = StreamController();
  StreamController<S>? get streamController => _streamController;
  bool _closed = false;
  bool get closed => _closed;
  abstract final StreamIsolateMethod method;
  @override
  ArgsType get type => ArgsType.streamRequest;

  IsolateStreamRequest();
  factory IsolateStreamRequest.deserialize(
      {List<int>? bytes, CborObject? object}) {
    final CborTagValue decode =
        CborSerializable.decode(cborBytes: bytes, object: object);
    final request = StreamIsolateMethod.fromTag(decode.tags);
    final IsolateStreamRequest args;
    switch (request) {
      case StreamIsolateMethod.moneroAccountTracker:
        args = StreamRequestMoneroBlockTracking.deserialize(object: decode);
        break;
      case StreamIsolateMethod.test:
        args = StreamRequestHexToBytes.deserialize(object: decode);
        break;
    }
    if (args is! IsolateStreamRequest<T, S>) {
      throw WalletExceptionConst.invalidArgruments(
          "${IsolateStreamRequest<T, S>}", "${args.runtimeType}");
    }
    return args;
  }

  void handleIsolateData(
      {required S param,
      required EventSink<MessageArgsStream> sink,
      required String streamId,
      List<int>? encryptedPart});
  void handleData(
      {required S param,
      required EventSink<T> sink,
      required String streamId,
      List<int>? encryptedPart});

  @override
  Stream<MessageArgsStream> getIsolateResult(
      {required String streamId, List<int>? encryptedPart}) {
    if (_streamController == null) {
      throw WalletException("stream_closed_desc");
    }
    return _streamController!.stream.transform(
        StreamTransformer<S, MessageArgsStream>.fromHandlers(
            handleData: (data, sink) => handleIsolateData(
                param: data,
                sink: sink,
                streamId: streamId,
                encryptedPart: encryptedPart)));
  }

  @override
  Stream<T> result({List<int>? encryptedPart}) {
    if (_streamController == null) {
      throw WalletException("stream_closed_desc");
    }
    return _streamController!.stream.transform(
        StreamTransformer<S, T>.fromHandlers(
            handleData: (data, sink) => handleData(
                param: data,
                sink: sink,
                streamId: 'main',
                encryptedPart: encryptedPart)));
  }

  void close() {
    if (_closed) return;
    _closed = true;
    _streamController?.close();
    _streamController = null;
  }

  @override
  void add(MessageArgsStream args) {
    switch (args.method) {
      case MessageArgsStreamMethod.close:
      case MessageArgsStreamMethod.done:
        close();
        break;
      default:
    }
  }
}
