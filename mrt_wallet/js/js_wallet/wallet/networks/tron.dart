import 'dart:js_interop';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/utils/list/extention.dart';
import 'package:mrt_wallet/app/utils/numbers/numbers.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/networks.dart';
import 'package:on_chain/on_chain.dart';
import '../../models/models.dart';
import '../core/network_handler.dart';

class TronWeb3State
    extends ChainWeb3State<TronAddress, TronChain, Web3TronChain> {
  final TronChain? chain;
  final JSTronAddress? defaultAddress;
  final TronClient? client;

  TronWeb3State._(
      {super.permission,
      required super.chains,
      required super.state,
      required super.permissionAccounts,
      this.defaultAddress,
      this.client,
      this.chain});
  factory TronWeb3State.init(
      {JSNetworkState state = JSNetworkState.disconnect}) {
    return TronWeb3State._(
        chains: const [], permissionAccounts: const [], state: state);
  }
  factory TronWeb3State(
      {required Web3APPAuthentication authenticated,
      required ChainsHandler chainHandler}) {
    final permission =
        authenticated.getChainFromNetworkType<Web3TronChain>(NetworkType.tron);
    if (permission == null) {
      return TronWeb3State.init(state: JSNetworkState.block);
    }
    final chains = chainHandler.chains().whereType<TronChain>().toList();
    final currentChain = chains.firstWhere(
        (e) => e.network.tronNetworkType == permission.currentChain);
    final permissionAccounts = permission.currentChainAccounts(currentChain);
    final defaultAddress = permissionAccounts
        .firstWhereOrNull((e) => e.defaultAddress, orElse: () {
      if (permissionAccounts.isEmpty) return null;
      return permissionAccounts.first;
    });
    return TronWeb3State._(
        chains: chainHandler.chains().whereType<TronChain>().toList(),
        permission: permission,
        permissionAccounts:
            permissionAccounts.map((e) => e.address.toAddress()).toList()
              ..sort((a, b) {
                if (a == defaultAddress?.addressStr) {
                  return -1;
                } else if (b == defaultAddress?.addressStr) {
                  return 1;
                }
                return a.compareTo(b);
              }),
        state: JSNetworkState.init,
        chain: currentChain,
        defaultAddress: defaultAddress == null
            ? null
            : JSTronAddress(
                base58: defaultAddress.address.toAddress(),
                hex: defaultAddress.address.toHex()),
        client: currentChain.getWeb3Provider(
            requestTimeout: ChainWeb3State.requestTimeout));
  }

  bool accountChanged(TronWeb3State other) {
    return !(CompareUtils.iterableIsEqual(
            permissionAccounts, other.permissionAccounts) &&
        defaultAddress?.base58 == other.defaultAddress?.base58);
  }

  bool chainChanged(TronWeb3State other) {
    return other.chain?.network.tronNetworkType !=
        chain?.network.tronNetworkType;
  }

  bool needToggle(TronWeb3State other) {
    return other.state != state;
  }

  bool get isConnect => chain?.provider() != null;
  TronAccountsChanged get accountsChange => TronAccountsChanged(
      accounts: permissionAccounts, defaultAddress: defaultAddress);
  ProviderConnectInfo get chainChangedEvent => ProviderConnectInfo(
      BigInt.from(chain!.network.tronNetworkType.genesisBlockNumber));
  bool hasPermission(TronAddress address) {
    return permission?.getPermission(address) != null;
  }

  TronWebNodeInfo? get nodeInfo => client == null
      ? null
      : TronWebNodeInfo(
          solidityNode: client!.solidityProvider.service.provider.callUrl,
          fullNode: client!.service.provider.callUrl,
          chainId:
              client!.network.tronNetworkType.genesisBlockNumber.toRadix16);
}

class JSTronHandler extends JSNetworkHandler<TronAddress, TronChain,
    Web3TronChain, ClientMessageTron, TronWeb3State> {
  @override
  TronWeb3State state = TronWeb3State.init();

  JSTronHandler({required super.sendMessageToClient});

  void initChain(
      {required Web3APPAuthentication authenticated,
      required ChainsHandler chainHandler}) {
    lock.synchronized(() async {
      final currentState = state;
      state = TronWeb3State(
          authenticated: authenticated, chainHandler: chainHandler);
      if (state.needToggle(currentState)) {
        _toggleTron(state);
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
        _toggleTron(state);
        if (state.isConnect) {
          _connect(state);
        }
      }
      if (state.accountChanged(currentState)) {
        _accountChanged(state);
      }
    });
  }

  Web3MessageCore _eventMessage(TronEventTypes type, TronWeb3State state) {
    switch (type) {
      case TronEventTypes.accountsChanged:
        _accountChanged(state);
        break;
      case TronEventTypes.chainChanged:
        _chainChanged(state);
        break;
      default:
        break;
    }
    return buildResponse(null);
  }

  @override
  Future<Web3MessageCore> request(ClientMessageTron params) async {
    final state = this.state;
    final isEvent = TronEventTypes.fromName(params.method);
    if (isEvent != null) {
      return _eventMessage(isEvent, state);
    }
    final method = Web3TronRequestMethods.fromName(params.method);
    switch (method) {
      case Web3TronRequestMethods.requestAccounts:
        if (state.permissionAccounts.isNotEmpty) {
          return buildResponse(state.permissionAccounts);
        }
        return Web3TronRequestAccounts();
      case Web3TronRequestMethods.signTransaction:
        return _parseTransaction(params, state);
      case Web3TronRequestMethods.signMessageV2:
        final signMessageV2 = _signMessageV2(params, state);
        return signMessageV2;
      default:
        throw Web3RequestExceptionConst.methodDoesNotExist;
    }
  }

  Web3TronSignMessageV2 _signMessageV2(
      ClientMessageTron params, TronWeb3State state) {
    try {
      final address = TronAddress(state.defaultAddress!.base58);
      if (params.params is JSArray) {
        final bytes = List<int>.from(params.params as List);
        return Web3TronSignMessageV2(
            address: address, challeng: BytesUtils.toHexString(bytes));
      } else if (params.params is String) {
        return Web3TronSignMessageV2(
            address: address,
            challeng: BytesUtils.toHexString(
                StringUtils.encode(params.params as String)));
      }
    } catch (_) {}
    throw Web3TronExceptionConstant.invalidSignedMessageV2Parameters;
  }

  Future<Web3TronSendTransaction> _parseTransaction(
      ClientMessageTron params, TronWeb3State state) async {
    final Map<String, dynamic>? transactionData = params.paramsAsMap();

    if (transactionData == null) {
      throw Web3TronExceptionConstant.invalidTransactionParams;
    }
    final transaction = Transaction.fromJson(transactionData);
    final txId = transactionData["txID"];
    if (txId != null && txId != transaction.rawData.txID) {
      throw Web3TronExceptionConstant.invalidTransactionTxId;
    }
    final owner = transaction.rawData.ownerAddress;
    final permissionId = transaction.rawData.permissionId();
    if (!state.hasPermission(owner)) {
      if (permissionId == null) {
        throw Web3RequestExceptionConst.missingPermission;
      }
      final accountInfo = await state.client!.getAccount(owner);
      if (accountInfo == null) {
        throw Web3TronExceptionConstant.accountNotFoundOrNotActivated;
      }
      final permission =
          accountInfo.permissions.firstWhereOrNull((e) => e.id == permissionId);
      if (permission == null) {
        throw Web3TronExceptionConstant.invalidTransactionPermissionId;
      }
      List<TronAddress> activeAddressees = [];
      for (final i in permission.keys) {
        if (state.hasPermission(i.address)) {
          activeAddressees.add(i.address);
        }
      }
      if (activeAddressees.isEmpty) {
        throw Web3RequestExceptionConst.missingPermission;
      }
      return Web3TronSendTransaction(
          transaction: transaction,
          txId: txId,
          account: activeAddressees.first);
    }
    return Web3TronSendTransaction(transaction: transaction, txId: txId);
  }

  void _disconnect() async {
    sendMessageToClient(JSWalletMessageResponseTron(
        event: TronEventTypes.disconnect,
        data: Web3RequestExceptionConst.disconnectedChain.toJson()));
  }

  void _connect(TronWeb3State state) async {
    if (state.chain == null) return;
    sendMessageToClient(JSWalletMessageResponseTron(
        event: TronEventTypes.connect, data: state.chainChangedEvent.toJson()));
  }

  void _accountChanged(TronWeb3State state) async {
    sendMessageToClient(JSWalletMessageResponseTron(
        event: TronEventTypes.accountsChanged,
        data: state.accountsChange.toJson()));
  }

  void _chainChanged(TronWeb3State state) async {
    if (state.chain == null) return;
    sendMessageToClient(JSWalletMessageResponseTron(
      event: TronEventTypes.chainChanged,
      data: state.chainChangedEvent.toJson(),
    ));
  }

  void _toggleTron(TronWeb3State state) {
    final nodeInfo = state.nodeInfo;
    if (nodeInfo != null) {
      sendMessageToClient(JSWalletMessageResponseTron(
          event: TronEventTypes.active, data: nodeInfo.toJson()));
    } else {
      sendMessageToClient(JSWalletMessageResponseTron(
          event: TronEventTypes.disable,
          data: Web3RequestExceptionConst.bannedHost.data));
    }
  }

  @override
  void onRequestDone(ClientMessageTron message) {
    final method = Web3TronRequestMethods.fromName(message.method);

    switch (method) {
      case Web3TronRequestMethods.requestAccounts:
        _accountChanged(state);
        break;
      default:
    }
  }

  @override
  Web3MessageCore finilize(
      ClientMessageTron request, Web3MessageCore response) {
    return response;
  }

  @override
  NetworkType get networkType => NetworkType.tron;
}
