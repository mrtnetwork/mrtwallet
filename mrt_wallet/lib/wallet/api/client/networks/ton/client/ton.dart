import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/utils/http/utils.dart';
import 'package:mrt_wallet/app/utils/method/utiils.dart';
import 'package:mrt_wallet/wallet/api/client/core/client.dart';
import 'package:mrt_wallet/wallet/api/client/networks/ton/methods/methods.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/ton.dart';
import 'package:mrt_wallet/wallet/api/services/service.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/ton/ton.dart';
import 'package:mrt_wallet/wallet/models/networks/networks.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/token/chains_tokens/jetton.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
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

  Future<void> updateJettonBalance(TonJettonToken jetton) async {
    final result = await MethodUtils.call(
        () async => getJettonBalance(jetton.walletAddress));
    if (result.hasResult) {
      jetton.updateBalance(result.result);
    }
  }

  Future<BigInt> getJettonBalance(TonAddress walletAddress) async {
    final data =
        await getStateStack(method: "get_wallet_data", address: walletAddress);
    final reader = data.reader();
    final balance = reader.readBigNumber();
    return balance;
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

  Future<String> sendMessage(Message exMessage) async {
    final boc = beginCell().store(exMessage).endCell();
    if (provider.isTonCenter) {
      await provider.request(TonCenterSendBocReturnHash(boc.toBase64()));
    } else {
      await provider
          .request(TonApiSendBlockchainMessage(batch: [], boc: boc.toBase64()));
    }
    return StringUtils.decode(boc.hash(), type: StringEncoding.base64);
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

  Future<JettonDataResponse> getJettonData(TonAddress jettonAddress,
      {Duration timeout = const Duration(seconds: 10)}) async {
    try {
      final data = await getStateStack(
          method: "get_jetton_data", address: jettonAddress, timeout: timeout);
      final reader = data.reader();
      final item = reader.pop();
      final BigInt totalSupply;
      if (item.type == TupleItemTypes.intItem) {
        totalSupply = (item as TupleItemInt).value;
      } else {
        totalSupply = reader.readBigNumber();
      }
      final bool mintable = reader.readBoolean();
      final TonAddress? admin = reader.readAddressOpt();
      final Cell content = reader.readCell();
      final Cell walletCode = reader.readCell();
      return JettonDataResponse(
          totalSupply: totalSupply,
          mintable: mintable,
          admin: admin,
          content: content,
          walletCode: walletCode);
    } catch (e) {
      rethrow;
    }
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
    if (metdata == null) {
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
        onChainMetadata = metdata as JettonOnChainMetadata;
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
