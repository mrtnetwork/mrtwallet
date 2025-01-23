import 'dart:js_interop';

import 'package:blockchain_utils/base58/base58_base.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/networks.dart';
import 'package:on_chain/on_chain.dart';
import '../../models/models/networks/solana.dart';
import '../../models/models/requests.dart';
import '../../utils/utils/utils.dart';
import '../core/network_handler.dart';

class SolanaWeb3State extends ChainWeb3State {
  final WalletSolanaNetwork? solanaNetwork;
  final SolAddress? defaultAddress;
  final SolanaClient? client;
  late final SolanaNetworkType? network = solanaNetwork?.coinParam.type;
  final List<Web3SolanaChainAccount> permissionAccounts;
  List<SolanaWalletAccount> get walletAccounts => permissionAccounts.map((e) {
        return SolanaWalletAccount(
            base58: e.address.address,
            bytes: e.address.toBytes(),
            chains: network == null ? [] : [network!.walletStandardChainName],
            features: []);
      }).toList();
  SolanaWeb3State._(
      {required super.state,
      required List<Web3SolanaChainAccount> permissionAccounts,
      this.defaultAddress,
      this.client,
      this.solanaNetwork})
      : permissionAccounts = permissionAccounts.imutable;
  factory SolanaWeb3State.init(
      {JSNetworkState state = JSNetworkState.disconnect}) {
    return SolanaWeb3State._(permissionAccounts: const [], state: state);
  }
  factory SolanaWeb3State(Web3SolanaChainAuthenticated? authenticated) {
    if (authenticated == null) {
      return SolanaWeb3State.init(state: JSNetworkState.block);
    }
    final permissionAccounts =
        List<Web3SolanaChainAccount>.from(authenticated.accounts);
    final defaultAddress = permissionAccounts
        .firstWhereOrNull((e) => e.defaultAddress, orElse: () {
      if (permissionAccounts.isEmpty) return null;
      return permissionAccounts.first;
    });
    return SolanaWeb3State._(
        solanaNetwork: authenticated.network,
        permissionAccounts: permissionAccounts
          ..sort((a, b) => JsUtils.compareAddress(
              a.addressStr, b.addressStr, defaultAddress?.addressStr)),
        state: JSNetworkState.init,
        defaultAddress: defaultAddress?.address,
        client: APIUtils.createApiClient(authenticated.network,
            allowInWeb3: true,
            identifier: authenticated.serviceIdentifier,
            isolate: APPIsolate.current,
            requestTimeut: ChainWeb3State.requestTimeout));
  }

  bool accountChanged(SolanaWeb3State other) {
    return !(CompareUtils.iterableIsEqual(
            permissionAccounts, other.permissionAccounts) &&
        defaultAddress == other.defaultAddress);
  }

  bool chainChanged(SolanaWeb3State other) {
    return other.solanaNetwork?.genesisBlock != solanaNetwork?.genesisBlock;
  }

  bool needToggle(SolanaWeb3State other) {
    return other.state != state;
  }

  SolanaAccountsChanged get accountsChange => SolanaAccountsChanged(
      accounts: walletAccounts,
      defaultAddress: defaultAddress == null
          ? null
          : SolanaWalletAccount(
              base58: defaultAddress!.address,
              bytes: defaultAddress!.toBytes(),
              chains: network == null ? [] : [network!.walletStandardChainName],
              features: []),
      connectInfo: chainChangedEvent);
  SolanaProviderConnectInfo get chainChangedEvent => SolanaProviderConnectInfo(
      genesisBlock: solanaNetwork!.genesisBlock,
      name: network!.walletStandardChainName);
  bool hasPermission(SolAddress address) {
    return permissionAccounts.any((e) => e.address == address);
  }

  bool get isConnect => defaultAddress != null;
}

class JSSolanaHandler extends JSNetworkHandler<SolanaWeb3State> {
  @override
  SolanaWeb3State state = SolanaWeb3State.init();

  JSSolanaHandler({required super.sendMessageToClient});
  void _sendEvent({required JSEventType event, Object? data}) {
    sendMessageToClient(WalletMessageEvent.build(event: event, data: data),
        JSClientType.solana);
  }

  @override
  void initChain(Web3APPData authenticated) {
    lock.synchronized(() async {
      final currentState = state;
      state = SolanaWeb3State(authenticated.getAuth(networkType));
      if (state.needToggle(currentState)) {
        _toggleSolana(state);
        _disconnect();
        if (state.isConnect) {
          _connect(state);
          _chainChanged(state);
        }
        _accountChanged(state);
        return;
      }
      if (state.chainChanged(currentState)) {
        _disconnect();
        if (state.isConnect) {
          _connect(state);
        }
        _chainChanged(state);
      }
      if (state.accountChanged(currentState)) {
        if (!state.chainChanged(currentState)) {
          if (state.isConnect) {
            _connect(state);
          } else {
            _disconnect();
          }
        }
        _accountChanged(state);
      }
    });
  }

  @override
  Future<Web3MessageCore> request(PageMessageRequest params) async {
    final state = this.state;
    final method = Web3SolanaRequestMethods.fromName(params.method);
    switch (method) {
      case Web3SolanaRequestMethods.requestAccounts:
        if (state.permissionAccounts.isNotEmpty) {
          return buildResponse(state.permissionAccounts);
        }
        return Web3SolanaRequestAccounts();
      case Web3SolanaRequestMethods.signTransaction:
      case Web3SolanaRequestMethods.signAllTransactions:
      case Web3SolanaRequestMethods.sendTransaction:
        return _parseTransaction(method: method!, params: params, state: state);
      case Web3SolanaRequestMethods.signMessage:
        final signMessageV2 = _signMessage(params, state);
        return signMessageV2;
      default:
        throw Web3RequestExceptionConst.methodDoesNotExist;
    }
  }

  Web3SolanaSignMessage _signMessage(
      PageMessageRequest params, SolanaWeb3State state) {
    if (state.defaultAddress == null) {
      throw Web3RequestExceptionConst.missingPermission;
    }
    final param = params.getElementAt(0);
    if (param == null) {
      throw Web3RequestExceptionConst.invalidSignMessageData;
    }
    SolanaWalletAdapterSignMessage? message =
        SolanaWalletAdapterSignMessage.fromJSAny(param);

    final data = JsUtils.toList<int>(message?.message ?? param,
        error: Web3RequestExceptionConst.invalidSignMessageData);
    SolAddress address = SolAddress(state.defaultAddress!.address);
    if (message != null) {
      address = SolAddress(message.account.address);
      if (!state.hasPermission(address)) {
        throw Web3RequestExceptionConst.missingPermission;
      }
    }
    try {
      VersionedMessage.fromBuffer(data);
      throw Web3SolanaExceptionConstant.singTransactionInsteadMessage;
    } on Web3RequestException {
      rethrow;
    } catch (_) {}
    return Web3SolanaSignMessage(
        address: address,
        challeng: BytesUtils.toHexString(data),
        content: StringUtils.tryDecode(data));
  }

  Future<Web3SolanaSendTransaction> _parseTransaction(
      {required PageMessageRequest params,
      required SolanaWeb3State state,
      required Web3SolanaRequestMethods method}) async {
    try {
      final transactions = params.getJSParamsAs<JSSolanaTransaction>();
      if (transactions?.isEmpty ?? true) {
        throw Web3SolanaExceptionConstant.emptyTransactionParameters;
      }
      final List<Web3SolanaSendTransactionData> messages = [];
      for (int i = 0; i < transactions!.length; i++) {
        final tx = transactions[i];
        Web3SolanaSendTransactionOptions? option;
        if (tx.options != null) {
          option =
              Web3SolanaSendTransactionOptions.fromJson(tx.options!.toJson());
        }
        final messageBytes = tx.transactionSerialize().toListInt();
        final List<SolAddress> activeAccounts = [];
        final message = SolanaTransaction.deserialize(messageBytes);
        List<SolAddress> signers = message.signers;
        if (tx.type == JSSolanalaTransactionType.walletAdapter) {
          final SolanaWalletAdapterStandardTransaction walletAdapterTx =
              tx as SolanaWalletAdapterStandardTransaction;
          if (walletAdapterTx.account != null) {
            signers = [SolAddress(walletAdapterTx.account!.address)];
          }
        }
        for (final i in signers) {
          if (state.hasPermission(i)) {
            activeAccounts.add(i);
          }
        }
        if (activeAccounts.isEmpty) {
          throw Web3RequestExceptionConst.missingPermission;
        }
        if (option?.signers ?? false) {
          throw Web3SolanaExceptionConstant.invalidTransactionOptionsSigner;
        }
        final account = activeAccounts.firstWhere(
            (e) => e.address == state.defaultAddress?.address,
            orElse: () => activeAccounts.first);
        messages.add(Web3SolanaSendTransactionData(
            account: account,
            messageByte: messageBytes,
            id: i,
            sendConfig: option));
      }

      switch (method) {
        case Web3SolanaRequestMethods.signTransaction:
        case Web3SolanaRequestMethods.sendTransaction:
          if (messages.length > 1) {
            throw Web3SolanaExceptionConstant.signleRequestInsteadBatchError;
          }
          break;
        default:
      }

      return Web3SolanaSendTransaction(messages: messages, method: method);
    } on Web3RequestException {
      rethrow;
    } catch (_) {}
    throw Web3SolanaExceptionConstant.invalidTransaction;
  }

  void _disconnect() async {
    _sendEvent(
        event: JSEventType.disconnect,
        data: Web3RequestExceptionConst.disconnectedChain.toJson());
  }

  void _connect(SolanaWeb3State state) async {
    if (state.defaultAddress == null) return;
    _sendEvent(event: JSEventType.connect, data: state.accountsChange.toJson());
  }

  void _accountChanged(SolanaWeb3State state) async {
    _sendEvent(
        event: JSEventType.accountsChanged,
        data: state.accountsChange.toJson());
  }

  void _chainChanged(SolanaWeb3State state) async {
    if (state.network == null) return;
    _sendEvent(
        event: JSEventType.chainChanged,
        data: state.chainChangedEvent.toJson());
  }

  void _toggleSolana(SolanaWeb3State state) {
    final chain = state.network;
    if (chain != null) {
      _sendEvent(event: JSEventType.active);
    } else {
      _sendEvent(
          event: JSEventType.disable,
          data: Web3RequestExceptionConst.bannedHost.data);
    }
  }

  @override
  void onRequestDone(PageMessageRequest message) {
    // final method = Web3SolanaRequestMethods.fromName(message.method);

    // switch (method) {
    //   case Web3SolanaRequestMethods.requestAccounts:
    //     _connect(state);
    //     break;
    //   default:
    // }
  }

  @override
  NetworkType get networkType => NetworkType.solana;

  @override
  WalletMessageResponse finilizeWalletResponse(
      {required PageMessageRequest message,
      required Web3RequestParams? params,
      required Web3WalletResponseMessage response}) {
    final method = Web3SolanaRequestMethods.fromName(message.method);
    switch (method) {
      case Web3SolanaRequestMethods.requestAccounts:
        if (state.permissionAccounts.isNotEmpty) {
          final cr =
              state.walletAccounts.map((e) => e.toJson()).toList().jsify();
          return WalletMessageResponse.success(cr);
        }
        return WalletMessageResponse.fail(Web3RequestExceptionConst
            .rejectedByUser
            .toResponseMessage()
            .toJson()
            .jsify());
      case Web3SolanaRequestMethods.signTransaction:
      case Web3SolanaRequestMethods.signAllTransactions:
        final transactions = message.getJSParamsAs<JSSolanaTransaction>();
        final transactionResponse = response
            .resultAsList<Map<String, dynamic>>(length: transactions!.length)
            .map((e) => SolanaWeb3TransactionResponse.fromJson(e));
        final List<Map<String, dynamic>?> result =
            List.filled(transactions.length, null);
        for (int i = 0; i < transactionResponse.length; i++) {
          final item = transactionResponse.elementAt(i);
          if (item.type != SolanaWeb3TransactionResponseType.sign) continue;
          final signResponse = item.cast<SolanaWeb3TransactionSignResponse>();
          result[i] = signResponse.toJson();
        }
        return WalletMessageResponse.success(result.jsify());
      case Web3SolanaRequestMethods.sendTransaction:
        final transactionResponse =
            response.resultAsList<Map<String, dynamic>>(length: 1);
        final transactions = message.getJSParamsAs<JSSolanaTransaction>();
        final txHash =
            SolanaWeb3TransactionResponse.fromJson(transactionResponse[0])
                .cast<SolanaWeb3TransactionSendResponse>();
        if (transactions![0].type == JSSolanalaTransactionType.web3) {
          return WalletMessageResponse.success(
              SolanaSignAndSendTransactionOutput(
                  signature: txHash.txHash.toJS));
        }
        return WalletMessageResponse.success([
          SolanaSignAndSendTransactionOutput(
              signature:
                  APPJSUint8Array.fromList(Base58Decoder.decode(txHash.txHash)))
        ].toJS);
      case Web3SolanaRequestMethods.signMessage:
        final signer =
            Web3SolanaSignMessageResponse.fromJson(response.resultAsMap());
        return WalletMessageResponse.success(signer.toJson().jsify());
    }
    return super.finilizeWalletResponse(
        message: message, params: params, response: response);
  }

  @override
  void event(PageMessageEvent event) {
    switch (event.eventType) {
      case JSEventType.connect:
        _connect(state);
        break;
      case JSEventType.accountsChanged:
        _accountChanged(state);
        break;
      case JSEventType.chainChanged:
        _chainChanged(state);
        break;
      default:
        break;
    }
  }
}
