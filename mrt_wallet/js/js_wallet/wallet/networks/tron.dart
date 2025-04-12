import 'dart:js_interop';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/utils/list/extension.dart';
import 'package:mrt_wallet/app/utils/method/utiils.dart';
import 'package:mrt_wallet/app/utils/numbers/numbers.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/networks.dart';
import 'package:on_chain/on_chain.dart';
import '../../models/models.dart';
import '../../models/models/networks/wallet_standard.dart';
import '../../utils/utils/extensions.dart';
import '../../utils/utils/utils.dart';
import '../core/network_handler.dart';

class TronWeb3State extends WalletStandardChainWeb3State<TronAddress,
    Web3TronChainAccount, JSSTronWalletAccount, Web3TronChainIdnetifier> {
  bool chainExist(int chainId) {
    return chains.any((e) => e.chainId == chainId);
  }

  TronWeb3State._({
    required super.state,
    required super.chains,
    required super.accounts,
    super.defaultAccount,
    super.defaultChain,
  });
  factory TronWeb3State.init(
      {JSNetworkState state = JSNetworkState.disconnect}) {
    return TronWeb3State._(accounts: const [], state: state, chains: []);
  }
  factory TronWeb3State(Web3TronChainAuthenticated? authenticated) {
    if (authenticated == null) {
      return TronWeb3State.init(state: JSNetworkState.block);
    }
    Map<int, Web3TronChainIdnetifier> networks = {
      for (final i in authenticated.networks) i.id: i
    };
    final accounts = authenticated.accounts
        .map((e) => JSWalletStateAccount<TronAddress, Web3TronChainAccount,
                JSSTronWalletAccount>(
            chainaccount: e,
            jsAccount: JSSTronWalletAccount.setup(
                address: e.addressStr,
                publicKey: e.publicKey,
                hex: e.address.toAddress(false),
                chain: networks[e.id]!.identifier),
            identifier: networks[e.id]!.identifier))
        .toList();
    final defaultAddress = authenticated.accounts.firstWhereOrNull(
        (e) => e.id == authenticated.currentNetwork.id && e.defaultAddress);
    return TronWeb3State._(
        accounts: accounts,
        state: JSNetworkState.init,
        chains: authenticated.networks,
        defaultChain: authenticated.currentNetwork,
        defaultAccount: defaultAddress == null
            ? null
            : JSWalletStateAccount<TronAddress, Web3TronChainAccount,
                JSSTronWalletAccount>(
                chainaccount: defaultAddress,
                identifier: authenticated.currentNetwork.identifier,
                jsAccount: JSSTronWalletAccount.setup(
                    address: defaultAddress.addressStr,
                    publicKey: defaultAddress.publicKey,
                    hex: defaultAddress.address.toAddress(false),
                    chain: networks[defaultAddress.id]!.identifier),
              ));
  }
}

class JSTronHandler extends JSWalletStandardNetworkHandler<
    TronAddress,
    Web3TronChainAccount,
    JSSTronWalletAccount,
    Web3TronChainIdnetifier,
    TronWeb3State> {
  JSTronHandler(
      {required super.sendMessageToClient, required super.sendInternalMessage});

  @override
  JSWalletNetworkEvent createStateEvent(
      {required TronWeb3State previousState,
      required TronWeb3State currentState,
      required bool networkAccountsChanged,
      required bool networkChanged,
      required bool accountsChanged,
      required bool networksChanged}) {
    final event = super.createStateEvent(
        previousState: previousState,
        currentState: currentState,
        networksChanged: networksChanged,
        networkAccountsChanged: networkAccountsChanged,
        networkChanged: networkChanged,
        accountsChanged: accountsChanged);
    if (networkChanged) {
      final chain = currentState.defaultChain;
      if (chain != null) {
        event.chainChanged = JSTronTIPChainChanged(
            chainId: chain.chainId.toRadix16,
            netVersion: chain.chainId.toString(),
            fullNode: chain.fullNode,
            solidityNode: chain.solidityNode,
            eventServer: chain.fullNode,
            chain: "_");
      } else {
        final error = Web3RequestExceptionConst.disconnectProvider;
        event.disconnect = JSEthereumEIPProviderRpcError(
            message: error.message, code: error.code);
      }
    }
    return event;
  }

  @override
  Future<Web3MessageCore> request(PageMessageRequest params) async {
    final state = await getState();
    final method = Web3TronRequestMethods.fromName(params.method);
    switch (method) {
      case Web3TronRequestMethods.requestAccounts:
        if (params.isWalletStandard) {
          if (state.hasAccount) {
            return createResponse();
          }
        } else if (state.hasChainAccount) {
          return createResponse(state.defaultNetworkAddresses);
        }
        return connect();
      case Web3TronRequestMethods.switchTronChain:
        final parse = _parseSwitchTronChain(params);
        final chainId = parse.chainId.toInt();
        if (chainId == state.defaultChain?.chainId) {
          return createResponse(parse.chainId.toRadix16);
        }
        final exists = state.chainExist(chainId);
        if (!exists) {
          throw Web3RequestExceptionConst.networkDoesNotExists;
        }
        return parse;
      case Web3TronRequestMethods.signTransaction:
        if (params.isWalletStandard) {
          return _parseWalletStandardTransaction(params, state);
        }
        return _parseTransaction(params, state);
      case Web3TronRequestMethods.signMessageV2:
        if (params.isWalletStandard) {
          return _parseWalletStandardPersonalSign(params: params, state: state);
        }
        return _signMessageV2(params, state);
      default:
        throw Web3RequestExceptionConst.methodDoesNotExist;
    }
  }

  Web3TronSignMessageV2 _parseWalletStandardPersonalSign(
      {required PageMessageRequest params, required TronWeb3State state}) {
    try {
      final param = params.elementAs<JSTronSignMessageParams>(0,
          peroperties: JSTronSignMessageParams.peroperties);
      final messageBytes = param?.message?.toListInt();
      if (param == null || messageBytes == null) {
        throw Web3RequestExceptionConst.invalidSignMessageData;
      }
      final account = state.getJsAddressChainAccountOrThrow(param.account);
      return Web3TronSignMessageV2(
          challeng: BytesUtils.toHexString(messageBytes),
          account: account,
          content: StringUtils.tryDecode(messageBytes));
    } on Web3RequestException {
      rethrow;
    } catch (e) {
      throw Web3RequestExceptionConst.invalidWalletStandardSignMessage;
    }
  }

  static Web3TronSwitchChain _parseSwitchTronChain(PageMessageRequest params) {
    final toObject = JsUtils.toDartMap(params.elementAs(0));
    if (toObject == null) {
      throw Web3RequestExceptionConst.invalidMethodArgruments;
    }

    return Web3TronSwitchChain.fromJson(toObject);
  }

  Web3TronSignMessageV2 _signMessageV2(
      PageMessageRequest params, TronWeb3State state) {
    try {
      final message = params.elementAs<JSAny>(0);

      if (message.isA<JSString>()) {
        return Web3TronSignMessageV2(
            account: state.defaultNetworkChainAccountOrThrow,
            challeng: BytesUtils.toHexString(
                StringUtils.encode((message as JSString).toDart)));
      }
      final bytes = (message as APPJSUint8Array).toListInt();
      return Web3TronSignMessageV2(
          account: state.defaultNetworkChainAccountOrThrow,
          challeng: BytesUtils.toHexString(bytes));
    } on Web3RequestException {
      rethrow;
    } catch (_) {}
    throw Web3RequestExceptionConst.invalidStringOrBytesParameters;
  }

  Future<Web3TronSendTransaction> _parseWalletStandardTransaction(
      PageMessageRequest params, TronWeb3State state) async {
    try {
      final param = params.elementAs<JSTronWalletStandardTransactionParams>(0,
          peroperties: JSTronWalletStandardTransactionParams.properties);
      if (param == null) {
        throw Web3RequestExceptionConst.invalidAccountOrTransaction;
      }
      final transaction = MethodUtils.nullOnException(
          () => Transaction.deserialize(param.transaction.toListInt()));

      if (transaction == null) {
        throw Web3RequestExceptionConst.invalidTransaction;
      }
      return Web3TronSendTransaction(
          transaction: transaction.toBuffer(),
          txId: transaction.rawData.txID,
          account: state.getJsAddressChainAccountOrThrow(param.account));
    } on Web3RequestException {
      rethrow;
    } catch (e) {
      return throw Web3RequestExceptionConst.invalidAccountOrTransaction;
    }
  }

  Future<Web3TronSendTransaction> _parseTransaction(
      PageMessageRequest params, TronWeb3State state) async {
    try {
      final Map<String, dynamic>? transactionData =
          JsUtils.toDartMap(params.elementAs(0));
      if (transactionData == null) {
        throw Web3RequestExceptionConst.invalidTransaction;
      }
      final transaction = Transaction.fromJson(transactionData);
      String? txId;
      if (transactionData["txID"] != null) {
        txId = BytesUtils.toHexString(
            BytesUtils.fromHexString(transactionData["txID"]));
      }
      if (txId != null && txId != transaction.rawData.txID) {
        throw Web3RequestExceptionConst.invalidTransaction;
      }

      return Web3TronSendTransaction(
          transaction: transaction.toBuffer(),
          txId: txId,
          account: state.defaultNetworkChainAccountOrThrow);
    } on Web3RequestException {
      rethrow;
    } catch (e) {
      throw Web3RequestExceptionConst.fromException(e);
    }
  }

  @override
  void onRequestDone(PageMessageRequest message) {}

  @override
  Future<WalletMessageResponse> finalizeWalletResponse(
      {required PageMessageRequest message,
      required Web3RequestParams? params,
      required Web3WalletResponseMessage response}) async {
    final method = Web3TronRequestMethods.fromName(message.method);
    final state = await getState();
    switch (method) {
      case Web3TronRequestMethods.requestAccounts:
        if (message.isWalletStandard) {
          if (state.hasAccount) {
            return WalletMessageResponse.success(
                JSTronWalletStandardConnect.setup(state.jsAccounts));
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
      case Web3TronRequestMethods.signMessageV2:
        final signature = response.resultAsString();
        if (message.isWalletStandard) {
          return WalletMessageResponse.success(JSTronSignatureResponse.setup(
              BytesUtils.fromHexString(signature)));
        } else {
          return WalletMessageResponse.success(signature.toJS);
        }
      case Web3TronRequestMethods.signTransaction:
        if (message.isWalletStandard) {
          return WalletMessageResponse.success(
              JSTronWalletStandardTransactionResponse.setup(
                  BytesUtils.fromHexString(response.resultAsString())));
        } else {
          final List<int> data =
              BytesUtils.fromHexString(response.resultAsString());
          final transaction = Transaction.deserialize(List<int>.from(data));
          final Map<String, dynamic>? transactionData =
              JsUtils.toDartMap(message.elementAs(0));
          if (transactionData == null) {
            throw Web3RequestExceptionConst.invalidTransaction;
          }
          transactionData["signature"] = transaction.signature
              .map((e) => BytesUtils.toHexString(e, prefix: '0x'))
              .toList();
          return WalletMessageResponse.success(transactionData.jsify());
        }

      default:
    }
    return super.finalizeWalletResponse(
        message: message, params: params, response: response);
  }

  @override
  NetworkType get networkType => NetworkType.tron;

  @override
  TronWeb3State createState(Web3APPData? authenticated) {
    if (authenticated == null) return TronWeb3State.init();
    return TronWeb3State(authenticated.getAuth(networkType));
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
          event.chainChanged = JSTronTIPChainChanged(
              chainId: chain.chainId.toRadix16,
              netVersion: chain.chainId.toString(),
              fullNode: chain.fullNode,
              solidityNode: chain.solidityNode,
              eventServer: chain.fullNode,
              chain: "_");
        } else {
          final error = Web3RequestExceptionConst.disconnectProvider;
          event.disconnect = JSEthereumEIPProviderRpcError(
              message: error.message, code: error.code);
        }
        return event;
      default:
        return super.createEvent(event);
    }
  }
}
