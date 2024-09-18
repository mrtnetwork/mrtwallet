import 'dart:js_interop';

import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/ton.dart';
import 'package:ton_dart/ton_dart.dart';
import '../../models/models.dart';
import '../../utils/utils/utils.dart';
import '../core/network_handler.dart';

class TonWeb3State
    extends ChainWeb3State<TonAddress, TheOpenNetworkChain, Web3TonChain> {
  final TheOpenNetworkChain? chain;
  final TonAddressItemDTO? defaultAddress;
  final TonClient? client;

  TonWeb3State._(
      {super.permission,
      required super.chains,
      required super.state,
      required super.permissionAccounts,
      this.defaultAddress,
      this.client,
      this.chain});
  factory TonWeb3State.init(
      {JSNetworkState state = JSNetworkState.disconnect}) {
    return TonWeb3State._(
        chains: const [], permissionAccounts: const [], state: state);
  }
  factory TonWeb3State(
      {required Web3APPAuthentication authenticated,
      required ChainsHandler chainHandler}) {
    final permission =
        authenticated.getChainFromNetworkType<Web3TonChain>(NetworkType.ton);
    if (permission == null) {
      return TonWeb3State.init(state: JSNetworkState.block);
    }
    final chains =
        chainHandler.chains().whereType<TheOpenNetworkChain>().toList();
    final currentChain = chains.firstWhere(
        (e) => e.network.coinParam.workchain == permission.currentChain);
    final permissionAccounts = permission.chainAccounts(currentChain);

    TonAddressItemDTO? defaultAddress;
    if (permissionAccounts.isNotEmpty) {
      final defaultNetworkAddress =
          permissionAccounts.firstWhere((e) => e.defaultAddress, orElse: () {
        return permissionAccounts.first;
      });
      final chainAddress = currentChain.addresses.firstWhere((e) =>
          e.networkAddress == defaultNetworkAddress.address &&
          e.keyIndex == defaultNetworkAddress.keyIndex);
      defaultAddress = TonAddressItemDTO.create(
          address: chainAddress.networkAddress.toFriendlyAddress(),
          network:
              TonChainId.fromNetworkId(currentChain.network.coinParam.workchain)
                  .value,
          walletStateInit: chainAddress
                  .toWalletContract()
                  .state
                  ?.initialState()
                  .serialize()
                  .toBase64() ??
              "",
          publicKey: BytesUtils.toHexString(chainAddress.publicKey));
    }

    return TonWeb3State._(
        chains: chainHandler.chains().whereType<TheOpenNetworkChain>().toList(),
        permission: permission,
        permissionAccounts: permissionAccounts
            .map((e) => e.address.toFriendlyAddress())
            .toList()
          ..sort(
              (a, b) => JsUtils.compareAddress(a, b, defaultAddress?.address)),
        state: JSNetworkState.init,
        chain: currentChain,
        defaultAddress: defaultAddress,
        client: currentChain.getWeb3Provider(
            requestTimeout: ChainWeb3State.requestTimeout));
  }

  bool accountChanged(TonWeb3State other) {
    return !(CompareUtils.iterableIsEqual(
            permissionAccounts, other.permissionAccounts) &&
        defaultAddress?.address == other.defaultAddress?.address);
  }

  bool chainChanged(TonWeb3State other) {
    return other.chain?.network != chain?.network;
  }

  bool needToggle(TonWeb3State other) {
    return other.state != state;
  }

  bool get isConnect => chain?.provider() != null;
  TonAccountsChanged get accountsChange => TonAccountsChanged(
      accounts: permissionAccounts, defaultAddress: defaultAddress?.address);

  TonChainChanged get chainChangedEvent =>
      TonChainChanged(chain!.network.coinParam.workchain);
  bool hasPermission(TonAddress address) {
    return permission?.getPermission(address) != null;
  }
}

class JSTonHandler extends JSNetworkHandler<TonAddress, TheOpenNetworkChain,
    Web3TonChainAccount, Web3TonChain, TonWeb3State> {
  @override
  TonWeb3State state = TonWeb3State.init();

  JSTonHandler({required super.sendMessageToClient});

  @override
  void initChain(
      {required Web3APPAuthentication authenticated,
      required ChainsHandler chainHandler}) {
    lock.synchronized(() async {
      final currentState = state;
      state = TonWeb3State(
          authenticated: authenticated, chainHandler: chainHandler);
      if (state.needToggle(currentState)) {
        _toggleTon(state);
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
        _accountChanged(state);
      }
    });
  }

  void _sendEvent({required JSEventType event, Object? data}) {
    sendMessageToClient(
        WalletMessageEvent.build(event: event, data: data), JSClientType.ton);
  }

  @override
  Future<Web3MessageCore> request(PageMessageRequest params) async {
    final state = this.state;
    final method = Web3TonRequestMethods.fromName(params.method);
    switch (method) {
      case Web3TonRequestMethods.requestAccounts:
        if (state.permissionAccounts.isNotEmpty) {
          return buildResponse(state.permissionAccounts);
        }
        return Web3TonRequestAccounts();
      case Web3TonRequestMethods.sendTransaction:
        return _parseTransaction(params, state);
      case Web3TonRequestMethods.signMessage:
        final signMessage = _signMessage(params, state);
        return signMessage;
      default:
        throw Web3RequestExceptionConst.methodDoesNotExist;
    }
  }

  Web3TonSignMessage _signMessage(
      PageMessageRequest params, TonWeb3State state) {
    if (state.defaultAddress == null) {
      throw Web3RequestExceptionConst.missingPermission;
    }
    final data = JsUtils.toList<int>(params.getFirstParam,
        error: Web3RequestExceptionConst.invalidSignMessageData);
    return Web3TonSignMessage(
        address: TonAddress(state.defaultAddress!.address),
        challeng: BytesUtils.toHexString(data),
        content: StringUtils.tryDecode(data));
  }

  Future<Web3TonSendTransaction> _parseTransaction(
      PageMessageRequest params, TonWeb3State state) async {
    try {
      final json = JsUtils.toMap(params.getFirstParam);
      final String? from = json["from"];
      TonAddress account;
      if (state.defaultAddress == null) {
        throw Web3RequestExceptionConst.missingPermission;
      }
      if (from == null) {
        account = TonAddress(state.defaultAddress!.address);
      } else {
        account = TonAddress(from);
        if (!state.hasPermission(account)) {
          throw Web3RequestExceptionConst.missingPermission;
        }
      }
      return Web3TonSendTransaction.fromJson(json: json, account: account);
    } on Web3RequestException {
      rethrow;
    } catch (_) {
      throw Web3TonExceptionConstant.invalidTransaction;
    }
  }

  void _disconnect() async {
    _sendEvent(
        event: JSEventType.disconnect,
        data: Web3RequestExceptionConst.disconnectedChain.toJson());
  }

  void _connect(TonWeb3State state) async {
    if (state.chain == null) return;
    _sendEvent(
        event: JSEventType.connect, data: state.chainChangedEvent.toJson());
  }

  void _accountChanged(TonWeb3State state) async {
    _sendEvent(
        event: JSEventType.accountsChanged,
        data: state.accountsChange.toJson());
  }

  void _chainChanged(TonWeb3State state) async {
    if (state.chain == null) return;
    _sendEvent(
        event: JSEventType.chainChanged,
        data: state.chainChangedEvent.toJson());
  }

  void _toggleTon(TonWeb3State state) {
    if (state.chain != null) {
      _sendEvent(event: JSEventType.active);
    } else {
      _sendEvent(
          event: JSEventType.disable,
          data: Web3RequestExceptionConst.bannedHost.data);
    }
  }

  @override
  void onRequestDone(PageMessageRequest message) {
    final method = Web3TonRequestMethods.fromName(message.method);

    switch (method) {
      case Web3TonRequestMethods.requestAccounts:
        _accountChanged(state);
        break;
      default:
    }
  }

  @override
  NetworkType get networkType => NetworkType.ton;

  @override
  WalletMessageResponse finilizeWalletResponse(
      {required PageMessageRequest message,
      required Web3RequestParams params,
      required Web3WalletResponseMessage response}) {
    final method = Web3TonRequestMethods.fromName(message.method);

    switch (method) {
      case Web3TonRequestMethods.requestAccounts:
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
