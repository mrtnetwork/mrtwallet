part of 'package:mrt_wallet/crypto/isolate/cross/web/web.dart';

@JS("workerListener_")
external set workerListener(JSFunction? f);
@JS("workerListener_")
external JSFunction get workerListener;

@JS("errorListener_")
external set onWorkerErrorListener(JSFunction? f);
@JS("errorListener_")
external JSFunction get onWorkerErrorListener;

class BrowserCryptoWorker extends IsolateCryptoWoker {
  BrowserCryptoWorker._() : super();
  final _connector = _WorkerConnector();
  late final bool isExtention = web.isExtension;
  bool _hasIsolate = true;
  @override
  bool get hasIsolate => _hasIsolate;

  @override
  void init(bool useIsolate) {
    _hasIsolate = useIsolate;
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

  @override
  Stream<A> getStream<A extends MessageArgsStream>(String streamId) {
    return _connector.onStreamRespone.stream
        .where((e) => e.streamId == streamId)
        .cast<A>()
        .asBroadcastStream();
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

typedef _OnIsolateError = Function(MessageEvent error, WorkerMode id);

class _WorkerConnector {
  final _lock = SynchronizedLock();
  int connectorId = 0;
  _WorkerConnection? mainIsolate;
  final Map<WorkerMode, _WorkerConnection> _syncWorkers = {};
  final StreamController<MessageArgsStream> onStreamRespone =
      StreamController.broadcast();
  _WorkerConnection? getConnectorById(WorkerMode mode) {
    return _syncWorkers[mode];
  }

  void _onDoneIsolate(MessageEvent event, WorkerMode mode) {
    _lock.synchronized(() {
      final isolate = _syncWorkers.remove(mode);
      isolate?.close();
    });
  }

  Future<_WorkerConnection> getConnector(WorkerMode mode) async {
    return await _lock.synchronized(() async {
      _syncWorkers[mode] ??= await _WorkerConnection._init(
          onDone: _onDoneIsolate, onStreamRespone: onStreamRespone, mode: mode);
      return _syncWorkers[mode]!;
    });
  }
}

class _WorkerConnection {
  final Map<int, WorkerMessageCompleter> _requests = {};
  final ChaCha20Poly1305 chacha;
  final web.Worker worker;
  final _lock = SynchronizedLock();
  int _requestId = 0;
  final WorkerMode mode;
  final StreamController<MessageArgsStream> onStreamRespone;
  void close() {
    worker.terminate();
  }

  _WorkerConnection({
    required List<int> key,
    required this.worker,
    required this.mode,
    required this.onStreamRespone,
  }) : chacha = ChaCha20Poly1305(key);

  static final bool isExtention = web.isExtension;
  static const String _wasmPath = "assets/wasm/crypto.wasm";
  static const String _extentionJs = "assets/wasm/wasm.mjs";
  static const String _wasmScryptPath = "assets/wasm/crypto.mjs";
  static const String _jsScryptPath = "assets/wasm/crypto.js";
  IsolateStatus status = IsolateStatus.idle;
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
      required WorkerMode mode,
      required StreamController<MessageArgsStream> onStreamRespone,
      bool isJs = false}) async {
    final Completer<_WorkerConnection> completer = Completer();
    String? moudle;
    final ByteBuffer? wasm;
    try {
      wasm = await _loadWasm(isJs);
      moudle = await _loadModuleScript(isJs);
    } catch (e) {
      throw FailedIsolateInitialization.failed;
    }
    final worker = await _buildWorker();
    void onEvent(MessageEvent event) {
      final String key = event.data.dartify() as String;
      final List<int> keyBytes = BytesUtils.fromHexString(key);
      switch (mode) {
        case WorkerMode.sync1:
        case WorkerMode.sync2:
          completer.complete(_WorkerConnection(
              key: keyBytes,
              worker: worker,
              onStreamRespone: onStreamRespone,
              mode: mode));
          break;
        default:
          completer.complete(_SyncWorkerConnection(
              key: keyBytes,
              worker: worker,
              onStreamRespone: onStreamRespone,
              mode: mode));
          break;
      }
    }

    onWorkerErrorListener = (MessageEvent event) {
      onDone(event, mode);
    }.toJS;
    worker.addEventListener("error", onWorkerErrorListener);
    workerListener = onEvent.toJS;
    worker.addEventListener("message", workerListener);
    worker.postMessage(
        {"module": moudle, "wasm": wasm, "isWasm": !isJs}.jsify()!);
    final result = await completer.future.timeout(const Duration(seconds: 20));
    worker.removeEventListener("message", workerListener);
    worker.addEventListener("message", result.onResponse.toJS);
    return result;
  }

  Future<int> _getRequestId() {
    return _lock.synchronized(() {
      _requestId++;
      final id = WorkerMessageCompleter(_requestId);
      _requests[id.id] = id;
      return id.id;
    });
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

  void onResponse(MessageEvent e) {
    final String message = (e.data.dartify() as String);
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

  WorkerEncryptedMessage _toEncryptedMessage(List<int> message, int id) {
    final nonce = QuickCrypto.generateRandom(16);
    final enc = chacha.encrypt(nonce, message);
    return WorkerEncryptedMessage(message: enc, nonce: nonce, id: id);
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
            : _toEncryptedMessage(encryptedPart, requestId));
  }

  void _sentRequest(
      {required RequestableMessage request,
      required int requestId,
      required List<int>? encryptedPart}) {
    final encryptMessage = _toWorkerMessage(
        request: request, encryptedPart: encryptedPart, requestId: requestId);
    worker.postMessage(BytesUtils.toHexString(encryptMessage.serialize()).toJS);
  }

  (CborMessageArgs, int?) _getResult(String message) {
    int? id;
    try {
      final msg =
          WorkerMessage.deserialize(bytes: BytesUtils.fromHexString(message));
      id = msg.id;
      if (msg.type.isEncrypted) {
        final encryptedMessage = msg.cast<WorkerEncryptedMessage>();
        final decrypt =
            chacha.decrypt(encryptedMessage.nonce, encryptedMessage.message);
        return (CborMessageArgs.deserialize(decrypt!), id);
      }
      return (CborMessageArgs.deserialize(msg.message), id);
    } catch (e) {
      return (EncryptedIsolateMessageController.verificationFailed, id);
    }
  }
}

class _SyncWorkerConnection extends _WorkerConnection {
  _SyncWorkerConnection(
      {required super.worker,
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
}
