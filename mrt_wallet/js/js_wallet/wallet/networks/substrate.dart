import 'dart:js_interop';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/utils/list/extension.dart';
import 'package:mrt_wallet/app/utils/method/utiils.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/substrate/substrate.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import '../../js_wallet.dart';
import '../../models/models/networks/substrate.dart';
import '../../models/models/requests.dart';
import '../core/network_handler.dart';

class SubstrateWeb3State extends WalletStandardChainWeb3State<
    BaseSubstrateAddress,
    Web3SubstrateChainAccount,
    JSSubstrateWalletAccount,
    Web3SubstrateChainIdnetifier> {
  List<JSSubstrateKownMetadata> get knownMetadatas => chains
      .map((e) => JSSubstrateKownMetadata(
          genesisHash: e.genesisHash,
          identifier: e.identifier,
          specVersion: e.specVersion))
      .toList();
  SubstrateWeb3State._({
    required super.state,
    required super.chains,
    required super.accounts,
    super.defaultAccount,
    super.defaultChain,
  });
  factory SubstrateWeb3State.init(
      {JSNetworkState state = JSNetworkState.disconnect}) {
    return SubstrateWeb3State._(accounts: const [], state: state, chains: []);
  }
  factory SubstrateWeb3State(Web3SubstrateChainAuthenticated? authenticated) {
    if (authenticated == null) {
      return SubstrateWeb3State.init(state: JSNetworkState.block);
    }
    Map<int, Web3SubstrateChainIdnetifier> networks = {
      for (final i in authenticated.networks) i.id: i
    };
    final accounts = authenticated.accounts
        .map((e) => JSWalletStateAccount<BaseSubstrateAddress,
                Web3SubstrateChainAccount, JSSubstrateWalletAccount>(
            chainaccount: e,
            jsAccount: JSSubstrateWalletAccount.setup(
                address: e.addressStr,
                publicKey: e.publicKey,
                genesisHash: networks[e.id]!.genesisHash,
                chain: networks[e.id]!.identifier),
            identifier: networks[e.id]!.identifier))
        .toList();
    final defaultAddress = authenticated.accounts.firstWhereOrNull(
        (e) => e.id == authenticated.currentNetwork.id && e.defaultAddress);
    return SubstrateWeb3State._(
        accounts: accounts,
        state: JSNetworkState.init,
        chains: authenticated.networks,
        defaultChain: authenticated.currentNetwork,
        defaultAccount: defaultAddress == null
            ? null
            : JSWalletStateAccount<BaseSubstrateAddress,
                Web3SubstrateChainAccount, JSSubstrateWalletAccount>(
                chainaccount: defaultAddress,
                identifier: authenticated.currentNetwork.identifier,
                jsAccount: JSSubstrateWalletAccount.setup(
                    address: defaultAddress.addressStr,
                    publicKey: defaultAddress.publicKey,
                    genesisHash: networks[defaultAddress.id]!.genesisHash,
                    chain: networks[defaultAddress.id]!.identifier),
              ));
  }
}

class JSSubstrateHandler extends JSWalletStandardNetworkHandler<
    BaseSubstrateAddress,
    Web3SubstrateChainAccount,
    JSSubstrateWalletAccount,
    Web3SubstrateChainIdnetifier,
    SubstrateWeb3State> {
  JSSubstrateHandler(
      {required super.sendMessageToClient, required super.sendInternalMessage});

  @override
  Future<Web3MessageCore> request(PageMessageRequest params) async {
    final state = await getState();
    final method = Web3SubstrateRequestMethods.fromName(params.method);
    switch (method) {
      case Web3SubstrateRequestMethods.requestAccounts:
        if (state.hasAccount) {
          return createResponse();
        }
        return connect();
      case Web3SubstrateRequestMethods.knownMetadata:
        return createResponse();
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
      throw Web3SubstrateExceptionConstant.metadataParsingFailed;
    }
  }

  Web3SubstrateSignMessage _signMessage(
      {required PageMessageRequest params, required SubstrateWeb3State state}) {
    try {
      final param = params.getElementAt<JSSubstrateSign>(0)!;
      final address = MethodUtils.nullOnException(
          () => BaseSubstrateAddress(param.address));
      if (address == null) {
        throw Web3RequestExceptionConst.missingPermission;
      }
      final account = state.getAddressNetworkChainAccountOrThrow(address);
      if (param.type != Web3SubstrateConst.signMessageType) {
        throw Web3SubstrateExceptionConstant.invalidSignMessageType;
      }
      final challeng = BytesUtils.fromHexString(param.data);
      return Web3SubstrateSignMessage(
          account: account,
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
      final address = MethodUtils.nullOnException(
          () => BaseSubstrateAddress(param.address));
      final account = state.getAddressChainAccountOrThrow(address,
          identifier: param.genesisHash);
      return Web3SubstrateSendTransaction(
          json: param.toJson(), address: account);
    } on Web3RequestException {
      rethrow;
    } catch (e) {
      throw Web3RequestExceptionConst.invalidTransaction;
    }
  }

  @override
  NetworkType get networkType => NetworkType.substrate;

  @override
  Future<WalletMessageResponse> finalizeWalletResponse(
      {required PageMessageRequest message,
      required Web3RequestParams? params,
      required Web3WalletResponseMessage response}) async {
    final state = await getState();
    final method = Web3SubstrateRequestMethods.fromName(message.method);
    switch (method) {
      case Web3SubstrateRequestMethods.knownMetadata:
        return WalletMessageResponse.success(state.knownMetadatas.toJS);
      case Web3SubstrateRequestMethods.requestAccounts:
        if (state.hasAccount) {
          return WalletMessageResponse.success(
              JSSubstrateWalletStandardConnect.setup(state.jsAccounts));
        }
        return WalletMessageResponse.fail(Web3RequestExceptionConst
            .rejectedByUser
            .toResponseMessage()
            .toJson()
            .jsify());
      case Web3SubstrateRequestMethods.addSubstrateChain:
        return WalletMessageResponse.success(true.toJS);
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
    return super.finalizeWalletResponse(
        message: message, params: params, response: response);
  }

  @override
  SubstrateWeb3State createState(Web3APPData? authenticated) {
    if (authenticated == null) return SubstrateWeb3State.init();
    return SubstrateWeb3State(authenticated.getAuth(networkType));
  }
}
