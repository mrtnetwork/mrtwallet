import 'dart:js_interop';
import 'package:blockchain_utils/uuid/uuid.dart';
import '../../models/models.dart';
import 'dart:async';
import 'package:mrt_native_support/web/mrt_native_web.dart';

class _Requests {
  _Requests(this.message);
  final Completer<JSAny?> completer = Completer();
  final EthereumRequestParams? message;
  void completeMessage(Object? object) {
    completer.complete(object.jsify());
  }

  void completerError(Map<String, dynamic> error) {
    final walletError = MRTWalletError.fromJson(message: error);
    completer.completeError(walletError);
  }
}

class EthereumJsController {
  final String clientId;
  late final String _id = "ETH_$clientId";
  late final String _walletId = "WALLET_$clientId";
  EthereumJsController._(this.clientId);
  void _initEthereum() {
    final eip = EIP1193.setup(
        request: onEthereumRequest.toJS,
        on: onEvent.toJS,
        removeListener: removeEvent.toJS,
        disconnect: disconnect.toJS,
        enable: enable.toJS);
    mrt.ethereum = eip;
    ethereum = eip;
    EIP6963ProviderDetail.setup(ethereum);
  }

  void _disableEthereun(String? message) {
    ethereum = null;
    jsConsole.error(message);
  }

  factory EthereumJsController.setup(String clientId) {
    final controller = EthereumJsController._(clientId);

    controller._listenOnWallet();
    return controller;
  }

  void _listenOnWallet() {
    jsWindow.addEventListener(_id, _onWalletEvent.toJS);
  }

  void _parseRequestResponse(WalletRequestResponse message) {
    switch (message.status) {
      case WalletRequestResponseType.success:
        _waitingRequest[message.requestId]?.completeMessage(message.data);
        break;
      case WalletRequestResponseType.failed:
        _waitingRequest[message.requestId]
            ?.completerError(message.data as Map<String, dynamic>);

        break;
      default:
        throw UnimplementedError("Wrong response in page.");
    }
  }

  void _parseEvents(WalletEthereumEventResponse message) {
    final WalletEthereumEventResponse eventMessage = message.cast();
    switch (eventMessage.event) {
      case EthereumEvnetTypes.connect:
        final result = eventMessage.data as Map<String, dynamic>;
        final BigInt chainId = BigInt.parse(
            (result["chainId"] as String).replaceFirst("0x", ""),
            radix: 16);
        ethereum.chainId = (result["chainId"] as String);
        ethereum.networkVersion = chainId.toString();
        break;
      case EthereumEvnetTypes.chainChanged:
        final BigInt chainId = BigInt.parse(
            (eventMessage.data as String).replaceFirst("0x", ""),
            radix: 16);
        ethereum.chainId = (eventMessage.data as String);
        ethereum.networkVersion = chainId.toString();
        break;
      case EthereumEvnetTypes.disconnect:
        ethereum.chainId = null;
        ethereum.networkVersion = null;
        ethereum.selectedAddress = null;
        break;
      case EthereumEvnetTypes.accountsChanged:
        final accounts = List<String>.from(eventMessage.data as List);
        ethereum.selectedAddress = accounts.isEmpty ? null : accounts[0];
        break;
      case EthereumEvnetTypes.disable:
        _disableEthereun(eventMessage.data as String?);
        break;
      case EthereumEvnetTypes.active:
        _initEthereum();
        break;
      default:
    }
    _eventListeners(eventMessage.event, object: message.data);
  }

  void _onWalletEvent(CustomEvent response) {
    final walletResponse =
        WalletResponse.deserialize(bytes: response.detailBytes());

    switch (walletResponse.type) {
      case WalletResponseType.event:
        _parseEvents(walletResponse.cast());
        break;
      case WalletResponseType.response:
        _parseRequestResponse(walletResponse.cast());
        break;
      default:
        throw UnimplementedError("Wrong response in page.");
    }
  }

  void _postWalletEvent(ClientRequest params) {
    final event =
        CustomEvent.create(type: _walletId, data: params.toCbor().encode());
    jsWindow.dispatchEvent(event);
  }

  final Map<String, _Requests> _waitingRequest = {};
  Future<JSAny?> onRequest(String id) async {
    try {
      return await _waitingRequest[id]!.completer.future;
    } finally {
      _waitingRequest.remove(id);
    }
  }

  final Map<EthereumEvnetTypes, List<JSFunction>> _onEvents = {
    EthereumEvnetTypes.accountsChanged: [],
    EthereumEvnetTypes.chainChanged: [],
    EthereumEvnetTypes.connect: [],
    EthereumEvnetTypes.message: [],
    EthereumEvnetTypes.disconnect: [],
  };
  void _eventListeners(EthereumEvnetTypes type,
      {Object? object, JSAny? jsObject}) {
    jsObject ??= object.jsify();
    if (jsObject == null) return;
    final listeners = <JSFunction>[..._onEvents[type]!];
    for (final i in listeners) {
      i.callAsFunction(i, jsObject);
    }
  }

  void disconnect() {}

  void onEvent(String type, JSFunction listener) {
    final event = EthereumEvnetTypes.fromName(type);
    if (event == null) return;
    _onEvents[event]?.add(listener);
    if (event != EthereumEvnetTypes.message &&
        event != EthereumEvnetTypes.disconnect) {
      _getEventResult(event).then((e) {
        return _eventListeners(event, jsObject: e);
      }).catchError((e) {});
    }
  }

  void removeEvent(String type, JSFunction listener) {
    final event = EthereumEvnetTypes.fromName(type);
    _onEvents[event]?.remove(listener);
  }

  /// ClientEthereumRequest
  Future<JSAny?> _getEventResult(EthereumEvnetTypes event) async {
    final id = UUID.generateUUIDv4();
    final toWalletRequest =
        ClientEthereumRequest.event(event: event, requestId: id);
    _postWalletEvent(toWalletRequest);
    final _Requests request = _Requests(null);
    _waitingRequest[id] = request;
    return await request.completer.future;
  }

  Future<JSAny?> _getResult(EthereumRequestParams params) async {
    final id = UUID.generateUUIDv4();
    final toWalletRequest = params.toWalletRequest(id);
    _postWalletEvent(toWalletRequest!);
    final _Requests request = _Requests(params);
    _waitingRequest[id] = request;
    return await request.completer.future;
  }

  JSPromise<JSAny?> enable() {
    final params = EthereumRequestParams(method: "eth_requestAccounts");
    final promise = _getResult(params).toPromise;
    return promise;
  }

  JSPromise<JSAny?> onEthereumRequest(EthereumRequestParams params) {
    final promise = _getResult(params).toPromise;
    return promise;
  }
}
