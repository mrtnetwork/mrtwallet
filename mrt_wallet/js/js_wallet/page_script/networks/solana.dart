part of '../scripts.dart';

class SolanaPageController extends PageNetworkController {
  SolanaPageController(super.postMessage);
  ProxyMethodHandler<SolanaWalletAdapter>? _solana;
  ProxyMethodHandler<SolanaWalletAdapter> _createAdapter() {
    final adapter = SolanaWalletAdapter.setup();
    final connect = _connect.toJS;
    final listener = _addListener.toJS;
    final signAndSendTransaction = _signAndSendTransaction.toJS;
    final signTransaction = _signTranaction.toJS;
    final features = SolanaWalletAdapterFeatures(JSObject());
    final signMessage = _signMessage.toJS;
    features.connect =
        SolanaWalletAdapterStandardConnectFeature.setup(connect: connect);
    features.events =
        SolanaWalletAdapterStandardEventsFeature.setup(on: listener);
    features.signTransaction =
        SolanaWalletAdapterSolanaSignTransactionFeature.setup(
            signTransaction: signTransaction,
            supportedTransactionVersions:
                SolanaJSConstant.solanaTransactionVersion);
    features.signAndSendTransaction =
        SolanaWalletAdapterSolanaSignAndSendTransactionFeature.setup(
            signAndSendTransaction: signAndSendTransaction,
            supportedTransactionVersions:
                SolanaJSConstant.solanaTransactionVersion);
    features.signMessage = SolanaWalletAdapterSolanaSignMessageFeature.setup(
        signMessage: signMessage);
    adapter.signTransaction = signTransaction;
    adapter.signAllTransactions = _signAllTransactions.toJS;
    adapter.signAndSendTransaction = signAndSendTransaction;
    adapter.removeListener = _removeListener.toJS;
    adapter.signMessage = signMessage;
    adapter.connect = connect;
    adapter.isConnected = false;
    adapter.on = listener;
    adapter.cancelListener = _removeListener.toJS;
    adapter.sendWalletRequest = _buildWalletRequest.toJS;
    adapter.sendTransaction = signAndSendTransaction;
    adapter.features = features.toProxy();
    adapter.name = JSWalletConstant.name;
    adapter.version = SolanaJSConstant.version;
    adapter.icon = JSWalletConstant.mrtPngBase64;
    adapter.accounts = <JSSolanaWalletAccount>[].toJS.freez;
    adapter.chains = SolanaJSConstant.supportedChains.freez;
    adapter.disconnect = _disconnectChain.toJS;
    final event = CustomEvent(
        SolanaJSConstant.walletStandardRegisterEvent,
        EventInit(
            bubbles: false,
            cancelable: false,
            detail: (StandardWalletAdapterRegisterEvent event) {
              event.register(adapter);
            }.toJS));
    jsWindow.addEventListener(
        SolanaJSConstant.walletStandardAppReadyEvent,
        (JSAny _) {
          jsWindow.dispatchEvent(event);
        }.toJS);
    jsWindow.dispatchEvent(event);
    return ProxyMethodHandler<SolanaWalletAdapter>(adapter);
  }

  void _initController() {
    _solana ??= _createAdapter();
    final proxy = Proxy(_solana!.object, createJSInteropWrapper(_solana!));
    solana = proxy;
  }

  void _disable({String? message}) {
    solana = null;
  }

  JSPromise<JSAny?> _signMessage(JSAny? message) {
    final walletAdapterMessage =
        SolanaWalletAdapterSignMessage.fromJSAny(message);
    return _postNetworkRequestMessage(PageMessageRequest.create(
            method: Web3SolanaConst.signMessage, params: [message].toJS))
        .then((e) {
      final result =
          JSSolanaSignMessageResponse.fromJson((e.dartify() as Map).cast());
      if (walletAdapterMessage != null) return [result].toJS;
      return result;
    }).toPromise;
  }

  JSPromise<JSAny?> _signTranaction(JSAny transaction) {
    final tx = _toSolanaTransaction(transaction);
    return _buildTransaction(
            transactions: [tx].toJS, method: Web3SolanaConst.signTransaction)
        .toPromise;
  }

  JSPromise<JSAny?> _signAllTransactions(JSArray<JSAny> transactions) {
    final dartTxes = transactions.toDart;
    final List<JSSolanaTransaction> txes = [];
    for (final i in dartTxes) {
      txes.add(_toSolanaTransaction(i));
    }
    return _buildTransaction(
            transactions: txes.toJS,
            method: Web3SolanaConst.signAllTransactions)
        .toPromise;
  }

  JSSolanaTransaction _toSolanaTransaction(JSAny? transaction) {
    JSSolanaTransaction? tx =
        SolanaWalletAdapterStandardTransaction.fromJSAny(transaction);
    tx ??= SolanaWeb3Transaction.fromJSAny(transaction);
    if (tx == null) {
      throw Web3SolanaExceptionConstant.invalidTransaction
          .toResponseMessage()
          .toWalletError();
    }
    return tx;
  }

  Future<JSAny?> _buildTransaction(
      {required JSArray<JSSolanaTransaction> transactions,
      required String method}) async {
    final message = transactions.toDart.map((e) => e).toList();
    final result = _postNetworkRequestMessage(
            PageMessageRequest.create(method: method, params: message.toJS))
        .then((e) {
      return _onTransactionResponse(
          method: method, transactions: transactions, result: e);
    });
    return result.toPromise;
  }

  JSPromise<JSAny?> _signAndSendTransaction(JSAny inputs,
      [JSSolanaTranasctionSendOptions? options]) {
    final tx = _toSolanaTransaction(inputs);
    tx.options ??= options;
    return _buildTransaction(
            transactions: [tx].toJS, method: Web3SolanaConst.sendTransaction)
        .toPromise;
  }

  JSPromise<JSAny?> _buildWalletRequest(Web3JSRequestParams request) {
    switch (request.method) {
      case Web3SolanaConst.requestAccounts:
        return _postWalletRequest(request);
      case Web3SolanaConst.signMessage:
        final message = PageMessageRequest.create(
            method: request.method,
            params: request.params,
            id: request.id ?? (_id++).toString());
        return _postWalletRequestMessage(message).then((e) {
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
    final String id = request.id ?? (_id++).toString();
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
    final List<JSSolanaTransaction> transactions = [];
    // JSSolanaTranasctionSendOptions? options;
    switch (method) {
      case Web3SolanaRequestMethods.signAllTransactions:
        final params = request.params?.elemetAt<JSArray>(0);
        final List<JSSolanaTransaction>? items =
            params?.toDart.map((e) => _toSolanaTransaction(e)).toList();
        if (items == null) {
          return WalletResponseError(
              error: JSWalletError.fromJson(
                  message: Web3SolanaExceptionConstant
                      .invalidBatchTransactionRequest
                      .toJson()),
              id: id);
        }
        transactions.addAll(items.cast());
        break;
      case Web3SolanaRequestMethods.sendTransaction:
      case Web3SolanaRequestMethods.signTransaction:
        final JSSolanaTransaction item =
            _toSolanaTransaction(params.elemetAt(0));
        if (method == Web3SolanaRequestMethods.sendTransaction) {
          item.options = params.elemetAt(1);
          item.options ??= JSSolanaTranasctionSendOptions.defaulConfig();
        }
        transactions.add(item);
        break;
      default:
        return WalletResponseError(
            error: JSWalletError.fromJson(
                message: Web3RequestExceptionConst.methodDoesNotExist.toJson()),
            id: id);
    }
    final result = _postWalletRequestMessage(PageMessageRequest.create(
            method: request.method, params: transactions.toJS, id: id))
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

  JSAny? _onTransactionResponse(
      {required String method,
      required JSArray<JSSolanaTransaction> transactions,
      JSAny? result}) {
    switch (method) {
      case Web3SolanaConst.signTransaction:
      case Web3SolanaConst.signAllTransactions:
        List<JSAny> response = [];
        final List<JSSolanaSignTransactionResponse?> toDart =
            (result.dartify() as List).map((e) {
          if (e == null) return null;
          return JSSolanaSignTransactionResponse.fromJson((e as Map).cast());
        }).toList();
        for (int i = 0; i < transactions.length; i++) {
          final signature = toDart.elementAt(i);
          if (signature == null) continue;
          final r = transactions[i].toResponse(
              signer: signature.signerPubKey,
              signature: signature.signature,
              signedTransaction: signature.serializedTx);
          response.add(r);
        }
        if (method == Web3SolanaConst.signTransaction &&
            transactions[0].type == JSSolanalaTransactionType.web3) {
          return response[0];
        }
        return response.toJS;
      case Web3SolanaConst.requestAccounts:
        return result;
      case Web3SolanaConst.sendTransaction:
        return result;
      default:
        return null;
    }
  }

  Future<JSArray<JSSolanaWalletAccount>> _connect_() async {
    final params =
        PageMessageRequest.create(method: Web3SolanaConst.requestAccounts);
    final promise = await _postNetworkRequestMessage<JSArray>(params).then(
        (e) => e.toDart
            .map((e) =>
                SolanaWalletAccount.fromJson((e.dartify() as Map).cast()).toJS)
            .toList()
            .toJS);
    return promise;
  }

  JSPromise<JSArray<JSSolanaWalletAccount>> _connect() {
    return _connect_().toPromise;
  }

  void onEvent(WalletMessageEvent message) {
    JSAny? eventData = message.data;
    switch (message.eventType) {
      case JSEventType.connect:
        final changeInfo = SolanaAccountsChanged.fromJson(message.asMap());
        eventData = changeInfo.connectInfo.toJS;
        _solana?.object.update(changeInfo);
        _eventListeners(JSEventType.change,
            jsObject: changeInfo.toChangeEvent().toJS());
        _eventListeners(JSEventType.change,
            jsObject: changeInfo.connectInfo.toChangeEvent().toJS());
        break;
      case JSEventType.chainChanged:
        final changeInfo = SolanaProviderConnectInfo.fromJson(message.asMap());
        _eventListeners(JSEventType.change,
            jsObject: changeInfo.toChangeEvent().toJS());
        eventData = changeInfo.toJS;
        break;
      case JSEventType.accountsChanged:
        final changeInfo = SolanaAccountsChanged.fromJson(message.asMap());
        _solana?.object.update(changeInfo);
        _eventListeners(JSEventType.change,
            jsObject: changeInfo.toChangeEvent().toJS());
        eventData = changeInfo.accounts.map((e) => e.base58.toJS).toList().toJS;
        break;
      case JSEventType.disconnect:
        _solana?.object.publicKey = null;
        _solana?.object.isConnected = false;
        break;
      case JSEventType.disable:
        _disable(message: message.asString());
        return;
      case JSEventType.active:
        _initController();
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
      i.callAsFunction(null, jsObject);
    }
  }

  void _addListener(String type, JSFunction listener) {
    final event = JSEventType.fromName(type);
    if (!_listeners.containsKey(event)) return;
    _listeners[event]?.add(listener);
    _emitEvent(PageMessageEvent.build(event: event!));
  }

  void _removeListener(String type, JSFunction listener) {
    final event = JSEventType.fromName(type);
    _listeners[event]?.remove(listener);
  }

  @override
  JSClientType get _client => JSClientType.solana;
}
