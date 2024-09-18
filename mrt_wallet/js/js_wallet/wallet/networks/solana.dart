import 'dart:js_interop';

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

class SolanaWeb3State
    extends ChainWeb3State<SolAddress, SolanaChain, Web3SolanaChain> {
  final SolanaChain? chain;
  final SolAddress? defaultAddress;
  final SolanaClient? client;

  SolanaWeb3State._(
      {super.permission,
      required super.chains,
      required super.state,
      required super.permissionAccounts,
      this.defaultAddress,
      this.client,
      this.chain});
  factory SolanaWeb3State.init(
      {JSNetworkState state = JSNetworkState.disconnect}) {
    return SolanaWeb3State._(
        chains: const [], permissionAccounts: const [], state: state);
  }
  factory SolanaWeb3State(
      {required Web3APPAuthentication authenticated,
      required ChainsHandler chainHandler}) {
    final permission = authenticated
        .getChainFromNetworkType<Web3SolanaChain>(NetworkType.solana);
    if (permission == null) {
      return SolanaWeb3State.init(state: JSNetworkState.block);
    }
    final chains = chainHandler.chains().whereType<SolanaChain>().toList();
    final currentChain = chains
        .firstWhere((e) => e.network.genesisBlock == permission.currentChain);
    final permissionAccounts = permission.chainAccounts(currentChain);
    final defaultAddress = permissionAccounts
        .firstWhereOrNull((e) => e.defaultAddress, orElse: () {
      if (permissionAccounts.isEmpty) return null;
      return permissionAccounts.first;
    });
    return SolanaWeb3State._(
        chains: chainHandler.chains().whereType<SolanaChain>().toList(),
        permission: permission,
        permissionAccounts:
            permissionAccounts.map((e) => e.address.address).toList()
              ..sort((a, b) =>
                  JsUtils.compareAddress(a, b, defaultAddress?.addressStr)),
        state: JSNetworkState.init,
        chain: currentChain,
        defaultAddress: defaultAddress?.address,
        client: currentChain.getWeb3Provider(
            requestTimeout: ChainWeb3State.requestTimeout));
  }

  bool accountChanged(SolanaWeb3State other) {
    return !(CompareUtils.iterableIsEqual(
            permissionAccounts, other.permissionAccounts) &&
        defaultAddress == other.defaultAddress);
  }

  bool chainChanged(SolanaWeb3State other) {
    return other.chain?.network.genesisBlock != chain?.network.genesisBlock;
  }

  bool needToggle(SolanaWeb3State other) {
    return other.state != state;
  }

  SolanaAccountsChanged get accountsChange => SolanaAccountsChanged(
      accounts: permissionAccounts,
      defaultAddress: defaultAddress?.address,
      defaultAddressBytes: defaultAddress?.toBytes(),
      connectInfo: chainChangedEvent);
  SolanaProviderConnectInfo get chainChangedEvent =>
      SolanaProviderConnectInfo(chain!.network.genesisBlock);
  bool hasPermission(SolAddress address) {
    return permission?.getPermission(address) != null;
  }

  bool get isConnect => defaultAddress != null;
}

class JSSolanaHandler extends JSNetworkHandler<
    SolAddress,
    SolanaChain,
    Web3SolanaChainAccount,
    Web3SolanaChain,
    // PageMessageRequest,
    SolanaWeb3State> {
  @override
  SolanaWeb3State state = SolanaWeb3State.init();

  JSSolanaHandler({required super.sendMessageToClient});
  void _sendEvent({required JSEventType event, Object? data}) {
    sendMessageToClient(WalletMessageEvent.build(event: event, data: data),
        JSClientType.solana);
  }

  @override
  void initChain(
      {required Web3APPAuthentication authenticated,
      required ChainsHandler chainHandler}) {
    lock.synchronized(() async {
      final currentState = state;
      state = SolanaWeb3State(
          authenticated: authenticated, chainHandler: chainHandler);
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
      case Web3SolanaRequestMethods.sendAllTransactions:
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
    final data = JsUtils.toList<int>(params.getFirstParam,
        error: Web3RequestExceptionConst.invalidSignMessageData);
    try {
      VersionedMessage.fromBuffer(data);
      throw Web3SolanaExceptionConstant.singTransactionInsteadMessage;
    } on Web3RequestException {
      rethrow;
    } catch (_) {}
    return Web3SolanaSignMessage(
        address: SolAddress(state.defaultAddress!.address),
        challeng: BytesUtils.toHexString(data),
        content: StringUtils.tryDecode(data));
  }

  Future<Web3SolanaSendTransaction> _parseTransaction({
    required PageMessageRequest params,
    required SolanaWeb3State state,
    required Web3SolanaRequestMethods method,
  }) async {
    try {
      final transactions = params.getJSParamsAs<JSUint8Array>();
      if (transactions?.isEmpty ?? true) {
        throw Web3SolanaExceptionConstant.emptyTransactionParameters;
      }
      List<Web3SolanaSendTransactionData> messages = [];
      for (int i = 0; i < transactions!.length; i++) {
        final messageBytes = transactions[i].toListInt();
        List<SolAddress> activeAccounts = [];
        final message = SolanaTransaction.deserialize(messageBytes);
        final signers = message.signers;
        for (final i in signers) {
          if (state.hasPermission(i)) {
            activeAccounts.add(i);
          }
        }
        if (activeAccounts.isEmpty) {
          throw Web3RequestExceptionConst.missingPermission;
        }
        final account = activeAccounts.firstWhere(
            (e) => e.address == state.defaultAddress?.address,
            orElse: () => activeAccounts.first);
        messages.add(Web3SolanaSendTransactionData(
            account: account, messageByte: messageBytes, id: i));
      }
      Web3SolanaSendTransactionOptions? option;
      switch (method) {
        case Web3SolanaRequestMethods.signTransaction:
          if (messages.length > 1) {
            throw Web3SolanaExceptionConstant.signleRequestInsteadBatchError;
          }
          break;
        case Web3SolanaRequestMethods.sendTransaction:
          if (messages.length > 1) {
            throw Web3SolanaExceptionConstant.signleRequestInsteadBatchError;
          }
          option = Web3SolanaSendTransactionOptions.fromJson(
              (params.additionalData as JSSolanaTranasctionSendOptions)
                  .toJson());
          break;
        case Web3SolanaRequestMethods.sendAllTransactions:
          option = Web3SolanaSendTransactionOptions.fromJson(
              (params.additionalData as JSSolanaTranasctionSendOptions)
                  .toJson());
          break;
        default:
      }
      if (option?.signers ?? false) {
        throw Web3SolanaExceptionConstant.invalidTransactionOptionsSigner;
      }
      return Web3SolanaSendTransaction(
          messages: messages, sendConfig: option, method: method);
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
    if (state.chain == null) return;
    _sendEvent(
        event: JSEventType.chainChanged,
        data: state.chainChangedEvent.toJson());
  }

  void _toggleSolana(SolanaWeb3State state) {
    final chain = state.chain;
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
    final method = Web3SolanaRequestMethods.fromName(message.method);

    switch (method) {
      case Web3SolanaRequestMethods.requestAccounts:
        _connect(state);
        break;
      default:
    }
  }

  @override
  NetworkType get networkType => NetworkType.solana;

  @override
  WalletMessageResponse finilizeWalletResponse(
      {required PageMessageRequest message,
      required Web3RequestParams params,
      required Web3WalletResponseMessage response}) {
    final method = Web3SolanaRequestMethods.fromName(message.method);
    switch (method) {
      case Web3SolanaRequestMethods.requestAccounts:
        if (state.permissionAccounts.isNotEmpty) {
          return WalletMessageResponse.success(
              state.permissionAccounts.jsify());
        }
        return WalletMessageResponse.fail(Web3RequestExceptionConst
            .rejectedByUser
            .toResponseMessage()
            .toJson()
            .jsify());
      case Web3SolanaRequestMethods.signTransaction:
      case Web3SolanaRequestMethods.signAllTransactions:
        final transactions = message.getJSParamsAs<JSUint8Array>();
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
        final txHash =
            SolanaWeb3TransactionResponse.fromJson(transactionResponse[0])
                .cast<SolanaWeb3TransactionSendResponse>();
        return WalletMessageResponse.success(txHash.txHash.toJS);
      case Web3SolanaRequestMethods.sendAllTransactions:
        final transactions = message.getJSParamsAs<JSUint8Array>();
        final transactionResponse = response
            .resultAsList<Map<String, dynamic>>(length: transactions!.length)
            .map((e) => SolanaWeb3TransactionResponse.fromJson(e));
        List<String?> txHashes = List.filled(transactions.length, null);
        for (int i = 0; i < transactionResponse.length; i++) {
          final item = transactionResponse.elementAt(i);
          if (item.type != SolanaWeb3TransactionResponseType.send) continue;
          final sendResponse = item.cast<SolanaWeb3TransactionSendResponse>();
          txHashes[i] = sendResponse.txHash;
        }
        return WalletMessageResponse.success(txHashes.jsify());
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
