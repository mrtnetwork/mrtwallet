import 'dart:async';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/crypto/isolate/cross/exception.dart';
import 'package:mrt_wallet/crypto/isolate/types/types.dart';
import 'package:mrt_wallet/crypto/requets/messages.dart';
import '../cross/cross.dart'
    if (dart.library.js_interop) '../cross/web/web.dart'
    if (dart.library.io) '../cross/io.dart';

abstract class IsolateCryptoWoker {
  static final IsolateCryptoWoker isolate = getCryptoWorker();
  Stream<A> getStream<A extends MessageArgsStream>(String streamId);

  void init(bool useIsolate);
  bool get hasIsolate;

  Future<T> _call<T>(
      {required Future<T> Function() onIsolate,
      required Future<T> Function() onMain,
      bool useIsolate = true}) async {
    if (!useIsolate || !hasIsolate) {
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

  Future<T> sendRequest<T extends CborMessageArgs>(
      {required RequestableMessage message,
      WorkerMode mode = WorkerMode.main,
      List<int>? encryptPart,
      Duration? timeout});

  Future<void> sendStreamMessage(
      {required MessageArgsStream message,
      required WorkerMode mode,
      List<int>? encryptPart,
      Duration? timeout});

  Future<MessageArgsStreamId> sendStreamRequest(
      {required StreamArgsRequestable message,
      required WorkerMode mode,
      List<int>? encryptPart,
      Duration? timeout});

  ///
  Future<List<int>> generateRandomBytes(
      {int length = 32, List<List<int>> existsKeys = const []}) async {
    List<int> rand = QuickCrypto.generateRandom(length);
    if (existsKeys.isEmpty) return rand;
    while (BytesUtils.isContains(existsKeys, rand)) {
      rand = QuickCrypto.generateRandom(length);
    }
    return rand;
  }

  Future<List<int>> generateHash(
      {required CryptoRequestHashingType type,
      List<int>? dataBytes,
      String? dataHex,
      bool isolate = true}) async {
    return nonEncryptedRequest(
        NoneEncryptedRequestHashing(
            type: type, dataBytes: dataBytes, dataHex: dataHex),
        isolate: isolate,
        mode: WorkerMode.main);
  }

  Future<String> generateHashString(
      {required CryptoRequestHashingType type,
      List<int>? dataBytes,
      String? dataHex,
      bool isolate = true}) async {
    final hashing = await generateHash(
        type: type, dataBytes: dataBytes, dataHex: dataHex, isolate: isolate);
    switch (type) {
      case CryptoRequestHashingType.uuid:
      case CryptoRequestHashingType.generateUuid:
        return StringUtils.decode(hashing);
      default:
        return BytesUtils.toHexString(hashing);
    }
  }

  Future<List<int>> hexToBytes(String hex) async {
    return nonEncryptedRequest(NoneEncryptedRequestHexToBytes(hex: hex),
        mode: WorkerMode.main);
  }

  Future<String> generateRandomHex(
      {int length = 32, List<List<int>> existsKeys = const []}) async {
    return BytesUtils.toHexString(QuickCrypto.generateRandom(length));
  }

  Future<T> cryptoIsolateRequest<T, A extends CborMessageArgs>(
    CryptoArgsCompleter<T, A> message, {
    bool isolate = true,
    Duration? timeout,
  }) async {
    return _call(
        onIsolate: () async {
          final A response =
              await sendRequest(message: message, timeout: timeout);
          return message.parsResult(response);
        },
        onMain: () async {
          return message.result();
        },
        useIsolate: isolate);
  }

  Future<T> cryptoMainRequest<T, A extends CborMessageArgs>(
    CryptoArgsCompleter<T, A> message, {
    Duration? timeout,
  }) async {
    return message.result();
  }

  Future<T> nonEncryptedRequest<T, A extends CborMessageArgs>(
      NoneEncryptedArgsCompleter<T, A> message,
      {List<int>? encryptedPart,
      Duration? timeout,
      bool isolate = true,
      required WorkerMode mode}) async {
    return _call(
        onIsolate: () async {
          final A response = await sendRequest(
              message: message,
              encryptPart: encryptedPart,
              timeout: timeout,
              mode: mode);
          return message.parsResult(response);
        },
        onMain: () async {
          return message.result(encryptedPart: encryptedPart);
        },
        useIsolate: isolate);
  }

  Future<SyncRequestController<T, S>>
      streamRequest<T, A extends MessageArgsStream, S>(
          IsolateStreamRequest<T, S> message,
          {List<int>? encryptedPart,
          Duration? timeout,
          bool isolate = true,
          required WorkerMode mode}) async {
    assert(mode != WorkerMode.main);
    return _call(
        onIsolate: () async {
          final response = await sendStreamRequest(
              message: message,
              encryptPart: encryptedPart,
              timeout: timeout,
              mode: mode);
          final streamId = response.streamId;
          final stream = getStream<A>(streamId)
              .transform(StreamTransformer<A, T>.fromHandlers(
            handleData: (data, sink) {
              final r = message.parsResult(data);
              sink.add(r);
            },
          ));
          message.streamController!.stream.listen((event) {
            final msg = message.toRequest(message: event, streamId: streamId);
            sendStreamMessage(message: msg, mode: mode);
          }, onDone: () {
            final msg = MessageArgsStream.close(streamId);
            sendStreamMessage(message: msg, mode: mode);
            message.close();
          });
          return SyncRequestController(
              controller: message.streamController!, stream: stream);
        },
        onMain: () async {
          final stream = message.result();
          message.streamController!.stream.listen((event) {
            message.streamController!.add(event);
          }, onDone: () {
            message.close();
          });
          return SyncRequestController(
              controller: message.streamController!, stream: stream);
        },
        useIsolate: isolate);
  }

  Future<T> walletArgs<T, A extends CborMessageArgs>(
      {required WalletArgsCompleter<T, A> message,
      required List<int> encryptedMasterKey,
      required List<int> key,
      Duration? timeout,
      bool isolate = true}) async {
    final args = WalletArgs.fromStorage(
        args: message, encryptedMasterKey: encryptedMasterKey, key: key);
    return _call(
        onIsolate: () async {
          final A response = await sendRequest(message: args, timeout: timeout);
          return message.parsResult(response);
        },
        onMain: () async {
          return args.result();
        },
        useIsolate: isolate);
  }
}
