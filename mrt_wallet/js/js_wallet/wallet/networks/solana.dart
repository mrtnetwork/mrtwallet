import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/networks.dart';
import 'package:on_chain/on_chain.dart';
import '../../models/models/networks/solana.dart';
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
    final permissionAccounts = permission.currentChainAccounts(currentChain);
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

class JSSolanaHandler extends JSNetworkHandler<SolAddress, SolanaChain,
    Web3SolanaChain, ClientMessageSolana, SolanaWeb3State> {
  @override
  SolanaWeb3State state = SolanaWeb3State.init();

  JSSolanaHandler({required super.sendMessageToClient});

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

  Web3MessageCore _eventMessage(SolanaEventTypes type, SolanaWeb3State state) {
    switch (type) {
      case SolanaEventTypes.connect:
        _connect(state);
        break;

      default:
        break;
    }
    return buildResponse(null);
  }

  @override
  Future<Web3MessageCore> request(ClientMessageSolana params) async {
    final state = this.state;
    final isEvent = SolanaEventTypes.fromName(params.method);
    if (isEvent != null) {
      return _eventMessage(isEvent, state);
    }
    final method = Web3SolanaRequestMethods.fromName(params.method);
    switch (method) {
      case Web3SolanaRequestMethods.requestAccounts:
        if (state.permissionAccounts.isNotEmpty) {
          return buildResponse(state.permissionAccounts);
        }
        return Web3SolanaRequestAccounts();
      case Web3SolanaRequestMethods.signTransaction:
        return _parseTransaction(params, state);
      case Web3SolanaRequestMethods.signMessage:
        final signMessageV2 = _signMessage(params, state);
        return signMessageV2;
      default:
        throw Web3RequestExceptionConst.methodDoesNotExist;
    }
  }

  Web3SolanaSignMessage _signMessage(
      ClientMessageSolana params, SolanaWeb3State state) {
    if (state.defaultAddress == null) {
      throw Web3RequestExceptionConst.missingPermission;
    }
    final data = List<int>.from(params.params as List);
    try {
      VersionedMessage.fromBuffer(data);
      throw Web3SolanaExceptionConstant.invalidSignMessageData;
    } on Web3RequestException {
      rethrow;
    } catch (_) {}
    return Web3SolanaSignMessage(
        address: SolAddress(state.defaultAddress!.address),
        challeng: BytesUtils.toHexString(data),
        content: StringUtils.tryDecode(data));
  }

  Future<Web3SolanaSendTransaction> _parseTransaction(
      ClientMessageSolana params, SolanaWeb3State state) async {
    try {
      final List<ClientSolanaTransactionMessage> requests =
          (params.params as List?)
                  ?.map((e) => ClientSolanaTransactionMessage.fromJson(e))
                  .toList() ??
              [];

      if (requests.isEmpty) {
        throw Web3SolanaExceptionConstant.emptyTransactionParameters;
      }
      List<Web3SolanaSendTransactionData> messages = [];

      for (final i in requests) {
        // if (i.sendOption != null && option == null) {}
        List<SolAddress> activeAccounts = [];
        final message = SolanaTransaction.deserialize(i.message);
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
            account: account, messageByte: i.message, id: i.id));
      }

      final Web3SolanaSendTransactionOptions? option =
          requests.first.sendOption == null
              ? null
              : Web3SolanaSendTransactionOptions.fromJson(
                  requests.first.sendOption!);
      if (option?.signers ?? false) {
        throw Web3SolanaExceptionConstant.invalidTransactionOptionsSigner;
      }
      return Web3SolanaSendTransaction(messages: messages, sendConfig: option);
    } on Web3RequestException {
      rethrow;
    } catch (e) {
      throw Web3SolanaExceptionConstant.invalidTransaction;
    }
  }

  void _disconnect() async {
    sendMessageToClient(JSWalletMessageResponseSolana(
        event: SolanaEventTypes.disconnect,
        data: Web3RequestExceptionConst.disconnectedChain.toJson()));
  }

  void _connect(SolanaWeb3State state) async {
    if (state.defaultAddress == null) return;
    sendMessageToClient(JSWalletMessageResponseSolana(
        event: SolanaEventTypes.connect, data: state.accountsChange.toJson()));
  }

  void _accountChanged(SolanaWeb3State state) async {
    sendMessageToClient(JSWalletMessageResponseSolana(
        event: SolanaEventTypes.accountsChanged,
        data: state.accountsChange.toJson()));
  }

  void _chainChanged(SolanaWeb3State state) async {
    if (state.chain == null) return;
    sendMessageToClient(JSWalletMessageResponseSolana(
        event: SolanaEventTypes.chainChanged,
        data: state.chainChangedEvent.toJson()));
  }

  void _toggleSolana(SolanaWeb3State state) {
    final chain = state.chain;
    if (chain != null) {
      sendMessageToClient(
          JSWalletMessageResponseSolana(event: SolanaEventTypes.active));
    } else {
      sendMessageToClient(JSWalletMessageResponseSolana(
          event: SolanaEventTypes.disable,
          data: Web3RequestExceptionConst.bannedHost.data));
    }
  }

  @override
  void onRequestDone(ClientMessageSolana message) {
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
  Web3MessageCore finilize(
      ClientMessageSolana request, Web3MessageCore response) {
    return response;
  }
}
