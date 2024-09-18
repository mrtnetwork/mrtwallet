part of '../scripts.dart';

class SolanaPageController extends PageNetworkController {
  SolanaPageController();
  ProxyMethodHandler<SolanaWalletAdapter>? _solana;
  ProxyMethodHandler<SolanaWalletAdapter> _createAdapter() {
    final adapter = SolanaWalletAdapter.setup();
    adapter.signTransaction = _signTranaction.toJS;
    adapter.signAllTransactions = _signAllTransactions.toJS;
    adapter.signAndSendTransaction = _signAndSendTransaction.toJS;
    adapter.signAndSendAllTransactions = _signAndSendAllTransactions.toJS;
    adapter.on = _addListener.toJS;
    adapter.removeListener = _removeListener.toJS;
    adapter.signMessage = _signMessage.toJS;
    adapter.connect = _connect.toJS;
    adapter.isConnected = false;
    adapter.on = _addListener.toJS;
    adapter.cancelListener = _removeListener.toJS;
    adapter.sendWalletRequest = _buildWalletRequest.toJS;
    return ProxyMethodHandler<SolanaWalletAdapter>(adapter);
  }

  void _init() {
    _solana ??= _createAdapter();
    final proxy = Proxy(_solana!.object, createJSInteropWrapper(_solana!));
    solana = proxy;
  }

  JSPromise<JSAny?> _signMessage(JSAny? message) {
    return _onNetworkRequest(PageMessageRequest.create(
            method: Web3SolanaConst.signMessage, params: [message].toJS))
        .then((e) {
      return JSSolanaSignMessageResponse.fromJson((e.dartify() as Map).cast());
    }).toPromise;
  }

  JSPromise<JSAny?> _signTranaction(JSSolanaTransaction transaction) {
    return _buildTransaction(
            transactions: [transaction].toJS,
            method: Web3SolanaConst.signTransaction)
        .toPromise;
  }

  JSPromise<JSAny?> _signAllTransactions(
      JSArray<JSSolanaTransaction> transaction) {
    return _buildTransaction(
            transactions: transaction,
            method: Web3SolanaConst.signAllTransactions)
        .toPromise;
  }

  JSPromise<JSAny?> _signAndSendTransaction(JSSolanaTransaction transaction,
      [JSSolanaTranasctionSendOptions? options]) {
    return _buildTransaction(
            transactions: [transaction].toJS,
            option: options ?? JSSolanaTranasctionSendOptions.defaulConfig(),
            method: Web3SolanaConst.sendTransaction)
        .toPromise;
  }

  JSPromise<JSAny?> _signAndSendAllTransactions(
      JSArray<JSSolanaTransaction> transaction,
      [JSSolanaTranasctionSendOptions? options]) {
    return _buildTransaction(
            transactions: transaction,
            option: options ?? JSSolanaTranasctionSendOptions.defaulConfig(),
            method: Web3SolanaConst.sendAllTransactions)
        .toPromise;
  }

  JSPromise<JSAny?> _buildWalletRequest(Web3JSRequestParams request) {
    switch (request.method) {
      case Web3SolanaConst.requestAccounts:
        return _onWalletRequest(request);
      case Web3SolanaConst.signMessage:
        final message = PageMessageRequest.create(
            method: request.method,
            params: request.params,
            id: request.id ?? (_id++).toString());
        return _onWalletRequest_(message).then((e) {
          if (e.error != null) return e;
          return WalletResponseSuccess(
              result: JSSolanaSignMessageResponse.fromJson(
                  (e.result.dartify() as Map).cast()),
              id: e.id);
        }).toPromise;
      default:
        return _toWalletRequest(request).toPromise;
    }
  }

  Future<JSAny?> _toWalletRequest(Web3JSRequestParams request) async {
    final method = Web3SolanaRequestMethods.fromName(request.method);
    String id = request.id ?? (_id++).toString();
    if (method == null) {
      return WalletResponseError(
          error: JSWalletError.fromJson(
              message: Web3RequestExceptionConst.methodDoesNotExist.toJson()),
          id: id);
    }
    final params = request.params;
    if (params == null || params.length == 0) {
      return WalletResponseError(
          error: JSWalletError.fromJson(
              message: Web3SolanaExceptionConstant.invalidTransaction.toJson()),
          id: id);
    }
    List<JSSolanaTransaction> transactions = [];
    JSSolanaTranasctionSendOptions? options;
    switch (method) {
      case Web3SolanaRequestMethods.sendAllTransactions:
      case Web3SolanaRequestMethods.signAllTransactions:
        final JSArray<JSSolanaTransaction>? items = params.elemetAt(0);
        if (items == null) {
          return WalletResponseError(
              error: JSWalletError.fromJson(
                  message: Web3SolanaExceptionConstant
                      .invalidBatchTransactionRequest
                      .toJson()),
              id: id);
        }
        transactions.addAll(items.toDart);
        if (method == Web3SolanaRequestMethods.sendAllTransactions) {
          options = params.elemetAt(1);
          options ??= JSSolanaTranasctionSendOptions.defaulConfig();
        }
        break;
      case Web3SolanaRequestMethods.sendTransaction:
      case Web3SolanaRequestMethods.signTransaction:
        final JSSolanaTransaction? item = params.elemetAt(0);
        if (item == null) {
          return WalletResponseError(
              error: JSWalletError.fromJson(
                  message:
                      Web3SolanaExceptionConstant.invalidTransaction.toJson()),
              id: id);
        }
        transactions.add(item);
        if (method == Web3SolanaRequestMethods.sendTransaction) {
          options = params.elemetAt(1);
          options ??= JSSolanaTranasctionSendOptions.defaulConfig();
        }
        break;
      default:
        return WalletResponseError(
            error: JSWalletError.fromJson(
                message: Web3RequestExceptionConst.methodDoesNotExist.toJson()),
            id: id);
    }
    final result = _onWalletRequest_(PageMessageRequest.create(
            method: request.method,
            params:
                transactions.map((e) => e.transactionSerialize()).toList().toJS,
            additionalData: options,
            id: id))
        .then((e) {
      if (e.error != null) {
        return e;
      }
      return WalletResponseSuccess(
          id: e.id,
          result: _onTransactionResponse(
              method: request.method,
              transactions: transactions.toJS,
              result: e.result));
    });
    return result.toPromise;
  }

  Future<JSAny?> _buildTransaction(
      {required JSArray<JSSolanaTransaction> transactions,
      JSSolanaTranasctionSendOptions? option,
      required String method}) async {
    final message =
        transactions.toDart.map((e) => e.transactionSerialize()).toList();
    final result = _onNetworkRequest(PageMessageRequest.create(
            method: method, params: message.toJS, additionalData: option))
        .then((e) {
      return _onTransactionResponse(
          method: method, transactions: transactions, result: e);
    });
    return result.toPromise;
  }

  JSAny? _onTransactionResponse(
      {required String method,
      required JSArray<JSSolanaTransaction> transactions,
      JSAny? result}) {
    switch (method) {
      case Web3SolanaConst.signTransaction:
      case Web3SolanaConst.signAllTransactions:
        final List<JSSolanaSignTransactionResponse?> toDart =
            (result.dartify() as List).map((e) {
          if (e == null) return null;
          return JSSolanaSignTransactionResponse.fromJson((e as Map).cast());
        }).toList();
        for (int i = 0; i < transactions.length; i++) {
          final signature = toDart.elementAt(i);
          if (signature == null) continue;
          transactions[i]?.addSignature(
              JSSolanaPublicKey(
                      base58: signature.address, bytes: signature.addressBytes)
                  .toJS,
              JSUint8Array.fromList(signature.signature));
        }
        if (method == Web3SolanaConst.signTransaction) {
          return transactions[0];
        }
        return transactions;
      case Web3SolanaConst.requestAccounts:
      case Web3SolanaConst.sendTransaction:
      case Web3SolanaConst.sendAllTransactions:
        return result;
      default:
        return null;
    }
  }

  JSPromise<JSAny?> _connect() {
    final params = PageMessageRequest.create(
      method: Web3SolanaConst.requestAccounts,
    );
    final promise = _onNetworkRequest(params).toPromise;
    return promise;
  }

  void _disable(String? message) {
    solana = null;
    jsConsole.error(message);
  }

  void onEvent(WalletMessageEvent message) {
    JSAny? eventData = message.data;
    switch (message.eventType) {
      case JSEventType.connect:
        final changeInfo = SolanaAccountsChanged.fromJson(message.asMap());
        final addr = changeInfo.toJSPublicKey()?.toJS;
        eventData = changeInfo.connectInfo.toJS;
        _solana?.object.publicKey = addr;
        _solana?.object.isConnected = addr != null;
        break;
      case JSEventType.chainChanged:
        final changeInfo = SolanaProviderConnectInfo.fromJson(message.asMap());
        eventData = changeInfo.toJS;
        break;
      case JSEventType.accountsChanged:
        final changeInfo = SolanaAccountsChanged.fromJson(message.asMap());
        final addr = changeInfo.defaultAddress?.toJS;
        eventData = changeInfo.accountJS;
        _solana?.object.selectedAddress = changeInfo.defaultAddress?.toJS;
        _solana?.object.publicKey = changeInfo.toJSPublicKey()?.toJS;
        _solana?.object.isConnected = addr != null;
        break;
      case JSEventType.disconnect:
        _solana?.object.publicKey = null;
        _solana?.object.isConnected = false;
        break;
      case JSEventType.disable:
        _disable(message.asString());
        return;
      case JSEventType.active:
        _init();
        return;
      default:
        return;
    }
    _eventListeners(message.eventType, jsObject: eventData);
  }

  void _eventListeners(JSEventType type, {JSAny? jsObject}) {
    if (!_listeners.containsKey(type)) return;
    final listeners = <JSFunction>[..._listeners[type]!];
    for (final i in listeners) {
      i.callAsFunction(i, jsObject);
    }
  }

  void _addListener(String type, JSFunction listener) {
    final event = JSEventType.fromName(type);
    if (event == null || !_listeners.containsKey(event)) return;
    _listeners[event]?.add(listener);
    _emitEvent(PageMessageEvent.build(event: event));
  }

  void _removeListener(String type, JSFunction listener) {
    final event = JSEventType.fromName(type);
    _listeners[event]?.remove(listener);
  }

  @override
  JSClientType get _client => JSClientType.solana;
}
