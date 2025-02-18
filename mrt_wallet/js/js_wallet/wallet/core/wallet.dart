import 'dart:async';
import 'dart:js_interop';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_native_support/models/events/models/wallet_event.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import '../../../webview.dart';
import '../../constant/constant.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import 'package:mrt_native_support/web/mrt_native_web.dart';
import '../networks/aptos.dart';
import '../networks/ethereum.dart';
import '../networks/solana.dart';
import '../networks/stellar.dart';
import '../networks/substrate.dart';
import '../networks/sui.dart';
import '../networks/ton.dart';
import '../networks/tron.dart';
import 'network_handler.dart';
part "../webview.dart";
part "../extension.dart";

@JS("onmessage")
external set onMessage(JSFunction _);
typedef SendMessageToClient = void Function(
    WalletMessageEvent, JSClientType client);

extension _FindClient on JSClientType {}

enum JSWalletMode {
  extension,
  webview;

  bool get isExtension => this == extension;
}

abstract class JSWalletHandler {
  JSWalletMode get mode;
  late final Map<JSClientType, JSNetworkHandler> _networks = {
    JSClientType.ethereum:
        JSEthereumHandler(sendMessageToClient: _sendEventToClient),
    JSClientType.tron: JSTronHandler(sendMessageToClient: _sendEventToClient),
    JSClientType.solana:
        JSSolanaHandler(sendMessageToClient: _sendEventToClient),
    JSClientType.ton: JSTonHandler(sendMessageToClient: _sendEventToClient),
    JSClientType.stellar:
        JSStellarHandler(sendMessageToClient: _sendEventToClient),
    JSClientType.substrate:
        JSSubstrateHandler(sendMessageToClient: _sendEventToClient),
    JSClientType.aptos: JSAptosHandler(sendMessageToClient: _sendEventToClient),
    JSClientType.sui: JSSuiHandler(sendMessageToClient: _sendEventToClient)
  };

  String get clientId;
  late final String _id = JsUtils.toWalletId(clientId);
  final MessageCompleterHandler completer = MessageCompleterHandler();
  final ChaCha20Poly1305 _crypto;
  JSWalletHandler._(this._crypto);

  void handleClientMessage(PageMessage request) {
    try {
      switch (request.data.messageType) {
        case PageMessageType.event:
          _networks[request.clientType]?.event(request.data.asEvent());
          break;
        case PageMessageType.request:
          final result = _completeJsRequest(request);
          result.then(_sendMessageToClient);
          result.catchError((e) {
            final message = WalletMessage.response(
                client: request.clientType,
                requestId: request.id,
                id: request.data.asRequest().id,
                data: WalletMessageResponse.fail(
                    Web3RequestExceptionConst.internalError.toJson().jsify()));
            _sendMessageToClient(message);
            return message;
          });
          break;
      }
    } catch (e) {
      WalletLogging.error("client error $e");
    }
  }

  void _onClientEvent(CustomEvent response) {
    final PageMessage request = response.detail as PageMessage;
    handleClientMessage(request);
  }

  void _listenOnClients() {
    jsWindow.addEventListener(_id, _onClientEvent.toJS);
  }

  void _sendMessageToClient(WalletMessage response) {
    final event = CustomEvent.create(
        type: JsUtils.toEthereumClientId(clientId),
        detail: response,
        clone: true);
    jsWindow.dispatchEvent(event);
  }

  void _sendEventToClient(WalletMessageEvent event, JSClientType client) {
    _sendMessageToClient(WalletMessage.event(client: client, data: event));
  }

  Future<void> _sendDisconnect(
      {required Web3MessageCore message,
      required String requestId,
      required NetworkType network}) {
    return _sendMessageToWallet(message: message, requestId: requestId);
  }

  Future<void> _sendMessageToWallet(
      {required Web3MessageCore message, required String requestId});

  Web3EncryptedMessage _encryptMessage(Web3MessageCore message) {
    final nonce = QuickCrypto.generateRandom(12);
    final List<int> encryptedBytes =
        _crypto.encrypt(nonce, message.toCbor().encode());
    return Web3EncryptedMessage(message: encryptedBytes, nonce: nonce);
  }

  Future<(Web3MessageCore, Web3RequestParams?)> _buildAndSendMessage(
      {required PageMessage params, required JSClientType client}) async {
    final request = completer.nextRequest;
    final String requestId = request.id;
    Web3MessageCore? message;
    try {
      final handler = _networks[client];
      if (handler == null) {
        throw WalletExceptionConst.invalidRequest;
      }
      final request = params.data.asRequest();
      final globalMethod = Web3GlobalRequestMethods.fromName(request.method);
      switch (globalMethod) {
        case Web3GlobalRequestMethods.disconnect:
          message = await handler.discoonect();
          break;
      }
      message ??= await handler.request(request);
      if (globalMethod == Web3GlobalRequestMethods.disconnect &&
          mode.isExtension) {
        await _sendDisconnect(
            message: message,
            requestId: requestId,
            network: handler.networkType);
      } else {
        switch (message.type) {
          case Web3MessageTypes.response:
          case Web3MessageTypes.walletResponse:
            completer.complete(response: message, requestId: requestId);
            break;
          default:
            await _sendMessageToWallet(message: message, requestId: requestId);
            break;
        }
      }
    } on Web3RequestException catch (e) {
      final exception = e.toResponseMessage();
      completer.complete(response: exception, requestId: requestId);
    } catch (e) {
      final exception =
          Web3RequestExceptionConst.internalError.toResponseMessage();
      completer.complete(response: exception, requestId: requestId);
    }
    final response = await request.wait;
    if (message?.type != Web3MessageTypes.walletRequest) {
      return (response, null);
    }
    return (response, message?.cast<Web3RequestParams>());
  }

  Future<WalletMessage> _completeJsRequest(PageMessage params) async {
    final client = params.clientType;
    final handler = _networks[client];
    try {
      final result = await _buildAndSendMessage(params: params, client: client);
      final Web3MessageCore response = result.$1;
      final Web3RequestParams? request = result.$2;
      final WalletMessageResponse message = switch (response.type) {
        Web3MessageTypes.response => handler!.finilizeResponse(
            message: params.data.asRequest(), response: response.cast()),
        Web3MessageTypes.walletResponse => handler!.finilizeWalletResponse(
            message: params.data.asRequest(),
            response: response.cast(),
            params: request),
        Web3MessageTypes.error => handler?.finilizeError(
                message: params.data.asRequest(),
                error: response.cast(),
                params: request) ??
            WalletMessageResponse.fail(response.toJson().jsify()),
        _ => WalletMessageResponse.fail(
            Web3RequestExceptionConst.invalidRequest.toJson().jsify())
      };
      return WalletMessage.response(
          requestId: params.id,
          id: params.data.asRequest().id,
          client: params.clientType,
          data: message);
    } catch (e) {
      rethrow;
    } finally {
      handler?.onRequestDone(params.data.asRequest());
    }
  }

  Future<void> _updateAuthenticated(Web3APPData authenticated) async {
    for (final i in authenticated.networks) {
      final client = JSClientType.fronNetworkName(i.name);
      await _networks[client]?.initChain(authenticated);
    }
  }

  void _handleOnResponse(WalletEvent request) async {
    try {
      final data = List<int>.from(request.data);
      final encryptedMessage = Web3EncryptedMessage.deserialize(bytes: data);
      final decode =
          _crypto.decrypt(encryptedMessage.nonce, encryptedMessage.message);
      final message = Web3MessageCore.deserialize(bytes: decode);
      switch (message.type) {
        case Web3MessageTypes.walletResponse:
          final Web3WalletResponseMessage msg =
              message.cast<Web3WalletResponseMessage>();
          if (msg.authenticated != null) {
            await _updateAuthenticated(msg.authenticated!);
          }

          completer.complete(response: msg, requestId: request.requestId);
          break;
        case Web3MessageTypes.error:
          final msg = message.cast<Web3ExceptionMessage>();
          if (msg.authenticated != null) {
            await _updateAuthenticated(msg.authenticated!);
          }
          completer.complete(response: msg, requestId: request.requestId);
          break;
        case Web3MessageTypes.chains:
          final Web3ChainMessage msg = message.cast<Web3ChainMessage>();
          _updateAuthenticated(msg.authenticated);
          break;
        default:
      }
    } on Web3RequestException catch (e, s) {
      WalletLogging.log("got errosr $e $s ");
      final toMessage = e.toResponseMessage(requestId: request.requestId);
      completer.complete(response: toMessage, requestId: request.requestId);
    } catch (e, s) {
      WalletLogging.log("got error $e $s");
      final toMessage = Web3RequestExceptionConst.internalError
          .toResponseMessage(requestId: request.requestId);
      completer.complete(response: toMessage, requestId: request.requestId);
    }
  }

  bool _onResponse(WalletEvent? request) {
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
