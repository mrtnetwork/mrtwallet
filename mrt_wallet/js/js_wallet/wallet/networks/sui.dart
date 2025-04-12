import 'dart:js_interop';

import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/sui/sui.dart';
import 'package:mrt_wallet/wallet/web3/networks/networks.dart';
import 'package:on_chain/on_chain.dart';
import '../../js_wallet.dart';
import '../../models/models/networks/sui.dart';
import '../../utils/utils/utils.dart';
import '../core/network_handler.dart';

class SuiWeb3State extends WalletStandardChainWeb3State<SuiAddress,
    Web3SuiChainAccount, JSSuiWalletAccount, Web3ChainDefaultIdnetifier> {
  SuiWeb3State._({
    required super.state,
    required super.chains,
    required super.accounts,
    super.defaultAccount,
    super.defaultChain,
  });
  factory SuiWeb3State.init(
      {JSNetworkState state = JSNetworkState.disconnect}) {
    return SuiWeb3State._(accounts: const [], state: state, chains: []);
  }
  factory SuiWeb3State(Web3SuiChainAuthenticated? authenticated) {
    if (authenticated == null) {
      return SuiWeb3State.init(state: JSNetworkState.block);
    }
    final accounts = authenticated.accounts
        .map((e) => JSWalletStateAccount<SuiAddress, Web3SuiChainAccount,
                JSSuiWalletAccount>(
            chainaccount: e,
            jsAccount: JSSuiWalletAccount.setup(
                address: e.addressStr,
                publicKey: e.publicKey,
                signingScheme: e.signingScheme,
                chain: e.network.identifier),
            identifier: e.network.identifier))
        .toList();
    final defaultAddress = authenticated.accounts.firstWhereOrNull(
        (e) => e.id == authenticated.currentNetwork.id && e.defaultAddress);
    return SuiWeb3State._(
        accounts: accounts,
        state: JSNetworkState.init,
        chains: authenticated.networks,
        defaultChain: authenticated.currentNetwork,
        defaultAccount: defaultAddress == null
            ? null
            : JSWalletStateAccount<SuiAddress, Web3SuiChainAccount,
                JSSuiWalletAccount>(
                chainaccount: defaultAddress,
                identifier: authenticated.currentNetwork.identifier,
                jsAccount: JSSuiWalletAccount.setup(
                    address: defaultAddress.addressStr,
                    publicKey: defaultAddress.publicKey,
                    signingScheme: defaultAddress.signingScheme,
                    chain: defaultAddress.network.identifier),
              ));
  }
}

class JSSuiHandler extends JSWalletStandardNetworkHandler<
    SuiAddress,
    Web3SuiChainAccount,
    JSSuiWalletAccount,
    Web3ChainDefaultIdnetifier,
    SuiWeb3State> {
  JSSuiHandler(
      {required super.sendMessageToClient, required super.sendInternalMessage});

  @override
  Future<Web3MessageCore> request(PageMessageRequest params) async {
    final state = await getState();
    final method = Web3SuiRequestMethods.fromName(params.method);
    switch (method) {
      case Web3SuiRequestMethods.requestAccounts:
        if (state.hasAccount) {
          return createResponse();
        }
        return connect();
      case Web3SuiRequestMethods.signTransaction:
      case Web3SuiRequestMethods.signAndExecuteTransaction:
      case Web3SuiRequestMethods.signTransactionBlock:
      case Web3SuiRequestMethods.signAndExecuteTransactionBlock:
        return _parseTransaction(params: params, state: state, method: method!);
      case Web3SuiRequestMethods.signMessage:
      case Web3SuiRequestMethods.signPersonalMessage:
        return _signMessage(params: params, state: state, method: method!);
      default:
        throw Web3RequestExceptionConst.methodDoesNotExist;
    }
  }

  Web3SuiSignMessage _signMessage(
      {required PageMessageRequest params,
      required SuiWeb3State state,
      required Web3NetworkRequestMethods method}) {
    try {
      final signingMessage = params.elementAs<JSSuiSignMessageParams>(0,
          peroperties: JSSuiSignMessageParams.properties);
      if (signingMessage != null) {
        final messageBytes = signingMessage.message.toListInt();
        final challeng = BytesUtils.toHexString(messageBytes);
        final content = StringUtils.tryDecode(messageBytes);
        return Web3SuiSignMessage(
            account:
                state.getJsAddressChainAccountOrThrow(signingMessage.account),
            challeng: challeng,
            method: method,
            content: content);
      }
    } on Web3RequestExceptionConst {
      rethrow;
    } catch (_) {}
    throw Web3RequestExceptionConst.invalidWalletStandardSignMessage;
  }

  Web3SuiSignOrExecuteTransaction _parseTransaction(
      {required PageMessageRequest params,
      required SuiWeb3State state,
      required Web3SuiRequestMethods method}) {
    try {
      if (!state.hasAccount) {
        throw Web3RequestExceptionConst.missingPermission;
      }
      final transaction =
          params.getElementAt<JSSuiSignTransactionWalletRequest>(0);
      final transactionData = JsUtils.toDartMap(transaction?.transaction);
      if (transactionData == null) {
        throw Web3RequestExceptionConst.invalidTransaction;
      }

      final tx = Web3SuiTransactionDataV2.fromJson(transactionData);
      SuiAddress owner = SuiAddress(transaction!.account);
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
          account: state.getAddressChainAccountOrThrow(owner,
              identifier: transaction.chain),
          transaction: tx,
          method: method,
          executeOptions: executeOptions,
          executeType: executeType);
    } on Web3RequestException {
      rethrow;
    } catch (_) {}
    throw Web3RequestExceptionConst.invalidTransaction;
  }

  @override
  void onRequestDone(PageMessageRequest message) {}

  @override
  NetworkType get networkType => NetworkType.sui;

  @override
  Future<WalletMessageResponse> finalizeWalletResponse(
      {required PageMessageRequest message,
      required Web3RequestParams? params,
      required Web3WalletResponseMessage response}) async {
    final state = await getState();
    final method = Web3SuiRequestMethods.fromName(message.method);
    switch (method) {
      case Web3SuiRequestMethods.requestAccounts:
        if (state.hasAccount) {
          return WalletMessageResponse.success(
              JSSuiWalletConnectResponse.setup(state.jsAccounts));
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
    return super.finalizeWalletResponse(
        message: message, params: params, response: response);
  }

  @override
  SuiWeb3State createState(Web3APPData? authenticated) {
    if (authenticated == null) return SuiWeb3State.init();
    return SuiWeb3State(authenticated.getAuth(networkType));
  }
}
