import 'dart:js_interop';
import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_native_support/web/api/core/js.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/aptos/aptos.dart';
import 'package:mrt_wallet/wallet/web3/networks/networks.dart';
import 'package:on_chain/on_chain.dart';
import '../../js_wallet.dart';
import '../../models/models/networks/aptos.dart';
import '../../utils/utils/utils.dart';
import '../core/network_handler.dart';

class AptosWeb3State extends ChainWeb3State {
  final WalletAptosNetwork? network;

  final JSAptosWalletAccount? defaultAddress;
  final AptosClient? client;
  final List<JSAptosWalletAccount> permissionAccounts;
  final List<int> chainIds;

  AptosWeb3State._(
      {required super.state,
      required List<JSAptosWalletAccount> permissionAccounts,
      required List<int> chainIds,
      this.defaultAddress,
      this.client,
      this.network})
      : permissionAccounts = permissionAccounts.imutable,
        chainIds = chainIds.immutable;
  factory AptosWeb3State.init(
      {JSNetworkState state = JSNetworkState.disconnect}) {
    return AptosWeb3State._(
        permissionAccounts: const [], state: state, chainIds: []);
  }
  factory AptosWeb3State(Web3AptosChainAuthenticated? authenticated) {
    if (authenticated == null) {
      return AptosWeb3State.init(state: JSNetworkState.block);
    }
    final permissionAccounts = authenticated.accounts;
    final defaultAddress = permissionAccounts
        .firstWhereOrNull((e) => e.defaultAddress, orElse: () {
      if (permissionAccounts.isEmpty) return null;
      return permissionAccounts.first;
    });
    final sortedAccounts = List<Web3AptosChainAccount>.from(permissionAccounts)
      ..sort((a, b) => JsUtils.compareAddress(
          a.addressStr, b.addressStr, defaultAddress?.addressStr));
    final accounts = sortedAccounts
        .map((e) => JSAptosWalletAccount.setup(
            address: e.addressStr,
            publicKey: JSAptosPublicKey.setup(
                publicKey: e.publicKey,
                publicKeyHex:
                    BytesUtils.toHexString(e.publicKey, prefix: "0x")),
            signingScheme: e.signingScheme))
        .toList();

    /// JSAptosWalletAccount
    return AptosWeb3State._(
        permissionAccounts: accounts,
        state: JSNetworkState.init,
        network: authenticated.network,
        defaultAddress: defaultAddress == null
            ? null
            : JSAptosWalletAccount.setup(
                address: defaultAddress.addressStr,
                publicKey: JSAptosPublicKey.setup(
                    publicKey: defaultAddress.publicKey,
                    publicKeyHex: BytesUtils.toHexString(
                        defaultAddress.publicKey,
                        prefix: "0x")),
                signingScheme: defaultAddress.signingScheme),
        client: APIUtils.createApiClient(authenticated.network,
            allowInWeb3: true,
            identifier: authenticated.serviceIdentifier,
            isolate: APPIsolate.current,
            requestTimeut: ChainWeb3State.requestTimeout),
        chainIds: authenticated.chainIds);
  }

  bool accountChanged(AptosWeb3State other) {
    return !(CompareUtils.iterableIsEqual(
            permissionAccounts, other.permissionAccounts) &&
        defaultAddress == other.defaultAddress);
  }

  bool chainChanged(AptosWeb3State other) {
    return other.network?.coinParam.aptosChainType !=
        network?.coinParam.aptosChainType;
  }

  bool needToggle(AptosWeb3State other) {
    return other.state != state;
  }

  JSAptosAccountChanged get accountsChange => JSAptosAccountChanged.setup(
      addresses: permissionAccounts, defaultAddress: defaultAddress);
  JSAptosNetworkInfo get chainChangedEvent => JSAptosNetworkInfo.setup(
      chainId: network!.coinParam.aptosChainType.chainId,
      name: network!.coinParam.aptosChainType.name);
  bool hasPermission(AptosAddress? address) {
    return permissionAccounts.any((e) => e.address == address?.address);
  }

  bool get isConnect => defaultAddress != null;
}

class JSAptosHandler extends JSNetworkHandler<AptosWeb3State> {
  @override
  AptosWeb3State state = AptosWeb3State.init();

  JSAptosHandler({required super.sendMessageToClient});
  void _sendEvent({required JSEventType event, Object? data}) {
    sendMessageToClient(
        WalletMessageEvent.build(event: event, data: data), JSClientType.aptos);
  }

  @override
  Future<void> initChain(Web3APPData authenticated) async {
    await lock.synchronized(() async {
      final currentState = state;
      state = AptosWeb3State(authenticated.getAuth(networkType));
      if (state.needToggle(currentState)) {
        _toggleStellar(state);
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
    final method = Web3AptosRequestMethods.fromName(params.method);
    switch (method) {
      case Web3AptosRequestMethods.requestAccounts:
        if (state.permissionAccounts.isNotEmpty) {
          if (params.pageRequestType.isNetworkRequest) {
            final message = JSAptosWalletStandardUserResponse.approved(
                state.defaultAddress!);
            return buildResponse(message);
          }
          return buildResponse(state.defaultAddress);
        }
        return Web3AptosRequestAccounts();
      case Web3AptosRequestMethods.getNetwork:
        if (state.isConnect) {
          return buildResponse(state.chainChangedEvent);
        }
        throw Web3RequestExceptionConst.missingPermission;
      case Web3AptosRequestMethods.signTransaction:
        return _parseTransaction(params: params, state: state, method: method!);
      case Web3AptosRequestMethods.signMessage:
        return _signMessage(params: params, state: state);
      case Web3AptosRequestMethods.switchNetwork:
        return _parseSwitchChain(params: params, state: state);
      default:
        throw Web3RequestExceptionConst.methodDoesNotExist;
    }
  }

  Web3AptosSignMessage _signMessage(
      {required PageMessageRequest params, required AptosWeb3State state}) {
    final account = state.defaultAddress;
    if (account == null) {
      throw Web3RequestExceptionConst.missingPermission;
    }
    try {
      final JSAny? tx = params.getElementAt<JSAny>(0);

      if (params.pageRequestType.isNetworkRequest) {
        final JSAptosSignMessageParams aptosSignMessage = MRTJsObject.as(
            object: tx, keys: JSAptosSignMessageParams.requiredKey)!;
        return Web3AptosSignMessage.aptos(
            account: AptosAddress(account.address),
            message: aptosSignMessage.message,
            nonce: aptosSignMessage.nonce,
            address: aptosSignMessage.address,
            chainId: aptosSignMessage.chainId,
            application: aptosSignMessage.application);
      }
      final asBytes = tx as APPJSUint8Array;
      final msgbytes = asBytes.toListInt();
      try {
        AptosSimpleTransaction.deserialize(msgbytes);
        throw Web3AptosExceptionConstant.singTransactionInsteadMessage;
      } on Web3RequestException {
        rethrow;
      } catch (_) {}
      try {
        AptosMultiAgentTransaction.deserialize(msgbytes);
        throw Web3AptosExceptionConstant.singTransactionInsteadMessage;
      } on Web3RequestException {
        rethrow;
      } catch (_) {}
      return Web3AptosSignMessage.wallet(
          account: AptosAddress(account.address),
          message: BytesUtils.toHexString(asBytes.toListInt()));
    } on Web3RequestException {
      rethrow;
    } catch (e) {
      if (params.pageRequestType.isNetworkRequest) {
        throw Web3AptosExceptionConstant.invalidAptosSigningMessage;
      }
      throw Web3AptosExceptionConstant.invalidSigningMessage;
    }
  }

  Web3AptosSendTransaction _parseTransaction(
      {required PageMessageRequest params,
      required AptosWeb3State state,
      required Web3AptosRequestMethods method}) {
    AptosRawTransaction transaction;
    AptosAddress? signer;
    AptosAddress? feePayer;
    List<AptosAddress>? secondarySignerAddresses;
    try {
      final JSAptosSignTransactionRequest? tx =
          params.getElementAt<JSAptosSignTransactionRequest>(0);
      if (tx!.isMultiAgent) {
        final data =
            AptosMultiAgentTransaction.deserialize(tx.data.toListInt());
        transaction = data.rawTransaction;
        feePayer = data.feePayerAddress;
        secondarySignerAddresses = data.secondarySignerAddresses;
      } else {
        final data = AptosSimpleTransaction.deserialize(tx.data.toListInt());
        transaction = data.rawTransaction;
        feePayer = data.feePayerAddress;
      }
      if (state.hasPermission(transaction.sender)) {
        signer = transaction.sender;
      } else if (state.hasPermission(feePayer)) {
        signer = transaction.sender;
      } else {
        signer = secondarySignerAddresses
            ?.firstWhereOrNull((e) => state.hasPermission(e));
      }
      if (signer == null) {
        throw Web3RequestExceptionConst.missingPermission;
      }
      if (transaction.chainId !=
          state.network?.coinParam.aptosChainType.chainId) {
        throw Web3AptosExceptionConstant.invalidTransactionChainId;
      }
      return Web3AptosSendTransaction(
          transaction: transaction,
          account: signer,
          feePayer: feePayer,
          socondarySignerAddresses: secondarySignerAddresses,
          method: method);
    } on Web3RequestException {
      rethrow;
    } catch (e) {}
    throw Web3AptosExceptionConstant.invalidTransaction;
  }

  Web3MessageCore _parseSwitchChain(
      {required PageMessageRequest params, required AptosWeb3State state}) {
    if (!state.isConnect) {
      throw Web3RequestExceptionConst.missingPermission;
    }
    try {
      final JSAptosNetworkInfo? tx = params.getElementAt<JSAptosNetworkInfo>(0);
      if (tx != null) {
        final chainId = state.chainIds.firstWhere((e) => e == tx.chainId,
            orElse: () =>
                throw Web3AptosExceptionConstant.aptosNetworkDoesNotExist);
        if (chainId == state.network!.coinParam.aptosChainType.chainId) {
          if (params.pageRequestType.isNetworkRequest) {
            return buildResponse(JSAptosSwitchChainResponse.success());
          }
          return buildResponse(
              state.network!.coinParam.aptosChainType.chainId.toRadix16);
        }
        return Web3AptosSwitchChain(chainId: chainId);
      }
    } on Web3RequestException {
      rethrow;
    } catch (_) {}
    throw Web3AptosExceptionConstant.invalidSwitchChain;
  }

  void _disconnect() async {
    _sendEvent(
        event: JSEventType.disconnect,
        data: Web3RequestExceptionConst.disconnectedChain.toJson());
  }

  void _connect(AptosWeb3State state) async {
    if (state.defaultAddress == null) return;
    _sendEvent(event: JSEventType.connect, data: state.chainChangedEvent);
  }

  void _accountChanged(AptosWeb3State state) async {
    _sendEvent(event: JSEventType.accountsChanged, data: state.accountsChange);
  }

  void _chainChanged(AptosWeb3State state) async {
    if (state.network == null) return;
    _sendEvent(event: JSEventType.chainChanged, data: state.chainChangedEvent);
  }

  void _toggleStellar(AptosWeb3State state) {
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
  void onRequestDone(PageMessageRequest message) {}

  @override
  NetworkType get networkType => NetworkType.aptos;

  @override
  WalletMessageResponse finilizeWalletResponse(
      {required PageMessageRequest message,
      required Web3RequestParams? params,
      required Web3WalletResponseMessage response}) {
    final method = Web3AptosRequestMethods.fromName(message.method);
    switch (method) {
      case Web3AptosRequestMethods.requestAccounts:
        switch (message.pageRequestType) {
          case PageRequestType.wallet:
            if (state.permissionAccounts.isNotEmpty) {
              return WalletMessageResponse.success(state.permissionAccounts
                  .map((e) => e.address.toJS)
                  .toList()
                  .toJS);
            }
            return WalletMessageResponse.fail(Web3RequestExceptionConst
                .rejectedByUser
                .toResponseMessage()
                .toJson()
                .jsify());
          default:
            if (state.permissionAccounts.isNotEmpty) {
              final message = JSAptosWalletStandardUserResponse.approved(
                  state.defaultAddress!);
              return WalletMessageResponse.success(message);
            }
            return WalletMessageResponse.fail(
                JSAptosWalletStandardUserResponse.rejected());
        }
      case Web3AptosRequestMethods.signTransaction:
        final transactionResponse = response.resultAsList<int>();
        final message = JSAptosWalletStandardUserResponse.approved(
            JSAptosSignTransactionResponse.setup(
                bytes: transactionResponse,
                dataHex:
                    BytesUtils.toHexString(transactionResponse, prefix: "0x")));
        return WalletMessageResponse.success(message);
      case Web3AptosRequestMethods.signMessage:
        final responseMessage =
            Web3AptosSignMessageResponse.fromJson(response.resultAsMap());
        if (message.pageRequestType.isNetworkRequest) {
          final signedMessage = JSAptosSignMessageResponse.setup(
              signatureBytes: responseMessage.signature,
              signatureHex: BytesUtils.toHexString(responseMessage.signature,
                  prefix: "0x"),
              message: responseMessage.message!,
              nonce: responseMessage.nonce!,
              fullMessage: responseMessage.fullMessage!,
              prefix: responseMessage.prefix!,
              address: responseMessage.address,
              application: responseMessage.application,
              chainId: responseMessage.chainId);
          return WalletMessageResponse.success(
              JSAptosWalletStandardUserResponse.approved(signedMessage));
        }
        return WalletMessageResponse.success(
            APPJSUint8Array.fromList(responseMessage.signature));
      case Web3AptosRequestMethods.switchNetwork:
        return WalletMessageResponse.success(
            JSAptosSwitchChainResponse.success());
      default:
        break;
    }
    return super.finilizeWalletResponse(
        message: message, params: params, response: response);
  }

  @override
  WalletMessageResponse finilizeError(
      {required PageMessageRequest message,
      required Web3RequestParams? params,
      required Web3ExceptionMessage error}) {
    final method = Web3AptosRequestMethods.fromName(message.method);
    if (error.isAuthenticatedError &&
        message.pageRequestType.isNetworkRequest) {
      switch (method) {
        case Web3AptosRequestMethods.requestAccounts:
        case Web3AptosRequestMethods.sendTransaction:
        case Web3AptosRequestMethods.signTransaction:
        case Web3AptosRequestMethods.signMessage:
          return WalletMessageResponse.success(
              JSAptosWalletStandardUserResponse.rejected());
        default:
      }
    } else if (message.pageRequestType.isNetworkRequest) {
      switch (method) {
        case Web3AptosRequestMethods.switchNetwork:
          return WalletMessageResponse.success(
              JSAptosSwitchChainResponse.fail(reason: error.message));
        default:
      }
    }
    return super.finilizeError(message: message, params: params, error: error);
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
