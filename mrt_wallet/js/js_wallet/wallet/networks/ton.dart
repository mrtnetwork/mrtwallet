import 'dart:js_interop';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_native_support/web/api/core/js.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/ton.dart';
import 'package:ton_dart/ton_dart.dart';
import '../../models/models.dart';
import '../core/network_handler.dart';

class TonWeb3State extends WalletStandardChainWeb3State<TonAddress,
    Web3TonChainAccount, JSTonWalletAccount, Web3ChainDefaultIdnetifier> {
  TonWeb3State._({
    required super.state,
    required super.chains,
    required super.accounts,
    super.defaultAccount,
    super.defaultChain,
  });
  factory TonWeb3State.init(
      {JSNetworkState state = JSNetworkState.disconnect}) {
    return TonWeb3State._(accounts: const [], state: state, chains: []);
  }
  factory TonWeb3State(Web3TonChainAuthenticated? authenticated) {
    if (authenticated == null) {
      return TonWeb3State.init(state: JSNetworkState.block);
    }
    final accounts = authenticated.accounts
        .map((e) => JSWalletStateAccount<TonAddress, Web3TonChainAccount,
                JSTonWalletAccount>(
            chainaccount: e,
            jsAccount: JSTonWalletAccount.setup(
                address: e.addressStr,
                publicKey: e.publicKey,
                walletStateInit: e.accountState,
                chain: e.identifier),
            identifier: e.identifier))
        .toList();
    final defaultAddress = authenticated.accounts.firstWhereOrNull(
        (e) => e.id == authenticated.currentNetwork.id && e.defaultAddress);
    return TonWeb3State._(
        accounts: accounts,
        state: JSNetworkState.init,
        chains: authenticated.networks,
        defaultChain: authenticated.currentNetwork,
        defaultAccount: defaultAddress == null
            ? null
            : JSWalletStateAccount<TonAddress, Web3TonChainAccount,
                JSTonWalletAccount>(
                chainaccount: defaultAddress,
                identifier: authenticated.currentNetwork.identifier,
                jsAccount: JSTonWalletAccount.setup(
                    address: defaultAddress.addressStr,
                    publicKey: defaultAddress.publicKey,
                    walletStateInit: defaultAddress.accountState,
                    chain: defaultAddress.identifier),
              ));
  }
}

class JSTonHandler extends JSWalletStandardNetworkHandler<
    TonAddress,
    Web3TonChainAccount,
    JSTonWalletAccount,
    Web3ChainDefaultIdnetifier,
    TonWeb3State> {
  JSTonHandler(
      {required super.sendMessageToClient, required super.sendInternalMessage});

  @override
  Future<Web3MessageCore> request(PageMessageRequest params) async {
    final state = await getState();
    final method = Web3TonRequestMethods.fromName(params.method);
    switch (method) {
      case Web3TonRequestMethods.requestAccounts:
        if (state.hasAccount) {
          return createResponse();
        }
        return connect();
      case Web3TonRequestMethods.sendTransaction:
      case Web3TonRequestMethods.signTransaction:
        return _parseTransaction(params: params, state: state, method: method!);
      case Web3TonRequestMethods.signMessage:
        final signMessage = _signMessage(params: params, state: state);
        return signMessage;
      default:
        throw Web3RequestExceptionConst.methodDoesNotExist;
    }
  }

  Web3TonSignMessage _signMessage(
      {required PageMessageRequest params, required TonWeb3State state}) {
    try {
      final signParams = params.elementAs<JSTonSignMessageParams>(0,
          peroperties: JSTonSignMessageParams.properties);
      final messageBytes =
          MethodUtils.nullOnException(() => signParams?.message.toListInt());
      if (signParams == null || messageBytes == null) {
        throw Web3RequestExceptionConst.invalidWalletStandardSignMessage;
      }
      Web3TonChainAccount defaultAccount =
          state.getJsAddressChainAccountOrThrow(signParams.account);
      return Web3TonSignMessage(
          account: defaultAccount,
          challeng: BytesUtils.toHexString(messageBytes),
          content: StringUtils.tryDecode(messageBytes));
    } on Web3RequestException {
      rethrow;
    } catch (_) {
      throw Web3RequestExceptionConst.invalidWalletStandardSignMessage;
    }
  }

  Future<Web3TonSendTransaction> _parseTransaction(
      {required PageMessageRequest params,
      required TonWeb3State state,
      required Web3TonRequestMethods method}) async {
    try {
      final txParams = params.elementAs<JSTonSendOrSignTransactionParams>(0,
          peroperties: JSTonSendOrSignTransactionParams.properties);
      if (txParams == null) {
        throw Web3RequestExceptionConst.invalidTransaction;
      }
      final account = state.getJsAddressChainAccountOrThrow(txParams.account);
      List<Web3TonTransactionMessage> messages = [];
      for (int i = 0; i < txParams.messages.length; i++) {
        final message = MRTJsObject.as<JSTonSendOrSignTransactionMessageParams>(
            object: txParams.messages[i],
            keys: JSTonSendOrSignTransactionMessageParams.properties);
        if (message == null) {
          throw Web3TonExceptionConstant.invalidTxMessage;
        }
        final address =
            MethodUtils.nullOnException(() => TonAddress(message.address!));
        if (address == null) {
          throw Web3TonExceptionConstant.invalidTxMessage;
        }
        if (address.workChain != account.network.workchain) {
          throw Web3TonExceptionConstant.invalidMessageAddressNetwork;
        }
        final amount = BigintUtils.tryParse(message.amount);
        if (amount == null) {
          throw Web3TonExceptionConstant.invalidTxMessage;
        }
        Cell? stateInit;
        Cell? payload;
        if (message.stateInit != null) {
          stateInit = MethodUtils.nullOnException(
              () => Cell.fromBase64(message.stateInit!));
          if (stateInit == null) {
            throw Web3TonExceptionConstant.invalidTxMessage;
          }
        }
        if (message.payload != null) {
          payload = MethodUtils.nullOnException(
              () => Cell.fromBase64(message.payload!));
          if (payload == null) {
            throw Web3TonExceptionConstant.invalidTxMessage;
          }
        }
        final msg = Web3TonTransactionMessage(
            address: address,
            amount: amount,
            stateInit: stateInit,
            payload: payload);
        messages.add(msg);
      }
      return Web3TonSendTransaction(
          account: account,
          messages: messages,
          validUntil: txParams.validUntil,
          method: method);
    } on Web3RequestException {
      rethrow;
    } catch (e) {
      throw Web3RequestExceptionConst.invalidTransaction;
    }
  }

  @override
  void onRequestDone(PageMessageRequest message) {}

  @override
  NetworkType get networkType => NetworkType.ton;

  @override
  Future<WalletMessageResponse> finalizeWalletResponse(
      {required PageMessageRequest message,
      required Web3RequestParams? params,
      required Web3WalletResponseMessage response}) async {
    final state = await getState();
    final method = Web3TonRequestMethods.fromName(message.method);

    switch (method) {
      case Web3TonRequestMethods.signMessage:
        return WalletMessageResponse.success(
            JSTonSignMessageResponse.setup(response.resultAsList()));
      case Web3TonRequestMethods.sendTransaction:
      case Web3TonRequestMethods.signTransaction:
        final r =
            Web3TonSendTransactionResponse.fromJson(response.resultAsMap());
        final txHash = r.txHash;
        if (txHash == null) {
          return WalletMessageResponse.success(
              JSTonSignTransactionResponse.setup(r.message));
        }
        return WalletMessageResponse.success(
            JSTonSendTransactionResponse.setup(boc: r.message, txId: txHash));
      case Web3TonRequestMethods.requestAccounts:
        if (state.hasAccount) {
          return WalletMessageResponse.success(
              JSTonWalletStandardConnect.setup(state.jsAccounts));
        }
        return WalletMessageResponse.fail(Web3RequestExceptionConst
            .rejectedByUser
            .toResponseMessage()
            .toJson()
            .jsify());
      default:
    }
    return super.finalizeWalletResponse(
        message: message, params: params, response: response);
  }

  @override
  TonWeb3State createState(Web3APPData? authenticated) {
    if (authenticated == null) return TonWeb3State.init();
    return TonWeb3State(authenticated.getAuth(networkType));
  }
}
