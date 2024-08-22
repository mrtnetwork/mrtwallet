import 'dart:async';
import 'dart:js_interop';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_native_support/models/events/models/wallet_event.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import '../../constant/constant.dart';
import '../../models/models.dart';
import '../../page_script/scripts.dart';
import '../../utils/utils.dart';
import 'package:mrt_native_support/web/mrt_native_web.dart';

import '../networks/ethereum.dart';
part "../webview.dart";
// part "../networks/ethereum.dart";
part "../extention.dart";

typedef SendMessageToClient = void Function(JSWalletMessage);

abstract class JSWalletHandler {
  late final JsEthereumHandler ethereumHandler =
      JsEthereumHandler(_sendMessageToClient);

  String get clientId;
  late final String _id = JsUtils.toWalletId(clientId);
  final MessageCompleterHandler completer = MessageCompleterHandler();
  final ChaCha20Poly1305 _crypto;
  abstract ChainsHandler _chain;
  JSWalletHandler._(this._crypto);

  void _onClientEvent(CustomEvent response) {
    final ClientMessage request =
        ClientMessage.deserialize(bytes: response.detailBytes());
    final result = _completeJsRequest(request);
    result.then(_sendMessageToClient);
  }

  void _listenOnClients() {
    jsWindow.addEventListener(_id, _onClientEvent.toJS);
  }

  void _sendMessageToClient(JSWalletMessage response) {
    final event = CustomEvent.create(
        type: JsUtils.toEthereumClientId(clientId),
        data: response.toCbor().encode(),
        clone: true);
    jsWindow.dispatchEvent(event);
  }

  Future<void> _sendMessageToWallet(
      {required Web3MessageCore message, required String requestId});

  Web3EncryptedMessage _encryptMessage(Web3MessageCore message) {
    final nonce = QuickCrypto.generateRandom(12);
    final List<int> encryptedBytes =
        _crypto.encrypt(nonce, message.toCbor().encode());
    return Web3EncryptedMessage(message: encryptedBytes, nonce: nonce);
  }

  Future<void> _buildAndSendMessage(
      {required ClientMessage? params, required String requestId}) async {
    try {
      Web3MessageCore message = await _createMessage(params!);
      switch (message.type) {
        case Web3MessageTypes.response:
        case Web3MessageTypes.walletResponse:
          completer.complete(response: message, requestId: requestId);
          break;
        default:
          await _sendMessageToWallet(message: message, requestId: requestId);
          break;
      }
    } on Web3RequestException catch (e) {
      final exception = e.toResponseMessage();
      completer.complete(response: exception, requestId: requestId);
    } catch (e) {
      final exception =
          Web3RequestExceptionConst.internalError.toResponseMessage();
      completer.complete(response: exception, requestId: requestId);
    }
  }

  Future<Web3MessageCore> _completeMessage(ClientMessage params) async {
    try {
      final request = completer.createRequest();
      _buildAndSendMessage(params: params, requestId: request.id);
      final result = await request.completer.future;
      return result;
    } finally {
      switch (params.type) {
        case JSClientType.ethereum:
          ethereumHandler.onRequestDone(params as ClientMessageEthereum);
          break;
        default:
      }
    }
  }

  Future<JSWalletMessageResponse> _completeJsRequest(
      ClientMessage params) async {
    Web3MessageCore message;
    try {
      message = await _completeMessage(params);
    } on Web3RequestException catch (e) {
      message = e.toResponseMessage();
    } catch (e) {
      message = Web3RequestExceptionConst.internalError.toResponseMessage();
    }
    return _parseWalletResponse(message: message, request: params);
  }

  void _updateAuthenticated(Web3APPAuthentication authenticated,
      {bool initChain = false}) {
    if (initChain) {
      ethereumHandler.initChain(
          chains: _chain.chains().whereType<EthereumChain>().toList(),
          permission:
              authenticated.getChainFromNetworkType(NetworkType.ethereum) ??
                  Web3EthereumChain.create());
    } else {
      ethereumHandler.updateChain(
          authenticated.getChainFromNetworkType(NetworkType.ethereum) ??
              Web3EthereumChain.create());
    }
  }

  void _handleOnResponse(WalletEvent request) {
    try {
      final data = List<int>.from(request.data);
      final encryptedMessage = Web3EncryptedMessage.deserialize(bytes: data);
      final decode =
          _crypto.decrypt(encryptedMessage.nonce, encryptedMessage.message);
      final message = Web3MessageCore.deserialize(bytes: decode);
      switch (message.type) {
        case Web3MessageTypes.response:
          final Web3ResponseMessage msg = message.cast<Web3ResponseMessage>();
          completer.complete(response: msg, requestId: request.requestId);
          break;
        case Web3MessageTypes.walletResponse:
          final Web3WalletResponseMessage msg =
              message.cast<Web3WalletResponseMessage>();
          _updateAuthenticated(msg.authenticated);
          completer.complete(response: msg, requestId: request.requestId);
          break;
        case Web3MessageTypes.error:
          completer.complete(
              response: message.cast<Web3ExceptionMessage>(),
              requestId: request.requestId);
          break;
        case Web3MessageTypes.chains:
          final Web3ChainMessage msg = message.cast<Web3ChainMessage>();
          final chains = ChainsHandler.deserialize(bytes: msg.message);
          _chain = chains;
          _updateAuthenticated(msg.authenticated, initChain: true);
          if (msg.response != null) {
            completer.complete(
                response: msg.response!, requestId: request.requestId);
          }
          break;
        default:
      }
    } on Web3RequestException catch (e) {
      final toMessage = e.toResponseMessage(requestId: request.requestId);
      completer.complete(response: toMessage, requestId: request.requestId);
    } catch (e) {
      final toMessage = Web3RequestExceptionConst.internalError
          .toResponseMessage(requestId: request.requestId);
      completer.complete(response: toMessage, requestId: request.requestId);
    }
  }

  bool _onResponse(JSWalletEvent jsRequest) {
    final request = jsRequest.toEvent();
    if (request?.clientId != clientId) {
      return false;
    }
    switch (request!.type) {
      case WalletEventTypes.exception:
        final message = Web3ExceptionMessage.deserialize(bytes: request.data);
        completer.complete(response: message, requestId: request.requestId);
        break;
      default:
        _handleOnResponse(request);
        break;
    }

    return true;
  }

  Future<Web3MessageCore> _createMessage(ClientMessage params) async {
    if (params.type == JSClientType.ethereum) {
      return await ethereumHandler.request(params as ClientMessageEthereum);
    }
    throw Web3RequestExceptionConst.invalidRequest;
  }

  JSWalletMessageResponse _parseWalletResponse(
      {required Web3MessageCore message, required ClientMessage request}) {
    Object? data;
    JSWalletResponseType type = JSWalletResponseType.success;
    switch (message.type) {
      case Web3MessageTypes.response:
        final responseMessage = message.cast<Web3ResponseMessage>();
        data = responseMessage.result;
        break;
      case Web3MessageTypes.walletResponse:
        final responseMessage = message.cast<Web3WalletResponseMessage>();
        data = responseMessage.result;
        break;
      case Web3MessageTypes.error:
        final responseMessage = message.cast<Web3ExceptionMessage>();
        data = responseMessage.toJson();
        type = JSWalletResponseType.failed;
        break;
      default:
        throw UnimplementedError("Invalid request type.");
    }
    return JSWalletMessageResponse(
        requestId: request.id, data: data, client: request.type, status: type);
  }
}
