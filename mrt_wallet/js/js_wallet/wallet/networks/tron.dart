import 'dart:js_interop';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/isolate/types.dart';
import 'package:mrt_wallet/app/utils/list/extension.dart';
import 'package:mrt_wallet/app/utils/numbers/numbers.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/networks.dart';
import 'package:on_chain/on_chain.dart';
import '../../models/models.dart';
import '../../utils/utils/utils.dart';
import '../core/network_handler.dart';

class TronWeb3State extends ChainWeb3State {
  final WalletTronNetwork? network;
  final JSTronDefaultAddress? defaultAddress;
  final TronClient? client;
  final List<BigInt> existsChain;
  final List<String> permissionAccounts;

  TronWeb3State._({
    required super.state,
    required List<String> permissionAccounts,
    required List<BigInt> existsChain,
    this.defaultAddress,
    this.client,
    this.network,
  })  : existsChain = existsChain.imutable,
        permissionAccounts = permissionAccounts.imutable;
  factory TronWeb3State.init(
      {JSNetworkState state = JSNetworkState.disconnect}) {
    return TronWeb3State._(
        permissionAccounts: const [], state: state, existsChain: []);
  }
  factory TronWeb3State(Web3TronChainAuthenticated? authenticated) {
    if (authenticated == null) {
      return TronWeb3State.init(state: JSNetworkState.block);
    }
    final permissionAccounts = authenticated.accounts;
    final defaultAddress = permissionAccounts
        .firstWhereOrNull((e) => e.defaultAddress, orElse: () {
      if (permissionAccounts.isEmpty) return null;
      return permissionAccounts.first;
    });
    return TronWeb3State._(
        permissionAccounts:
            permissionAccounts.map((e) => e.address.toAddress()).toList()
              ..sort((a, b) =>
                  JsUtils.compareAddress(a, b, defaultAddress?.addressStr)),
        state: JSNetworkState.init,
        existsChain: authenticated.chainIds,
        network: authenticated.network,
        defaultAddress: defaultAddress == null
            ? null
            : JSTronDefaultAddress(
                base58: defaultAddress.address.toAddress(),
                hex: defaultAddress.address.toHex()),
        client: APIUtils.createApiClient(authenticated.network,
            allowInWeb3: true,
            identifier: authenticated.serviceIdentifier,
            isolate: APPIsolate.current,
            requestTimeut: ChainWeb3State.requestTimeout));
  }

  bool accountChanged(TronWeb3State other) {
    return !(CompareUtils.iterableIsEqual(
            permissionAccounts, other.permissionAccounts) &&
        defaultAddress?.base58 == other.defaultAddress?.base58);
  }

  bool chainChanged(TronWeb3State other) {
    return other.network?.tronNetworkType != network?.tronNetworkType;
  }

  bool needToggle(TronWeb3State other) {
    return other.state != state;
  }

  bool get isConnect => network != null;
  TronAccountsChanged get accountsChange => TronAccountsChanged(
      accounts: permissionAccounts, defaultAddress: defaultAddress);
  TronChainChanged get chainChangedEvent => TronChainChanged(
      netVersion: BigInt.from(network!.tronNetworkType.genesisBlockNumber),
      fullNode: client!.service.provider.callUrl,
      solidityNode: client!.solidityProvider.service.provider.callUrl,
      address: defaultAddress);
  bool hasPermission(TronAddress address) {
    return permissionAccounts.any((e) => e == address.toAddress());
  }

  TronWebNodeInfo? get nodeInfo => client == null
      ? null
      : TronWebNodeInfo(
          solidityNode: client!.solidityProvider.service.provider.callUrl,
          fullNode: client!.service.provider.callUrl,
          chainId:
              client!.network.tronNetworkType.genesisBlockNumber.toRadix16);
}

class JSTronHandler extends JSNetworkHandler<TronWeb3State> {
  @override
  TronWeb3State state = TronWeb3State.init();

  JSTronHandler({required super.sendMessageToClient});

  @override
  void initChain(Web3APPData authenticated) {
    lock.synchronized(() async {
      final currentState = state;
      state = TronWeb3State(authenticated.getAuth(networkType));
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

  @override
  Future<Web3MessageCore> request(PageMessageRequest params) async {
    final state = this.state;
    final method = Web3TronRequestMethods.fromName(params.method);
    switch (method) {
      case Web3TronRequestMethods.requestAccounts:
        if (state.permissionAccounts.isNotEmpty) {
          return buildResponse(state.permissionAccounts);
        }
        return Web3TronRequestAccounts();
      case Web3TronRequestMethods.switchTronChain:
        final parse = _parseSwitchTronChain(params);
        if (parse.chainId.toInt() ==
            state.network?.tronNetworkType.genesisBlockNumber) {
          return buildResponse(parse.chainId.toRadix16);
        }
        final chain = state.existsChain.contains(parse.chainId);
        if (!chain) {
          throw Web3TronExceptionConstant.tronNetworkDoesNotExist;
        }
        return parse;
      case Web3TronRequestMethods.signTransaction:
        return _parseTransaction(params, state);
      case Web3TronRequestMethods.signMessageV2:
        final signMessageV2 = _signMessageV2(params, state);
        return signMessageV2;
      default:
        throw Web3RequestExceptionConst.methodDoesNotExist;
    }
  }

  static Web3TronSwitchChain _parseSwitchTronChain(PageMessageRequest params) {
    final toList = params.getFirstParam;
    if (toList == null) {
      throw Web3RequestExceptionConst.invalidList(parameterName: params.method);
    }
    final toObject = JsUtils.toMap(toList,
        error:
            Web3RequestExceptionConst.invalidMethodArgruments(params.method));
    return Web3TronSwitchChain.fromJson(toObject);
  }

  Web3TronSignMessageV2 _signMessageV2(
      PageMessageRequest params, TronWeb3State state) {
    try {
      final address = TronAddress(state.defaultAddress!.base58);
      final data = params.getFirstParam;

      if (data is String) {
        return Web3TronSignMessageV2(
            address: address,
            challeng: BytesUtils.toHexString(StringUtils.encode(data)));
      }
      final bytes = List<int>.from(data as List);
      return Web3TronSignMessageV2(
          address: address, challeng: BytesUtils.toHexString(bytes));
    } catch (_) {}
    throw Web3TronExceptionConstant.invalidSignedMessageV2Parameters;
  }

  Future<Web3TronSendTransaction> _parseTransaction(
      PageMessageRequest params, TronWeb3State state) async {
    try {
      final Map<String, dynamic> transactionData = JsUtils.toMap(
          params.getFirstParam,
          error: Web3TronExceptionConstant.invalidTransactionParams);
      final transaction = Transaction.fromJson(transactionData);
      String? txId;
      if (transactionData["txID"] != null) {
        txId = BytesUtils.toHexString(
            BytesUtils.fromHexString(transactionData["txID"]));
      }
      if (txId != null && txId != transaction.rawData.txID) {
        throw Web3TronExceptionConstant.invalidTransactionTxId;
      }
      final owner = transaction.rawData.ownerAddress;
      final permissionId = transaction.rawData.permissionId();
      if (!state.hasPermission(owner)) {
        final accountInfo = await state.client!.getAccount(owner);
        if (accountInfo == null) {
          throw Web3TronExceptionConstant.accountNotFoundOrNotActivated;
        }
        final permission = accountInfo.permissions.firstWhereOrNull(
            (e) => e.type != PermissionType.witness && e.id == permissionId);
        if (permission == null) {
          throw Web3TronExceptionConstant.invalidTransactionPermissionId;
        }
        final List<TronAddress> activeAddressees = [];
        for (final i in permission.keys) {
          if (state.hasPermission(i.address)) {
            activeAddressees.add(i.address);
          }
        }
        if (activeAddressees.isEmpty) {
          throw Web3RequestExceptionConst.missingPermission;
        }
        return Web3TronSendTransaction(
            transaction: transactionData,
            txId: txId,
            account: activeAddressees.first);
      }
      return Web3TronSendTransaction(
          transaction: transactionData,
          txId: txId,
          account: transaction.rawData.ownerAddress);
    } on Web3RequestException {
      rethrow;
    } catch (e) {
      throw Web3RequestExceptionConst.fromException(e);
    }
  }

  void _sendEvent({required JSEventType event, Object? data}) {
    sendMessageToClient(
        WalletMessageEvent.build(event: event, data: data), JSClientType.tron);
  }

  void _disconnect() async {
    _sendEvent(
        event: JSEventType.disconnect,
        data: Web3RequestExceptionConst.disconnectedChain.toJson());
  }

  void _connect(TronWeb3State state) async {
    if (state.network == null) return;
    _sendEvent(
        event: JSEventType.connect, data: state.chainChangedEvent.toJson());
  }

  void _accountChanged(TronWeb3State state) async {
    _sendEvent(
        event: JSEventType.accountsChanged,
        data: state.accountsChange.toJson());
  }

  void _chainChanged(TronWeb3State state) async {
    if (state.network == null) return;
    _sendEvent(
        event: JSEventType.chainChanged,
        data: state.chainChangedEvent.toJson());
  }

  void _toggleTron(TronWeb3State state) {
    final nodeInfo = state.nodeInfo;
    if (nodeInfo != null) {
      _sendEvent(event: JSEventType.active, data: nodeInfo.toJson());
    } else {
      _sendEvent(
          event: JSEventType.active,
          data: Web3RequestExceptionConst.bannedHost.data);
    }
  }

  @override
  void onRequestDone(PageMessageRequest message) {}

  @override
  WalletMessageResponse finilizeWalletResponse(
      {required PageMessageRequest message,
      required Web3RequestParams? params,
      required Web3WalletResponseMessage response}) {
    final method = Web3TronRequestMethods.fromName(message.method);

    switch (method) {
      case Web3TronRequestMethods.requestAccounts:
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
  NetworkType get networkType => NetworkType.tron;

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
