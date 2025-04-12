import 'dart:js_interop';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_native_support/web/mrt_native_web.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/web3.dart';
import '../../models/models/networks/wallet_standard.dart';
import '../../models/models/requests.dart';
import '../../utils/utils/utils.dart';
import 'wallet.dart';

typedef FINALIZEERROR = WalletMessageResponse Function(
    {required PageMessageRequest message,
    required Web3RequestParams? params,
    required Web3ExceptionMessage error});

typedef FINALIZEWALLLETRESPONSE = WalletMessageResponse Function(
    {required PageMessageRequest message,
    required Web3RequestParams? params,
    required Web3WalletResponseMessage response});
typedef INTERNALMESSAGE = Future<WalletMessageResponse> Function(
    {required PageMessage message,
    required Web3RequestParams? params,
    required Web3WalletResponseMessage response});

class JSWalletStateAccount<
    NETWORKADDRESS,
    CHAINACCOUNT extends Web3ChainAccount<NETWORKADDRESS>,
    JSACCOUNT extends JSWalletStandardAccount> with Equatable {
  final CHAINACCOUNT chainaccount;
  final JSACCOUNT jsAccount;
  final String identifier;
  bool get isDefault => chainaccount.defaultAddress;
  const JSWalletStateAccount(
      {required this.chainaccount,
      required this.jsAccount,
      required this.identifier});
  NETWORKADDRESS get address => chainaccount.address;

  @override
  List get variabels =>
      [chainaccount.keyIndex, chainaccount.addressStr, chainaccount.id];
}

abstract class WalletStandardChainWeb3State<
    NETWORKADDRESS,
    CHAINACCOUNT extends Web3ChainAccount<NETWORKADDRESS>,
    JSACCOUNT extends JSWalletStandardAccount,
    CHAIN extends Web3ChainIdnetifier> {
  static List<JSWalletStateAccount<NETWORKADDRESS, CHAINACCOUNT, JSACCOUNT>>
      _sortAccounts<
              NETWORKADDRESS,
              CHAINACCOUNT extends Web3ChainAccount<NETWORKADDRESS>,
              JSACCOUNT extends JSWalletStandardAccount>(
          List<JSWalletStateAccount<NETWORKADDRESS, CHAINACCOUNT, JSACCOUNT>>
              accounts,
          {JSWalletStateAccount<NETWORKADDRESS, CHAINACCOUNT, JSACCOUNT>?
              defaultAccount}) {
    final clone = accounts.clone();

    if (defaultAccount == null) {
      clone.sort((a, b) =>
          a.chainaccount.addressStr.compareTo(b.chainaccount.addressStr));
      return clone.immutable;
    }

    clone.sort((a, b) => JsUtils.compareAddress(a.chainaccount.addressStr,
        b.chainaccount.addressStr, defaultAccount.chainaccount.addressStr));
    return clone.immutable;
  }

  static List<CHAIN> _sortChains<CHAIN extends Web3ChainIdnetifier>(
      List<CHAIN> chains) {
    final clone = chains.clone();
    clone.sort((a, b) => a.id.compareTo(b.id));
    return clone.immutable;
  }

  WalletStandardChainWeb3State(
      {required this.state,
      required List<
              JSWalletStateAccount<NETWORKADDRESS, CHAINACCOUNT, JSACCOUNT>>
          accounts,
      required List<CHAIN> chains,
      required this.defaultAccount,
      required this.defaultChain})
      : networkAccounts =
            _sortAccounts<NETWORKADDRESS, CHAINACCOUNT, JSACCOUNT>(
                accounts
                    .where((e) => e.chainaccount.id == defaultChain?.id)
                    .toList(),
                defaultAccount: defaultAccount),
        chains = _sortChains<CHAIN>(chains),
        accounts =
            _sortAccounts<NETWORKADDRESS, CHAINACCOUNT, JSACCOUNT>(accounts);

  final JSNetworkState state;
  final JSWalletStateAccount<NETWORKADDRESS, CHAINACCOUNT, JSACCOUNT>?
      defaultAccount;
  final List<JSWalletStateAccount<NETWORKADDRESS, CHAINACCOUNT, JSACCOUNT>>
      accounts;
  final List<JSWalletStateAccount<NETWORKADDRESS, CHAINACCOUNT, JSACCOUNT>>
      networkAccounts;
  final List<CHAIN> chains;
  final CHAIN? defaultChain;

  CHAIN get defaultChainOrThrow {
    if (defaultChain == null) throw Web3RequestExceptionConst.bannedHost;
    return defaultChain!;
  }

  List<JSACCOUNT> get jsAccounts => accounts.map((e) => e.jsAccount).toList();
  List<JSACCOUNT> get networkJsAccounts =>
      networkAccounts.map((e) => e.jsAccount).toList();

  bool networkChanged(
      WalletStandardChainWeb3State<NETWORKADDRESS, CHAINACCOUNT, JSACCOUNT,
              CHAIN>
          other) {
    return defaultChain != other.defaultChain;
  }

  bool networksChanged(
      WalletStandardChainWeb3State<NETWORKADDRESS, CHAINACCOUNT, JSACCOUNT,
              CHAIN>
          other) {
    return !CompareUtils.iterableIsEqual(other.chains, chains);
  }

  bool networkAccountChanged(
      WalletStandardChainWeb3State<NETWORKADDRESS, CHAINACCOUNT, JSACCOUNT,
              CHAIN>
          other) {
    return defaultAccount?.chainaccount != other.defaultAccount?.chainaccount ||
        !CompareUtils.iterableIsEqual(
            networkAccounts.map((e) => e.chainaccount),
            other.networkAccounts.map((e) => e.chainaccount));
  }

  bool accountsChanged(
      WalletStandardChainWeb3State<NETWORKADDRESS, CHAINACCOUNT, JSACCOUNT,
              CHAIN>
          other) {
    return !CompareUtils.iterableIsEqual(accounts, other.accounts);
  }

  bool stateChanged(
      WalletStandardChainWeb3State<NETWORKADDRESS, CHAINACCOUNT, JSACCOUNT,
              CHAIN>
          other) {
    return state != other.state;
  }

  bool addressHasChainPermission(NETWORKADDRESS address) {
    return networkAccounts.any((e) => e.chainaccount.address == address);
  }

  bool addressHasPermission(NETWORKADDRESS address) {
    return accounts.any((e) => e.chainaccount.address == address);
  }

  bool jsAccountHasPermission(JSACCOUNT address) {
    return accounts.any((e) => e.jsAccount.address == address.address);
  }

  CHAINACCOUNT getAddressChainAccountOrThrow(NETWORKADDRESS? address,
      {String? identifier}) {
    if (address == null) {
      throw Web3RequestExceptionConst.missingPermission;
    }
    if (identifier != null) {
      return accounts
          .firstWhere(
              (e) => e.address == address && e.identifier.contains(identifier),
              orElse: () => throw Web3RequestExceptionConst.missingPermission)
          .chainaccount;
    }
    return accounts
        .firstWhere((e) => e.address == address,
            orElse: () => throw Web3RequestExceptionConst.missingPermission)
        .chainaccount;
  }

  CHAINACCOUNT getAddressNetworkChainAccountOrThrow(NETWORKADDRESS? address) {
    if (address == null) {
      throw Web3RequestExceptionConst.missingPermission;
    }
    return networkAccounts
        .firstWhere((e) => e.address == address,
            orElse: () => throw Web3RequestExceptionConst.missingPermission)
        .chainaccount;
  }

  CHAINACCOUNT get defaultNetworkChainAccountOrThrow {
    if (defaultAccount == null) {
      throw Web3RequestExceptionConst.missingPermission;
    }
    return defaultAccount!.chainaccount;
  }

  CHAIN getAccountChain(CHAINACCOUNT account) {
    final chain = chains.firstWhere((e) => e.id == account.id,
        orElse: () => throw Web3RequestExceptionConst.missingPermission);

    return chain;
  }

  JSACCOUNT get defaultNetworkChainJsAccountOrThrow {
    if (defaultAccount == null) {
      throw Web3RequestExceptionConst.missingPermission;
    }
    return defaultAccount!.jsAccount;
  }

  CHAINACCOUNT getJsAddressChainAccountOrThrow(JSAny? address) {
    if (address != null) {
      final jsAccount = MRTJsObject.as<JSWalletStandardAccount>(
          object: address, keys: ['address']);
      String? addr = jsAccount?.address;
      if (jsAccount != null) {
        final chain = jsAccount.chain;
        if (chain != null) {
          return accounts
              .firstWhere(
                  (e) =>
                      e.chainaccount.addressStr == jsAccount.address &&
                      chain == e.identifier,
                  orElse: () =>
                      throw Web3RequestExceptionConst.missingPermission)
              .chainaccount;
        }
      } else {
        if (address.isA<JSString>()) {
          addr = (address as JSString).toDart;
        }
      }
      final existsAccount =
          accounts.where((e) => e.chainaccount.addressStr == addr);
      if (existsAccount.length == 1) {
        return existsAccount.first.chainaccount;
      }
    }
    throw Web3RequestExceptionConst.missingPermission;
  }

  bool get hasAccount => accounts.isNotEmpty;
  bool get hasChainAccount => defaultAccount != null;

  List<String> get defaultNetworkAddresses =>
      networkAccounts.map((e) => e.chainaccount.addressStr).toList();

  JSACCOUNT getJSAccountOrThrow(NETWORKADDRESS address, {String? identifier}) {
    if (identifier != null) {
      return accounts
          .firstWhere(
              (e) => e.address == address && e.identifier.contains(identifier),
              orElse: () => throw Web3RequestExceptionConst.missingPermission)
          .jsAccount;
    }
    return accounts
        .firstWhere((e) => e.address == address,
            orElse: () => throw Web3RequestExceptionConst.missingPermission)
        .jsAccount;
  }
}

abstract class JSWalletStandardNetworkHandler<
    NETWORKADDRESS,
    CHAINACCOUNT extends Web3ChainAccount<NETWORKADDRESS>,
    JSACCOUNT extends JSWalletStandardAccount,
    CHAIN extends Web3ChainIdnetifier,
    STATE extends WalletStandardChainWeb3State<NETWORKADDRESS, CHAINACCOUNT,
        JSACCOUNT, CHAIN>> {
  late STATE _state = createState(null);
  final SynchronizedLock lock = SynchronizedLock();
  final SendMessageToClient sendMessageToClient;
  final SENDINTERNALWALLETMESSAGE sendInternalMessage;
  abstract final NetworkType networkType;
  JSWalletStandardNetworkHandler(
      {required this.sendMessageToClient, required this.sendInternalMessage});

  Future<Web3MessageCore> connect() async {
    await sendInternalMessage(
        client: jsNetworkType,
        request: Web3ConnectApplication(chain: networkType));
    return createResponse();
  }

  JSWalletNetworkEvent createStateEvent(
      {required STATE previousState,
      required STATE currentState,
      required bool networkAccountsChanged,
      required bool networkChanged,
      required bool accountsChanged,
      required bool networksChanged}) {
    List<JSNetworkEventType> events = [
      if (networksChanged || accountsChanged) JSNetworkEventType.change,
      if (networkChanged) JSNetworkEventType.defaultChainChanged,
      if (networkAccountsChanged) ...[
        JSNetworkEventType.defaultAccountChanged,
        JSNetworkEventType.networkAccountsChanged,
      ],
    ];
    return JSWalletNetworkEvent(
        events: events,
        change: JSWalletStandardChange.setup(
            accounts: accountsChanged ? currentState.jsAccounts : null,
            chains: networksChanged
                ? currentState.chains.map((e) => e.identifier).toList()
                : null),
        networkAccounts: networkAccountsChanged
            ? JSWalletConnectEvent.setup(currentState.networkJsAccounts)
            : null,
        account: networkAccountsChanged
            ? currentState.defaultAccount?.jsAccount
            : null);
  }

  JSWalletNetworkEvent _createStateEvent(STATE other, STATE currentState) {
    final stateChanged = currentState.stateChanged(other);
    return createStateEvent(
        previousState: other,
        currentState: currentState,
        networksChanged: stateChanged || currentState.networksChanged(other),
        networkAccountsChanged:
            stateChanged || currentState.networkAccountChanged(other),
        networkChanged: stateChanged || currentState.networkChanged(other),
        accountsChanged: stateChanged || currentState.accountsChanged(other));
  }

  Future<STATE> getState() async {
    return await lock.synchronized(() {
      return _state;
    });
  }

  Future<Web3MessageCore> request(PageMessageRequest message);

  STATE createState(Web3APPData? authenticated);

  void onRequestDone(PageMessageRequest message) {}

  Future<WalletMessageResponse> finalizeError(
      {required PageMessageRequest message,
      required Web3RequestParams? params,
      required Web3ExceptionMessage error}) async {
    return WalletMessageResponse.fail(error.toJson().jsify());
  }

  Future<WalletMessageResponse> finalizeWalletResponse(
      {required PageMessageRequest message,
      required Web3RequestParams? params,
      required Web3WalletResponseMessage response}) async {
    return WalletMessageResponse.success(response.result.jsify());
  }

  Web3WalletResponseMessage createResponse([Object? result]) {
    return Web3WalletResponseMessage(result: result, network: networkType);
  }

  Future<JSWalletNetworkEvent> initChain(Web3APPData authenticated) async {
    return await lock.synchronized(() async {
      final currentState = this._state;
      final state = createState(authenticated);
      final event = _createStateEvent(currentState, state);
      _state = state;
      return event;
    });
  }

  Web3DisconnectApplication discoonect() {
    return Web3DisconnectApplication(chain: networkType);
  }

  Future<JSWalletNetworkEvent?> createEvent(JSEventType event) async {
    final state = await getState();
    switch (event) {
      case JSEventType.change:
        return JSWalletNetworkEvent(
          events: [JSNetworkEventType.change],
          change: JSWalletStandardChange.setup(
              accounts: state.jsAccounts,
              chains: state.chains.map((e) => e.identifier).toList()),
        );
      case JSEventType.accountsChanged:
        return JSWalletNetworkEvent(
            events: [
              JSNetworkEventType.defaultAccountChanged,
              JSNetworkEventType.networkAccountsChanged
            ],
            account: state.defaultAccount?.jsAccount,
            networkAccounts:
                JSWalletConnectEvent.setup(state.networkJsAccounts));
      default:
        break;
    }
    return null;
  }

  Future<void> event(PageMessageEvent event) async {
    final e = await createEvent(event.eventType);
    if (e == null) return;
    sendMessageToClient(WalletMessageEvent.build(data: e), jsNetworkType);
  }

  late final JSClientType jsNetworkType =
      JSClientType.fronNetworkName(networkType.name);
}

enum JSNetworkState {
  init,
  disconnect,
  block;

  bool get isBlock => this == block;
  bool get isInit => this == init;
}
