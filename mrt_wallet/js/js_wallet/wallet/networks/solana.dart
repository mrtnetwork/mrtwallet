import 'dart:js_interop';

import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/networks.dart';
import 'package:on_chain/ethereum/src/eip_4361/eip_4361.dart';

import 'package:on_chain/solana/solana.dart'
    show Commitment, SolAddress, VersionedMessage;
// import 'package:on_chain/on_chain.dart';
import '../../models/models/networks/solana.dart';
import '../../models/models/requests.dart';
import '../core/network_handler.dart';

class SolanaWeb3State extends WalletStandardChainWeb3State<SolAddress,
    Web3SolanaChainAccount, JSSolanaWalletAccount, Web3ChainDefaultIdnetifier> {
  final String? applicationId;
  SolanaWeb3State._({
    required super.state,
    required super.chains,
    required super.accounts,
    this.applicationId,
    super.defaultAccount,
    super.defaultChain,
  });
  factory SolanaWeb3State.init(
      {JSNetworkState state = JSNetworkState.disconnect}) {
    return SolanaWeb3State._(accounts: const [], state: state, chains: []);
  }
  factory SolanaWeb3State(
      Web3SolanaChainAuthenticated? authenticated, String applicationId) {
    if (authenticated == null) {
      return SolanaWeb3State.init(state: JSNetworkState.block);
    }
    final accounts = authenticated.accounts
        .map((e) => JSWalletStateAccount<SolAddress, Web3SolanaChainAccount,
                JSSolanaWalletAccount>(
            chainaccount: e,
            jsAccount: JSSolanaWalletAccount.setup(
                address: e.addressStr,
                publicKey: e.address.toBytes(),
                chain: e.network.identifier),
            identifier: e.network.identifier))
        .toList();
    final defaultAddress = authenticated.accounts.firstWhereOrNull(
        (e) => e.id == authenticated.currentNetwork.id && e.defaultAddress);
    return SolanaWeb3State._(
        accounts: accounts,
        applicationId: applicationId,
        state: JSNetworkState.init,
        chains: authenticated.networks,
        defaultChain: authenticated.currentNetwork,
        defaultAccount: defaultAddress == null
            ? null
            : JSWalletStateAccount<SolAddress, Web3SolanaChainAccount,
                JSSolanaWalletAccount>(
                chainaccount: defaultAddress,
                identifier: authenticated.currentNetwork.identifier,
                jsAccount: JSSolanaWalletAccount.setup(
                    address: defaultAddress.addressStr,
                    publicKey: defaultAddress.address.toBytes(),
                    chain: defaultAddress.network.identifier),
              ));
  }
}

class JSSolanaHandler extends JSWalletStandardNetworkHandler<
    SolAddress,
    Web3SolanaChainAccount,
    JSSolanaWalletAccount,
    Web3ChainDefaultIdnetifier,
    SolanaWeb3State> {
  JSSolanaHandler(
      {required super.sendMessageToClient, required super.sendInternalMessage});

  @override
  Future<Web3MessageCore> request(PageMessageRequest params) async {
    final state = await getState();
    final method = Web3SolanaRequestMethods.fromName(params.method);
    switch (method) {
      case Web3SolanaRequestMethods.requestAccounts:
        if (state.hasAccount) {
          return createResponse();
        }
        return connect();
      case Web3SolanaRequestMethods.signAndSendAllTransactions:
        return _parseSendAllTransaction(
            method: method!, state: state, params: params);
      case Web3SolanaRequestMethods.signTransaction:
      case Web3SolanaRequestMethods.sendTransaction:
        return _parseSignOrSendTransaction(
            method: method!, state: state, params: params);
      case Web3SolanaRequestMethods.signMessage:
        return _parseSignMessageRequest(params, state);
      case Web3SolanaRequestMethods.signIn:
        if (!state.hasAccount) {
          await connect();
          return _parseSignInRequest(params, state);
        }
        return _parseSignInRequest(params, state);
      default:
        throw Web3RequestExceptionConst.methodDoesNotExist;
    }
  }

  Web3SolanaSendTransactionData _parseTransaction(
      {required JSSolanaSignTransactionParams transaction,
      required Web3SolanaRequestMethods method,
      required SolanaWeb3State state}) {
    try {
      final account =
          state.getJsAddressChainAccountOrThrow(transaction.account);
      Web3SolanaSendTransactionOptions? option;
      if (transaction.options?.preflightCommitment != null) {
        Commitment.values.firstWhere(
            (e) => e.value == transaction.options?.preflightCommitment,
            orElse: () =>
                throw Web3SolanaExceptionConstant.invalidCommitmentOptions);
      }
      if (transaction.options?.commitment != null) {
        Commitment.values.firstWhere(
            (e) => e.value == transaction.options?.commitment,
            orElse: () =>
                throw Web3SolanaExceptionConstant.invalidCommitmentOptions);
      }
      switch (method) {
        case Web3SolanaRequestMethods.signTransaction:
          option = Web3SolanaSendTransactionOptions(
              preflightCommitment: transaction.options?.preflightCommitment,
              minContextSlot: transaction.options?.minContextSlot);
          break;
        case Web3SolanaRequestMethods.sendTransaction:
        case Web3SolanaRequestMethods.signAndSendAllTransactions:
          option = Web3SolanaSendTransactionOptions(
            preflightCommitment: transaction.options?.preflightCommitment,
            minContextSlot: transaction.options?.minContextSlot,
            commitment: transaction.options?.commitment,
            maxRetries: transaction.options?.maxRetries,
            skipPreflight: transaction.options?.skipPreflight,
          );
          break;
        default:
      }
      final List<int> txBytes = transaction.transaction.toListInt();
      VersionedMessage.fromBuffer(txBytes);
      return Web3SolanaSendTransactionData(
          account: account, messageByte: txBytes, sendConfig: option);
    } on Web3RequestException {
      rethrow;
    } catch (_) {}
    throw Web3RequestExceptionConst.invalidAccountOrTransaction;
  }

  Future<Web3SolanaSendTransaction> _parseSignOrSendTransaction(
      {required PageMessageRequest params,
      required SolanaWeb3State state,
      required Web3SolanaRequestMethods method}) async {
    try {
      final length = params.params!.length;
      final List<Web3SolanaSendTransactionData> messages = [];
      for (int i = 0; i < length; i++) {
        final transactions = params.elementAs<JSSolanaSignTransactionParams>(i,
            peroperties: JSSolanaSignTransactionParams.properties);
        if (transactions == null) {
          throw Web3RequestExceptionConst.invalidAccountOrTransaction;
        }
        final msg = _parseTransaction(
            transaction: transactions, method: method, state: state);
        messages.add(msg);
      }
      return Web3SolanaSendTransaction(messages: messages, method: method);
    } on Web3RequestException {
      rethrow;
    } catch (_) {}
    throw Web3RequestExceptionConst.invalidAccountOrTransaction;
  }

  Web3SolanaSignMessageParams _parseSignMessage(
      {required JSSolanaSignMessageParams message,
      required SolanaWeb3State state}) {
    try {
      final messageBytes =
          MethodUtils.nullOnException(() => message.message.toListInt());
      if (messageBytes == null) {
        throw Web3RequestExceptionConst.invalidWalletStandardSignMessage;
      }

      return Web3SolanaSignMessageParams(
          account: state.getJsAddressChainAccountOrThrow(message.account),
          data: BytesUtils.toHexString(messageBytes),
          content: StringUtils.tryDecode(messageBytes));
    } on EIP4631Exception catch (e) {
      throw Web3RequestExceptionConst.invalidParameters(e.message);
    } on Web3RequestException {
      rethrow;
    } catch (e) {}
    throw Web3RequestExceptionConst.invalidWalletStandardSignMessage;
  }

  Web3SolanaSignInParams _parseSignIn(
      {required JSSolanaSignInParams signIn, required SolanaWeb3State state}) {
    try {
      Web3SolanaChainAccount account;
      if (signIn.address != null) {
        final address =
            MethodUtils.nullOnException(() => SolAddress(signIn.address!));
        account = state.getAddressChainAccountOrThrow(address,
            identifier: signIn.chainId);
      } else {
        account = state.defaultNetworkChainAccountOrThrow;
      }
      final message = EIP4631(
          domain: signIn.domain ?? state.applicationId!,
          address: account.addressStr,
          statement: signIn.statement!,
          chainId: signIn.chainId,
          expirationTime: signIn.expirationTime,
          issuedAt: signIn.issuedAt,
          nonce: signIn.nonce,
          notBefore: signIn.notBefore,
          requestId: signIn.requestId,
          resources: signIn.resources?.toDart.map((e) => e.toDart).toList(),
          uri: signIn.uri,
          version: signIn.version);
      return Web3SolanaSignInParams(message: message, account: account);
    } on EIP4631Exception catch (e) {
      throw Web3RequestExceptionConst.invalidParameters(e.message);
    } on Web3RequestException {
      rethrow;
    } catch (e) {}
    throw Web3SolanaExceptionConstant.invalidSignInParams;
  }

  Future<Web3SolanaSignMessage> _parseSignMessageRequest(
      PageMessageRequest params, SolanaWeb3State state) async {
    try {
      final length = params.params!.length;
      final List<Web3SolanaSignMessageParams> messages = [];
      for (int i = 0; i < length; i++) {
        final message = params.elementAs<JSSolanaSignMessageParams>(i);
        if (message == null) {
          throw Web3RequestExceptionConst.invalidWalletStandardSignMessage;
        }
        final msg = _parseSignMessage(message: message, state: state);
        messages.add(msg);
      }
      if (messages.isEmpty) {
        throw Web3RequestExceptionConst.invalidWalletStandardSignMessage;
      }
      return Web3SolanaSignMessage(
          messages: messages, method: Web3SolanaRequestMethods.signMessage);
    } on Web3RequestException {
      rethrow;
    } catch (_) {
      throw Web3RequestExceptionConst.invalidWalletStandardSignMessage;
    }
  }

  Future<Web3SolanaSignMessage> _parseSignInRequest(
      PageMessageRequest params, SolanaWeb3State state) async {
    try {
      final length = params.params!.length;
      final List<Web3SolanaSignInParams> messages = [];
      for (int i = 0; i < length; i++) {
        final signIn = params.elementAs<JSSolanaSignInParams>(i);
        if (signIn == null || signIn.statement == null) {
          throw Web3SolanaExceptionConstant.invalidSignInParams;
        }
        final msg = _parseSignIn(signIn: signIn, state: state);
        messages.add(msg);
      }
      if (messages.isEmpty) {
        throw Web3SolanaExceptionConstant.invalidSignInParams;
      }
      return Web3SolanaSignMessage(
          messages: messages, method: Web3SolanaRequestMethods.signIn);
    } on Web3RequestException {
      rethrow;
    } catch (_) {
      throw Web3SolanaExceptionConstant.invalidSignInParams;
    }
  }

  Future<Web3SolanaSendTransaction> _parseSendAllTransaction(
      {required PageMessageRequest params,
      required SolanaWeb3State state,
      required Web3SolanaRequestMethods method}) async {
    try {
      final transactions =
          params.elementAs<JSArray<JSSolanaSignAndSendTransactionParams>>(0);
      if (transactions == null) {
        throw Web3RequestExceptionConst.invalidAccountOrTransaction;
      }
      final List<Web3SolanaSendTransactionData> messages = [];
      for (int i = 0; i < transactions.length; i++) {
        final msg = _parseTransaction(
            transaction: transactions[i], method: method, state: state);
        messages.add(msg);
      }
      final options =
          params.elementAs<JSSolanaSignAndSendAllTransactionMode>(1);
      return Web3SolanaSendTransaction(
          messages: messages,
          method: method,
          mode: options?.mode != null
              ? SolanaSignAndSendAllTransactionMode.fromName(options?.mode)
              : null);
    } on Web3RequestException {
      rethrow;
    } catch (_) {}
    throw Web3RequestExceptionConst.invalidAccountOrTransaction;
  }

  @override
  NetworkType get networkType => NetworkType.solana;

  @override
  Future<WalletMessageResponse> finalizeWalletResponse(
      {required PageMessageRequest message,
      required Web3RequestParams? params,
      required Web3WalletResponseMessage response}) async {
    final state = await getState();
    final method = Web3SolanaRequestMethods.fromName(message.method);
    switch (method) {
      case Web3SolanaRequestMethods.requestAccounts:
        if (state.hasAccount) {
          return WalletMessageResponse.success(
              JSSolanaWalletStandardConnect.setup(state.jsAccounts));
        }
        return WalletMessageResponse.fail(Web3RequestExceptionConst
            .rejectedByUser
            .toResponseMessage()
            .toJson()
            .jsify());

      case Web3SolanaRequestMethods.signTransaction:
        final signedTxs = response
            .resultAsList<Map<String, dynamic>>()
            .map((e) => SolanaWeb3TransactionSignResponse.fromJson(e))
            .toList()
            .map((e) => SolanaSignTransactionOutput.setup(e.signedTransaction))
            .toList();
        return WalletMessageResponse.success(signedTxs.toJS);
      case Web3SolanaRequestMethods.sendTransaction:
      case Web3SolanaRequestMethods.signAndSendAllTransactions:
        final signedTxs = response
            .resultAsList<Map<String, dynamic>>()
            .map((e) => SolanaWeb3TransactionSendResponse.fromJson(e))
            .toList()
            .map((e) => SolanaSignAndSendTransactionOutput.setup(e.signature))
            .toList();
        return WalletMessageResponse.success(signedTxs.toJS);
      case Web3SolanaRequestMethods.signMessage:
      case Web3SolanaRequestMethods.signIn:
        List<JSSolanaSignInResponse> signatures = [];
        final r = params!.cast<Web3SolanaSignMessage>();
        final signedMessages = response
            .resultAsList<Map<String, dynamic>>()
            .map((e) => Web3SolanaSignMessageResponse.fromJson(e))
            .toList();
        for (int i = 0; i < signedMessages.length; i++) {
          final signedMessage = signedMessages[i];
          final param = r.messages[i];
          final response = JSSolanaSignInResponse.setup(
              signature: signedMessage.signature,
              signedMessage: signedMessage.signedMessage,
              account: state.getJSAccountOrThrow(param.account.address,
                  identifier: param.account.network.identifier));
          signatures.add(response);
        }
        return WalletMessageResponse.success(signatures.toJS);
    }
    return super.finalizeWalletResponse(
        message: message, params: params, response: response);
  }

  @override
  SolanaWeb3State createState(Web3APPData? authenticated) {
    if (authenticated == null) return SolanaWeb3State.init();
    return SolanaWeb3State(
        authenticated.getAuth(networkType), authenticated.applicationId);
  }
}
