part of '../scripts.dart';

class _SolanaPageControllerConst {
  static const String signTransaction = "solana_signTransaction";
  static const String requestAccounts = "solana_requestAccounts";
  static const String signMessage = "solana_signMessage";
}

class SolanaPageController extends PageNetworkController {
  SolanaPageController({required super.getWalletMessage});
  ProxyMethodHandler<SolanaWalletAdapter>? _solana;
  final Map<SolanaEventTypes, List<JSFunction>> _listeners = {
    SolanaEventTypes.connect: [],
    SolanaEventTypes.message: [],
    SolanaEventTypes.disconnect: [],
    SolanaEventTypes.chainChanged: [],
    SolanaEventTypes.accountsChanged: [],
  };

  void _init() {
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
    final handler = ProxyMethodHandler<SolanaWalletAdapter>(adapter);
    final proxy = Proxy(handler.object, createJSInteropWrapper(handler));
    _solana = handler;
    solana = proxy;
  }

  JSPromise<JSAny?> _signMessage(JSUint8Array transaction) {
    final result = _personalSign(transaction);
    return result.toPromise;
  }

  Future<JSSolanaSignMessageResponse?> _personalSign(
      JSUint8Array transaction) async {
    final result = await getWalletMessage(ClientMessageSolana(
        method: _SolanaPageControllerConst.signMessage,
        params: transaction.toListInt()));
    final data = JSUint8Array.from(result);

    return JSSolanaSignMessageResponse(signature: data);
  }

  JSPromise<JSAny?> _signTranaction(JSSolanaTransaction transaction) {
    return _buildTransaction(transactions: [transaction].toJS, batch: false)
        .toPromise;
  }

  JSPromise<JSAny?> _signAllTransactions(
      JSArray<JSSolanaTransaction> transaction) {
    return _buildTransaction(transactions: transaction, batch: true).toPromise;
  }

  JSPromise<JSAny?> _signAndSendTransaction(JSSolanaTransaction transaction,
      [JSSolanaTranasctionSendOptions? options]) {
    return _buildTransaction(
            transactions: [transaction].toJS,
            option: options ?? JSSolanaTranasctionSendOptions.defaulConfig(),
            batch: false)
        .toPromise;
  }

  JSPromise<JSAny?> _signAndSendAllTransactions(
      JSArray<JSSolanaTransaction> transaction,
      [JSSolanaTranasctionSendOptions? options]) {
    return _buildTransaction(
            transactions: transaction,
            option: options ?? JSSolanaTranasctionSendOptions.defaulConfig(),
            batch: true)
        .toPromise;
  }

  Future<JSAny?> _buildTransaction(
      {required JSArray<JSSolanaTransaction> transactions,
      JSSolanaTranasctionSendOptions? option,
      required bool batch}) async {
    final toDart = transactions.toDart;
    final messages = List.generate(toDart.length, (index) {
      return ClientSolanaTransactionMessage(
          id: index,
          message: toDart[index].transactionSerialize(),
          sendOption: option?.toJson());
    });
    final Completer<JSAny?> completer = Completer<JSAny?>();
    final result = getWalletMessage(ClientMessageSolana(
        method: _SolanaPageControllerConst.signTransaction,
        params: messages.map((e) => e.toJson()).toList()));
    result.catchError((e) {
      completer.completeError(e);
      return null;
    });
    result.then((e) {
      final response =
          (e.dartify() as List).map((e) => Map<String, dynamic>.from(e));
      final results = response
          .map((e) => SolanaWeb3TransactionResponse.fromJson(e))
          .toList();
      if (option != null) {
        final List<String?> txHash = List.generate(toDart.length, (e) => null);
        for (final i in results) {
          switch (i.type) {
            case SolanaWeb3TransactionResponseType.send:
              final message =
                  results[i.id].cast<SolanaWeb3TransactionSendResponse>();
              txHash[i.id] = message.txHash;
              break;
            default:
          }
        }
        if (batch) {
          completer.complete(txHash.map((e) => e?.toJS).toList().toJS);
        } else {
          completer.complete(txHash.first?.toJS);
        }
      } else {
        for (final i in results) {
          switch (i.type) {
            case SolanaWeb3TransactionResponseType.sign:
              final message = i.cast<SolanaWeb3TransactionSignResponse>();
              toDart[i.id].addSignature(
                  JSSolanaPublicKey(
                          base58: message.signer,
                          bytes: message.signerAddressBytes)
                      .toJS,
                  JSUint8Array.from(message.signature.jsify()));
              break;
            default:
          }
        }
        if (batch) {
          completer.complete(List<JSAny>.from(toDart).toJS);
        } else {
          completer.complete(toDart[0]);
        }
      }
    });
    return completer.future;
  }

  JSPromise<JSAny?> _connect() {
    const params =
        ClientMessageSolana(method: _SolanaPageControllerConst.requestAccounts);
    return _onRequest(params);
  }

  void _disable(String? message) {
    solana = null;
    jsConsole.error(message);
  }

  void onEvent(JSWalletMessageResponseSolana message) {
    final JSWalletMessageResponseSolana eventMessage = message.cast();
    JSAny? eventData;
    switch (eventMessage.event) {
      case SolanaEventTypes.connect:
        final changeInfo =
            SolanaAccountsChanged.fromJson(eventMessage.dataAs());
        final addr = changeInfo.toJSPublicKey()?.toJS;
        eventData = addr;
        _solana?.object.publicKey = addr;
        _solana?.object.isConnected = addr != null;
        break;
      case SolanaEventTypes.chainChanged:
        final changeInfo =
            SolanaProviderConnectInfo.fromJson(eventMessage.dataAs());
        eventData = changeInfo.toJS;
        break;
      case SolanaEventTypes.accountsChanged:
        final changeInfo =
            SolanaAccountsChanged.fromJson(eventMessage.dataAs());
        final addr = changeInfo.defaultAddress?.toJS;
        eventData = changeInfo.accounts.map((e) => e.toJS).toList().toJS;
        _solana?.object.publicKey = changeInfo.toJSPublicKey()?.toJS;
        _solana?.object.isConnected = addr != null;
        break;
      case SolanaEventTypes.disconnect:
        _solana?.object.publicKey = null;
        _solana?.object.isConnected = false;
        break;
      case SolanaEventTypes.disable:
        _disable(eventMessage.dataAs());
        return;
      case SolanaEventTypes.active:
        _init();
        return;
      default:
        return;
    }
    _eventListeners(eventMessage.event, jsObject: eventData);
  }

  void _eventListeners(SolanaEventTypes type, {JSAny? jsObject}) {
    if (!_listeners.containsKey(type)) return;
    final listeners = <JSFunction>[..._listeners[type]!];
    for (final i in listeners) {
      i.callAsFunction(i, jsObject);
    }
  }

  void _addListener(String type, JSFunction listener) {
    final event = SolanaEventTypes.fromName(type);
    if (event == null || !_listeners.containsKey(event)) return;
    _listeners[event]?.add(listener);
    if (event != SolanaEventTypes.message &&
        event != SolanaEventTypes.disconnect) {
      getWalletMessage(ClientMessageSolana.event(event));
    }
  }

  void _removeListener(String type, JSFunction listener) {
    final event = SolanaEventTypes.fromName(type);
    _listeners[event]?.remove(listener);
  }

  JSPromise<JSAny?> _onRequest(ClientMessageSolana params) {
    final promise = getWalletMessage(params).toPromise;
    return promise;
  }
}
