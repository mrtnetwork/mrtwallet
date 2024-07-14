import 'dart:async';
import 'dart:isolate';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wroker/core/worker.dart';
import 'package:mrt_wallet/wroker/crypto/crypto.dart';
import 'package:mrt_wallet/wroker/messages/argruments/argruments.dart';
import 'package:mrt_wallet/wroker/messages/completer/completer.dart';
import 'package:mrt_wallet/wroker/messages/request/requests/request.dart';
import 'package:mrt_wallet/wroker/messages/response/response.dart';

import 'exception.dart';

IsolateCryptoWoker getCryptoWorker() => _IoCryptoWorker._io;

class _IoCryptoWorker extends IsolateCryptoWoker {
  static final _IoCryptoWorker _io = _IoCryptoWorker._();
  _IoCryptoWorker._() : super.parent();
  _IoConnectionInfo? _initialInfo;
  final _lock = SynchronizedLock();
  final Map<int, WorkerMessageCompleter> _requests = {};
  int _id = 0;
  int _retry = 0;

  @override
  Future<T> getResult<T extends MessageArgs>(WorkerMessageBytes message) async {
    return _lock.synchronized(() async {
      await _init();
      final id = WorkerMessageCompleter(_id++);
      try {
        _requests[id.id] = id;
        // final request = WorkerMessageRequest(message: message);
        _initialInfo!.sentRequest(message, id.id);
        final args = await id.getResult();
        if (args.type == ArgsType.exception) {
          throw WalletException((args as MessageArgsException).message);
        }
        if (args is! T) {
          throw WalletExceptionConst.dataVerificationFailed;
        }
        return args;
      } finally {
        _requests.remove(id.id);
      }
    });
  }

  Future<_IoConnectionInfo> _initIsolate() async {
    try {
      final initPort = RawReceivePort();
      final connection = Completer<_IoConnectionInfo>.sync();
      final List<int> key =
          List<int>.unmodifiable(QuickCrypto.generateRandom());
      initPort.handler = (initialMessage) {
        final commandPort = initialMessage as SendPort;
        final init = _IoConnectionInfo(
            receivePort: ReceivePort.fromRawReceivePort(initPort),
            sendPort: commandPort,
            key: key);
        connection.complete(init);
      };
      try {
        await Isolate.spawn(_startRemoteIsolate,
            _IoInitialRequest(sendPort: initPort.sendPort, key: key));
      } on Object {
        initPort.close();
        throw Exception();
      }
      final result = await connection.future;
      result.receivePort.listen(_handleResponsesFromIsolate,
          onDone: _onDone, onError: _onError);
      return result;
    } catch (e) {
      throw FailedIsolateInitialization.failed;
    }
  }

  Future<void> _init() async {
    try {
      if (_retry > 5) {
        throw FailedIsolateInitialization.failed;
      }
      _initialInfo ??= await _initIsolate();
      _retry = 0;
    } on FailedIsolateInitialization {
      _retry++;
      rethrow;
    }
  }

  void _onError(Object? e) {
    _initialInfo = null;
  }

  void _onDone() {
    _initialInfo = null;
  }

  void _handleResponsesFromIsolate(dynamic message) {
    final response = _initialInfo!.getResult(message);
    _requests[response.id]?.complete(response);
  }

  static void _startRemoteIsolate(_IoInitialRequest request) {
    final receivePort = ReceivePort();
    request.sendPort.send(receivePort.sendPort);
    _handleCommandsToIsolate(receivePort,
        _IoIsolateInitialData(sendPort: request.sendPort, key: request.key));
  }

  static void _handleCommandsToIsolate(
      ReceivePort receivePort, _IoIsolateInitialData intialData) {
    receivePort.listen(intialData.sentResult);
  }

  @override
  bool get hasIsolate => true;
}

class _IoConnectionInfo {
  final ReceivePort receivePort;
  final SendPort sendPort;
  final List<int> key;
  late final ChaCha20Poly1305 chacha = ChaCha20Poly1305(key);
  _IoConnectionInfo(
      {required this.receivePort, required this.sendPort, required this.key});

  WorkerEncryptedMessage _toEncryptedMessage(
      WorkerMessageBytes request, int requestId) {
    final nonce = QuickCrypto.generateRandom(16);
    final enc = chacha.encrypt(nonce, request.toCbor().encode());
    return WorkerEncryptedMessage(message: enc, nonce: nonce, id: requestId);
  }

  void sentRequest(WorkerMessageBytes request, int requestId) {
    final enc = _toEncryptedMessage(request, requestId);
    sendPort.send(enc.toCbor().encode());
  }

  WorkerMessageResponse getResult(List<int> message) {
    int? id;
    try {
      final encryptedMessage = WorkerEncryptedMessage.deserialize(message);
      final decode =
          chacha.decrypt(encryptedMessage.nonce, encryptedMessage.message);
      id = encryptedMessage.id;
      final response = WorkerMessageResponse.deserialize(decode!);
      return response;
    } catch (e) {
      return WorkerMessageResponse(
          args: WalletCrypto.verificationFailed, id: id ?? -1);
    }
  }
}

class _IoInitialRequest {
  final SendPort sendPort;
  final List<int> key;
  _IoInitialRequest({required this.sendPort, required this.key});
}

class _IoIsolateInitialData {
  final SendPort sendPort;
  final List<int> key;
  static const WalletCrypto crypto = WalletCrypto();
  late final ChaCha20Poly1305 chacha = ChaCha20Poly1305(key);
  _IoIsolateInitialData({required this.sendPort, required List<int> key})
      : key = BytesUtils.toBytes(key, unmodifiable: true);

  WorkerMessageResponse _getResult(List<int> message) {
    int? id;
    try {
      final encryptedMessage = WorkerEncryptedMessage.deserialize(message);
      id = encryptedMessage.id;
      final decode =
          chacha.decrypt(encryptedMessage.nonce, encryptedMessage.message);
      return crypto.handleMessage(decode!, id);
    } catch (e) {
      return WorkerMessageResponse(
          args: WalletCrypto.verificationFailed, id: id ?? -1);
    }
  }

  void sentResult(dynamic message) {
    try {
      WorkerMessageResponse? result;
      if (message is! List<int>) {
        result = const WorkerMessageResponse(
            args: WalletCrypto.verificationFailed, id: -1);
      }
      result ??= _getResult(message);
      final encrypted = _toEncryptedMessage(result);

      sendPort.send(encrypted.toCbor().encode());
      // ignore: empty_catches
    } catch (e) {}
  }

  WorkerEncryptedMessage _toEncryptedMessage(WorkerMessageResponse request) {
    final nonce = QuickCrypto.generateRandom(16);
    final enc = chacha.encrypt(nonce, request.toCbor().encode());
    return WorkerEncryptedMessage(message: enc, nonce: nonce, id: request.id);
  }
}
