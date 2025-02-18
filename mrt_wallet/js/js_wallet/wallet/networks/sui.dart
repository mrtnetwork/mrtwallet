import 'dart:js_interop';

import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/sui/sui.dart';
import 'package:mrt_wallet/wallet/web3/networks/networks.dart';
import 'package:on_chain/on_chain.dart';
import '../../js_wallet.dart';
import '../../models/models/networks/sui.dart';
import '../../utils/utils/utils.dart';
import '../core/network_handler.dart';

class SuiWeb3State extends ChainWeb3State {
  final WalletSuiNetwork? network;
  final JSSuiWalletAccount? defaultAddress;
  final SuiClient? client;
  final List<JSSuiWalletAccount> permissionAccounts;

  SuiWeb3State._(
      {required super.state,
      required List<JSSuiWalletAccount> permissionAccounts,
      this.defaultAddress,
      this.client,
      this.network})
      : permissionAccounts = permissionAccounts.imutable;
  factory SuiWeb3State.init(
      {JSNetworkState state = JSNetworkState.disconnect}) {
    return SuiWeb3State._(permissionAccounts: const [], state: state);
  }
  factory SuiWeb3State(Web3SuiChainAuthenticated? authenticated) {
    if (authenticated == null) {
      return SuiWeb3State.init(state: JSNetworkState.block);
    }
    final permissionAccounts = authenticated.accounts;
    final defaultAddress = permissionAccounts
        .firstWhereOrNull((e) => e.defaultAddress, orElse: () {
      if (permissionAccounts.isEmpty) return null;
      return permissionAccounts.first;
    });
    final sortedAccounts = List<Web3SuiChainAccount>.from(permissionAccounts)
      ..sort((a, b) => JsUtils.compareAddress(
          a.addressStr, b.addressStr, defaultAddress?.addressStr));
    final accounts = sortedAccounts
        .map((e) => JSSuiWalletAccount.setup(
            address: e.addressStr,
            chain: authenticated.network.coinParam.suiChain.web3Name,
            publicKey: APPJSUint8Array.fromList(e.publicKey),
            signingScheme: e.signingScheme))
        .toList();

    return SuiWeb3State._(
        permissionAccounts: accounts,
        state: JSNetworkState.init,
        network: authenticated.network,
        defaultAddress: defaultAddress == null
            ? null
            : JSSuiWalletAccount.setup(
                address: defaultAddress.addressStr,
                chain: authenticated.network.coinParam.suiChain.web3Name,
                publicKey: APPJSUint8Array.fromList(defaultAddress.publicKey),
                signingScheme: defaultAddress.signingScheme),
        client: APIUtils.createApiClient(authenticated.network,
            allowInWeb3: true,
            identifier: authenticated.serviceIdentifier,
            isolate: APPIsolate.current,
            requestTimeut: ChainWeb3State.requestTimeout));
  }

  bool accountChanged(SuiWeb3State other) {
    return !(CompareUtils.iterableIsEqual(
            permissionAccounts, other.permissionAccounts) &&
        defaultAddress == other.defaultAddress);
  }

  bool chainChanged(SuiWeb3State other) {
    return other.network?.coinParam.suiChain != network?.coinParam.suiChain;
  }

  bool needToggle(SuiWeb3State other) {
    return other.state != state;
  }

  JSSuiAccountChanged get accountsChange => JSSuiAccountChanged.setup(
      accounts: permissionAccounts, defaultAddress: defaultAddress);
  JSSuiNetworkInfo get chainChangedEvent =>
      JSSuiNetworkInfo.setup(name: network!.coinParam.suiChain.web3Name);
  bool hasPermission(SuiAddress? address) {
    return permissionAccounts.any((e) => e.address == address?.address);
  }

  bool get isConnect => defaultAddress != null;
}

class JSSuiHandler extends JSNetworkHandler<SuiWeb3State> {
  @override
  SuiWeb3State state = SuiWeb3State.init();

  JSSuiHandler({required super.sendMessageToClient});
  void _sendEvent({required JSEventType event, Object? data}) {
    sendMessageToClient(
        WalletMessageEvent.build(event: event, data: data), JSClientType.sui);
  }

  @override
  Future<void> initChain(Web3APPData authenticated) async {
    await lock.synchronized(() async {
      final currentState = state;
      state = SuiWeb3State(authenticated.getAuth(networkType));
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
    final method = Web3SuiRequestMethods.fromName(params.method);
    switch (method) {
      case Web3SuiRequestMethods.requestAccounts:
        if (state.permissionAccounts.isNotEmpty) {
          return buildResponse(
              JSSuiWalletConnectResponse.setup(state.permissionAccounts));
        }
        return Web3SuiRequestAccounts();
      case Web3SuiRequestMethods.getNetwork:
        if (state.isConnect) {
          return buildResponse(state.chainChangedEvent);
        }
        throw Web3RequestExceptionConst.missingPermission;
      case Web3SuiRequestMethods.signTransaction:
      case Web3SuiRequestMethods.signAndExecuteTransaction:
      case Web3SuiRequestMethods.signTransactionBlock:
      case Web3SuiRequestMethods.signAndExecuteTransactionBlock:
        return _parseTransaction(params: params, state: state, method: method!);
      case Web3SuiRequestMethods.signMessage:
      case Web3SuiRequestMethods.signPersonalMessage:
        return _signMessage(params: params, state: state, method: method!);
      case Web3SuiRequestMethods.switchNetwork:
        return _parseSwitchChain(params: params, state: state);
      default:
        throw Web3RequestExceptionConst.methodDoesNotExist;
    }
  }

  Web3SuiSignMessage _signMessage(
      {required PageMessageRequest params,
      required SuiWeb3State state,
      required Web3RequestMethods method}) {
    try {
      final signingMessage = params.getElementAt<JSSuiSignMessageParams>(0);
      if (signingMessage?.account != null) {
        final account = SuiAddress(signingMessage!.account.address);
        if (!state.hasPermission(account)) {
          throw Web3RequestExceptionConst.missingPermission;
        }
        final messageBytes = signingMessage.message.toListInt();
        final challeng = BytesUtils.toHexString(messageBytes);
        final content = StringUtils.tryDecode(messageBytes);
        return Web3SuiSignMessage(
            account: account,
            challeng: challeng,
            method: method,
            content: content);
      }
    } on Web3RequestExceptionConst {
      rethrow;
    } catch (_) {}
    throw Web3SuiExceptionConstant.invalidSuiSigningMessage;
  }

  Web3SuiSignOrExecuteTransaction _parseTransaction(
      {required PageMessageRequest params,
      required SuiWeb3State state,
      required Web3SuiRequestMethods method}) {
    try {
      if (!state.isConnect) {
        throw Web3RequestExceptionConst.missingPermission;
      }
      final transaction =
          params.getElementAt<JSSuiSignTransactionWalletRequest>(0);
      final transactionData = JsUtils.toMap(transaction?.transaction.toDart);

      final tx = Web3SuiTransactionDataV2.fromJson(transactionData);
      if (transaction?.chain != state.network?.coinParam.suiChain.web3Name) {
        throw Web3SuiExceptionConstant.invalidTransactionNetwork(
            requestChain: transaction!.chain,
            currentChain: state.network!.coinParam.suiChain.web3Name);
      }
      SuiAddress owner = SuiAddress(transaction!.account);
      if (!state.hasPermission(owner)) {
        throw Web3RequestExceptionConst.missingPermission;
      }
      SuiApiTransactionBlockResponseOptions? executeOptions;
      SuiApiExecuteTransactionRequestType? executeType =
          SuiApiExecuteTransactionRequestType.values
              .firstWhereOrNull((e) => e.name == transaction.requestType);
      if (transaction.options != null) {
        final option = transaction.options!;
        executeOptions = SuiApiTransactionBlockResponseOptions(
            showBalanceChange: option.showBalanceChanges,
            showEffects: option.showEffects,
            showEvents: option.showEvents,
            showInput: option.showInput,
            showObjectChanges: option.showObjectChanges,
            showRawEffects: option.showEffects,
            showRawInput: option.showRawInput);
      }
      return Web3SuiSignOrExecuteTransaction(
          account: owner,
          transaction: tx,
          method: method,
          executeOptions: executeOptions,
          executeType: executeType);
    } on Web3RequestException {
      rethrow;
    } catch (_) {}
    throw Web3SuiExceptionConstant.invalidTransaction;
  }

  Web3MessageCore _parseSwitchChain(
      {required PageMessageRequest params, required SuiWeb3State state}) {
    throw Web3SuiExceptionConstant.invalidSwitchChain;
  }

  void _disconnect() async {
    _sendEvent(
        event: JSEventType.disconnect,
        data: Web3RequestExceptionConst.disconnectedChain.toJson());
  }

  void _connect(SuiWeb3State state) async {
    if (state.defaultAddress == null) return;
    _sendEvent(event: JSEventType.connect, data: state.chainChangedEvent);
  }

  void _accountChanged(SuiWeb3State state) async {
    _sendEvent(event: JSEventType.accountsChanged, data: state.accountsChange);
  }

  void _chainChanged(SuiWeb3State state) async {
    if (state.network == null) return;
    _sendEvent(event: JSEventType.chainChanged, data: state.chainChangedEvent);
  }

  void _toggleStellar(SuiWeb3State state) {
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
  NetworkType get networkType => NetworkType.sui;

  @override
  WalletMessageResponse finilizeWalletResponse(
      {required PageMessageRequest message,
      required Web3RequestParams? params,
      required Web3WalletResponseMessage response}) {
    final method = Web3SuiRequestMethods.fromName(message.method);
    switch (method) {
      case Web3SuiRequestMethods.requestAccounts:
        if (state.permissionAccounts.isNotEmpty) {
          return WalletMessageResponse.success(
              JSSuiWalletConnectResponse.setup(state.permissionAccounts));
        }
        return WalletMessageResponse.fail(Web3RequestExceptionConst
            .rejectedByUser
            .toResponseMessage()
            .toJson()
            .jsify());
      case Web3SuiRequestMethods.signTransaction:
        final transaction =
            Web3SuiSignTransactionResponse.fromJson(response.resultAsMap());
        return WalletMessageResponse.success(JSSuiSignTransactionResponse.setup(
            bytes: transaction.bytes, signature: transaction.signature));
      case Web3SuiRequestMethods.signMessage:
        final signedMessage =
            Web3SuiSignMessageResponse.fromJson(response.resultAsMap());
        return WalletMessageResponse.success(JSSuiSignMessageResponse.setup(
            messageBytes: signedMessage.messageBytes,
            signature: signedMessage.signature));
      case Web3SuiRequestMethods.signPersonalMessage:
        final signedMessage =
            Web3SuiSignMessageResponse.fromJson(response.resultAsMap());
        return WalletMessageResponse.success(
            JSSuiSignPrsonalMessageResponse.setup(
                bytes: signedMessage.messageBytes,
                signature: signedMessage.signature));

      case Web3SuiRequestMethods.signTransactionBlock:
        final transaction =
            Web3SuiSignTransactionResponse.fromJson(response.resultAsMap());
        return WalletMessageResponse.success(
            JSSuiSignTransactionBlockResponse.setup(
                transactionBlockBytes: transaction.bytes,
                signature: transaction.signature));
      case Web3SuiRequestMethods.signAndExecuteTransaction:
        final transaction = Web3SuiSignAndExecuteTransactionResponse.fromJson(
            response.resultAsMap());
        return WalletMessageResponse.success(
            JSSuiSignAndExecuteTransactionResponse.setup(
                digest: transaction.digest, effects: transaction.effects));
      case Web3SuiRequestMethods.signAndExecuteTransactionBlock:
        final transaction = Web3SuiSignAndExecuteTransactionResponse.fromJson(
            response.resultAsMap());
        final jsResponse = JSSuiSignAndExecuteTransactionBlockResponse(
            transaction.excuteResponse.jsify() ?? JSObject());
        jsResponse.digest = transaction.digest;
        return WalletMessageResponse.success(jsResponse);

      default:
        break;
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
      case JSEventType.change:
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
