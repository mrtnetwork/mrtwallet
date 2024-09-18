import 'dart:js_interop';

import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:on_chain/on_chain.dart';
import 'dart:async';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import '../core/network_handler.dart';

class EthereumWeb3State
    extends ChainWeb3State<ETHAddress, EthereumChain, Web3EthereumChain> {
  final EthereumChain? chain;
  final String? defaultAddress;
  final EthereumClient? client;

  EthereumWeb3State._({
    super.permission,
    required super.chains,
    required super.state,
    required super.permissionAccounts,
    this.client,
    this.defaultAddress,
    this.chain,
  });
  factory EthereumWeb3State.init(
      {JSNetworkState state = JSNetworkState.disconnect}) {
    return EthereumWeb3State._(
        chains: const [], permissionAccounts: const [], state: state);
  }
  factory EthereumWeb3State(
      {required Web3APPAuthentication authenticated,
      required ChainsHandler chainHandler}) {
    final permission = authenticated
        .getChainFromNetworkType<Web3EthereumChain>(NetworkType.ethereum);
    if (permission == null) {
      return EthereumWeb3State.init(state: JSNetworkState.block);
    }
    final chains = chainHandler.chains().whereType<EthereumChain>().toList();
    final currentChain =
        chains.firstWhereOrNull((e) => e.chainId == permission.currentChain);
    final permissionAccounts = currentChain == null
        ? <Web3EthereumChainAccount>[]
        : permission.chainAccounts(currentChain);
    final defaultAddress = permissionAccounts
        .firstWhereOrNull((e) => e.defaultAddress, orElse: () {
      if (permissionAccounts.isEmpty) return null;
      return permissionAccounts.first;
    });

    return EthereumWeb3State._(
        chains: chainHandler.chains().whereType<EthereumChain>().toList(),
        permission: permission,
        permissionAccounts: permissionAccounts.map((e) => e.addressStr).toList()
          ..sort(
            (a, b) => JsUtils.compareAddress(a, b, defaultAddress?.addressStr),
          ),
        state: JSNetworkState.init,
        defaultAddress: defaultAddress?.addressStr,
        chain: currentChain,
        client: currentChain?.getWeb3Provider(
            requestTimeout: ChainWeb3State.requestTimeout));
  }

  bool accountChanged(EthereumWeb3State other) {
    return !(CompareUtils.iterableIsEqual(
            permissionAccounts, other.permissionAccounts) &&
        defaultAddress == other.defaultAddress);
  }

  bool chainChanged(EthereumWeb3State other) {
    return other.chain?.chainId != chain?.chainId;
  }

  bool needToggle(EthereumWeb3State other) {
    return other.state != state;
  }

  EthereumAccountsChanged get accountsChange => EthereumAccountsChanged(
      accounts: permissionAccounts, defaultAddress: defaultAddress);
  ProviderConnectInfo get chainChangedEvent =>
      ProviderConnectInfo(chain!.chainId);

  bool get isConnect => client != null;
}

class JSEthereumHandler extends JSNetworkHandler<
    ETHAddress,
    EthereumChain,
    Web3EthereumChainAccount,
    Web3EthereumChain,
    // PageMessageRequest,
    EthereumWeb3State> {
  @override
  EthereumWeb3State state = EthereumWeb3State.init();
  JSEthereumHandler({required super.sendMessageToClient});
  void _sendEvent({required JSEventType event, Object? data}) {
    sendMessageToClient(WalletMessageEvent.build(event: event, data: data),
        JSClientType.ethereum);
  }

  void _onSubscribe(EthereumSubscribeResult result) {
    _sendEvent(event: JSEventType.message, data: result.toJson());
  }

  @override
  void initChain(
      {required Web3APPAuthentication authenticated,
      required ChainsHandler chainHandler}) {
    lock.synchronized(() async {
      final currentState = state;
      state = EthereumWeb3State(
          authenticated: authenticated, chainHandler: chainHandler);
      if (state.needToggle(currentState)) {
        _toggleEthereum(state);
        _disconnect();
        if (state.isConnect) {
          _connect(state);
          _chainChanged(state);
          if (state.client!.supportSubscribe) {
            state.client!.addSubscriptionListener(_onSubscribe);
          }
        }
        _accountChanged(state);
        return;
      }
      if (state.chainChanged(currentState)) {
        _disconnect();
        if (state.isConnect) {
          _connect(state);
          if (state.client!.supportSubscribe) {
            state.client!.addSubscriptionListener(_onSubscribe);
          }
        }
        _chainChanged(state);
      }
      if (state.accountChanged(currentState)) {
        _accountChanged(state);
      }
    });
  }

  void _disconnect() {
    _sendEvent(
        event: JSEventType.disconnect,
        data: Web3RequestExceptionConst.disconnectedChain.toJson());
  }

  void _connect(EthereumWeb3State state) async {
    if (state.client == null) return;
    _sendEvent(
        event: JSEventType.connect, data: state.chainChangedEvent.toJson());
  }

  void _accountChanged(EthereumWeb3State state) async {
    _sendEvent(
        event: JSEventType.accountsChanged,
        data: state.accountsChange.toJson());
  }

  void _chainChanged(EthereumWeb3State state) async {
    if (state.chain == null) return;
    _sendEvent(
        event: JSEventType.chainChanged,
        data: state.chainChangedEvent.toJson());
  }

  void _toggleEthereum(EthereumWeb3State state) {
    if (state.chain != null) {
      _sendEvent(event: JSEventType.active);
    } else {
      _sendEvent(
          event: JSEventType.disable,
          data: Web3RequestExceptionConst.bannedHost.data);
    }
  }

  @override
  Future<Web3MessageCore> request(PageMessageRequest params) async {
    final state = this.state;
    final method = Web3EthereumRequestMethods.fromName(params.method);
    if (method == null) return _rpcCall(params, state);
    switch (method) {
      case Web3EthereumRequestMethods.requestAccounts:
        if (state.permissionAccounts.isNotEmpty) {
          return buildResponse(state.permissionAccounts);
        }
        return Web3EthreumRequestAccounts();
      case Web3EthereumRequestMethods.switchEthereumChain:
        final parse = _parseSwitchEthereumChain(params);
        if (parse.chainId == state.chain?.chainId) {
          return buildResponse(parse.chainId.toRadix16);
        }
        final chain =
            state.chains.firstWhereOrNull((e) => e.chainId == parse.chainId);
        if (chain == null) {
          throw Web3RequestExceptionConst.ethereumNetworkDoesNotExist;
        }
        return parse;
      case Web3EthereumRequestMethods.persoalSign:
        return _personalSign(params);
      case Web3EthereumRequestMethods.addEthereumChain:
        return _parseAddEthereumChain(params);
      case Web3EthereumRequestMethods.typedData:
        return _parseTypedData(params, state.chain!.chainId);
      case Web3EthereumRequestMethods.sendTransaction:
        final transaction = _parseTransaction(params, state.chain!.chainId);
        if (transaction.transactionType == ETHTransactionType.eip1559 &&
            !state.chain!.network.coinParam.supportEIP1559) {
          throw Web3RequestExceptionConst.invalidParameters(
              Web3RequestExceptionConst.eip1559NotSupported);
        }
        return transaction;
      case Web3EthereumRequestMethods.ethAccounts:
        return buildResponse(state.permissionAccounts);
      case Web3EthereumRequestMethods.ethChainId:
        return buildResponse(state.chain!.chainId.toRadix16);
      default:
        throw UnimplementedError();
    }
  }

  Future<Web3MessageCore> _rpcCall(
      PageMessageRequest params, EthereumWeb3State state) async {
    final cl = state.client;
    if (cl == null) {
      throw Web3RequestExceptionConst.disconnected();
    }
    await cl.init();
    if (!cl.isConnect) {
      throw Web3RequestExceptionConst.disconnectedChain;
    }

    final method = EthereumMethods.fromName(params.method);
    if (method == null) {
      throw Web3RequestExceptionConst.methodDoesNotExist;
    }
    try {
      if (method == EthereumMethods.subscribe) {
        if (!cl.supportSubscribe) {
          throw Web3RequestExceptionConst.methodDoesNotSupport;
        }
        final result = await cl.subscribe(params: params.dartParams);
        return buildResponse(result);
      }
      final call = await cl.dynamicCall(method.value, params.dartParams);
      return buildResponse(call);
    } on Web3RequestException {
      rethrow;
    } on RPCError catch (e) {
      throw Web3RequestExceptionConst.fromException(e);
    } on ApiProviderException catch (e) {
      if (e.isTimeout) {
        throw Web3RequestExceptionConst.disconnected(
            message: Web3RequestExceptionConst.requestTimeoutMessage);
      } else {
        throw Web3RequestExceptionConst.disconnected();
      }
    } catch (e) {
      throw Web3RequestExceptionConst.disconnected();
    }
  }

  static EIP712Version _typedDataVersion(String methodName) {
    final version = int.tryParse(methodName[methodName.length - 1]) ?? 1;
    return EIP712Version.fromVersion(version);
  }

  static Web3EthreumTypdedData _parseTypedData(
      PageMessageRequest params, BigInt chainId) {
    try {
      final items = params.getElements(2);
      final item0 = items?.elementAt(0);
      final item1 = items?.elementAt(1);
      if (items == null) {
        throw Web3RequestExceptionConst.ethTypedData;
      }

      final EIP712Version version = _typedDataVersion(params.method);
      final String address;
      EIP712Base data;
      if (version == EIP712Version.v1) {
        address = item1 as String;
        data = EIP712Legacy.fromJson(JsUtils.toList(item0)
            .map((e) => Map<String, dynamic>.from(e))
            .toList());
      } else {
        address = item0 as String;
        data = Eip712TypedData.fromJson(JsUtils.toMap(item1), version: version);
      }
      final typdedDataParams = Web3EthreumTypdedData.fromJson({
        "address": address,
        "typedData": StringUtils.fromJson(data.toJson())
      });

      return typdedDataParams;
    } on Web3RequestException {
      rethrow;
    } catch (e) {
      throw Web3RequestExceptionConst.ethTypedData;
    }
  }

  static Web3EthreumSwitchChain _parseSwitchEthereumChain(
      PageMessageRequest params) {
    final toList = params.getFirstParam;
    if (toList == null) {
      throw Web3RequestExceptionConst.invalidList(parameterName: params.method);
    }
    final toObject = JsUtils.toMap(toList,
        error:
            Web3RequestExceptionConst.invalidMethodArgruments(params.method));
    return Web3EthreumSwitchChain.fromJson(toObject);
  }

  Future<Web3EthereumAddNewChain> _parseAddEthereumChain(
      PageMessageRequest params) async {
    final toList = params.getFirstParam;
    if (toList == null) {
      throw Web3RequestExceptionConst.invalidMethodArgruments(params.method);
    }
    final toObject = JsUtils.toMap(toList,
        error:
            Web3RequestExceptionConst.invalidMethodArgruments(params.method));

    final newChain = Web3EthereumAddNewChain.fromJson(toObject);
    final network = newChain.toNewNetwork();
    List<String> rpcsUrls = [];
    bool hasWrongChainId = false;
    for (final i in network.coinParam.providers) {
      final chainId = await MethodUtils.call(() async {
        final client = APIUtils.buildEthereumProvider(i, network);
        return await client.getChainId();
      });

      if (chainId.hasResult) {
        if (chainId.result == newChain.newChainId) {
          rpcsUrls.add(i.callUrl);
        } else {
          hasWrongChainId = true;
        }
      }
    }
    if (rpcsUrls.isEmpty) {
      if (hasWrongChainId) {
        throw Web3RequestExceptionConst.ethereumRpcWrongChainId;
      } else {
        throw Web3RequestExceptionConst.rpcConnection;
      }
    }
    return newChain.updateRpcUrl(rpcsUrls);
  }

  static Web3EthreumSendTransaction _parseTransaction(
      PageMessageRequest params, BigInt chainId) {
    final Map<String, dynamic> toJson = JsUtils.toMap(params.getFirstParam,
        error:
            Web3RequestExceptionConst.invalidMethodArgruments(params.method));
    return Web3EthreumSendTransaction.fromJson(toJson);
  }

  Web3EthreumPersonalSign _personalSign(PageMessageRequest params) {
    final items = params.getElements(2);
    final address = items?.elementAt(0);
    final challeng = items?.elementAt(1);
    if (address == null || challeng == null) {
      throw Web3RequestExceptionConst.invalidMethodArgruments(params.method);
    }
    final Map<String, dynamic> message = {
      "address": address,
      "challeng": challeng
    };
    return Web3EthreumPersonalSign.fromJson(message);
  }

  @override
  void onRequestDone(PageMessageRequest message) {
    final method = Web3EthereumRequestMethods.fromName(message.method);
    switch (method) {
      case Web3EthereumRequestMethods.addEthereumChain:
      case Web3EthereumRequestMethods.switchEthereumChain:
      case Web3EthereumRequestMethods.ethChainId:
        _chainChanged(state);
        break;
      case Web3EthereumRequestMethods.requestAccounts:
      case Web3EthereumRequestMethods.ethAccounts:
        _accountChanged(state);
        break;
      default:
    }
  }

  @override
  NetworkType get networkType => NetworkType.ethereum;

  @override
  WalletMessageResponse finilizeWalletResponse(
      {required PageMessageRequest message,
      required Web3RequestParams params,
      required Web3WalletResponseMessage response}) {
    final method = Web3EthereumRequestMethods.fromName(message.method);

    switch (method) {
      case Web3EthereumRequestMethods.requestAccounts:
        if (state.permissionAccounts.isNotEmpty) {
          return WalletMessageResponse.success(
              state.permissionAccounts.jsify());
        }
        return WalletMessageResponse.fail(Web3RequestExceptionConst
            .rejectedByUser
            .toResponseMessage()
            .toJson()
            .jsify());
      default:
    }
    return super.finilizeWalletResponse(
        message: message, params: params, response: response);
  }

  @override
  void event(PageMessageEvent event) {
    switch (event.eventType) {
      case JSEventType.accountsChanged:
        _accountChanged(state);
        break;
      case JSEventType.chainChanged:
        _chainChanged(state);
        break;
      case JSEventType.connect:
        _connect(state);
        break;
      default:
        break;
    }
  }
}
