import 'dart:js_interop';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/stellar.dart';
import 'package:stellar_dart/stellar_dart.dart';
import '../../models/models/networks/stellar.dart';
import '../../models/models/requests.dart';
import '../../utils/utils/utils.dart';
import '../core/network_handler.dart';

class StellarWeb3State
    extends ChainWeb3State<StellarAddress, StellarChain, Web3StellarChain> {
  final StellarChain? chain;
  final StellarAddress? defaultAddress;
  final StellarClient? client;

  StellarWeb3State._(
      {super.permission,
      required super.chains,
      required super.state,
      required super.permissionAccounts,
      this.defaultAddress,
      this.client,
      this.chain});
  factory StellarWeb3State.init(
      {JSNetworkState state = JSNetworkState.disconnect}) {
    return StellarWeb3State._(
        chains: const [], permissionAccounts: const [], state: state);
  }
  factory StellarWeb3State(
      {required Web3APPAuthentication authenticated,
      required ChainsHandler chainHandler}) {
    final permission = authenticated
        .getChainFromNetworkType<Web3StellarChain>(NetworkType.stellar);
    if (permission == null) {
      return StellarWeb3State.init(state: JSNetworkState.block);
    }
    final chains = chainHandler.chains().whereType<StellarChain>().toList();
    final currentChain = chains.firstWhere(
        (e) => e.network.coinParam.passphrase == permission.currentChain);
    final permissionAccounts = permission.chainAccounts(currentChain);
    final defaultAddress = permissionAccounts
        .firstWhereOrNull((e) => e.defaultAddress, orElse: () {
      if (permissionAccounts.isEmpty) return null;
      return permissionAccounts.first;
    });
    return StellarWeb3State._(
        chains: chainHandler.chains().whereType<StellarChain>().toList(),
        permission: permission,
        permissionAccounts:
            permissionAccounts.map((e) => e.address.toString()).toList()
              ..sort((a, b) =>
                  JsUtils.compareAddress(a, b, defaultAddress?.addressStr)),
        state: JSNetworkState.init,
        chain: currentChain,
        defaultAddress: defaultAddress?.address,
        client: currentChain.getWeb3Provider(
            requestTimeout: ChainWeb3State.requestTimeout));
  }

  bool accountChanged(StellarWeb3State other) {
    return !(CompareUtils.iterableIsEqual(
            permissionAccounts, other.permissionAccounts) &&
        defaultAddress == other.defaultAddress);
  }

  bool chainChanged(StellarWeb3State other) {
    return other.chain?.network.coinParam.passphrase !=
        chain?.network.coinParam.passphrase;
  }

  bool needToggle(StellarWeb3State other) {
    return other.state != state;
  }

  StellarAccountsChanged get accountsChange => StellarAccountsChanged(
      accounts: permissionAccounts,
      defaultAddress: defaultAddress?.toString(),
      connectInfo: chainChangedEvent);
  StellarProviderConnectInfo get chainChangedEvent =>
      StellarProviderConnectInfo(chain!.network.coinParam.passphrase);
  bool hasPermission(StellarAddress address) {
    return permission?.getPermission(address) != null;
  }

  bool get isConnect => defaultAddress != null;
}

class JSStellarHandler extends JSNetworkHandler<StellarAddress, StellarChain,
    Web3StellarChainAccount, Web3StellarChain, StellarWeb3State> {
  @override
  StellarWeb3State state = StellarWeb3State.init();

  JSStellarHandler({required super.sendMessageToClient});
  void _sendEvent({required JSEventType event, Object? data}) {
    sendMessageToClient(WalletMessageEvent.build(event: event, data: data),
        JSClientType.stellar);
  }

  @override
  void initChain(
      {required Web3APPAuthentication authenticated,
      required ChainsHandler chainHandler}) {
    lock.synchronized(() async {
      final currentState = state;
      state = StellarWeb3State(
          authenticated: authenticated, chainHandler: chainHandler);
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
    final method = Web3StellarRequestMethods.fromName(params.method);
    switch (method) {
      case Web3StellarRequestMethods.requestAccounts:
        if (state.permissionAccounts.isNotEmpty) {
          return buildResponse(state.permissionAccounts);
        }
        return Web3StellarRequestAccounts();
      case Web3StellarRequestMethods.signMessage:
        return _signMessage(params: params, state: state);
      case Web3StellarRequestMethods.signTransaction:
      case Web3StellarRequestMethods.sendTransaction:
        return _parseTransaction(params: params, state: state, method: method!);
      default:
        throw Web3RequestExceptionConst.methodDoesNotExist;
    }
  }

  Web3StellarSignMessage _signMessage(
      {required PageMessageRequest params, required StellarWeb3State state}) {
    if (state.defaultAddress == null) {
      throw Web3RequestExceptionConst.missingPermission;
    }

    final data = JsUtils.toList<int>(params.getFirstParam,
        error: Web3RequestExceptionConst.invalidSignMessageData);
    try {
      Envelope.fromXdr(data);
      throw Web3StellarExceptionConstant.singTransactionInsteadMessage;
    } catch (_) {}
    return Web3StellarSignMessage(
        address: state.defaultAddress!,
        challeng: BytesUtils.toHexString(data),
        content: StringUtils.tryDecode(data));
  }

  Web3StellarSendTransaction _parseTransaction(
      {required PageMessageRequest params,
      required StellarWeb3State state,
      required Web3StellarRequestMethods method}) {
    if (state.defaultAddress == null) {
      throw Web3RequestExceptionConst.missingPermission;
    }

    try {
      final data = params.getElementAt<JSString>(0);
      final toBytes =
          StringUtils.encode(data!.toDart, type: StringEncoding.base64);
      final tx = Envelope.fromXdr(toBytes);
      if (tx.type == EnvelopeType.txV0) {
        throw Web3StellarExceptionConstant.unsuportedTxVersion;
      }
      final StellarAddress surceAccount;
      StellarAddress account = state.defaultAddress!;
      if (tx.tx.type == EnvelopeType.txFeeBump) {
        final feeBumpTx = tx.tx.cast<StellarFeeBumpTransaction>();
        surceAccount = feeBumpTx.feeSource.address;
      } else {
        final txV1 = tx.tx.cast<StellarTransactionV1>();
        surceAccount = txV1.sourceAccount.address;
      }
      if (state.hasPermission(surceAccount)) {
        account = surceAccount;
      }
      return Web3StellarSendTransaction(
          account: account, transaction: tx, method: method);
    } on Web3RequestException {
      rethrow;
    } catch (e) {
      throw Web3StellarExceptionConstant.invalidTransaction;
    }
  }

  void _disconnect() async {
    _sendEvent(
        event: JSEventType.disconnect,
        data: Web3RequestExceptionConst.disconnectedChain.toJson());
  }

  void _connect(StellarWeb3State state) async {
    if (state.defaultAddress == null) return;
    _sendEvent(
        event: JSEventType.connect, data: state.chainChangedEvent.toJson());
  }

  void _accountChanged(StellarWeb3State state) async {
    _sendEvent(
        event: JSEventType.accountsChanged,
        data: state.accountsChange.toJson());
  }

  void _chainChanged(StellarWeb3State state) async {
    if (state.chain == null) return;
    _sendEvent(
        event: JSEventType.chainChanged,
        data: state.chainChangedEvent.toJson());
  }

  void _toggleStellar(StellarWeb3State state) {
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
    final method = Web3StellarRequestMethods.fromName(message.method);

    switch (method) {
      case Web3StellarRequestMethods.requestAccounts:
        _connect(state);
        break;
      default:
    }
  }

  @override
  NetworkType get networkType => NetworkType.stellar;

  @override
  WalletMessageResponse finilizeWalletResponse(
      {required PageMessageRequest message,
      required Web3RequestParams params,
      required Web3WalletResponseMessage response}) {
    final method = Web3StellarRequestMethods.fromName(message.method);
    switch (method) {
      case Web3StellarRequestMethods.requestAccounts:
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
