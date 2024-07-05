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

IsolateCryptoWoker getCryptoWorker() => _WebCryptoWorker._web;

class _WebCryptoWorker extends IsolateCryptoWoker {
  static final _WebCryptoWorker _web = _WebCryptoWorker._();

  static const String _scriptHash =
      "74f0a7867518f8d84c0314c4007cc746d421c92984f339c5d6e43ca6a4d9f496";
  static const String _wasmhash =
      "748ef3c4836a896629903872170a45ef79c6f01464d70200a682e3bca31a7fcf";
  _WebCryptoWorker._() : super.parent();
  static const String _wasmPath = "crypto.wasm";
  static const String _scryptPath = "crypto.mjs";
  bool _hasIsolate = true;
  @override
  bool get hasIsolate => _hasIsolate;
  int _id = 0;

  final _lock = SynchronizedLock();

  @override
  Future<T> getResult<T extends ArgsBytes>(WorkerMessageBytes message) async {
    return _lock.synchronized(() async {
      await _init();
      final request = WorkerMessageRequest(message: message, id: _id++);
      final args = _connector!.sentRequest(request);
      if (args.type == ArgsType.exception) {
        throw WalletException((args as ExceptionArg).message);
      }
      if (args is! T) {
        throw WalletExceptionConst.dataVerificationFailed;
      }
      return args;
    });
  }

  _WebConnectionInfo? _connector;

  Future<JSObject?> _loadScript() async {
    final file = await html.window.fetch(_scryptPath);
    final buffer = await js_util
        .promiseToFuture(js_util.callMethod<Object>(file, "text", []));
    final scriptHash = BytesUtils.toHexString(
        QuickCrypto.sha3256Hash(StringUtils.encode(buffer)));
    if (scriptHash == _scriptHash) return null;
    final loadMDL =
        ((await importModule("data:text/javascript,$buffer").toDart));
    if (js_util.hasProperty(loadMDL, "instantiate")) {
      return loadMDL;
    }
    return null;
  }

  Future<Object?> _compile() async {
    final file = await html.window.fetch(_wasmPath);
    ByteBuffer buffer = await js_util
        .promiseToFuture(js_util.callMethod<Object>(file, "arrayBuffer", []));
    final wasmHash =
        BytesUtils.toHexString(QuickCrypto.sha3256Hash(buffer.asUint8List()));
    if (wasmHash == _wasmhash) return null;
    final wasm = js_util.getProperty(js_util.globalThis, "WebAssembly");
    final moudle = await js_util
        .promiseToFuture(js_util.callMethod<Object>(wasm, "compile", [buffer]));
    return moudle;
  }

  Future<_WebConnectionInfo?> _run(
      {required JSObject moudle, required Object wasm}) async {
    const String methodOne = "mrtJsHandler";
    const String methodTwo = "mrtWalletActivation";
    final instantiate = await js_util.promiseToFuture(
        js_util.callMethod<Object>(moudle, "instantiate", [wasm]));
    js_util.callMethod(moudle, "invoke", [instantiate, methodOne, methodTwo]);
    if (js_util.hasProperty(js_util.globalThis, methodTwo)) {
      final keyStr =
          js_util.callMethod<String>(js_util.globalThis, methodTwo, []);
      if (js_util.hasProperty(js_util.globalThis, methodOne)) {
        return _WebConnectionInfo(
            funcName: methodOne, key: BytesUtils.fromHexString(keyStr));
      }
    }
    return null;
  }

  Future<_WebConnectionInfo?> _loadMoudle() async {
    try {
      if (_connector?.isActive ?? false) {
        return _connector!;
      }
      final moudle = await _loadScript();
      final wasm = await _compile();
      if (moudle != null && wasm != null) {
        final run = await _run(moudle: moudle, wasm: wasm);
        if (run != null) return run;
      }
      throw FailedIsolateInitialization.failed;
    } catch (e) {
      _hasIsolate = false;
      return null;
    }
  }

  Future<void> _init() async {
    _connector ??= await _loadMoudle();
  }
}

class _WebConnectionInfo {
  final String funcName;
  final ChaCha20Poly1305 chacha;
  _WebConnectionInfo({
    required this.funcName,
    required List<int> key,
  }) : chacha = ChaCha20Poly1305(key);

  bool get isActive => js_util.hasProperty(js_util.globalThis, funcName);

  String _toEncryptedMessage(WorkerMessageRequest request) {
    final nonce = QuickCrypto.generateRandom(16);
    final enc = chacha.encrypt(nonce, request.toCbor().encode());
    final encryptMessage =
        WorkerEncryptedMessage(message: enc, nonce: nonce, id: request.id);
    return BytesUtils.toHexString(encryptMessage.toCbor().encode());
  }

  ArgsBytes sentRequest(WorkerMessageRequest request) {
    final encryptMessage = _toEncryptedMessage(request);
    final response =
        js_util.callMethod(js_util.globalThis, funcName, [encryptMessage]);
    return getResult(response).args;
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
