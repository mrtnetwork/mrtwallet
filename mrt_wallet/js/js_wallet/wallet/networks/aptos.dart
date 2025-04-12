import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/wallet.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/aptos/aptos.dart';
import 'package:mrt_wallet/wallet/web3/networks/networks.dart';
import 'package:on_chain/on_chain.dart';
import '../../js_wallet.dart';
import '../../models/models/networks/aptos.dart';
import '../../models/models/networks/wallet_standard.dart';
import '../core/network_handler.dart';

class AptosWeb3State extends WalletStandardChainWeb3State<AptosAddress,
    Web3AptosChainAccount, JSAptosWalletAccount, Web3AptosChainIdnetifier> {
  JSAptosNetworkInfo get currentChainInfo {
    final chain = defaultChain;
    if (chain == null) {
      throw Web3RequestExceptionConst.missingPermission;
    }
    return JSAptosNetworkInfo.setup(
        chainId: chain.chainId, name: chain.aptosChain.name);
  }

  AptosWeb3State._({
    required super.state,
    required super.chains,
    required super.accounts,
    super.defaultAccount,
    super.defaultChain,
  });
  factory AptosWeb3State.init(
      {JSNetworkState state = JSNetworkState.disconnect}) {
    return AptosWeb3State._(accounts: const [], state: state, chains: []);
  }
  factory AptosWeb3State(Web3AptosChainAuthenticated? authenticated) {
    if (authenticated == null) {
      return AptosWeb3State.init(state: JSNetworkState.block);
    }
    final accounts = authenticated.accounts
        .map((e) => JSWalletStateAccount<AptosAddress, Web3AptosChainAccount,
                JSAptosWalletAccount>(
            chainaccount: e,
            jsAccount: JSAptosWalletAccount.setup(
                address: e.addressStr,
                signingScheme: e.signingScheme,
                publicKey: JSAptosPublicKey.setup(
                    publicKey: e.publicKey, publicKeyHex: e.publicKeyHex),
                chain: e.network.identifier),
            identifier: e.network.identifier))
        .toList();
    final defaultAddress = authenticated.accounts.firstWhereOrNull(
        (e) => e.id == authenticated.currentNetwork.id && e.defaultAddress);
    return AptosWeb3State._(
        accounts: accounts,
        state: JSNetworkState.init,
        chains: authenticated.networks,
        defaultChain: authenticated.currentNetwork,
        defaultAccount: defaultAddress == null
            ? null
            : JSWalletStateAccount<AptosAddress, Web3AptosChainAccount,
                JSAptosWalletAccount>(
                chainaccount: defaultAddress,
                identifier: authenticated.currentNetwork.identifier,
                jsAccount: JSAptosWalletAccount.setup(
                    signingScheme: defaultAddress.signingScheme,
                    publicKey: JSAptosPublicKey.setup(
                        publicKey: defaultAddress.publicKey,
                        publicKeyHex: defaultAddress.publicKeyHex),
                    address: defaultAddress.addressStr,
                    chain: defaultAddress.network.identifier),
              ));
  }
}

class JSAptosHandler extends JSWalletStandardNetworkHandler<
    AptosAddress,
    Web3AptosChainAccount,
    JSAptosWalletAccount,
    Web3AptosChainIdnetifier,
    AptosWeb3State> {
  JSAptosHandler(
      {required super.sendMessageToClient, required super.sendInternalMessage});
  @override
  JSWalletNetworkEvent createStateEvent(
      {required AptosWeb3State previousState,
      required AptosWeb3State currentState,
      required bool networkAccountsChanged,
      required bool networkChanged,
      required bool networksChanged,
      required bool accountsChanged}) {
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
        event.chainChanged = JSAptosNetworkInfo.setup(
            chainId: chain.chainId, name: chain.aptosChain.name);
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
    final method = Web3AptosRequestMethods.fromName(params.method);
    switch (method) {
      case Web3AptosRequestMethods.requestAccounts:
        if (state.hasChainAccount) {
          return createResponse();
        }
        return connect();
      case Web3AptosRequestMethods.getNetwork:
        if (state.hasChainAccount) {
          return createResponse(state.currentChainInfo);
        }
        throw Web3RequestExceptionConst.missingPermission;
      case Web3AptosRequestMethods.signTransaction:
        return _parseTransaction(params: params, state: state, method: method!);
      case Web3AptosRequestMethods.signMessage:
        return _signMessage(params: params, state: state);
      case Web3AptosRequestMethods.switchNetwork:
        return _parseSwitchChain(params: params, state: state);
      default:
        throw Web3RequestExceptionConst.methodDoesNotExist;
    }
  }

  Web3AptosSignMessage _signMessage(
      {required PageMessageRequest params, required AptosWeb3State state}) {
    final account = state.defaultNetworkChainAccountOrThrow;
    try {
      final JSAptosSignMessageParams? aptosSignMessage =
          params.elementAs<JSAptosSignMessageParams>(0,
              peroperties: JSAptosSignMessageParams.requiredKey);
      if (aptosSignMessage == null) {
        throw Web3AptosExceptionConstant.invalidAptosSigningMessage;
      }
      return Web3AptosSignMessage.aptos(
          account: account,
          message: aptosSignMessage.message,
          nonce: aptosSignMessage.nonce,
          address: aptosSignMessage.address,
          chainId: aptosSignMessage.chainId,
          application: aptosSignMessage.application);
    } on Web3RequestException {
      rethrow;
    } catch (e) {
      throw Web3AptosExceptionConstant.invalidAptosSigningMessage;
    }
  }

  Web3AptosSendTransaction _parseTransaction(
      {required PageMessageRequest params,
      required AptosWeb3State state,
      required Web3AptosRequestMethods method}) {
    AptosRawTransaction transaction;
    AptosAddress? feePayer;
    List<AptosAddress>? secondarySignerAddresses;
    try {
      final JSAptosSignTransactionRequest? tx =
          params.getElementAt<JSAptosSignTransactionRequest>(0);
      if (tx!.isMultiAgent) {
        final data =
            AptosMultiAgentTransaction.deserialize(tx.data.toListInt());
        transaction = data.rawTransaction;
        feePayer = data.feePayerAddress;
        secondarySignerAddresses = data.secondarySignerAddresses;
      } else {
        final data = AptosSimpleTransaction.deserialize(tx.data.toListInt());
        transaction = data.rawTransaction;
        feePayer = data.feePayerAddress;
      }
      final chainType = AptosChainType.fromValue(transaction.chainId);
      if (chainType != state.defaultChain?.aptosChain) {
        throw Web3AptosExceptionConstant.invalidTransactionChainId;
      }
      return Web3AptosSendTransaction(
          transaction: transaction,
          account: state.defaultNetworkChainAccountOrThrow,
          feePayer: feePayer,
          socondarySignerAddresses: secondarySignerAddresses,
          method: method);
    } on Web3RequestException catch (_) {
      rethrow;
    } catch (_) {}
    throw Web3AptosExceptionConstant.invalidTransaction;
  }

  Web3MessageCore _parseSwitchChain(
      {required PageMessageRequest params, required AptosWeb3State state}) {
    if (!state.hasChainAccount) {
      throw Web3RequestExceptionConst.missingPermission;
    }
    try {
      final JSAptosNetworkInfo? networkInfo =
          params.elementAs<JSAptosNetworkInfo>(0);
      if (networkInfo != null) {
        AptosChainType chain;
        try {
          chain = AptosChainType.fromValue(networkInfo.chainId);
        } catch (e) {
          throw Web3RequestExceptionConst.networkDoesNotExists;
        }
        if (chain == state.defaultChain?.aptosChain) {
          return createResponse(JSAptosSwitchChainResponse.success());
        }
        return Web3AptosSwitchChain(chainType: chain);
      }
    } on Web3RequestException {
      rethrow;
    } catch (_) {}
    throw Web3AptosExceptionConstant.invalidChainId;
  }

  @override
  void onRequestDone(PageMessageRequest message) {}

  @override
  NetworkType get networkType => NetworkType.aptos;

  @override
  Future<WalletMessageResponse> finalizeWalletResponse(
      {required PageMessageRequest message,
      required Web3RequestParams? params,
      required Web3WalletResponseMessage response}) async {
    final state = await getState();
    final method = Web3AptosRequestMethods.fromName(message.method);
    switch (method) {
      case Web3AptosRequestMethods.requestAccounts:
        if (state.hasChainAccount) {
          final message = JSAptosWalletStandardUserResponse.approved(
              state.defaultNetworkChainJsAccountOrThrow);
          return WalletMessageResponse.success(message);
        }
        return WalletMessageResponse.success(
            JSAptosWalletStandardUserResponse.rejected());
      case Web3AptosRequestMethods.signTransaction:
        final transactionResponse = response.resultAsList<int>();
        final message = JSAptosWalletStandardUserResponse.approved(
            JSAptosSignTransactionResponse.setup(
                bytes: transactionResponse,
                dataHex:
                    BytesUtils.toHexString(transactionResponse, prefix: "0x")));
        return WalletMessageResponse.success(message);
      case Web3AptosRequestMethods.signMessage:
        final responseMessage =
            Web3AptosSignMessageResponse.fromJson(response.resultAsMap());
        final signedMessage = JSAptosSignMessageResponse.setup(
            signatureBytes: responseMessage.signature,
            signatureHex:
                BytesUtils.toHexString(responseMessage.signature, prefix: "0x"),
            message: responseMessage.message!,
            nonce: responseMessage.nonce!,
            fullMessage: responseMessage.fullMessage!,
            prefix: responseMessage.prefix!,
            address: responseMessage.address,
            application: responseMessage.application,
            chainId: responseMessage.chainId);
        return WalletMessageResponse.success(
            JSAptosWalletStandardUserResponse.approved(signedMessage));
      case Web3AptosRequestMethods.switchNetwork:
        return WalletMessageResponse.success(
            JSAptosSwitchChainResponse.success());
      default:
        break;
    }
    return super.finalizeWalletResponse(
        message: message, params: params, response: response);
  }

  @override
  Future<WalletMessageResponse> finalizeError(
      {required PageMessageRequest message,
      required Web3RequestParams? params,
      required Web3ExceptionMessage error}) async {
    final method = Web3AptosRequestMethods.fromName(message.method);
    if (error.isAuthenticatedError) {
      switch (method) {
        case Web3AptosRequestMethods.requestAccounts:
        case Web3AptosRequestMethods.sendTransaction:
        case Web3AptosRequestMethods.signTransaction:
        case Web3AptosRequestMethods.signMessage:
          return WalletMessageResponse.success(
              JSAptosWalletStandardUserResponse.rejected());
        default:
      }
    } else {
      switch (method) {
        case Web3AptosRequestMethods.switchNetwork:
          return WalletMessageResponse.success(
              JSAptosSwitchChainResponse.fail(reason: error.message));
        default:
      }
    }
    return super.finalizeError(message: message, params: params, error: error);
  }

  @override
  AptosWeb3State createState(Web3APPData? authenticated) {
    if (authenticated == null) return AptosWeb3State.init();
    return AptosWeb3State(authenticated.getAuth(networkType));
  }

  @override
  Future<JSWalletNetworkEvent?> createEvent(JSEventType event) async {
    final state = await getState();
    switch (event) {
      case JSEventType.chainChanged:
        final event = JSWalletNetworkEvent(
            events: [JSNetworkEventType.defaultChainChanged]);
        final chain = state.defaultChain;
        if (chain != null) {
          event.chainChanged = JSAptosNetworkInfo.setup(
              chainId: chain.chainId, name: chain.aptosChain.name);
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
