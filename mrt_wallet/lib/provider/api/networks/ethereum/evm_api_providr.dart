import 'package:mrt_wallet/models/api/api_provider_tracker.dart';
import 'package:mrt_wallet/models/wallet_models/address/core/bip/bip32_address_core.dart';
import 'package:mrt_wallet/models/wallet_models/address/network_address/network_address.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/models/wallet_models/token/core/core.dart';
import 'package:mrt_wallet/models/wallet_models/token/networks/ethereum/erc20_token.dart';
import 'package:mrt_wallet/models/wallet_models/token/networks/tron/trc20_token.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';
import 'package:on_chain/address/core.dart';
import 'package:on_chain/on_chain.dart';

class EVMApiProvider implements NetworkApiProvider<IEthAddress> {
  EVMApiProvider({required this.provider});
  final EVMRPC provider;
  @override
  ApiProviderTracker<EVMApiProviderService> get serviceProvider =>
      (provider.rpc as BaseProviderProtocol).provider
          as ApiProviderTracker<EVMApiProviderService>;

  @override
  Future<void> updateBalance(IEthAddress account) async {
    final balance = await provider
        .request(RPCGetBalance(address: account.address.toAddress));
    account.address.updateBalance(balance);
    await updateAccountTokensBalance(account);
  }

  Future<FeeHistorical> getHistoricalFee() async {
    final historical = await provider.request(RPCGetFeeHistory(
        blockCount: 10,
        newestBlock: BlockTagOrNumber.latest,
        rewardPercentiles: [30, 60, 99]));
    return historical!.toFee();
  }

  Future<(BigInt, bool)> getNetworkInfo() async {
    final BigInt chainId = await provider.request(RPCGetChainId());
    final eip = await provider.request(RPCGetFeeHistory(
        blockCount: 25,
        newestBlock: BlockTagOrNumber.pending,
        rewardPercentiles: [25, 50, 90]));
    return (chainId, eip != null);
  }

  Future<BigInt> gasPrice() async {
    final historical = await provider.request(RPCGetGasPrice());
    return historical;
  }

  Future<BigInt> estimateGasLimit(Map<String, dynamic> estimateDetails) async {
    final estimate =
        await provider.request(RPCEstimateGas(transaction: estimateDetails));
    return estimate;
  }

  Future<int> getAccountNonce(ETHAddress account) async {
    final nonce = await provider
        .request(RPCGetTransactionCount(address: account.address));
    return nonce;
  }

  Future<String> sendRawTransaction(String digest) async {
    final txID =
        await provider.request(RPCSendRawTransaction(transaction: digest));
    return txID;
  }

  Future<Token?> getErc20Details(BaseHexAddress contractAddress) async {
    try {
      final symbol = await provider.request(RPCERC20Symbol(contractAddress));
      if (symbol == null) return null;
      final decimal = await provider.request(RPCERC20Decimal(contractAddress));
      if (decimal == null) return null;
      return Token(name: symbol, symbol: symbol, decimal: decimal);
    } on RPCException {
      return null;
    }
  }

  Future<void> updateTokenBalance(
      BaseHexAddress account, SolidityToken token) async {
    final balance =
        await provider.request(RPCERC20TokenBalance(token.toHex(), account));
    token.updateBalance(balance);
  }

  Future<void> updateAccountTokensBalance(Bip32AddressCore account) async {
    if (account is! IEthAddress && account is! ITronAddress) return;
    for (final i in account.tokens) {
      try {
        await updateTokenBalance(account.networkAddress, i as SolidityToken);
      } catch (e) {
        continue;
      }
    }
  }

  Future<SolidityToken?> getAccountERC20Token(
      BaseHexAddress account, BaseHexAddress contractAddress) async {
    final token = await getErc20Details(contractAddress);
    if (token == null) return null;
    final balance = await provider
        .request(RPCERC20TokenBalance(contractAddress.toHex(), account));
    if (contractAddress is TronAddress) {
      return TronTRC20Token.create(
          balance: balance, token: token, contractAddress: contractAddress);
    }
    return ETHERC20Token.create(
        balance: balance,
        token: token,
        contractAddress: contractAddress as ETHAddress);
  }
}
