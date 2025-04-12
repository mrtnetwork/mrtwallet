import 'dart:js_interop';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/stellar/stellar.dart';
import 'package:stellar_dart/stellar_dart.dart';
import '../../models/models/networks/stellar.dart';
import '../../models/models/requests.dart';
import '../core/network_handler.dart';

class StellarWeb3State extends WalletStandardChainWeb3State<
    StellarAddress,
    Web3StellarChainAccount,
    JSStellarWalletAccount,
    Web3ChainDefaultIdnetifier> {
  StellarWeb3State._({
    required super.state,
    required super.chains,
    required super.accounts,
    super.defaultAccount,
    super.defaultChain,
  });
  factory StellarWeb3State.init(
      {JSNetworkState state = JSNetworkState.disconnect}) {
    return StellarWeb3State._(accounts: const [], state: state, chains: []);
  }
  factory StellarWeb3State(Web3StellarChainAuthenticated? authenticated) {
    if (authenticated == null) {
      return StellarWeb3State.init(state: JSNetworkState.block);
    }
    final accounts = authenticated.accounts
        .map((e) => JSWalletStateAccount<StellarAddress,
                Web3StellarChainAccount, JSStellarWalletAccount>(
            chainaccount: e,
            jsAccount: JSStellarWalletAccount.setup(
                address: e.addressStr,
                publicKey: e.publicKey,
                chain: e.network.identifier),
            identifier: e.network.identifier))
        .toList();
    final defaultAddress = authenticated.accounts.firstWhereOrNull(
        (e) => e.id == authenticated.currentNetwork.id && e.defaultAddress);
    return StellarWeb3State._(
        accounts: accounts,
        state: JSNetworkState.init,
        chains: authenticated.networks,
        defaultChain: authenticated.currentNetwork,
        defaultAccount: defaultAddress == null
            ? null
            : JSWalletStateAccount<StellarAddress, Web3StellarChainAccount,
                JSStellarWalletAccount>(
                chainaccount: defaultAddress,
                identifier: authenticated.currentNetwork.identifier,
                jsAccount: JSStellarWalletAccount.setup(
                    address: defaultAddress.addressStr,
                    publicKey: defaultAddress.publicKey,
                    chain: defaultAddress.network.identifier),
              ));
  }
}

class JSStellarHandler extends JSWalletStandardNetworkHandler<
    StellarAddress,
    Web3StellarChainAccount,
    JSStellarWalletAccount,
    Web3ChainDefaultIdnetifier,
    StellarWeb3State> {
  JSStellarHandler(
      {required super.sendMessageToClient, required super.sendInternalMessage});

  @override
  Future<Web3MessageCore> request(PageMessageRequest params) async {
    final state = await getState();
    final method = Web3StellarRequestMethods.fromName(params.method);
    switch (method) {
      case Web3StellarRequestMethods.requestAccounts:
        if (state.hasAccount) {
          return createResponse();
        }
        return connect();
      case Web3StellarRequestMethods.signMessage:
        return _signMessage(params: params, state: state);
      case Web3StellarRequestMethods.signTransaction:
      case Web3StellarRequestMethods.sendTransaction:
        return _parseTransaction(params: params, state: state, method: method!);
      default:
        throw Web3RequestExceptionConst.methodDoesNotExist;
    }
  }

  Web3StellarSignMessage _signMessage(
      {required PageMessageRequest params, required StellarWeb3State state}) {
    try {
      final data = params.elementAs<JSStellarSignMessageParams>(0,
          peroperties: JSStellarSignMessageParams.properties);
      final messageBytes =
          MethodUtils.nullOnException(() => data?.message.toListInt());
      if (messageBytes == null || data == null) {
        throw Web3RequestExceptionConst.invalidWalletStandardSignMessage;
      }
      return Web3StellarSignMessage(
          account: state.getJsAddressChainAccountOrThrow(data.account),
          challeng: BytesUtils.toHexString(messageBytes),
          content: StringUtils.tryDecode(messageBytes));
    } on Web3RequestException {
      rethrow;
    } catch (e) {
      throw Web3RequestExceptionConst.invalidWalletStandardSignMessage;
    }
  }

  Web3StellarSendTransaction _parseTransaction(
      {required PageMessageRequest params,
      required StellarWeb3State state,
      required Web3StellarRequestMethods method}) {
    try {
      final data = params.elementAs<JSStellarSendOrSignTransactionParams>(0,
          peroperties: JSStellarSendOrSignTransactionParams.properties);

      final toBytes =
          StringUtils.encode(data!.transaction, type: StringEncoding.base64);
      if (data.account == null) {
        throw Web3StellarExceptionConstant.invalidAccountOrTransaction;
      }
      return Web3StellarSendTransaction(
          account: state.getJsAddressChainAccountOrThrow(data.account),
          transaction: toBytes,
          method: method);
    } on Web3RequestException {
      rethrow;
    } catch (e) {
      throw Web3StellarExceptionConstant.invalidAccountOrTransaction;
    }
  }

  @override
  void onRequestDone(PageMessageRequest message) {}

  @override
  NetworkType get networkType => NetworkType.stellar;

  @override
  Future<WalletMessageResponse> finalizeWalletResponse(
      {required PageMessageRequest message,
      required Web3RequestParams? params,
      required Web3WalletResponseMessage response}) async {
    final state = await getState();

    final method = Web3StellarRequestMethods.fromName(message.method);
    switch (method) {
      case Web3StellarRequestMethods.signMessage:
        return WalletMessageResponse.success(
            JSStellarSignMessageResponse.setup(response.resultAsList()));
      case Web3StellarRequestMethods.signTransaction:
      case Web3StellarRequestMethods.sendTransaction:
        final signedResponse =
            Web3StellarSendTransactionResponse.fromJson(response.resultAsMap());
        if (signedResponse.txHash != null) {
          return WalletMessageResponse.success(
              JSStellarSendTransactionResponse.setup(
                  envlope: signedResponse.envlope,
                  txId: signedResponse.txHash!));
        }
        return WalletMessageResponse.success(
            JSStellarSignTransactionResponse.setup(signedResponse.envlope));
      case Web3StellarRequestMethods.requestAccounts:
        if (state.hasAccount) {
          return WalletMessageResponse.success(
              JSStellarWalletConnectResponse.setup(state.jsAccounts));
        }
        return WalletMessageResponse.fail(Web3RequestExceptionConst
            .rejectedByUser
            .toResponseMessage()
            .toJson()
            .jsify());
      default:
        break;
    }
    return super.finalizeWalletResponse(
        message: message, params: params, response: response);
  }

  @override
  StellarWeb3State createState(Web3APPData? authenticated) {
    if (authenticated == null) return StellarWeb3State.init();
    return StellarWeb3State(authenticated.getAuth(networkType));
  }
}
