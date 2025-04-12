import 'dart:async';
import 'dart:js_interop';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_native_support/models/events/models/wallet_event.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import '../../../webview.dart';
import '../../constant/constant.dart';
import '../../models/models.dart';
import '../../models/models/networks/wallet_standard.dart';
import '../../utils/utils.dart';
import 'package:mrt_native_support/web/mrt_native_web.dart';
import '../networks/aptos.dart';
import '../networks/bitcoin.dart';
import '../networks/cosmos.dart';
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
part 'wallet_standard.dart';

@JS("onmessage")
external set onMessage(JSFunction _);
typedef SendMessageToClient = void Function(
    WalletMessageEvent, JSClientType client);
typedef SENDINTERNALWALLETMESSAGE = Future<Web3MessageCore> Function(
    {required JSClientType client, required Web3WalletRequestParams request});
typedef ONCHANGESTATE = void Function();

extension _FindClient on JSClientType {}

enum JSWalletMode {
  extension,
  webview;

  bool get isExtension => this == extension;
}

abstract class JSWalletHandler with JSWalletStandardHandler {
  JSWalletMode get mode;
  @override
  late final Map<JSClientType, JSWalletStandardNetworkHandler> _networks = {
    JSClientType.ethereum: JSEthereumHandler(
        sendMessageToClient: _sendEventToClient,
        sendInternalMessage: _sendInternalWalletMessage),
    JSClientType.tron: JSTronHandler(
        sendMessageToClient: _sendEventToClient,
        sendInternalMessage: _sendInternalWalletMessage),
    JSClientType.solana: JSSolanaHandler(
        sendMessageToClient: _sendEventToClient,
        sendInternalMessage: _sendInternalWalletMessage),
    JSClientType.ton: JSTonHandler(
        sendMessageToClient: _sendEventToClient,
        sendInternalMessage: _sendInternalWalletMessage),
    JSClientType.stellar: JSStellarHandler(
        sendMessageToClient: _sendEventToClient,
        sendInternalMessage: _sendInternalWalletMessage),
    JSClientType.substrate: JSSubstrateHandler(
        sendMessageToClient: _sendEventToClient,
        sendInternalMessage: _sendInternalWalletMessage),
    JSClientType.aptos: JSAptosHandler(
        sendMessageToClient: _sendEventToClient,
        sendInternalMessage: _sendInternalWalletMessage),
    JSClientType.sui: JSSuiHandler(
        sendMessageToClient: _sendEventToClient,
        sendInternalMessage: _sendInternalWalletMessage),
    JSClientType.cosmos: JSCosmosHandler(
        sendMessageToClient: _sendEventToClient,
        sendInternalMessage: _sendInternalWalletMessage),
    JSClientType.bitcoin: JSBitcoinHandler(
        sendMessageToClient: _sendEventToClient,
        sendInternalMessage: _sendInternalWalletMessage),
  };

  String get clientId;
  late final String _id = JsUtils.toWalletId(clientId);
  final MessageCompleterHandler completer = MessageCompleterHandler();
  final ChaCha20Poly1305 _crypto;
  JSWalletHandler._(this._crypto);

  void handleClientMessage(PageMessage request) {
    final client = request.clientType;
    switch (request.data.messageType) {
      case PageMessageType.event:
        if (client == null) {
          _onGlobalEvent(request.data.asEvent());
        } else {
          _networks[client]?.event(request.data.asEvent());
        }

        break;
      case PageMessageType.request:
        final result = _completeJsRequest(request);
        result.then(_sendMessageToClient);
        result.catchError((e) {
          final message = WalletMessage.response(
              client: request.clientType,
              requestId: request.requestId,
              data: WalletMessageResponse.fail(
                  Web3RequestExceptionConst.internalError.toJson().jsify()));
          _sendMessageToClient(message);
          return message;
        });
        break;
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

  @override
  void _sendEventToClient(WalletMessageEvent event, JSClientType? client) {
    _sendMessageToClient(WalletMessage.event(client: client, data: event));
  }

  Future<void> _sendMessageToWallet(
      {required Web3WalletRequestParams message, required String requestId});

  Web3EncryptedMessage _encryptMessage(Web3MessageCore message) {
    final nonce = QuickCrypto.generateRandom(12);
    final List<int> encryptedBytes =
        _crypto.encrypt(nonce, message.toCbor().encode());
    return Web3EncryptedMessage(message: encryptedBytes, nonce: nonce);
  }

  Future<Web3MessageCore> _sendInternalWalletMessage(
      {required JSClientType client,
      required Web3WalletRequestParams request}) async {
    final result = await _buildAndSendMessage(client: client, message: request);
    final Web3MessageCore response = result.$1;
    if (response.type == Web3MessageTypes.error) {
      final result = response.cast<Web3ExceptionMessage>();
      throw result.toException();
    }
    return response.cast();
  }

  Future<(Web3MessageCore, Web3RequestParams?)> _buildAndSendMessage(
      {PageMessage? params,
      Web3MessageCore? message,
      JSClientType? client}) async {
    final completer = this.completer.nextRequest;
    final String requestId = completer.id;
    try {
      if (message == null) {
        if (params == null) {
          throw WalletExceptionConst.invalidRequest;
        }
        final request = params.data.asRequest();
        Web3GlobalRequestMethods? globalMethod =
            Web3GlobalRequestMethods.fromName(request.method);
        if (globalMethod != null) {
          message = await _onGlobalRequest(
              globalMethod: globalMethod, client: client);
        } else {
          final handler = _networks[client];
          if (handler == null) {
            throw WalletExceptionConst.invalidRequest;
          }
          message ??= await handler.request(request);
        }
      }

      switch (message.type) {
        case Web3MessageTypes.globalResponse:
        case Web3MessageTypes.walletResponse:
          this.completer.complete(response: message, requestId: requestId);
          break;
        default:
          await _sendMessageToWallet(
              message: message.cast(), requestId: requestId);
          break;
      }
    } on Web3RequestException catch (e) {
      final exception = e.toResponseMessage();
      this.completer.complete(response: exception, requestId: requestId);
    } catch (e) {
      final exception =
          Web3RequestExceptionConst.internalError.toResponseMessage();
      this.completer.complete(response: exception, requestId: requestId);
    }
    final response = await completer.wait;
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
        Web3MessageTypes.globalResponse => await _finalizeGlobalResponse(
            message: params.data.asRequest(),
            response: response.cast(),
            params: request),
        Web3MessageTypes.walletResponse => await handler!
            .finalizeWalletResponse(
                message: params.data.asRequest(),
                response: response.cast(),
                params: request),
        Web3MessageTypes.error => await handler?.finalizeError(
                message: params.data.asRequest(),
                error: response.cast(),
                params: request) ??
            WalletMessageResponse.fail(
                response.cast<Web3ExceptionMessage>().toJson().jsify()),
        _ => WalletMessageResponse.fail(
            Web3RequestExceptionConst.invalidRequest.toJson().jsify())
      };
      return WalletMessage.response(
          requestId: params.requestId,
          client: params.clientType,
          data: message);
    } finally {
      handler?.onRequestDone(params.data.asRequest());
    }
  }

  Future<void> _updateAuthenticated(Web3APPData authenticated) async {
    for (final i in authenticated.networks) {
      final client = JSClientType.fronNetworkName(i.name);
      final event = await _networks[client]?.initChain(authenticated);
      if (event == null) continue;
      _sendEventToClient(WalletMessageEvent.build(data: event), client);
    }
    _sendGlobalEvent();
  }

  void _handleOnResponse(WalletEvent request) async {
    try {
      final data = List<int>.from(request.data);
      final encryptedMessage = Web3EncryptedMessage.deserialize(bytes: data);
      final decode =
          _crypto.decrypt(encryptedMessage.nonce, encryptedMessage.message);
      final message = Web3MessageCore.deserialize(bytes: decode);
      switch (message.type) {
        case Web3MessageTypes.globalResponse:
          final Web3GlobalResponseMessage msg =
              message.cast<Web3GlobalResponseMessage>();
          if (msg.authenticated != null) {
            await _updateAuthenticated(msg.authenticated!);
          }
          completer.complete(response: msg, requestId: request.requestId);
          break;
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
    } on Web3RequestException catch (e) {
      final toMessage = e.toResponseMessage(requestId: request.requestId);
      completer.complete(response: toMessage, requestId: request.requestId);
    } catch (e) {
      final toMessage = Web3RequestExceptionConst.internalError
          .toResponseMessage(requestId: request.requestId);
      completer.complete(response: toMessage, requestId: request.requestId);
    }
  }

  bool _onResponse(WalletEvent? request) {
    assert(request?.clientId == clientId, 'invalid clinet id');
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
