// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:mrt_native_support/web/api/api.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/http/isolate/exception/exception.dart';
import 'package:mrt_wallet/app/http/isolate/models/mode.dart';
import 'package:mrt_wallet/app/http/models/models.dart';
import 'package:mrt_wallet/app/http/isolate/core/service.dart';
import 'package:mrt_wallet/app/http/isolate/models/message.dart';
import 'package:mrt_native_support/web/mrt_native_web.dart' as web;
import 'package:mrt_wallet/app/synchronized/basic_lock.dart';
import 'package:mrt_wallet/app/utils/utils.dart';

@JS("serviceWorkerListener_")
external set workerListener(JSFunction? f);
@JS("serviceWorkerListener_")
external JSFunction get workerListener;

@JS("serviceErrorListener_")
external set onWorkerErrorListener(JSFunction? f);
@JS("serviceErrorListener_")
external JSFunction get onWorkerErrorListener;

WebHTTPServiceWorker getHTTPWorker() => WebHTTPServiceWorker();

class WebHTTPServiceWorker extends HTTPServiceWorker {
  final _WorkerConnector connector = _WorkerConnector();
  @override
  Future<HTTPCallerResponse> send(HTTPWorkerMessage request) async {
    final isolate = await connector.getConnector();
    final result = await isolate.getResult(message: request);
    return result.response;
  }
}

typedef _OnIsolateError = Function(MessageEvent error, HttpWorkerMode id);

class _WorkerConnector {
  final _lock = SynchronizedLock();
  int connectorId = 0;
  final Map<int, _WorkerConnection> _workers = {};
  void _onError(MessageEvent? error, HttpWorkerMode id) {
    _lock.synchronized(() {
      _workers.remove(id.id);
    });
  }

  Future<_WorkerConnection> getConnector(
      {HttpWorkerMode mode = HttpWorkerMode.main}) async {
    return await _lock.synchronized(() async {
      _workers[mode.id] ??= await _WorkerConnection._init(onDone: _onError);
      return _workers[mode.id]!;
    });
  }
}

class _WorkerConnection {
  final Map<int, HTTPWorkerMessageCompleter> _requests = {};
  final web.Worker worker;
  final _lock = SynchronizedLock();
  int _requestId = 0;
  void close() {
    worker.terminate();
  }

  _WorkerConnection({
    required this.worker,
  });

  static final bool isExtention = web.isExtension;
  static const String _wasmPath = "assets/wasm/http.wasm";
  static const String _extentionJs = "assets/wasm/wasm.mjs";
  static const String _wasmScryptPath = "assets/wasm/http.mjs";
  static const String _jsScryptPath = "assets/wasm/http.js";
  static Future<String> loadFileText(String path) async {
    final f = await jsWindow.fetch_(path);
    return await f.text_();
  }

  static Future<ByteBuffer> loadFileBinary(String path) async {
    final f = await PlatformUtils.loadAssets(path);
    return Uint8List.fromList(f).buffer;
  }

  static Future<ByteBuffer?> _loadWasm(bool isJs) async {
    if (isJs) return null;
    final file = await loadFileBinary(_wasmPath);
    return file;
  }

  static Future<web.Worker> _buildExtentionWorker() async {
    final url = PlatformUtils.assetPath(_extentionJs);
    return web.Worker(url, WorkerOptions()..type = "module");
  }

  static Future<web.Worker> _buildWorker() async {
    return _buildExtentionWorker();
  }

  static String _scriptPath(bool isJs) {
    if (isJs) return _jsScryptPath;
    return _wasmScryptPath;
  }

  static Future<String?> _loadModuleScript(bool isJs) async {
    if (isExtention) return null;
    final scriptPath = _scriptPath(isJs);
    final file = await loadFileText(PlatformUtils.assetPath(scriptPath));
    return file;
  }

  static Future<_WorkerConnection> _init(
      {required _OnIsolateError onDone,
      bool isJs = true,
      HttpWorkerMode mode = HttpWorkerMode.main}) async {
    final Completer<_WorkerConnection> completer = Completer();
    String? moudle;
    final ByteBuffer? wasm;
    try {
      wasm = await _loadWasm(isJs);
      moudle = await _loadModuleScript(isJs);
    } catch (e) {
      throw FailedHttpIsolateInitialization.failed;
    }
    final worker = await _buildWorker();
    void onEvent(MessageEvent event) {
      completer.complete(_WorkerConnection(worker: worker));
    }

    onWorkerErrorListener = (MessageEvent event) {
      onDone(event, mode);
    }.toJS;
    worker.addEventListener("error", onWorkerErrorListener);
    workerListener = onEvent.toJS;
    worker.addEventListener("message", workerListener);
    worker.postMessage({
      "module": moudle,
      "wasm": wasm,
      "isWasm": !isJs,
      "isHttp": true
    }.jsify()!);
    final result = await completer.future.timeout(const Duration(seconds: 20));
    worker.removeEventListener("message", workerListener);
    worker.addEventListener("message", result.onResponse.toJS);
    worker.removeEventListener("error", onWorkerErrorListener);
    worker.addEventListener(
        "error",
        (MessageEvent event) {
          onDone(event, mode);
        }.toJS);

    return result;
  }

  Future<int> _getRequestId() {
    return _lock.synchronized(() {
      _requestId++;
      final id = HTTPWorkerMessageCompleter(_requestId);
      _requests[id.id] = id;
      return id.id;
    });
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

  void onResponse(MessageEvent e) {
    final HTTPWorkerResponse r = HTTPWorkerResponse.fromJs(
        (e.data.dartify() as Map).cast<String, dynamic>());
    _requests[r.id]?.complete(r);
  }

  void _sentRequest(HTTPWorkerMessage message, int id) {
    final request = HTTPWorkerRequest(id: id, message: message);
    final toJs = request.toJson().jsify();
    if (toJs == null) {
      Future.delayed(Duration.zero, () {
        _requests[id]?.error(WalletExceptionConst.castingFailed(
            messsage: "jsify object failed."));
      });
      return;
    }
    worker.postMessage(request.toJson().jsify()!);
  }
}
