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
import '../networks/solana.dart';
import '../networks/stellar.dart';
import '../networks/ton.dart';
import '../networks/tron.dart';
import 'network_handler.dart';
part "../webview.dart";
part "../extension.dart";

typedef SendMessageToClient = void Function(
    WalletMessageEvent, JSClientType client);

extension _FindClient on JSClientType {}

abstract class JSWalletHandler {
  late final Map<JSClientType, JSNetworkHandler> _networks = {
    JSClientType.ethereum:
        JSEthereumHandler(sendMessageToClient: _sendEventToClient),
    JSClientType.tron: JSTronHandler(sendMessageToClient: _sendEventToClient),
    JSClientType.solana:
        JSSolanaHandler(sendMessageToClient: _sendEventToClient),
    JSClientType.ton: JSTonHandler(sendMessageToClient: _sendEventToClient),
    JSClientType.stellar:
        JSStellarHandler(sendMessageToClient: _sendEventToClient)
  };

  String get clientId;
  late final String _id = JsUtils.toWalletId(clientId);
  final MessageCompleterHandler completer = MessageCompleterHandler();
  final ChaCha20Poly1305 _crypto;
  abstract ChainsHandler _chain;
  JSWalletHandler._(this._crypto);

  void _onClientEvent(CustomEvent response) {
    final PageMessage request = response.detail as PageMessage;
    switch (request.data.messageType) {
      case PageMessageType.event:
        _networks[request.clientType]?.event(request.data.cast());
        break;
      case PageMessageType.request:
        final result = _completeJsRequest(request);
        result.then(_sendMessageToClient);
        result.catchError((e) {
          final message = WalletMessage.response(
              client: request.clientType,
              requestId: request.id,
              id: request.data.cast<PageMessageRequest>().id,
              data: WalletMessageResponse.fail(
                  Web3RequestExceptionConst.internalError.toJson().jsify()));
          _sendMessageToClient(message);
          return message;
        });
        break;
      default:
        throw UnimplementedError("Invalid page request.");
    }
  }

  void _listenOnClients() {
    jsWindow.addEventListener(_id, _onClientEvent.toJS);
  }

  void _sendMessageToClient(WalletMessage response) {
    final event = CustomEvent.create(
        type: JsUtils.toEthereumClientId(clientId),
        eventData: response,
        clone: true);
    jsWindow.dispatchEvent(event);
  }

  void _sendEventToClient(WalletMessageEvent event, JSClientType client) {
    _sendMessageToClient(WalletMessage.event(client: client, data: event));
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
      message = await handler.request(params.data.cast());
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
            message: params.data.cast(), response: response.cast()),
        Web3MessageTypes.walletResponse => handler!.finilizeWalletResponse(
            message: params.data.cast(),
            response: response.cast(),
            params: request!),
        Web3MessageTypes.error => handler?.finilizeError(
                message: params.data.cast(),
                error: response.cast(),
                params: request) ??
            WalletMessageResponse.fail(response.toJson().jsify()),
        _ => WalletMessageResponse.fail(
            Web3RequestExceptionConst.invalidRequest.toJson().jsify())
      };
      return WalletMessage.response(
          requestId: params.id,
          id: params.data.cast<PageMessageRequest>().id,
          client: params.clientType,
          data: message);
    } finally {
      handler?.onRequestDone(params.data.cast());
    }
  }

  void _updateAuthenticated(Web3APPAuthentication authenticated,
      {NetworkType? network}) {
    final client = JSClientType.fronNetworkName(network?.name);
    if (client == JSClientType.global) {
      for (final i in _networks.values) {
        i.initChain(authenticated: authenticated, chainHandler: _chain);
      }
      return;
    }
    _networks[client]
        ?.initChain(chainHandler: _chain, authenticated: authenticated);
  }

  void _handleOnResponse(WalletEvent request) {
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
          if (msg.chain != null) {
            _chain = ChainsHandler.deserialize(bytes: msg.chain);
          }
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
          _chain = ChainsHandler.deserialize(bytes: msg.message);
          _updateAuthenticated(msg.authenticated, network: null);
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
