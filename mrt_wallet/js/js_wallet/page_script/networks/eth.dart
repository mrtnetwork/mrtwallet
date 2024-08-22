part of '../scripts.dart';

mixin EthereumPageController on JSBasePageController {
  final Map<EthereumEvnetTypes, List<JSFunction>> _onEvents = {
    EthereumEvnetTypes.accountsChanged: [],
    EthereumEvnetTypes.chainChanged: [],
    EthereumEvnetTypes.connect: [],
    EthereumEvnetTypes.message: [],
    EthereumEvnetTypes.disconnect: [],
  };

  void _initEthereum() {
    final eip = EIP1193.setup(
        request: _onEthereumRequest.toJS,
        on: _onEthereumEvent.toJS,
        removeListener: _removeEthereumEvent.toJS,
        disconnect: _disconnectEthereum.toJS,
        enable: _enableEthereum.toJS);
    mrt.ethereum = eip;
    ethereum = eip;
    EIP6963ProviderDetail.setup(ethereum);
  }

  void _disableEthereun(String? message) {
    ethereum = null;
    jsConsole.error(message);
  }

  void _onEthereumWalletEvent(JSWalletMessage walletResponse) {
    switch (walletResponse.type) {
      case JSWalletMessageType.event:
        _parseEvents(walletResponse.cast());
        break;
      case JSWalletMessageType.response:
        _parseRequestResponse(walletResponse.cast());
        break;
      default:
        throw UnimplementedError("Wrong response in page.");
    }
  }

  void _parseRequestResponse(JSWalletMessageResponse message) {
    switch (message.status) {
      case JSWalletResponseType.success:
        _waitingRequest[message.requestId]?.completeMessage(message.data);
        break;
      case JSWalletResponseType.failed:
        _waitingRequest[message.requestId]
            ?.completerError(message.data as Map<String, dynamic>);

        break;
      default:
        throw UnimplementedError("Wrong response in page.");
    }
  }

  void _parseEvents(JSWalletMessageResponseEthereum message) {
    final JSWalletMessageResponseEthereum eventMessage = message.cast();
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

  void _eventListeners(EthereumEvnetTypes type,
      {Object? object, JSAny? jsObject}) {
    jsObject ??= object.jsify();
    if (jsObject == null) return;
    final listeners = <JSFunction>[..._onEvents[type]!];
    for (final i in listeners) {
      i.callAsFunction(i, jsObject);
    }
  }

  void _disconnectEthereum() {}

  void _onEthereumEvent(String type, JSFunction listener) {
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

  void _removeEthereumEvent(String type, JSFunction listener) {
    final event = EthereumEvnetTypes.fromName(type);
    _onEvents[event]?.remove(listener);
  }

  Future<JSAny?> _getEventResult(EthereumEvnetTypes event) async {
    final id = UUID.generateUUIDv4();
    final toWalletRequest =
        ClientMessageEthereum.event(event: event, requestId: id);
    _postWalletEvent(toWalletRequest);
    final PageRequestCompeleter request = PageRequestCompeleter(id);
    return _onRequest(request);
  }

  JSPromise<JSAny?> _enableEthereum() {
    final params = EthereumRequestParams(method: "eth_requestAccounts");
    final promise = _getResult(params).toPromise;
    return promise;
  }

  JSPromise<JSAny?> _onEthereumRequest(EthereumRequestParams params) {
    final promise = _getResult(params).toPromise;

    return promise;
  }
}
