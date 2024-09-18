import 'package:blockchain_utils/exception/rpc_error.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/api/client/core/client.dart';
import 'package:mrt_wallet/wallet/api/client/networks/ton/methods/methods.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/ton.dart';
import 'package:mrt_wallet/wallet/api/services/service.dart';
import 'package:mrt_wallet/wallet/models/models.dart';
import 'package:mrt_wallet/wallet/web3/networks/ton/params/params.dart';
import 'package:ton_dart/ton_dart.dart';

class TonClient extends NetworkClient<ITonAddress, TonAPIProvider> {
  TonClient({required this.provider, required this.network});
  final TonProvider provider;
  @override
  final WalletTonNetwork network;
  TonApiType get apiType => provider.rpc.api;

  @override
  BaseServiceProtocol<TonAPIProvider> get service =>
      provider.rpc as BaseServiceProtocol<TonAPIProvider>;

  @override
  Future<void> updateBalance(ITonAddress account) async {
    final balance = await provider.request(
        TonRquestGetBalance(address: account.networkAddress, api: apiType));

    account.address.updateBalance(balance);
    updateJettonsBalances(account.tokens);
  }

  Future<void> updateJettonsBalances(List<TonJettonToken> jettons) async {
    for (final i in jettons) {
      await updateJettonBalance(i);
    }
  }

  Future<AccountStateResponse> getStaticState(TonAddress address) async {
    if (provider.isTonCenter) {
      final state = await provider
          .request(TonCenterGetAddressInformation(address.toString()));
      return AccountStateResponse(
          balance: state.balance,
          code: TonHelper.tryToCell(state.code),
          data: TonHelper.tryToCell(state.data),
          state: state.state);
    }
    try {
      final state = await provider
          .request(TonApiGetBlockchainRawAccount(address.toString()));
      return AccountStateResponse(
          balance: state.balance,
          code: TonHelper.tryToCell(state.code),
          data: TonHelper.tryToCell(state.data),
          state: state.status);
    } on RPCError catch (e) {
      if (e.message == ApiProviderConst.tonApiNotiFoundError) {
        return AccountStateResponse(
            balance: BigInt.zero,
            code: null,
            data: null,
            state: AccountStatusResponse.uninit);
      }

      rethrow;
    }
  }

  Future<void> updateJettonBalance(TonJettonToken jetton) async {
    final result = await MethodUtils.call(
        () async => await getJettonWalletData(jetton.walletAddress));
    if (result.hasResult) {
      jetton.updateBalance(result.result.balance);
    }
  }

  Future<MsgForwardPricesResponse> getMsgFrowardPricesConfing(
      {bool isMasterChain = true}) async {
    return await provider.request(TonRquestGetMsgForwardPricesConfig(apiType,
        isMasterChan: isMasterChain));
  }

  Future<TonTransactionFeeDetails> getTransactionFee(
      {required TonAddress address,
      required Message message,
      MsgForwardPricesResponse? forwardPrice,
      bool isMasterChain = true}) async {
    forwardPrice ??=
        await getMsgFrowardPricesConfing(isMasterChain: isMasterChain);
    return await provider.request(TonRquestGetFee(
        message: message,
        address: address,
        forwardPrice: forwardPrice,
        api: apiType));
  }

  Future<String> sendMessage({required Cell boc}) async {
    if (provider.isTonCenter) {
      await provider.request(TonCenterSendBocReturnHash(boc.toBase64()));
    } else {
      await provider
          .request(TonApiSendBlockchainMessage(batch: [], boc: boc.toBase64()));
    }
    return StringUtils.decode(boc.hash(), type: StringEncoding.base64);
  }

  Future<TonAddress> getJettonWalletAddress(
      {required TonAddress minterAddress, required TonAddress owner}) async {
    final data = await getStateStack(
        address: minterAddress,
        method: "get_wallet_address",
        stack: [
          if (provider.isTonCenter)
            ["tvm.Slice", beginCell().storeAddress(owner).endCell().toBase64()]
          else
            owner.toString()
        ]);
    return data.reader().readAddress();
  }

  Future<List<TonAccountJettonResponse>> _getTonCenterAccountJettons(
      TonAddress address) async {
    assert(provider.isTonCenter, "incorrect provider.");
    Set<TonAccountJettonResponse> jettons = {};
    int offset = 0;
    int max = TonCenterV3GetJettonWallets.maximumLimit;
    while (max == TonCenterV3GetJettonWallets.maximumLimit) {
      final result = await provider.request(TonCenterV3GetJettonWallets(
          ownerAddress: address.toFriendlyAddress(),
          offset: offset,
          limit: TonCenterV3GetJettonWallets.maximumLimit));
      offset++;
      max = result.length;
      final fetchedJettons = result
          .map((e) => TonAccountJettonResponse(
              balance: e.balance,
              tokenAddress: e.jetton,
              owner: address,
              jettonWalletAddress: e.address))
          .toList();
      jettons.addAll(fetchedJettons);
      if (jettons.length != max) break;
    }

    return jettons.toList();
  }

  Future<JettonWalletState> getJettonWalletData(
      TonAddress jettonWalletAddress) async {
    final data = await getStateStack(
        method: "get_wallet_data", address: jettonWalletAddress);
    return JettonWalletState.fromTuple(data.reader());
  }

  Future<TonWeb3TransactionMessageInfo> getWeb3TransactionMessageInfo(
      {required ITonAddress address,
      required TheOpenNetworkChain account,
      required Web3TonTransactionMessage message}) async {
    final destination =
        account.getReceiptAddress(message.address.toFriendlyAddress()) ??
            ReceiptAddress<TonAddress>(
                view: message.address.toFriendlyAddress(),
                networkAddress: message.address);
    final StateInit? init = message.stateInit == null
        ? null
        : StateInit.deserialize(message.stateInit!.beginParse());
    if (message.payload == null) {
      return TonWeb3TransactionMessageInfo(
          amount: message.amount, destination: destination, initState: init);
    }
    final info = TonWeb3TransactionPayload.fromPayload(
        payload: message.payload!, destination: message.address);
    switch (info.type) {
      case TonWeb3TransactionPayloadType.transfer:
      case TonWeb3TransactionPayloadType.jetton:
        break;
      default:
        return TonWeb3TransactionMessageInfo(
            amount: message.amount,
            destination: destination,
            payload: info,
            initState: init);
    }

    final jettonInfo = await MethodUtils.call(() async {
      final tokenInfo = await getJettonWalletData(message.address);

      TonJettonToken? jetton = address.tokens
          .firstWhereOrNull((e) => e.walletAddress == message.address);
      jetton?.minterAddress;
      bool? isAccountJetton = jetton == null ? null : true;
      if (jetton == null) {
        jetton ??= await getJettonInfo(TonAccountJettonResponse(
            tokenAddress: tokenInfo.minterAddress,
            balance: BigInt.zero,
            owner: address.networkAddress,
            jettonWalletAddress: message.address));
        final jettonWalletAddress = await MethodUtils.call(() async =>
            await getJettonWalletAddress(
                minterAddress: jetton!.minterAddress,
                owner: address.networkAddress));
        if (jettonWalletAddress.hasResult &&
            jettonWalletAddress.result == message.address) {
          isAccountJetton = true;
        }
      }
      updateJettonBalance(jetton);
      return (jetton, isAccountJetton);
    });
    if (jettonInfo.hasError) {
      return TonWeb3TransactionMessageInfo(
          amount: message.amount,
          destination: destination,
          initState: init,
          payload: info);
    }
    final contractInfo = info as ContractTonTransactionPayload;
    BigInt? transfer;
    if (info.type == TonWeb3TransactionPayloadType.transfer) {
      transfer = info.jettonAmount;
    }
    TonWeb3TransactionPayload payload = JettonContractTonTransactionPayload(
        payload: info.payload,
        content: contractInfo.contentJson,
        token: jettonInfo.result.$1,
        isAccountJetton: jettonInfo.result.$2,
        transferAmount: transfer,
        type: transfer != null
            ? TonWeb3TransactionPayloadType.transfer
            : TonWeb3TransactionPayloadType.jetton,
        operation: info.operation,
        tonAmount: info.tonAmount);
    return TonWeb3TransactionMessageInfo(
        amount: message.amount,
        destination: destination,
        initState: init,
        payload: payload);
  }

  Future<RunMethodResponse> getStateStack(
      {required String method,
      required TonAddress address,
      List<dynamic> stack = const [],
      bool throwOnFail = true,
      Duration timeout = const Duration(seconds: 10)}) async {
    final RunMethodResponse response;
    if (provider.isTonCenter) {
      final request = await provider.request(
          TonCenterRunGetMethod(
              address: address.toString(), methodName: method, stack: stack),
          timeout);
      response =
          RunMethodResponse(items: request.items, exitCode: request.exitCode);
    } else {
      final request = await provider.request(
          TonApiExecGetMethodForBlockchainAccount(
              accountId: address.toString(),
              methodName: method,
              args: stack.cast()),
          timeout);
      response = RunMethodResponse(
          items: request.toTuples(), exitCode: request.exitCode);
    }
    return response;
  }

  Future<List<TonAccountJettonResponse>> getAccountJettons(
      TonAddress address) async {
    if (provider.isTonCenter) {
      return _getTonCenterAccountJettons(address);
    }
    final result = await provider.request(TonApiGetAccountJettonsBalances(
        accountId: address.toFriendlyAddress()));

    return result.balances.map((e) {
      return TonAccountJettonResponse(
          tokenAddress: e.jetton.address,
          balance: e.balance,
          owner: address,
          jettonWalletAddress: e.walletAddress.address);
    }).toList();
  }

  Future<MinterWalletState> getJettonData(TonAddress jettonAddress,
      {Duration timeout = const Duration(seconds: 10)}) async {
    final data = await getStateStack(
        method: "get_jetton_data", address: jettonAddress, timeout: timeout);
    return MinterWalletState.fromTupple(data.reader());
  }

  final Map<TonAddress, Cell> _contractsCode = {};

  Future<Cell?> getContractCode(TonAddress address) async {
    if (_contractsCode.containsKey(address)) return _contractsCode[address];
    final state = await getStaticState(address);
    if (state.code == null) return null;
    _contractsCode[address] = state.code!;
    return state.code!;
  }

  Future<TonJettonToken> getJettonInfo(TonAccountJettonResponse jetton,
      {Duration timeout = const Duration(seconds: 10)}) async {
    final result = await getJettonData(jetton.tokenAddress, timeout: timeout);
    final metdata = TokneMetadataUtils.loadContent(result.content);
    final noneVerifiedToken = TonJettonToken.create(
        balance: jetton.balance,
        token: Token(
            name: jetton.tokenAddress.toFriendlyAddress(),
            symbol: jetton.tokenAddress.toFriendlyAddress(),
            decimal: 0),
        minterAddress: jetton.tokenAddress,
        verified: false,
        walletAddress: jetton.jettonWalletAddress);
    if (metdata.type == TokenContentType.unknown) {
      return noneVerifiedToken;
    }
    String? url;
    JettonOnChainMetadata? onChainMetadata;
    TokenContentType type = TokenContentType.onchain;
    switch (metdata.type) {
      case TokenContentType.unknown:
        return noneVerifiedToken;
      case TokenContentType.offchain:
        url = (metdata as JettonOffChainMetadata).uri;
        type = TokenContentType.offchain;
        break;
      case TokenContentType.onchain:
        onChainMetadata = metdata.cast<JettonOnChainMetadata>();
        break;
    }

    url ??= onChainMetadata?.uri;

    if (url == null) {
      return TonJettonToken.create(
          balance: jetton.balance,
          token: Token(
              name: onChainMetadata?.name ??
                  jetton.tokenAddress.toFriendlyAddress(),
              symbol: onChainMetadata?.symbol ??
                  jetton.tokenAddress.toFriendlyAddress(),
              decimal: onChainMetadata?.decimals ?? 9),
          description: onChainMetadata?.description,
          minterAddress: jetton.tokenAddress,
          walletAddress: jetton.jettonWalletAddress,
          verified: true);
    }
    final json = await MethodUtils.nullOnException(
      () async {
        final result = await HttpUtils.get<Map<String, dynamic>>(url!,
            header: HttpUtils.applicationJson, timeout: timeout);
        return result.result;
      },
    );
    if (type == TokenContentType.onchain) {
      return TonJettonToken.create(
          balance: jetton.balance,
          token: Token(
              name: json?["name"] ??
                  onChainMetadata?.name ??
                  jetton.tokenAddress.toFriendlyAddress(),
              symbol: json?["symbol"] ??
                  onChainMetadata?.symbol ??
                  jetton.tokenAddress.toFriendlyAddress(),
              decimal: IntUtils.tryParse(json?["decimals"]) ??
                  onChainMetadata?.decimals ??
                  9),
          description: json?["description"] ?? onChainMetadata?.description,
          uri: url,
          minterAddress: jetton.tokenAddress,
          walletAddress: jetton.jettonWalletAddress,
          verified: true);
    }
    if (json == null) {
      return noneVerifiedToken;
    } else {
      return TonJettonToken.create(
          balance: jetton.balance,
          token: Token(
              name: json["name"] ?? jetton.tokenAddress.toFriendlyAddress(),
              symbol: json["symbol"] ?? jetton.tokenAddress.toFriendlyAddress(),
              decimal: IntUtils.tryParse(json["decimals"]) ?? 9),
          description: json["description"],
          uri: url,
          minterAddress: jetton.tokenAddress,
          walletAddress: jetton.jettonWalletAddress,
          verified: true);
    }
  }

  @override
  Future<bool> onInit() async {
    final result = await MethodUtils.call(() async {
      if (provider.isTonCenter) {
        final result = await provider.request(TonCenterGetMasterchainInfo());
        return IntUtils.parse(result["last"]["workchain"]);
      } else {
        final result =
            await provider.request(TonApiGetBlockchainMasterchainHead());
        return result.workchainId;
      }
    });
    return result.hasResult;
  }
}
