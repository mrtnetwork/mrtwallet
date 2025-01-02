import 'dart:async';
import 'dart:isolate';
import 'package:mrt_wallet/app/http/http.dart';
import 'package:mrt_wallet/app/synchronized/basic_lock.dart';
import 'package:mrt_wallet/app/http/isolate/core/service.dart';
import 'package:mrt_wallet/app/http/isolate/exception/exception.dart';
import 'package:mrt_wallet/app/http/isolate/impl/caller/caller.dart';
import 'package:mrt_wallet/app/http/isolate/models/message.dart';
import 'package:mrt_wallet/app/http/isolate/models/mode.dart';

IoHTTPServiceWorker getHTTPWorker() => IoHTTPServiceWorker();

class IoHTTPServiceWorker extends HTTPServiceWorker {
  final connector = _WorkerConnector();
  // final ServicesHTTPCaller caller = ServicesHTTPCaller();

  @override
  Future<HTTPCallerResponse> send(HTTPWorkerMessage request) async {
    final isolate = await connector.getConnector();
    final result = await isolate.getResult(message: request);
    return result.response;
  }
}

typedef _OnIsolateError = Function(Object? error, int id);

class _WorkerConnector {
  final _lock = SynchronizedLock();
  int connectorId = 0;
  final Map<int, _WorkerConnection> _workers = {};
  void _onError(Object? error, int id) {
    _lock.synchronized(() {
      _workers.remove(id);
    });
  }

  Future<_WorkerConnection> getConnector(
      {HttpWorkerMode mode = HttpWorkerMode.main}) async {
    return await _lock.synchronized(() async {
      _workers[mode.id] ??= await _WorkerConnection._init(
          connectorId: mode.id, onError: _onError, onDone: _onError);
      return _workers[mode.id]!;
    });
  }
}

class _WorkerConnection {
  final _lock = SynchronizedLock();
  int _requestId = 0;
  final ReceivePort receivePort;
  final SendPort sendPort;
  final Map<int, HTTPWorkerMessageCompleter> _requests = {};
  _WorkerConnection({required this.receivePort, required this.sendPort});

  Future<int> _getRequestId() {
    return _lock.synchronized(() {
      _requestId++;
      final id = HTTPWorkerMessageCompleter(_requestId);
      _requests[id.id] = id;
      return id.id;
    });
  }

  static Future<_WorkerConnection> _init(
      {required int connectorId,
      required _OnIsolateError onError,
      required _OnIsolateError onDone}) async {
    try {
      final initPort = RawReceivePort();
      final connection = Completer<_WorkerConnection>.sync();
      initPort.handler = (initialMessage) {
        final commandPort = initialMessage as SendPort;
        final init = _WorkerConnection(
            receivePort: ReceivePort.fromRawReceivePort(initPort),
            sendPort: commandPort);
        connection.complete(init);
      };
      try {
        await Isolate.spawn(_WorkerConnection._startRemoteIsolate,
            _IoEncryptedInitialRequest(sendPort: initPort.sendPort));
      } on Object {
        initPort.close();
        throw Exception();
      }

      final result = await connection.future;
      result.receivePort.listen(result._handleResponsesFromIsolate,
          onDone: () => onDone(null, connectorId),
          onError: (e) => onDone(e, connectorId));
      return result;
    } catch (e) {
      throw FailedHttpIsolateInitialization.failed;
    }
  }

  void _sentRequest(HTTPWorkerMessage message, int id) {
    final request = HTTPWorkerRequest(id: id, message: message);
    sendPort.send(request);
  }

  static void _startRemoteIsolate(_IoEncryptedInitialRequest request) {
    final receivePort = ReceivePort();
    request.sendPort.send(receivePort.sendPort);
    _handleCommandsToIsolate(receivePort,
        _IoEncryptedIsolateInitialData(sendPort: request.sendPort));
  }

  static void _handleCommandsToIsolate(
      ReceivePort receivePort, _IoEncryptedIsolateInitialData intialData) {
    receivePort.listen(intialData.sentResult);
  }

  void _handleResponsesFromIsolate(dynamic message) {
    final response = message as HTTPWorkerResponse;
    _requests[response.id]?.complete(response);
  }

  Future<HTTPWorkerResponse> getResult(
      {required HTTPWorkerMessage message, Duration? timeout}) async {
    final next = await _getRequestId();
    try {
      _sentRequest(message, next);
      final args = await _requests[next]!.getResult(timeout: timeout);
      return args;
    } finally {
      _requests.remove(next);
    }
  }
}

class _IoEncryptedInitialRequest {
  final SendPort sendPort;
  _IoEncryptedInitialRequest({required this.sendPort});
}

class _IoEncryptedIsolateInitialData {
  final SendPort sendPort;
  final ServicesHTTPCaller caller = ServicesHTTPCaller();
  _IoEncryptedIsolateInitialData({required this.sendPort});

  void sentResult(dynamic message) async {
    if (message is! HTTPWorkerRequest) return;

    final response = await caller.makeCall(message);
    sendPort.send(response);
  }
}
