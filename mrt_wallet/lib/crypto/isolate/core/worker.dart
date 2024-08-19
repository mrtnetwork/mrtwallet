import 'dart:async';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/crypto/isolate/cross/exception.dart';
import 'package:mrt_wallet/crypto/requets/messages.dart';
import '../cross/cross.dart'
    if (dart.library.js_interop) '../cross/web/web.dart'
    if (dart.library.io) '../cross/io.dart';

abstract class IsolateCryptoWoker {
  static final IsolateCryptoWoker isolate = getCryptoWorker();
  void init(bool useIsolate);
  bool get hasIsolate;

  Future<T> _call<T>(
      {required Future<T> Function() onIsolate,
      required Future<T> Function() onMain}) async {
    if (!hasIsolate) {
      return onMain();
    }
    try {
      final result = await onIsolate();
      return result;
    } on FailedIsolateInitialization {
      final result = onMain();
      return result;
    } on TimeoutException {
      final result = onMain();
      return result;
    }
  }

  Future<T> getResult<T extends MessageArgs>(WorkerRequestMessage message);

  ///
  Future<List<int>> generateRandomBytes(
      {int length = 32, List<List<int>> existsKeys = const []}) async {
    return cryptoRequest(
        CryptoRequestRandomGenerator(length: length, existsKeys: existsKeys));
  }

  Future<List<int>> generateHash(
      {required CryptoRequestHashingType type,
      List<int>? dataBytes,
      String? dataHex}) async {
    return cryptoRequest(CryptoRequestHashing(
        type: type, dataBytes: dataBytes, dataHex: dataHex));
  }

  Future<String> generateHashString(
      {required CryptoRequestHashingType type,
      List<int>? dataBytes,
      String? dataHex}) async {
    final hashing =
        await generateHash(type: type, dataBytes: dataBytes, dataHex: dataHex);
    switch (type) {
      case CryptoRequestHashingType.uuid:
      case CryptoRequestHashingType.generateUuid:
        return StringUtils.decode(hashing);
      default:
        return BytesUtils.toHexString(hashing);
    }
  }

  String generateUUIDSync({List<int>? dataBytes, String? dataHex}) {
    if (dataBytes == null && dataHex == null) {
      final rand = QuickCrypto.generateRandom(16);
      return UUID.fromBuffer(rand);
    }
    final hash = MD4.hash(dataBytes ?? StringUtils.toBytes(dataHex!));
    return UUID.fromBuffer(hash);
  }

  Future<String> generateUUID({List<int>? dataBytes, String? dataHex}) async {
    CryptoRequestHashingType type = CryptoRequestHashingType.uuid;
    if (dataBytes == null && dataHex == null) {
      type = CryptoRequestHashingType.generateUuid;
    }
    return await generateHashString(
        type: type, dataBytes: dataBytes, dataHex: dataHex);
  }

  Future<List<int>> hexToBytes(String hex) async {
    return cryptoRequest(CryptoRequestHexToBytes(hex: hex));
  }

  Future<String> generateRandomHex(
      {int length = 32, List<List<int>> existsKeys = const []}) async {
    final random = await cryptoRequest(
        CryptoRequestRandomGenerator(length: length, existsKeys: existsKeys));
    return BytesUtils.toHexString(random);
  }

  Future<T> cryptoRequest<T, A extends MessageArgs>(
      MessageArgsCompleter<T, A> message,
      {bool isolate = true}) async {
    if (!isolate) {
      return message.result();
    }
    return _call(onIsolate: () async {
      final args = CryptoArgs(message);
      final request = WorkerRequestMessage(
          args: args, message: CryptoMessageType.cryptoRequest);
      final A response = await getResult(request);
      return message.parsResult(response);
    }, onMain: () async {
      return message.result();
    });
  }

  Future<T> walletArgs<T, A extends MessageArgs>(
      {required WalletMessageArgsCompleter<T, A> message,
      required List<int> encryptedMasterKey,
      required List<int> key}) async {
    final args = WalletArgs.fromStorage(
        args: message, encryptedMasterKey: encryptedMasterKey, key: key);
    return _call(onIsolate: () async {
      final request = WorkerRequestMessage(
          args: args, message: CryptoMessageType.walletRequest);
      final A response = await getResult(request);
      return message.parsResult(response);
    }, onMain: () async {
      return args.result();
    });
  }
}
