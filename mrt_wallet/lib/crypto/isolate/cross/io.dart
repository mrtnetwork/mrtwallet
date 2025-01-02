import 'dart:async';
import 'dart:isolate';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/isolate/core/worker.dart';
import 'package:mrt_wallet/crypto/isolate/controller/message_controller.dart';
import 'package:mrt_wallet/crypto/isolate/types/types.dart';
import 'package:mrt_wallet/crypto/requets/argruments/argruments.dart';
import 'package:mrt_wallet/crypto/requets/completer/completer.dart';
import 'package:mrt_wallet/crypto/requets/messages/models/models.dart';

import 'exception.dart';

IsolateCryptoWoker getCryptoWorker() => IoCryptoWorker._();

class IoCryptoWorker extends IsolateCryptoWoker {
  IoCryptoWorker._() : super();
  final _connector = _WorkerConnector();

  @override
  Stream<A> getStream<A extends MessageArgsStream>(String streamId) {
    return _connector.onStreamRespone.stream
        .where((e) => e.streamId == streamId)
        .cast<A>()
        .asBroadcastStream();
  }

  @override
  Future<T> sendRequest<T extends CborMessageArgs>(
      {required RequestableMessage message,
      WorkerMode mode = WorkerMode.main,
      List<int>? encryptPart,
      Duration? timeout}) async {
    final connector = await _connector.getConnector(mode);
    return connector.getResult(
        args: message, timeout: timeout, encryptPart: encryptPart);
  }

  bool _hasIsolate = true;
  @override
  bool get hasIsolate => _hasIsolate;
  @override
  void init(bool useIsolate) {
    _hasIsolate = useIsolate;
    if (_hasIsolate) {
      // _init();
    }
  }

  @override
  Future<MessageArgsStreamId> sendStreamRequest(
      {required StreamArgsRequestable<ArgsCompleter> message,
      required WorkerMode mode,
      List<int>? encryptPart,
      Duration? timeout}) async {
    final connector = await _connector.getConnector(mode);
    final result = await connector.getStreamResult<MessageArgsStreamId>(
        args: message, timeout: timeout, encryptPart: encryptPart);
    return result;
  }

  @override
  Future<void> sendStreamMessage(
      {required MessageArgsStream message,
      required WorkerMode mode,
      List<int>? encryptPart,
      Duration? timeout}) async {
    final connector = _connector.getConnectorById(mode);
    connector?.getResult(
        args: message, timeout: timeout, encryptPart: encryptPart);
  }
}

typedef _OnIsolateError = Function(WorkerMode mode);

class _WorkerConnector {
  final StreamController<MessageArgsStream> onStreamRespone =
      StreamController.broadcast();
  final _lock = SynchronizedLock();
  final Map<WorkerMode, _WorkerConnection> _syncWorkers = {};

  void _onDoneIsolate(WorkerMode mode) {
    _lock.synchronized(() {
      final isolate = _syncWorkers.remove(mode);
      isolate?.close();
    });
  }

  _WorkerConnection? getConnectorById(WorkerMode mode) {
    return _syncWorkers[mode];
  }

  Future<_WorkerConnection> getConnector(WorkerMode mode) async {
    final connector = await _lock.synchronized(() async {
      _syncWorkers[mode] ??= await _WorkerConnection._init(
          onDone: _onDoneIsolate, onStreamRespone: onStreamRespone, mode: mode);
      return _syncWorkers[mode]!;
    });
    return connector;
  }
}

class _WorkerConnection {
  final _lock = SynchronizedLock();
  int _requestId = 0;
  final ReceivePort receivePort;
  final SendPort sendPort;
  final List<int> key;
  late final ChaCha20Poly1305 chacha = ChaCha20Poly1305(key);
  final Map<int, WorkerMessageCompleter> _requests = {};
  final WorkerMode mode;
  final StreamController<MessageArgsStream> onStreamRespone;
  IsolateStatus status = IsolateStatus.idle;

  _WorkerConnection(
      {required this.receivePort,
      required this.sendPort,
      required this.key,
      required this.mode,
      required this.onStreamRespone});

  Future<int> _getRequestId() {
    return _lock.synchronized(() {
      _requestId++;
      final id = WorkerMessageCompleter(_requestId);
      _requests[id.id] = id;
      return id.id;
    });
  }

  static Future<_WorkerConnection> _init(
      {required _OnIsolateError onDone,
      required StreamController<MessageArgsStream> onStreamRespone,
      required WorkerMode mode}) async {
    try {
      final initPort = RawReceivePort(null, mode.name);
      final connection = Completer<_WorkerConnection>.sync();
      final List<int> key = QuickCrypto.generateRandom().immutable;
      initPort.handler = (SendPort initialMessage) {
        final commandPort = initialMessage;
        _WorkerConnection worker;
        switch (mode) {
          case WorkerMode.sync1:
          case WorkerMode.sync2:
            worker = _SyncWorkerConnection(
                receivePort: ReceivePort.fromRawReceivePort(initPort),
                sendPort: commandPort,
                key: key,
                onStreamRespone: onStreamRespone,
                mode: mode);
            break;
          default:
            worker = _WorkerConnection(
                receivePort: ReceivePort.fromRawReceivePort(initPort),
                sendPort: commandPort,
                key: key,
                onStreamRespone: onStreamRespone,
                mode: mode);
            break;
        }
        connection.complete(worker);
      };
      final enExit = ReceivePort();
      enExit.listen((s) {
        onDone(mode);
        enExit.close();
      });
      try {
        await Isolate.spawn(_WorkerConnection._startRemoteIsolate,
            _IoEncryptedInitialRequest(sendPort: initPort.sendPort, key: key),
            debugName: "connector ${mode.name}",
            errorsAreFatal: true,
            onExit: enExit.sendPort);
      } catch (_) {
        initPort.close();
        enExit.close();
        rethrow;
      }

      final result = await connection.future;
      result.receivePort.listen(result._handleResponsesFromIsolate);
      return result;
    } catch (e) {
      throw FailedIsolateInitialization.failed;
    }
  }

  WorkerEncryptedMessage _toEncryptedMessage(List<int> message, int requestId) {
    final nonce = QuickCrypto.generateRandom(16);
    final enc = chacha.encrypt(nonce, message);
    return WorkerEncryptedMessage(message: enc, nonce: nonce, id: requestId);
  }

  WorkerMessage _toWorkerMessage(
      {required RequestableMessage request,
      required int requestId,
      required List<int>? encryptedPart}) {
    if (request.type.isEncrypted) {
      return _toEncryptedMessage(request.toCbor().encode(), requestId);
    }
    return WorkerNoneEncryptedMessage(
        message: request.toCbor().encode(),
        id: requestId,
        encryptedPart: encryptedPart == null
            ? null
            : _toEncryptedMessage(encryptedPart, -1));
  }

  void _sentRequest(
      {required RequestableMessage request,
      required int requestId,
      required List<int>? encryptedPart}) {
    final enc = _toWorkerMessage(
        request: request, encryptedPart: encryptedPart, requestId: requestId);
    sendPort.send(enc);
  }

  (CborMessageArgs, int?) _getResult(WorkerMessage msg) {
    int? id;
    try {
      id = msg.id;
      if (msg.type.isEncrypted) {
        final encryptedMessage = msg.cast<WorkerEncryptedMessage>();
        final decrypt =
            chacha.decrypt(encryptedMessage.nonce, encryptedMessage.message);
        return (CborMessageArgs.deserialize(decrypt!), id);
      }
      if (msg.type == WorkerMessageType.cbor) {
        return (msg.message, id);
      }
      return (CborMessageArgs.deserialize(msg.message), id);
    } catch (e) {
      return (EncryptedIsolateMessageController.verificationFailed, id);
    }
  }

  static void _startRemoteIsolate(_IoEncryptedInitialRequest request) {
    final receivePort = ReceivePort();
    request.sendPort.send(receivePort.sendPort);
    _handleCommandsToIsolate(
        receivePort,
        _IoEncryptedIsolateInitialData(
            sendPort: request.sendPort, key: request.key));
  }

  static void _handleCommandsToIsolate(
      ReceivePort receivePort, _IoEncryptedIsolateInitialData intialData) {
    receivePort.listen(intialData.sentResult);
  }

  void _handleResponsesFromIsolate(dynamic message) {
    final response = _getResult(message);
    switch (response.$1.type) {
      case ArgsType.streamArgs:
        onStreamRespone.add(response.$1 as MessageArgsStream);
        break;
      default:
        _requests[response.$2]?.complete(response.$1);
        break;
    }
  }

  Future<T> getStreamResult<T extends CborMessageArgs>(
      {required StreamArgsRequestable args,
      List<int>? encryptPart,
      Duration? timeout}) async {
    final next = await _getRequestId();
    try {
      _sentRequest(request: args, requestId: next, encryptedPart: encryptPart);
      final result = await _requests[next]!.getResult(timeout: timeout);
      if (result.type == ArgsType.exception) {
        throw WalletException((result as MessageArgsException).message);
      }
      if (result is! T) {
        throw WalletExceptionConst.dataVerificationFailed;
      }
      return result;
    } finally {
      _requests.remove(next);
    }
  }

  Future<T> getResult<T extends CborMessageArgs>(
      {required RequestableMessage args,
      List<int>? encryptPart,
      Duration? timeout}) async {
    final next = await _getRequestId();
    try {
      _sentRequest(request: args, requestId: next, encryptedPart: encryptPart);
      final result = await _requests[next]!.getResult(timeout: timeout);
      if (result.type == ArgsType.exception) {
        throw WalletException((result as MessageArgsException).message);
      }
      if (result is! T) {
        throw WalletExceptionConst.dataVerificationFailed;
      }
      return result;
    } finally {
      _requests.remove(next);
    }
  }

  void close() {
    try {
      for (final i in _requests.values) {
        i.close();
      }
      _requests.clear();
      receivePort.close();
    } catch (_) {}
  }

  @override
  String toString() {
    return "connection.$mode";
  }
}

class _SyncWorkerConnection extends _WorkerConnection {
  _SyncWorkerConnection(
      {required super.receivePort,
      required super.sendPort,
      required super.key,
      required super.mode,
      required super.onStreamRespone});

  @override
  Future<int> _getRequestId() async {
    _requestId++;
    final id = WorkerMessageCompleter(_requestId);
    _requests[id.id] = id;
    return id.id;
  }

  @override
  Future<T> getResult<T extends CborMessageArgs>(
      {required RequestableMessage args,
      List<int>? encryptPart,
      Duration? timeout}) async {
    return await _lock.synchronized(() async {
      try {
        status = IsolateStatus.busy;
        return await super
            .getResult(args: args, encryptPart: encryptPart, timeout: timeout);
      } finally {
        status = IsolateStatus.idle;
      }
    });
  }

  @override
  String toString() {
    return "SyncWorker: $mode $status";
  }
}

class _IoEncryptedInitialRequest {
  final SendPort sendPort;
  final List<int> key;
  _IoEncryptedInitialRequest({required this.sendPort, required this.key});
}

class _IoEncryptedIsolateInitialData {
  final SendPort sendPort;
  final List<int> key;
  late final EncryptedIsolateMessageController crypto =
      EncryptedIsolateMessageController((message, id) {
    final encrypted =
        _toEncryptedMessage(request: message, encrypted: true, requestId: id);
    sendPort.send(encrypted);
  });
  late final ChaCha20Poly1305 chacha = ChaCha20Poly1305(key);
  _IoEncryptedIsolateInitialData(
      {required this.sendPort, required List<int> key})
      : key = key.asImmutableBytes;

  Future<(CborMessageArgs, bool, int)> _getResult(WorkerMessage msg) async {
    int? id;
    bool? encrypted;
    try {
      id = msg.id;
      encrypted = msg.type.isEncrypted;
      List<int> messageBytes = msg.message;
      if (encrypted) {
        final encryptedMessage = msg.cast<WorkerEncryptedMessage>();
        messageBytes =
            chacha.decrypt(encryptedMessage.nonce, encryptedMessage.message)!;
      }
      final CborMessageArgs args = CborMessageArgs.deserialize(messageBytes);
      List<int>? encryptedPart;
      if (!encrypted) {
        final nonEncryptedMessage = msg.cast<WorkerNoneEncryptedMessage>();
        if (nonEncryptedMessage.encryptedPart != null) {
          encryptedPart = chacha.decrypt(
              nonEncryptedMessage.encryptedPart!.nonce,
              nonEncryptedMessage.encryptedPart!.message)!;
        }
      }

      final response = await crypto.handleMessage(
          args: args, id: id, encryptedPart: encryptedPart);
      return (response, encrypted, id);
    } catch (e) {
      return (
        EncryptedIsolateMessageController.verificationFailed,
        encrypted ?? true,
        id ?? -1
      );
    }
  }

  void sentResult(dynamic message) async {
    try {
      CborMessageArgs? result;
      bool isEncrypted = true;
      assert(message is WorkerMessage, "invalid message to isolate!");
      if (message is! WorkerMessage) {
        result = EncryptedIsolateMessageController.verificationFailed;
      }
      int id = -1;
      if (result == null) {
        final r = await _getResult(message);
        isEncrypted = r.$2;
        result = r.$1;
        id = r.$3;
      }
      final encrypted = _toEncryptedMessage(
          request: result, encrypted: isEncrypted, requestId: id);
      sendPort.send(encrypted);
    } catch (_) {}
  }

  WorkerMessage _toEncryptedMessage(
      {required CborMessageArgs request,
      required bool encrypted,
      required int requestId}) {
    if (request.type == ArgsType.cbor) {
      return WorkerCborMessage(
          message: request as MessageArgsCbor, id: requestId);
    }
    if (encrypted) {
      final nonce = QuickCrypto.generateRandom(16);
      final enc = chacha.encrypt(nonce, request.toCbor().encode());

      return WorkerEncryptedMessage(message: enc, nonce: nonce, id: requestId);
    }
    return WorkerNoneEncryptedMessage(
        message: request.toCbor().encode(), id: requestId);
  }
}
