import 'dart:js_interop';

import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/web3/constant/constant/exception.dart';
import 'package:mrt_wallet/wallet/web3/core/core.dart';
import 'package:mrt_wallet/wallet/web3/networks/networks.dart';
import '../../js_wallet.dart';
import '../../models/models/networks/bitcoin.dart';
import '../../models/models/networks/wallet_standard.dart';
import '../core/network_handler.dart';

class BitcoinWeb3State extends WalletStandardChainWeb3State<
    BitcoinBaseAddress,
    Web3BitcoinChainAccount,
    JSBitcoinWalletAccount,
    Web3ChainDefaultIdnetifier> {
  BitcoinWeb3State._({
    required super.state,
    required super.chains,
    required super.accounts,
    super.defaultAccount,
    super.defaultChain,
  });
  factory BitcoinWeb3State.init(
      {JSNetworkState state = JSNetworkState.disconnect}) {
    return BitcoinWeb3State._(accounts: const [], state: state, chains: []);
  }
  factory BitcoinWeb3State(Web3BitcoinChainAuthenticated? authenticated) {
    if (authenticated == null) {
      return BitcoinWeb3State.init(state: JSNetworkState.block);
    }
    final accounts = authenticated.accounts
        .map((e) => JSWalletStateAccount<BitcoinBaseAddress,
                Web3BitcoinChainAccount, JSBitcoinWalletAccount>(
            chainaccount: e,
            jsAccount: JSBitcoinWalletAccount.setup(
                address: e.addressStr,
                publicKey: e.publicKey,
                redeemScript: e.redeemScript,
                type: e.type.value,
                witnessScript: e.witnessScript,
                features: BitcoinJSConstant.accountFeatures(
                    e.network.identifier, e.type.supportBip137),
                chain: e.network.identifier),
            identifier: e.network.identifier))
        .toList();
    final defaultAddress = authenticated.accounts.firstWhereOrNull(
        (e) => e.id == authenticated.currentNetwork.id && e.defaultAddress);
    return BitcoinWeb3State._(
        accounts: accounts,
        state: JSNetworkState.init,
        chains: authenticated.networks,
        defaultChain: authenticated.currentNetwork,
        defaultAccount: defaultAddress == null
            ? null
            : JSWalletStateAccount<BitcoinBaseAddress, Web3BitcoinChainAccount,
                JSBitcoinWalletAccount>(
                chainaccount: defaultAddress,
                identifier: authenticated.currentNetwork.identifier,
                jsAccount: JSBitcoinWalletAccount.setup(
                    address: defaultAddress.addressStr,
                    redeemScript: defaultAddress.redeemScript,
                    type: defaultAddress.type.value,
                    witnessScript: defaultAddress.witnessScript,
                    features: BitcoinJSConstant.accountFeatures(
                        defaultAddress.network.identifier,
                        defaultAddress.type.supportBip137),
                    publicKey: defaultAddress.publicKey,
                    chain: defaultAddress.network.identifier),
              ));
  }
}

class JSBitcoinHandler extends JSWalletStandardNetworkHandler<
    BitcoinBaseAddress,
    Web3BitcoinChainAccount,
    JSBitcoinWalletAccount,
    Web3ChainDefaultIdnetifier,
    BitcoinWeb3State> {
  JSBitcoinHandler(
      {required super.sendMessageToClient, required super.sendInternalMessage});

  @override
  Future<Web3MessageCore> request(PageMessageRequest params) async {
    final state = await getState();
    final method = Web3BitcoinRequestMethods.fromName(params.method);
    switch (method) {
      case Web3BitcoinRequestMethods.requestAccounts:
        if (state.hasAccount) {
          return createResponse();
        }
        return connect();
      case Web3BitcoinRequestMethods.signTransaction:
        return _parseTransaction(params: params, state: state);
      case Web3BitcoinRequestMethods.sendTransaction:
        return _parseSendTransaction(params: params, state: state);
      case Web3BitcoinRequestMethods.signPersonalMessage:
        return _signMessage(params: params, state: state, method: method!);
      default:
        throw Web3RequestExceptionConst.methodDoesNotExist;
    }
  }

  Web3BitcoinSendTransactionOutput _parseOutput(
      JSBitcoinSendTransactionOutput output, BasedUtxoNetwork network) {
    try {
      final amount = BigintUtils.tryParse(output.value);
      if (amount == null ||
          amount > maxU64 ||
          amount.isNegative ||
          (output.address != null && output.script != null) ||
          (output.address == null && output.script == null)) {
        throw Web3BitcoinExceptionConstant.invalidOutput;
      }
      Script? outputScript;
      if (output.script != null) {
        final List<int>? scriptBytes =
            BytesUtils.tryFromHexString(output.script!);
        outputScript = MethodUtils.nullOnException(
            () => Script.deserialize(bytes: scriptBytes!));
        if (outputScript == null ||
            !BytesUtils.bytesEqual(scriptBytes, outputScript.toBytes())) {
          throw Web3BitcoinExceptionConstant.parsingOutputScriptFailed(
              output.script!);
        }
      } else {
        final address = BitcoinNetworkAddress.tryParse(
            address: output.address!, network: network);
        if (address == null) {
          throw Web3BitcoinExceptionConstant.invalidAddress(
              output.address!, network.value);
        }
        outputScript = address.baseAddress.toScriptPubKey();
      }
      return Web3BitcoinSendTransactionOutput(
          value: amount, scriptPubKey: outputScript, address: output.address);
    } on Web3RequestException {
      rethrow;
    } catch (_) {
      throw Web3BitcoinExceptionConstant.invalidOutput;
    }
  }

  Web3BitcoinSendTransaction _parseSendTransaction(
      {required PageMessageRequest params, required BitcoinWeb3State state}) {
    try {
      final transactions = params.elementAs<JSBitcoinSendTransactionParams>(0,
          peroperties: JSBitcoinSendTransactionParams.properties);
      if (transactions == null) {
        throw Web3BitcoinExceptionConstant.invalidSendTransaction;
      }
      List<Web3BitcoinChainAccount> accounts = [];
      final addresses = transactions.accounts.toDart;
      for (final i in addresses) {
        final account = state.getJsAddressChainAccountOrThrow(i);
        accounts.add(account);
      }
      if (addresses.isEmpty) {
        throw Web3RequestExceptionConst.missingPermission;
      }
      if (accounts.map((e) => e.network).toSet().length != 1) {
        throw Web3BitcoinExceptionConstant.invalidTransactionAccount;
      }
      final network = accounts[0].network;

      final outputs = transactions.outputs.toDart;
      final List<Web3BitcoinSendTransactionOutput> txOutputs =
          outputs.map((e) => _parseOutput(e, network)).toList();
      if (txOutputs.isEmpty) {
        throw Web3BitcoinExceptionConstant.emptyOutput;
      }
      return Web3BitcoinSendTransaction(accounts: accounts, outputs: txOutputs);
    } on Web3RequestException {
      rethrow;
    } catch (_) {}
    throw Web3BitcoinExceptionConstant.invalidSendTransaction;
  }

  Web3BitcoinSignTransaction _parseTransaction(
      {required PageMessageRequest params, required BitcoinWeb3State state}) {
    try {
      final transactions = params.elementAs<JSBitcoinSignTransactionParams>(0,
          peroperties: JSBitcoinSignTransactionParams.properties);
      if (transactions == null) {
        throw Web3BitcoinExceptionConstant.invalidTransaction;
      }
      final psbt = Psbt.fromBase64(transactions.psbt);
      List<Web3BitcoinChainAccount> accounts = [];
      final addresses = transactions.accounts.toDart;
      for (final i in addresses) {
        final account = state.getJsAddressChainAccountOrThrow(i);
        accounts.add(account);
      }
      if (addresses.isEmpty) {
        throw Web3RequestExceptionConst.missingPermission;
      }
      if (accounts.map((e) => e.network).toSet().length != 1) {
        throw Web3BitcoinExceptionConstant.invalidTransactionAccount;
      }
      final inputs = psbt.input.length;
      final output = psbt.output.length;
      if (inputs == 0 || output == 0) {
        throw Web3BitcoinExceptionConstant.invalidPSBT;
      }
      Set<Web3BitcoinChainAccount> spenderAccounts = {};
      final builder = PsbtBuilder.fromPsbt(psbt);
      for (int i = 0; i < inputs; i++) {
        final psbtInput = builder.psbtInput(i);
        final account = accounts.firstWhereOrNull(
            (e) => e.address.toScriptPubKey() == psbtInput.scriptPubKey);
        if (account != null) {
          spenderAccounts.add(account);
        }
      }
      if (spenderAccounts.isEmpty) {
        throw Web3BitcoinExceptionConstant.noRelatedInput;
      }
      return Web3BitcoinSignTransaction(
          accounts: spenderAccounts.toList(), psbt: psbt);
    } on Web3RequestException {
      rethrow;
    } catch (_) {}
    throw Web3BitcoinExceptionConstant.invalidTransaction;
  }

  Web3BitcoinSignMessage _signMessage(
      {required PageMessageRequest params,
      required BitcoinWeb3State state,
      required Web3NetworkRequestMethods method}) {
    try {
      final message = params.getElementAt<JSBitcoinSignMessageParams>(0);
      final List<int> messageBytes = message!.message.toListInt();
      final content = StringUtils.tryDecode(messageBytes);
      final account = state.getJsAddressChainAccountOrThrow(message.account);
      if (!account.type.supportBip137) {
        throw Web3BitcoinExceptionConstant.invalidSignMessageAccount(
            account.addressStr);
      }
      return Web3BitcoinSignMessage(
          account: account,
          message: BytesUtils.toHexString(messageBytes),
          content: content,
          messagePrefix: message.messagePrefix);
    } on Web3RequestException {
      rethrow;
    } catch (_) {
      throw Web3RequestExceptionConst.invalidWalletStandardSignMessage;
    }
  }

  @override
  void onRequestDone(PageMessageRequest message) {}

  @override
  Future<WalletMessageResponse> finalizeWalletResponse(
      {required PageMessageRequest message,
      required Web3RequestParams? params,
      required Web3WalletResponseMessage response}) async {
    final state = await getState();
    final method = Web3BitcoinRequestMethods.fromName(message.method);
    switch (method) {
      case Web3BitcoinRequestMethods.requestAccounts:
        if (state.hasAccount) {
          return WalletMessageResponse.success(
              JSWalletStandardConnect.setup(state.jsAccounts));
        }
        return WalletMessageResponse.fail(Web3RequestExceptionConst
            .rejectedByUser
            .toResponseMessage()
            .toJson()
            .jsify());
      case Web3BitcoinRequestMethods.signTransaction:
        return WalletMessageResponse.success(
            JSBitcoinSignTransactionResponse.setup(response.resultAsString()));
      case Web3BitcoinRequestMethods.sendTransaction:
        return WalletMessageResponse.success(
            JSBitcoinSendTransactionResponse.setup(response.resultAsString()));
      case Web3BitcoinRequestMethods.signPersonalMessage:
        final signedMessage =
            Web3BitcoinSignMessageResponse.fromJson(response.resultAsMap());
        return WalletMessageResponse.success(JSBitcoinSignMessageResponse.setup(
            digest: signedMessage.digest, signature: signedMessage.signature));
      default:
        break;
    }
    return super.finalizeWalletResponse(
        message: message, params: params, response: response);
  }

  @override
  NetworkType get networkType => NetworkType.bitcoinAndForked;

  @override
  BitcoinWeb3State createState(Web3APPData? authenticated) {
    if (authenticated == null) return BitcoinWeb3State.init();
    return BitcoinWeb3State(authenticated.getAuth(networkType));
  }
}
