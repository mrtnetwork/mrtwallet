// ignore_for_file: unused_import,

import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:blockchain_utils/crypto/crypto/chacha20poly1305/chacha20poly1305.dart';
import 'package:blockchain_utils/crypto/quick_crypto.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wroker/core/worker.dart';
import 'package:mrt_wallet/wroker/crypto/crypto.dart';
import 'package:mrt_wallet/wroker/models/bytes.dart';
import 'package:mrt_wallet/wroker/models/completer.dart';
import 'package:mrt_wallet/wroker/models/message_type.dart';
import 'package:mrt_wallet/wroker/models/request_message.dart';
import 'package:mrt_wallet/wroker/models/response_message.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js_util' as js_util;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;
import 'dart:js_interop';

import 'exception.dart';
import 'package:flutter/services.dart' show rootBundle;

IsolateCryptoWoker getCryptoWorker() => _WebCryptoWorker._web;

class _WebCryptoWorker extends IsolateCryptoWoker {
  static final _WebCryptoWorker _web = _WebCryptoWorker._();

  static const String _scriptHash =
      "74f0a7867518f8d84c0314c4007cc746d421c92984f339c5d6e43ca6a4d9f496";
  static const String _wasmhash =
      "748ef3c4836a896629903872170a45ef79c6f01464d70200a682e3bca31a7fcf";
  static const String _workerHash =
      "3e271fd1f7f2f62d511d7d0d4c2a39328b60ec83e947290a4507edf64db2d335";
  _WebCryptoWorker._() : super.parent();
  static const String _wasmPath = "assets/wasm/crypto.wasm";
  static const String _wrokerJs = "assets/wasm/wasm.js";
  static const String _scryptPath = "assets/wasm/crypto.mjs";
  int _retryFailed = 0;
  late bool _hasIsolate = html.Worker.supported;
  @override
  bool get hasIsolate => _hasIsolate;
  int _id = 0;

  final _lock = SynchronizedLock();

  @override
  Future<T> getResult<T extends ArgsBytes>(WorkerMessageBytes message) async {
    await _lock.synchronized(() async {
      try {
        await _init();
      } on IsolateAuthenticated {
        _hasIsolate = false;
        throw FailedIsolateInitialization.failed;
      } catch (e) {
        _retryFailed += 1;
        throw FailedIsolateInitialization.failed;
      } finally {
        if (_retryFailed > 3) {
          _hasIsolate = false;
        }
      }
    });

    final request = WorkerMessageRequest(message: message, id: _id++);
    final args = await _connector!.sentRequest(request);
    if (args.type == ArgsType.exception) {
      throw WalletException((args as ExceptionArg).message);
    }
    if (args is! T) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    return args;
  }

  _WebConnectionInfo? _connector;

  Future<String> _loadWorker() async {
    final file = await rootBundle.loadString(_wrokerJs);
    final workerHash = BytesUtils.toHexString(
        QuickCrypto.sha3256Hash(StringUtils.encode(file)));
    if (workerHash != _workerHash) {
      throw IsolateAuthenticated.failed;
    }
    return file;
  }

  Future<ByteBuffer> _loadWasm() async {
    final file = await rootBundle.load(_wasmPath);
    final wasmHash = BytesUtils.toHexString(
        QuickCrypto.sha3256Hash(file.buffer.asUint8List()));
    if (wasmHash != _wasmhash) {
      throw IsolateAuthenticated.failed;
    }
    return file.buffer;
  }

  Future<String> _loadScript() async {
    final file = await rootBundle.loadString(_scryptPath);
    final scriptHash = BytesUtils.toHexString(
        QuickCrypto.sha3256Hash(StringUtils.encode(file)));
    if (scriptHash != _scriptHash) {
      throw IsolateAuthenticated.failed;
    }
    return file;
  }

  Future<_WebConnectionInfo> _loadMoudle() async {
    if (_connector?.isActive ?? false) {
      return _connector!;
    }

    Completer<_WebConnectionInfo> completer = Completer();

    if (html.Worker.supported) {
      final String workerJs;
      final String moudle;
      final ByteBuffer wasm;
      try {
        workerJs = await _loadWorker();
        moudle = await _loadScript();
        wasm = await _loadWasm();
      } catch (e) {
        throw IsolateAuthenticated.failed;
      }
      final worker = html.Worker("data:text/javascript,$workerJs");
      void onEvent(html.Event event) {
        final String key = (event as html.MessageEvent).data;
        completer.complete(_WebConnectionInfo(
            key: BytesUtils.fromHexString(key), worker: worker));
      }

      worker.addEventListener("message", onEvent);
      worker.postMessage({"module": moudle, "wasm": wasm});
      final result =
          await completer.future.timeout(const Duration(seconds: 10));
      worker.removeEventListener("message", onEvent);
      return result;
    }

    // return _runJs();

    throw FailedIsolateInitialization.failed;
  }

  Future<void> _init() async {
    _connector ??= await _loadMoudle();
  }
}

class _WebConnectionInfo {
  final ChaCha20Poly1305 chacha;
  final html.Worker worker;
  _WebConnectionInfo({
    required List<int> key,
    required this.worker,
  }) : chacha = ChaCha20Poly1305(key) {
    setResponse();
  }

  final Map<int, WorkerMessageCompleter> _requests = {};
  // final id = WorkerMessageCompleter(_id++);
  // _requests[id.id] = id;
  void setResponse() {
    worker.addEventListener("message", (e) {
      final String message = (e as html.MessageEvent).data;
      final result = getResult(message);
      _requests[result.id]?.complete(result);
    });
  }

  bool get isActive => true;

  String _toEncryptedMessage(WorkerMessageRequest request) {
    final nonce = QuickCrypto.generateRandom(16);
    final enc = chacha.encrypt(nonce, request.toCbor().encode());
    final encryptMessage =
        WorkerEncryptedMessage(message: enc, nonce: nonce, id: request.id);
    return BytesUtils.toHexString(encryptMessage.toCbor().encode());
  }

  Future<ArgsBytes> sentRequest(WorkerMessageRequest request) async {
    final id = WorkerMessageCompleter(request.id);
    _requests[id.id] = id;
    final encryptMessage = _toEncryptedMessage(request);
    worker.postMessage(encryptMessage);
    final r = await id.getResult();
    return r;
  }

  WorkerMessageResponse getResult(dynamic message) {
    int? id;
    try {
      final encryptMessageBytes = BytesUtils.fromHexString(message);
      final encryptedMessage =
          WorkerEncryptedMessage.deserialize(encryptMessageBytes);
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
