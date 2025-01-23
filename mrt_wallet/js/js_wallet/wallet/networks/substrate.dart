import 'dart:js_interop';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/isolate/types.dart';
import 'package:mrt_wallet/app/utils/list/extension.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/substrate/substrate.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import '../../js_wallet.dart';
import '../../models/models/networks/substrate.dart';
import '../../models/models/requests.dart';
import '../../utils/utils/utils.dart';
import '../core/network_handler.dart';

class SubstrateWeb3State extends ChainWeb3State {
  final WalletSubstrateNetwork? network;
  final JSSubstrateAddress? defaultAddress;
  final SubstrateClient? client;
  final List<JSSubstrateAddress> permissionAccounts;
  final List<JSSubstrateKownMetadata> knownMetadata;

  SubstrateWeb3State._(
      {required super.state,
      required List<JSSubstrateAddress> permissionAccounts,
      required List<JSSubstrateKownMetadata> knownMetadata,
      this.defaultAddress,
      this.client,
      this.network})
      : permissionAccounts = permissionAccounts.imutable,
        knownMetadata = knownMetadata.immutable;
  factory SubstrateWeb3State.init(
      {JSNetworkState state = JSNetworkState.disconnect}) {
    return SubstrateWeb3State._(
        permissionAccounts: const [], state: state, knownMetadata: const []);
  }
  factory SubstrateWeb3State(Web3SubstrateChainAuthenticated? authenticated) {
    if (authenticated == null) {
      return SubstrateWeb3State.init(state: JSNetworkState.block);
    }
    final permissionAccounts =
        List<Web3SubstrateChainAccount>.from(authenticated.accounts);
    final defaultAddress = permissionAccounts
        .firstWhereOrNull((e) => e.defaultAddress, orElse: () {
      if (permissionAccounts.isEmpty) return null;
      return permissionAccounts.first;
    });

    permissionAccounts.sort((a, b) => JsUtils.compareAddress(
        a.addressStr, b.addressStr, defaultAddress?.addressStr));

    return SubstrateWeb3State._(
        knownMetadata: authenticated.knownMetadata
            .map((e) => JSSubstrateKownMetadata(
                genesisHash: StringUtils.add0x(e.genesisHash),
                specVersion: e.specVersion))
            .toList(),
        permissionAccounts: permissionAccounts
            .map((e) => JSSubstrateAddress(
                address: e.addressStr,
                genesisHash: StringUtils.add0x(e.genesis)))
            .toList(),
        state: JSNetworkState.init,
        network: authenticated.network,
        defaultAddress: defaultAddress == null
            ? null
            : JSSubstrateAddress(
                address: defaultAddress.addressStr,
                genesisHash: StringUtils.add0x(defaultAddress.genesis)),
        client: APIUtils.createApiClient(authenticated.network,
            allowInWeb3: true,
            identifier: authenticated.serviceIdentifier,
            isolate: APPIsolate.current,
            requestTimeut: ChainWeb3State.requestTimeout));
  }

  bool accountChanged(SubstrateWeb3State other) {
    return !(CompareUtils.iterableIsEqual(
            permissionAccounts, other.permissionAccounts) &&
        defaultAddress == other.defaultAddress);
  }

  bool chainChanged(SubstrateWeb3State other) {
    return other.network?.genesisBlock != network?.genesisBlock;
  }

  bool needToggle(SubstrateWeb3State other) {
    return other.state != state;
  }

  JSSubstrateAccountsChanged get accountsChange => JSSubstrateAccountsChanged(
        accounts: permissionAccounts.toJS,
        defaultAddress: defaultAddress,
      );
  JSSubstrateProviderConnectInfo get chainChangedEvent =>
      JSSubstrateProviderConnectInfo(genesis: network!.genesisBlock);
  bool hasPermission(BaseSubstrateAddress address) {
    return permissionAccounts.any((e) => e.address == address.address);
  }

  bool get isConnect => defaultAddress != null;
}

class JSSubstrateHandler extends JSNetworkHandler<SubstrateWeb3State> {
  @override
  SubstrateWeb3State state = SubstrateWeb3State.init();
  JSSubstrateHandler({required super.sendMessageToClient});

  void _sendEvent({required JSEventType event, Object? data}) {
    sendMessageToClient(WalletMessageEvent.build(event: event, data: data),
        JSClientType.substrate);
  }

  @override
  void initChain(Web3APPData authenticated) {
    lock.synchronized(() async {
      final currentState = state;
      state = SubstrateWeb3State(authenticated.getAuth(networkType));
      if (state.needToggle(currentState)) {
        _toggleSubstrate(state);
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
    final method = Web3SubstrateRequestMethods.fromName(params.method);
    switch (method) {
      case Web3SubstrateRequestMethods.requestAccounts:
        if (state.permissionAccounts.isNotEmpty) {
          return buildResponse(state.permissionAccounts);
        }
        return Web3SubstrateRequestAccounts();
      case Web3SubstrateRequestMethods.knownMetadata:
        return buildResponse(state.knownMetadata);
      case Web3SubstrateRequestMethods.signMessage:
        return _signMessage(params: params, state: state);
      case Web3SubstrateRequestMethods.signTransaction:
        return _parseTransaction(params: params, state: state, method: method!);
      case Web3SubstrateRequestMethods.addSubstrateChain:
        return _addNewChain(params: params, state: state);
      default:
        throw Web3RequestExceptionConst.methodDoesNotExist;
    }
  }

  int? _parsingMetadata(String rawMetadata) {
    final toBytes = BytesUtils.fromHexString(rawMetadata);
    final decode = LayoutConst.bytes().deserialize(toBytes).value;
    try {
      final metadata = VersionedMetadata.fromBytes(decode);
      if (metadata.supportedByApi) return metadata.version;
    } catch (_) {}
    return null;
  }

  Web3SubstrateAddNewChain _addNewChain(
      {required PageMessageRequest params, required SubstrateWeb3State state}) {
    try {
      final param = params.getElementAt<JSSubstrateMetadataProvide>(0)!;
      if (param.rawMetadata != null) {
        try {
          final metadata = _parsingMetadata(param.rawMetadata!);
          if (metadata == null) {
            throw Web3SubstrateExceptionConstant.unsuportedMetadataVersion;
          }
        } catch (e) {
          throw Web3SubstrateExceptionConstant.metadataParsingFailed;
        }
      }
      return Web3SubstrateAddNewChain.fromJson(param.toJson());
    } on Web3RequestException {
      rethrow;
    } catch (e) {
      throw Web3SubstrateExceptionConstant.invalidProvideMetadataRequest;
    }
  }

  Web3SubstrateSignMessage _signMessage(
      {required PageMessageRequest params, required SubstrateWeb3State state}) {
    try {
      if (state.defaultAddress == null) {
        throw Web3RequestExceptionConst.missingPermission;
      }
      final param = params.getElementAt<JSSubstrateSign>(0)!;
      final address = state.permissionAccounts.firstWhere(
          (e) => e.address == param.address,
          orElse: () => throw Web3RequestExceptionConst.missingPermission);
      if (param.type != Web3SubstrateConst.signMessageType) {
        throw Web3SubstrateExceptionConstant.invalidSignMessageType;
      }
      final challeng = BytesUtils.fromHexString(param.data);
      return Web3SubstrateSignMessage(
          address: BaseSubstrateAddress(address.address),
          challeng: BytesUtils.toHexString(challeng),
          content: StringUtils.tryDecode(challeng));
    } on Web3RequestException {
      rethrow;
    } catch (_) {}
    throw Web3SubstrateExceptionConstant.invalidSignMessage;
  }

  Web3SubstrateSendTransaction _parseTransaction(
      {required PageMessageRequest params,
      required SubstrateWeb3State state,
      required Web3SubstrateRequestMethods method}) {
    try {
      final param = params.getElementAt<JSSubstrateTransaction>(0)!;
      final address = state.permissionAccounts.firstWhere(
          (e) =>
              e.address == param.address && e.genesisHash == param.genesisHash,
          orElse: () => throw Web3RequestExceptionConst.missingPermission);
      return Web3SubstrateSendTransaction(
          json: param.toJson(), address: BaseSubstrateAddress(address.address));
    } on Web3RequestException {
      rethrow;
    } catch (e) {
      throw Web3SubstrateExceptionConstant.invalidTransaction;
    }
  }

  void _disconnect() async {
    _sendEvent(
        event: JSEventType.disconnect,
        data: Web3RequestExceptionConst.disconnectedChain.toJson());
  }

  void _connect(SubstrateWeb3State state) async {
    if (state.defaultAddress == null) return;
    _sendEvent(event: JSEventType.connect, data: state.chainChangedEvent);
  }

  void _accountChanged(SubstrateWeb3State state) async {
    _sendEvent(event: JSEventType.accountsChanged, data: state.accountsChange);
  }

  void _chainChanged(SubstrateWeb3State state) async {
    if (state.network == null) return;
    _sendEvent(event: JSEventType.chainChanged, data: state.chainChangedEvent);
  }

  void _toggleSubstrate(SubstrateWeb3State state) {
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
  NetworkType get networkType => NetworkType.substrate;

  @override
  WalletMessageResponse finilizeWalletResponse(
      {required PageMessageRequest message,
      required Web3RequestParams? params,
      required Web3WalletResponseMessage response}) {
    final method = Web3SubstrateRequestMethods.fromName(message.method);
    switch (method) {
      case Web3SubstrateRequestMethods.knownMetadata:
        return WalletMessageResponse.success(state.knownMetadata.toJS);
      case Web3SubstrateRequestMethods.requestAccounts:
        if (state.permissionAccounts.isNotEmpty) {
          return WalletMessageResponse.success(
              state.permissionAccounts.jsify());
        }
        return WalletMessageResponse.fail(Web3RequestExceptionConst
            .rejectedByUser
            .toResponseMessage()
            .toJson()
            .jsify());

      case Web3SubstrateRequestMethods.signTransaction:
      case Web3SubstrateRequestMethods.signMessage:
        final signedTx = Web3SubstrateSendTransactionResponse.fromJson(
            response.resultAsMap());
        return WalletMessageResponse.success(JSSubstrateTxResponse(
            signature: signedTx.signature,
            id: signedTx.id,
            signedTransaction: signedTx.signedTransaction));
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
