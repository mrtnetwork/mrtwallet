import 'dart:js_interop';
import 'package:mrt_native_support/web/mrt_native_web.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:on_chain/on_chain.dart';
import 'dart:async';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import '../../models/models.dart';
import '../../models/models/networks/wallet_standard.dart';
import '../../utils/utils.dart';
import '../../utils/utils/ethreum_js_provider.dart';
import '../core/network_handler.dart';

class EthereumWeb3State extends WalletStandardChainWeb3State<
    ETHAddress,
    Web3EthereumChainAccount,
    JSSEthereumWalletAccount,
    Web3EthereumChainIdnetifier> {
  final JSEthereumClient? client;

  bool chainExist(BigInt chainId) {
    return chains.any((e) => e.chainId == chainId);
  }

  Web3EthereumChainIdnetifier getChainFromChainId(BigInt chainId) {
    return chains.firstWhere((e) => e.chainId == chainId,
        orElse: () => throw Web3RequestExceptionConst.networkDoesNotExists);
  }

  EthereumWeb3State._({
    required super.state,
    required super.chains,
    required super.accounts,
    this.client,
    super.defaultAccount,
    super.defaultChain,
  });
  factory EthereumWeb3State.init(
      {JSNetworkState state = JSNetworkState.disconnect}) {
    return EthereumWeb3State._(accounts: const [], state: state, chains: []);
  }
  factory EthereumWeb3State(Web3EthereumChainAuthenticated? authenticated) {
    if (authenticated == null) {
      return EthereumWeb3State.init(state: JSNetworkState.block);
    }
    Map<int, Web3EthereumChainIdnetifier> networks = {
      for (final i in authenticated.networks) i.id: i
    };
    final accounts = authenticated.accounts
        .map((e) => JSWalletStateAccount<ETHAddress, Web3EthereumChainAccount,
                JSSEthereumWalletAccount>(
            chainaccount: e,
            jsAccount: JSSEthereumWalletAccount.setup(
                address: e.addressStr,
                publicKey: e.publicKey,
                chain: networks[e.id]!.identifier),
            identifier: networks[e.id]!.identifier))
        .toList();
    final defaultAddress = authenticated.accounts.firstWhereOrNull(
        (e) => e.id == authenticated.currentNetwork.id && e.defaultAddress);
    final provider = authenticated.serviceIdentifier;
    return EthereumWeb3State._(
        accounts: accounts,
        state: JSNetworkState.init,
        chains: authenticated.networks,
        client: provider == null ? null : JSEthereumClient(provider),
        defaultChain: authenticated.currentNetwork,
        defaultAccount: defaultAddress == null
            ? null
            : JSWalletStateAccount<ETHAddress, Web3EthereumChainAccount,
                JSSEthereumWalletAccount>(
                chainaccount: defaultAddress,
                identifier: authenticated.currentNetwork.identifier,
                jsAccount: JSSEthereumWalletAccount.setup(
                    publicKey: defaultAddress.publicKey,
                    address: defaultAddress.addressStr,
                    chain: networks[defaultAddress.id]!.identifier),
              ));
  }
}

class JSEthereumHandler extends JSWalletStandardNetworkHandler<
    ETHAddress,
    Web3EthereumChainAccount,
    JSSEthereumWalletAccount,
    Web3EthereumChainIdnetifier,
    EthereumWeb3State> {
  JSEthereumHandler(
      {required super.sendMessageToClient, required super.sendInternalMessage});
  void _onSubscribe(EthereumSubscribeResult result) {
    final event = JSWalletNetworkEvent(
        events: [JSNetworkEventType.message], message: result.toJson().jsify());
    sendMessageToClient(WalletMessageEvent.build(data: event),
        JSClientType.fronNetworkName(networkType.name));
  }

  @override
  JSWalletNetworkEvent createStateEvent(
      {required EthereumWeb3State previousState,
      required EthereumWeb3State currentState,
      required bool networkAccountsChanged,
      required bool networkChanged,
      required bool networksChanged,
      required bool accountsChanged}) {
    final event = super.createStateEvent(
        previousState: previousState,
        currentState: currentState,
        networksChanged: networksChanged,
        networkAccountsChanged: networkAccountsChanged,
        networkChanged: networkChanged,
        accountsChanged: accountsChanged);
    if (networkChanged) {
      previousState.client?.close();
      final chain = currentState.defaultChain;
      currentState.client?.addSubscriptionListener(_onSubscribe);
      if (chain != null) {
        event.chainChanged = JSEthereumEIPChainChanged(
            chainId: chain.chainId.toRadix16,
            netVersion: chain.chainId.toString());
      }
      if (chain == null || currentState.client == null) {
        final error = Web3RequestExceptionConst.disconnectProvider;
        event.disconnect = JSEthereumEIPProviderRpcError(
            message: error.message, code: error.code);
      }
    }
    return event;
  }

  @override
  Future<JSWalletNetworkEvent?> createEvent(JSEventType event) async {
    final state = await getState();
    switch (event) {
      case JSEventType.chainChanged:
      case JSEventType.connect:
        final event = JSWalletNetworkEvent(
            events: [JSNetworkEventType.defaultChainChanged]);
        final chain = state.defaultChain;
        if (chain != null) {
          event.chainChanged = JSEthereumEIPChainChanged(
              chainId: chain.chainId.toRadix16,
              netVersion: chain.chainId.toString());
        }
        if (chain == null || state.client == null) {
          final error = Web3RequestExceptionConst.disconnectProvider;
          event.disconnect = JSEthereumEIPProviderRpcError(
              message: error.message, code: error.code);
        }
        return event;
      default:
        return super.createEvent(event);
    }
  }

  @override
  Future<Web3MessageCore> request(PageMessageRequest params) async {
    final state = await getState();
    final method = Web3EthereumRequestMethods.fromName(params.method);
    if (method == null) return _rpcCall(params, state);
    switch (method) {
      case Web3EthereumRequestMethods.requestAccounts:
        if (params.isWalletStandard) {
          if (state.hasAccount) {
            return createResponse();
          }
        } else if (state.hasChainAccount) {
          return createResponse();
        }
        return connect();
      case Web3EthereumRequestMethods.switchEthereumChain:
        final parse = _parseSwitchEthereumChain(params);

        if (parse.chainId == state.defaultChain?.chainId) {
          return createResponse(parse.chainId.toRadix16);
        }
        if (!state.chainExist(parse.chainId)) {
          throw Web3RequestExceptionConst.networkDoesNotExists;
        }
        return parse;
      case Web3EthereumRequestMethods.persoalSign:
        if (params.isWalletStandard) {
          return _parseWalletStandardPersonalSign(params: params, state: state);
        }
        return _personalSign(params: params, state: state);
      case Web3EthereumRequestMethods.addEthereumChain:
        return _parseAddEthereumChain(params: params, state: state);
      case Web3EthereumRequestMethods.typedData:
        if (params.isWalletStandard) {
          return _parseWalletStandardTypedData(params: params, state: state);
        }
        return _parseTypedData(params: params, state: state);
      case Web3EthereumRequestMethods.sendTransaction:
        return _parseTransactionRequest(params: params, state: state);
      case Web3EthereumRequestMethods.ethAccounts:
        return createResponse(state.defaultNetworkAddresses);
      case Web3EthereumRequestMethods.ethChainId:
        return createResponse(state.defaultChainOrThrow.chainId.toRadix16);
      default:
        throw UnimplementedError();
    }
  }

  Future<Web3MessageCore> _rpcCall(
      PageMessageRequest params, EthereumWeb3State state) async {
    final client = state.client;
    if (client == null) {
      throw Web3RequestExceptionConst.disconnectProvider;
    }
    final method = EthereumMethods.fromName(params.method);
    if (method == null) {
      throw Web3RequestExceptionConst.methodDoesNotExist;
    }
    final result = await client.call(params.method, params.dartParams);
    return createResponse(result);
  }

  static EIP712Version _typedDataVersion(String methodName) {
    final version = int.tryParse(methodName[methodName.length - 1]) ?? 1;
    return EIP712Version.fromVersion(version);
  }

  static Web3EthreumTypdedData _parseWalletStandardTypedData(
      {required PageMessageRequest params, required EthereumWeb3State state}) {
    try {
      final param = params.elementAs<JSEthereumSignTypedDataParams>(0,
          peroperties: JSEthereumSignTypedDataParams.peroperties);
      if (param == null) {
        throw Web3EthereumExceptionConst.invalidWalletStandardTypeData;
      }

      final EIP712Version version = _typedDataVersion(params.method);
      final account = state.getJsAddressChainAccountOrThrow(param.account);
      EIP712Base? data;
      if (version == EIP712Version.v1) {
        data = MethodUtils.nullOnException(
            () => EIP712Legacy.fromJson(JsUtils.toListOfMap(param.typedData)!));
      } else {
        data = MethodUtils.nullOnException(() => Eip712TypedData.fromJson(
            JsUtils.toDartMap(param.typedData)!,
            version: version));
      }
      if (data == null) {
        throw Web3EthereumExceptionConst.parsignTypedDataFailed(
            version.version);
      }
      final typdedDataParams = Web3EthreumTypdedData(data, account);
      return typdedDataParams;
    } on Web3RequestException {
      rethrow;
    } catch (e) {
      throw Web3EthereumExceptionConst.invalidTypeData;
    }
  }

  static Web3EthreumTypdedData _parseTypedData(
      {required PageMessageRequest params, required EthereumWeb3State state}) {
    try {
      final EIP712Version version = _typedDataVersion(params.method);
      ETHAddress? address;
      EIP712Base? data;
      if (version == EIP712Version.v1) {
        address = MethodUtils.nullOnException(
            () => ETHAddress(params.elementAs<JSString>(1)?.toDart ?? ''));
        data = MethodUtils.nullOnException(() =>
            EIP712Legacy.fromJson(JsUtils.toListOfMap(params.elementAs(0))!));
      } else {
        address = MethodUtils.nullOnException(
            () => ETHAddress(params.elementAs<JSString>(0)?.toDart ?? ''));
        data = MethodUtils.nullOnException(() => Eip712TypedData.fromJson(
            JsUtils.toDartMap(params.elementAs(1))!,
            version: version));
      }
      if (address == null || data == null) {
        throw Web3EthereumExceptionConst.invalidTypeData;
      }

      final typdedDataParams = Web3EthreumTypdedData(
          data, state.getAddressNetworkChainAccountOrThrow(address));

      return typdedDataParams;
    } on Web3RequestException {
      rethrow;
    } catch (e) {
      throw Web3EthereumExceptionConst.invalidTypeData;
    }
  }

  static Web3EthreumSwitchChain _parseSwitchEthereumChain(
      PageMessageRequest params) {
    try {
      final param = params.elementAs<JSEthereumSwitchChainParams>(0);
      return Web3EthreumSwitchChain(chainId: BigintUtils.parse(param?.chainId));
    } catch (e) {
      throw Web3EthereumExceptionConst.invalidSwitchChain;
    }
  }

  Future<Web3MessageCore> _parseAddEthereumChain(
      {required PageMessageRequest params,
      required EthereumWeb3State state}) async {
    final param = params.elementAs<JSEthereumAddNewChainParams>(0);
    if (param == null) {
      throw Web3EthereumExceptionConst.missingChainId;
    }
    final chainId = BigintUtils.tryParse(param.chainId);
    if (chainId == null) {
      throw Web3EthereumExceptionConst.missingChainId;
    }
    if (state.chainExist(chainId)) {
      return createResponse(chainId.toRadix16);
    }

    final chainName = param.chainName;
    if (chainName == null) {
      throw Web3EthereumExceptionConst.missingChainName;
    }
    final nativeCurrency = param.nativeCurrency;
    if (nativeCurrency == null) {
      throw Web3EthereumExceptionConst.missingNativeCurrency;
    }
    if (nativeCurrency.name == null) {
      throw Web3EthereumExceptionConst.missingName;
    }
    if (nativeCurrency.symbol == null) {
      throw Web3EthereumExceptionConst.missingSymbol;
    }

    List<String> rpcUrls =
        param.rpcUrls?.toDart.map((e) => e.toDart).toList() ?? [];
    rpcUrls = rpcUrls.where((e) => ServiceProtocol.isValid(e)).toList();

    if (rpcUrls.isEmpty) {
      throw Web3EthereumExceptionConst.missingRpcUrls;
    }
    return Web3EthereumAddNewChain(
        newChainId: chainId,
        chainName: chainName,
        name: nativeCurrency.name!,
        symbol: nativeCurrency.symbol!,
        decimals: ETHConst.decimals,
        rpcUrls: rpcUrls,
        blockExplorerUrls:
            param.blockExplorerUrls?.toDart.map((e) => e.toDart).toList(),
        iconUrls: param.iconUrls?.toDart.map((e) => e.toDart).toList());
  }

  static Web3EthreumSendTransaction _parseTransaction(
      {required PageMessageRequest params,
      required EthereumWeb3State state,
      required Web3EthereumChainAccount account,
      required JSEthereumTransactionParams param}) {
    final chainId = BigintUtils.tryParse(param.chainId);
    if (chainId != null) {
      final network = state.getChainFromChainId(chainId);
      if (network.id != account.id) {
        throw Web3EthereumExceptionConst.mismatchAccountAndTransactionChainId;
      }
    }
    final maxFeePerGas = BigintUtils.tryParse(param.maxFeePerGas);
    final gasPrice = BigintUtils.tryParse(param.gasPrice);
    final value = BigintUtils.tryParse(param.value);
    final maxPriorityFeePerGas =
        BigintUtils.tryParse(param.maxPriorityFeePerGas);
    final gas = IntUtils.tryParse(param.gasLimit);
    if (value == null) {
      throw Web3EthereumExceptionConst.missingTransactionRequiredFields;
    }
    final type = IntUtils.tryParse(param.type);
    final to = MethodUtils.nullOnException(() => ETHAddress(param.to!));
    if (param.to != null && to == null) {
      throw Web3EthereumExceptionConst.missingTo;
    }
    List<int>? data;
    if (param.data != null) {
      data = BytesUtils.tryFromHexString(param.data);
      if (data == null) {
        throw Web3EthereumExceptionConst.invalidTransactionData;
      }
    }
    List<Web3EthreumTransactionAccessList> accessList = [];
    if (param.accessList != null) {
      final accessListDart = param.accessList!.toDart;
      for (final i in accessListDart) {
        final address =
            MethodUtils.nullOnException(() => ETHAddress(i.address!));
        final dartStorageKeys = i.storageKeys?.toDart;
        if (address == null ||
            dartStorageKeys == null ||
            dartStorageKeys.isEmpty) {
          throw Web3EthereumExceptionConst.invalidAccessListParams;
        }
        List<List<int>> storageKeys = [];
        for (final i in dartStorageKeys) {
          final storageKey = BytesUtils.tryFromHexString(i.toDart);
          if (storageKey == null) {
            throw Web3EthereumExceptionConst.invalidAccessListParams;
          }
          storageKeys.add(storageKey);
        }
        accessList.add(Web3EthreumTransactionAccessList(
            address: address, storageKeys: storageKeys));
      }
    }
    final transaction = Web3EthreumSendTransaction(
        account: account,
        chainId: chainId,
        gas: gas,
        maxPriorityFeePerGas: maxPriorityFeePerGas,
        maxFeePerGas: maxFeePerGas,
        gasPrice: gasPrice,
        value: value,
        to: to,
        transactionType: type,
        data: data,
        accessList: accessList.isEmpty ? null : accessList);
    if (transaction.transactionType == ETHTransactionType.eip1559 &&
        !state.defaultChain!.supportEIP1559) {
      throw Web3RequestExceptionConst.invalidParameters(
          Web3RequestExceptionConst.eip1559NotSupported);
    }

    return Web3EthreumSendTransaction(
        account: account,
        chainId: chainId,
        gas: gas,
        maxPriorityFeePerGas: maxPriorityFeePerGas,
        maxFeePerGas: maxFeePerGas,
        gasPrice: gasPrice,
        value: value,
        to: to,
        transactionType: type,
        data: data,
        accessList: accessList.isEmpty ? null : accessList);
  }

  static Web3EthreumSendTransaction _parseTransactionRequest(
      {required PageMessageRequest params, required EthereumWeb3State state}) {
    JSEthereumTransactionParams? param;
    final Web3EthereumChainAccount account;
    ETHAddress? from;
    if (params.isWalletStandard) {
      final wsParam =
          params.elementAs<JSEthereumWalletStandardTransactionParams>(0,
              peroperties:
                  JSEthereumWalletStandardTransactionParams.properties);
      if (wsParam == null) {
        throw Web3EthereumExceptionConst.invalidWalletStandardSendTransaction;
      }
      account = state.getJsAddressChainAccountOrThrow(wsParam.account);
      param = MRTJsObject.as(
          object: wsParam.transaction,
          keys: JSEthereumTransactionParams.properties);
      if (param == null) {
        throw Web3EthereumExceptionConst.missingTransactionRequiredFields;
      }
    } else {
      param = params.elementAs(0,
          peroperties: JSEthereumTransactionParams.properties);
      if (param?.from != null) {
        from = MethodUtils.nullOnException(() => ETHAddress(param!.from!));
        account = state.getAddressNetworkChainAccountOrThrow(from);
      } else {
        account = state.defaultNetworkChainAccountOrThrow;
      }
    }
    if (param == null) {
      throw Web3EthereumExceptionConst.missingTransactionRequiredFields;
    }
    if (param.from != null) {
      from ??= MethodUtils.nullOnException(() => ETHAddress(param!.from!));
      if (from == null) {
        throw Web3EthereumExceptionConst.missingFrom;
      }
      if (from != account.address) {
        throw Web3EthereumExceptionConst.mismatchAccountAndTransactionFrom;
      }
    }

    return _parseTransaction(
        params: params, state: state, account: account, param: param);
  }

  Web3EthreumPersonalSign _parseWalletStandardPersonalSign(
      {required PageMessageRequest params, required EthereumWeb3State state}) {
    try {
      final param = params.elementAs<JSEthereumSignMessageParams>(0,
          peroperties: JSEthereumSignMessageParams.peroperties);
      final messageBytes = param?.message?.toListInt();
      if (param == null || messageBytes == null) {
        throw Web3RequestExceptionConst.invalidWalletStandardSignMessage;
      }
      Web3EthereumChainAccount account =
          state.getJsAddressChainAccountOrThrow(param.account);
      return Web3EthreumPersonalSign(
          BytesUtils.toHexString(messageBytes), account);
    } on Web3RequestException {
      rethrow;
    } catch (e) {
      throw Web3RequestExceptionConst.invalidWalletStandardSignMessage;
    }
  }

  Web3EthreumPersonalSign _personalSign(
      {required PageMessageRequest params, required EthereumWeb3State state}) {
    final message = JsUtils.parseHexString(params.elementAs<JSString>(0));
    if (message == null) {
      throw Web3EthereumExceptionConst.invalidMessage;
    }
    Web3EthereumChainAccount account;
    final address = params.elementAs<JSString>(1);
    if (address != null) {
      final ethAddress =
          MethodUtils.nullOnException(() => ETHAddress(address.toDart));
      if (ethAddress == null) {
        throw Web3EthereumExceptionConst.invalidAddress;
      }
      account = state.getAddressNetworkChainAccountOrThrow(ethAddress);
    } else {
      account = state.defaultNetworkChainAccountOrThrow;
    }
    return Web3EthreumPersonalSign(message, account);
  }

  @override
  void onRequestDone(PageMessageRequest message) {}

  @override
  NetworkType get networkType => NetworkType.ethereum;

  @override
  Future<WalletMessageResponse> finalizeWalletResponse(
      {required PageMessageRequest message,
      required Web3RequestParams? params,
      required Web3WalletResponseMessage response}) async {
    final state = await getState();
    final method = Web3EthereumRequestMethods.fromName(message.method);

    switch (method) {
      case Web3EthereumRequestMethods.sendTransaction:
        final signature = response.resultAsString();
        if (message.isWalletStandard) {
          return WalletMessageResponse.success(
              JSEthereumSendTransactionResponse.setup(signature));
        } else {
          return WalletMessageResponse.success(signature.toJS);
        }
      case Web3EthereumRequestMethods.typedData:
      case Web3EthereumRequestMethods.persoalSign:
        final signature = response.resultAsString();
        if (message.isWalletStandard) {
          return WalletMessageResponse.success(
              JSEthereumSignatureResponse.setup(
                  BytesUtils.fromHexString(signature)));
        } else {
          return WalletMessageResponse.success(signature.toJS);
        }
      case Web3EthereumRequestMethods.requestAccounts:
        if (message.isWalletStandard) {
          if (state.hasAccount) {
            return WalletMessageResponse.success(
                JSEthereumWalletStandardConnect.setup(state.jsAccounts));
          }
        } else if (state.hasChainAccount) {
          return WalletMessageResponse.success(
              state.defaultNetworkAddresses.toJS);
        }
        return WalletMessageResponse.fail(Web3RequestExceptionConst
            .rejectedByUser
            .toResponseMessage()
            .toJson()
            .jsify());
      default:
    }
    return super.finalizeWalletResponse(
        message: message, params: params, response: response);
  }

  @override
  EthereumWeb3State createState(Web3APPData? authenticated) {
    if (authenticated == null) return EthereumWeb3State.init();
    return EthereumWeb3State(authenticated.getAuth(networkType));
  }
}
