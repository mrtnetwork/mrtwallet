import 'dart:js_interop';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/networks.dart';
import '../../js_wallet.dart';
import '../../models/models/networks/cosmos.dart';
import '../../utils/utils/utils.dart';
import '../core/network_handler.dart';

class CosmosWeb3State extends WalletStandardChainWeb3State<CosmosBaseAddress,
    Web3CosmosChainAccount, JSCosmosWalletAccount, Web3CosmoshainIdnetifier> {
  CosmosWeb3State._({
    required super.state,
    required super.chains,
    required super.accounts,
    super.defaultAccount,
    super.defaultChain,
  });

  bool chainExist(String chainId) {
    return chains.any((e) => e.chainId == chainId);
  }

  List<JSCosmosWalletAccount> getChainIdJsAccounts(String chainId) {
    final network = chains.firstWhere((e) => e.chainId == chainId,
        orElse: () => throw Web3RequestExceptionConst.networkDoesNotExists);
    return accounts
        .where((e) => e.identifier == network.identifier)
        .map((e) => e.jsAccount)
        .toList();
  }

  factory CosmosWeb3State.init(
      {JSNetworkState state = JSNetworkState.disconnect}) {
    return CosmosWeb3State._(accounts: const [], state: state, chains: []);
  }
  factory CosmosWeb3State(Web3CosmosChainAuthenticated? authenticated) {
    if (authenticated == null) {
      return CosmosWeb3State.init(state: JSNetworkState.block);
    }
    Map<int, Web3CosmoshainIdnetifier> networks = {
      for (final i in authenticated.networks) i.id: i
    };
    final accounts = authenticated.accounts
        .map((e) => JSWalletStateAccount<CosmosBaseAddress,
                Web3CosmosChainAccount, JSCosmosWalletAccount>(
            chainaccount: e,
            jsAccount: JSCosmosWalletAccount.setup(
                address: e.addressStr,
                publicKey: e.publicKey,
                algo: e.algo.name,
                typeUrl: e.algo.pubKeyTypeUrl.typeUrl,
                chain: networks[e.id]!.identifier),
            identifier: networks[e.id]!.identifier))
        .toList();
    final defaultAddress = authenticated.accounts.firstWhereOrNull(
        (e) => e.id == authenticated.currentNetwork.id && e.defaultAddress);
    return CosmosWeb3State._(
        accounts: accounts,
        state: JSNetworkState.init,
        chains: authenticated.networks,
        defaultChain: authenticated.currentNetwork,
        defaultAccount: defaultAddress == null
            ? null
            : JSWalletStateAccount<CosmosBaseAddress, Web3CosmosChainAccount,
                JSCosmosWalletAccount>(
                chainaccount: defaultAddress,
                identifier: authenticated.currentNetwork.identifier,
                jsAccount: JSCosmosWalletAccount.setup(
                    address: defaultAddress.addressStr,
                    publicKey: defaultAddress.publicKey,
                    typeUrl: defaultAddress.algo.pubKeyTypeUrl.typeUrl,
                    algo: defaultAddress.algo.name,
                    chain: networks[defaultAddress.id]!.identifier),
              ));
  }
}

class JSCosmosHandler extends JSWalletStandardNetworkHandler<
    CosmosBaseAddress,
    Web3CosmosChainAccount,
    JSCosmosWalletAccount,
    Web3CosmoshainIdnetifier,
    CosmosWeb3State> {
  JSCosmosHandler(
      {required super.sendMessageToClient, required super.sendInternalMessage});

  @override
  Future<Web3MessageCore> request(PageMessageRequest params) async {
    final state = await getState();
    final method = Web3CosmosRequestMethods.fromName(params.method);
    switch (method) {
      case Web3CosmosRequestMethods.requestAccounts:
        if (state.hasAccount) {
          return createResponse();
        }
        return connect();
      case Web3CosmosRequestMethods.signTransactionDirect:
        return _parseDirectTransaction(
            params: params, state: state, method: method!);
      case Web3CosmosRequestMethods.signTransaction:
        return _parseSignTransaction(
            params: params, state: state, method: method!);
      case Web3CosmosRequestMethods.signTransactionAmino:
        return _parseAminoTransaction(
            params: params, state: state, method: method!);
      case Web3CosmosRequestMethods.signMessage:
        return _signMessage(params: params, state: state);
      case Web3CosmosRequestMethods.switchNetwork:
        return _parseSwitchChain(params: params, state: state);
      case Web3CosmosRequestMethods.addNewChain:
        return _parseAddNewChain(params: params, state: state);
      default:
        throw Web3RequestExceptionConst.methodDoesNotExist;
    }
  }

  Web3MessageCore _parseAddNewChain(
      {required PageMessageRequest params, required CosmosWeb3State state}) {
    final param = params.elementAs<CosmosAddNewChainParams>(0,
        peroperties: CosmosAddNewChainParams.properties);
    if (param == null) {
      throw Web3CosmosExceptionConstant.invalidAddNewChain;
    }
    try {
      final request = Web3CosmosAddNewChain.fromJson(param.toJson());
      if (state.chainExist(request.chainId)) {
        return createResponse(true);
      }
      return request;
    } on Web3RequestException {
      rethrow;
    } catch (e) {
      throw Web3RequestExceptionConst.invalidMethodArgruments;
    }
  }

  Web3CosmosSignMessage _signMessage({
    required PageMessageRequest params,
    required CosmosWeb3State state,
  }) {
    try {
      final signingMessage = params.elementAs<JSCosmosSignMessageParams>(0,
          peroperties: JSCosmosSignMessageParams.properties);
      if (signingMessage != null) {
        final messageBytes = signingMessage.message.toListInt();
        final challeng = BytesUtils.toHexString(messageBytes);
        final content = StringUtils.tryDecode(messageBytes);
        return Web3CosmosSignMessage(
            account:
                state.getJsAddressChainAccountOrThrow(signingMessage.account),
            challeng: challeng,
            content: content);
      }
    } on Web3RequestExceptionConst {
      rethrow;
    } catch (_) {}
    throw Web3RequestExceptionConst.invalidWalletStandardSignMessage;
  }

  Future<Web3CosmosSignTransaction> _parseAminoTransaction(
      {required PageMessageRequest params,
      required CosmosWeb3State state,
      required Web3CosmosRequestMethods method}) async {
    try {
      final request = params.elementAs<JSCosmosSignAminoRequest>(0,
          peroperties: JSCosmosSignAminoRequest.properties);
      if (!state.chainExist(request!.chainId)) {
        throw Web3RequestExceptionConst.networkDoesNotExists;
      }
      final amino = AminoTx.fromJson(StringUtils.toJson(request.signDoc));
      if (amino.chainId != request.chainId) {
        throw Web3CosmosExceptionConstant.mismatchChainId;
      }

      return Web3CosmosSignTransaction(
          account:
              state.getJsAddressChainAccountOrThrow(request.signerAddress.toJS),
          chainId: request.chainId,
          disableBalanceCheck: request.signOption?.disableBalanceCheck,
          preferNoSetFee: request.signOption?.preferNoSetFee,
          preferNoSetMemo: request.signOption?.preferNoSetMemo,
          transaction: Web3CosmosSignTransactionAminoParams(amino));
    } on Web3RequestException {
      rethrow;
    } on AminoJsonParserException catch (e) {
      throw Web3RequestExceptionConst.invalidParameters(e.message);
    } catch (_) {
      rethrow;
    }
  }

  Future<Web3CosmosSignTransaction> _parseSignTransaction(
      {required PageMessageRequest params,
      required CosmosWeb3State state,
      required Web3CosmosRequestMethods method}) async {
    try {
      final param = params.elementAs<JSCosmosSendOrSignTransactionParams>(0,
          peroperties: JSCosmosSendOrSignTransactionParams.properties);
      final bytes = param!.transaction.toListInt();
      final toString = StringUtils.tryDecode(bytes);
      final toJson = StringUtils.toJson(toString);
      final account = state.getJsAddressChainAccountOrThrow(param.account);
      final chain = state.getAccountChain(account);
      if (toJson != null) {
        final aminoTx = AminoTx.fromJson(toJson);
        if (aminoTx.chainId != chain.chainId) {
          throw Web3RequestExceptionConst.mismatchAccountAndTransactionChainId;
        }
        return Web3CosmosSignTransaction(
            account: state.getJsAddressChainAccountOrThrow(param.account),
            chainId: aminoTx.chainId,
            transaction: Web3CosmosSignTransactionAminoParams(aminoTx));
      } else {
        final signDoc = SignDoc.deserialize(bytes);
        if (signDoc.chainId != chain.chainId) {
          throw Web3RequestExceptionConst.mismatchAccountAndTransactionChainId;
        }
        return Web3CosmosSignTransaction(
            account: account,
            chainId: signDoc.chainId,
            transaction: Web3CosmosSignTransactionDirectParams(
                accountNumber: signDoc.accountNumber,
                bodyBytes: signDoc.bodyBytes,
                authInfos: signDoc.authInfoBytes));
      }
    } on Web3RequestException {
      rethrow;
    } catch (_) {
      throw Web3RequestExceptionConst.invalidAccountOrTransaction;
    }
  }

  Future<Web3CosmosSignTransaction> _parseDirectTransaction(
      {required PageMessageRequest params,
      required CosmosWeb3State state,
      required Web3CosmosRequestMethods method}) async {
    try {
      final request = params.elementAs<JSCosmosSignDirectRequest>(0,
          peroperties: JSCosmosSignDirectRequest.properties);
      if (!state.chainExist(request!.chainId)) {
        throw Web3RequestExceptionConst.networkDoesNotExists;
      }
      if (request.signDoc.chainId != null &&
          request.signDoc.chainId != request.chainId) {
        throw Web3CosmosExceptionConstant.mismatchChainId;
      }
      if (request.signDoc.bodyBytes == null) {
        throw Web3CosmosExceptionConstant.missingBodyBytes;
      }
      return Web3CosmosSignTransaction(
          account:
              state.getJsAddressChainAccountOrThrow(request.signerAddress.toJS),
          chainId: request.chainId,
          disableBalanceCheck: request.signOption?.disableBalanceCheck,
          preferNoSetFee: request.signOption?.preferNoSetFee,
          preferNoSetMemo: request.signOption?.preferNoSetMemo,
          transaction: Web3CosmosSignTransactionDirectParams(
              bodyBytes: request.signDoc.bodyBytes!.toListInt(),
              authInfos: request.signDoc.authInfoBytes?.toListInt(),
              accountNumber:
                  JsUtils.parseNumber(request.signDoc.accountNumber)));
    } on Web3RequestException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Web3MessageCore _parseSwitchChain(
      {required PageMessageRequest params, required CosmosWeb3State state}) {
    throw UnimplementedError();
  }

  @override
  void onRequestDone(PageMessageRequest message) {}

  @override
  NetworkType get networkType => NetworkType.cosmos;

  @override
  Future<WalletMessageResponse> finalizeWalletResponse(
      {required PageMessageRequest message,
      required Web3RequestParams? params,
      required Web3WalletResponseMessage response}) async {
    final method = Web3CosmosRequestMethods.fromName(message.method);
    final state = await getState();
    switch (method) {
      case Web3CosmosRequestMethods.signMessage:
        final signedMessage =
            Web3CosmosSignMessageResponse.fromJson(response.resultAsMap());
        return WalletMessageResponse.success(JSCosmosSignMessageResponse.setup(
            signedMessage: signedMessage.messageBytes,
            signature: signedMessage.signature));
      case Web3CosmosRequestMethods.requestAccounts:
        if (state.hasAccount) {
          final chainId = message.elementAs<JSString>(0);
          if (chainId != null) {
            final chainAddresses = state.getChainIdJsAccounts(chainId.toDart);
            if (chainAddresses.isNotEmpty) {
              return WalletMessageResponse.success(chainAddresses.toJS);
            }
          } else {
            return WalletMessageResponse.success(
                JSCosmosWalletStandardConnect.setup(state.jsAccounts));
          }
        }
        return WalletMessageResponse.fail(Web3RequestExceptionConst
            .rejectedByUser
            .toResponseMessage()
            .toJson()
            .jsify());
      case Web3CosmosRequestMethods.signTransactionAmino:
      case Web3CosmosRequestMethods.signTransaction:
      case Web3CosmosRequestMethods.signTransactionDirect:
        final transaction = response.resultAsMap();
        final request = params!.cast<Web3CosmosSignTransaction>();
        switch (request.transaction.method) {
          case Web3CosmosRequestMethods.signTransactionAmino:
            final signedResponse =
                Web3CosmosSignTransactionResponse.fromJson(transaction)
                    .cast<Web3CosmosSignTransactionAminoSignResponse>();

            return WalletMessageResponse.success(
                JSCosmosAminoSignResponse.setup(
                    tx: signedResponse.tx.toJson(),
                    signature: JSCosmosStdSignature.setup(
                        pubKey: JSCosmosPubKey.setup(
                            type: signedResponse.publicKey.typeUrl,
                            value: signedResponse.publicKey.toBase64),
                        signature: signedResponse.singaureAsBase64())));
          case Web3CosmosRequestMethods.signTransactionDirect:
            final signedResponse =
                Web3CosmosSignTransactionResponse.fromJson(transaction)
                    .cast<Web3CosmosSignTransactionDirectSignResponse>();
            return WalletMessageResponse.success(
                JSCosmosDirectSignResponse.setup(
                    signed: JSCosmosSignDoc.setup(
                        bodyBytes: signedResponse.bodyBytes,
                        authInfoBytes: signedResponse.authInfoBytes,
                        chainId: signedResponse.chainId,
                        accountNumber: signedResponse.accountNumber),
                    signature: JSCosmosStdSignature.setup(
                        pubKey: JSCosmosPubKey.setup(
                            type: signedResponse.publicKey.typeUrl,
                            value: signedResponse.publicKey.toBase64),
                        signature: signedResponse.singaureAsBase64())));
          default:
        }
      // return WalletMessageResponse.success(JSCosmosAminoSignResponse.setup(
      //     tx: signedResponse.tx.toJson(),
      //     signature: JSCosmosStdSignature.setup(
      //         pubKey: JSCosmosPubKey.setup(
      //             type: signedResponse.publicKey.typeUrl,
      //             value: signedResponse.publicKey.toBase64),
      //         signature: signedResponse.singaureAsBase64())));
      // case Web3CosmosRequestMethods.signTransactionDirect:
      //   final transaction = response.resultAsMap();
      //   final signedResponse =
      //       Web3CosmosSignTransactionResponse.fromJson(transaction)
      //           .cast<Web3CosmosSignTransactionDirectSignResponse>();
      //   return WalletMessageResponse.success(JSCosmosDirectSignResponse.setup(
      //       signed: JSCosmosSignDoc.setup(
      //           bodyBytes: signedResponse.bodyBytes,
      //           authInfoBytes: signedResponse.authInfoBytes,
      //           chainId: signedResponse.chainId,
      //           accountNumber: signedResponse.accountNumber),
      //       signature: JSCosmosStdSignature.setup(
      //           pubKey: JSCosmosPubKey.setup(
      //               type: signedResponse.publicKey.typeUrl,
      //               value: signedResponse.publicKey.toBase64),
      //           signature: signedResponse.singaureAsBase64())));

      default:
        break;
    }
    return super.finalizeWalletResponse(
        message: message, params: params, response: response);
  }

  @override
  CosmosWeb3State createState(Web3APPData? authenticated) {
    if (authenticated == null) return CosmosWeb3State.init();
    return CosmosWeb3State(authenticated.getAuth(networkType));
  }
}
