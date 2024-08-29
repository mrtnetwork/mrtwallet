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
import '../networks/tron.dart';
part "../webview.dart";
part "../extention.dart";

typedef SendMessageToClient = void Function(JSWalletMessage);

abstract class JSWalletHandler {
  late final JSEthereumHandler ethereumHandler =
      JSEthereumHandler(sendMessageToClient: _sendMessageToClient);
  late final JSTronHandler tronHandler =
      JSTronHandler(sendMessageToClient: _sendMessageToClient);

  String get clientId;
  late final String _id = JsUtils.toWalletId(clientId);
  final MessageCompleterHandler completer = MessageCompleterHandler();
  final ChaCha20Poly1305 _crypto;
  abstract ChainsHandler _chain;
  JSWalletHandler._(this._crypto);

  void _onClientEvent(CustomEvent response) {
    final JSPageRequest request =
        JSPageRequest.deserialize(bytes: response.detailBytes());
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
      {required JSPageRequest? params, required String requestId}) async {
    try {
      Web3MessageCore message = switch (params?.type) {
        JSClientType.ethereum => await ethereumHandler
            .request(params!.message as ClientMessageEthereum),
        JSClientType.tron =>
          await tronHandler.request(params!.message as ClientMessageTron),
        _ => throw Web3RequestExceptionConst.invalidRequest
      };
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

  Future<JSWalletMessageResponse> _completeJsRequest(
      JSPageRequest params) async {
    try {
      final request = completer.nextRequest;
      _buildAndSendMessage(params: params, requestId: request.id);
      final message = await request.wait;
      return switch (message.type) {
        Web3MessageTypes.response => JSWalletMessageResponse(
            requestId: params.id,
            data: message.cast<Web3ResponseMessage>().result,
            client: params.type,
            status: JSWalletResponseType.success),
        Web3MessageTypes.walletResponse => JSWalletMessageResponse(
            requestId: params.id,
            data: message.cast<Web3WalletResponseMessage>().result,
            client: params.type,
            status: JSWalletResponseType.success),
        Web3MessageTypes.error => JSWalletMessageResponse(
            requestId: params.id,
            data: message.cast<Web3ExceptionMessage>().toJson(),
            client: params.type,
            status: JSWalletResponseType.failed),
        _ => throw Web3RequestExceptionConst.invalidRequest
      };
    } finally {
      switch (params.type) {
        case JSClientType.ethereum:
          ethereumHandler
              .onRequestDone(params.message as ClientMessageEthereum);
          break;
        case JSClientType.tron:
          tronHandler.onRequestDone(params.message as ClientMessageTron);
          break;
        default:
      }
    }
  }

  void _updateAuthenticated(Web3APPAuthentication authenticated,
      {NetworkType? network}) {
    switch (network) {
      case NetworkType.ethereum:
        ethereumHandler.initChain(
            chainHandler: _chain, authenticated: authenticated);
        break;
      case NetworkType.tron:
        tronHandler.initChain(
            chainHandler: _chain, authenticated: authenticated);
        break;
      default:
        tronHandler.initChain(
            chainHandler: _chain, authenticated: authenticated);
        ethereumHandler.initChain(
            chainHandler: _chain, authenticated: authenticated);
        break;
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
          _updateAuthenticated(msg.authenticated, network: msg.network);
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
          _updateAuthenticated(msg.authenticated, network: null);
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
}
