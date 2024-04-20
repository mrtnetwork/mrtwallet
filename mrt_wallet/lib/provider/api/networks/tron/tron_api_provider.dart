import 'package:mrt_wallet/models/api/api_provider_tracker.dart';
import 'package:mrt_wallet/models/wallet_models/address/network_address/network_address.dart';
import 'package:mrt_wallet/models/wallet_models/network/core/network.dart';
import 'package:mrt_wallet/models/wallet_models/network/custom/custom.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';
import 'package:on_chain/on_chain.dart';

class TVMApiProvider implements NetworkApiProvider<ITronAddress> {
  TVMApiProvider(
      {required this.provider,
      required this.solidityProvider,
      required this.network});
  final TronProvider provider;
  final EVMApiProvider solidityProvider;
  @override
  final APPTVMNetwork network;

  @override
  ApiProviderTracker get serviceProvider =>
      (provider.rpc as HttpProvider).provider;
  @override
  Future<void> updateBalance(ITronAddress account) async {
    final tronAccount = await getAccount(account.networkAddress);
    account.address.updateBalance(tronAccount?.balance ?? BigInt.zero);
    account.setTronAccount(tronAccount);
    if (tronAccount != null) {
      await updateAccountResource(account);
    }
    await solidityProvider.updateAccountTokensBalance(account);
  }

  Future<TronAccountInfo?> getAccount(TronAddress account) async {
    final tronAccount =
        await provider.request(TronRequestGetAccountInfo(address: account));
    return tronAccount;
  }

  Future<void> updateAccountResource(ITronAddress account) async {
    final accountResource = await provider.request(
        TronRequestGetAccountResourceInfo(address: account.networkAddress));
    account.setAccountResource(accountResource);
  }

  Future<TronChainParameters> getChainParameters() async {
    final tronAccount = await provider.request(TronRequestGetChainParameters());
    return tronAccount;
  }

  Future<TronBlock> getNowBlock() async {
    final tronBlock = await provider.request(TronRequestGetNowBlock());
    return tronBlock;
  }

  Future<List<TronIssueTRC10Token>> getIssueAssetList() async {
    final tokens = await provider.request(TronRequestListOfIssueTRC10());
    return tokens;
  }

  Future<String> sendTransaction(String digest) async {
    final tronBlock =
        await provider.request(TronRequestBroadcastHex(transaction: digest));
    if (!tronBlock.isSuccess) {
      throw ApiProviderException(message: tronBlock.error);
    }
    return tronBlock.txId!;
  }

  Future<int> estimateContractEnergy(
      {required ITronAddress account,
      required TronAddress contractAddress,
      required String data}) async {
    final energyRequired = await provider.request(
        TronRequestTriggerTRC20TransferContract(
            ownerAddress: account.networkAddress,
            contractAddress: contractAddress,
            data: data));
    if (!energyRequired.isSuccess) {
      throw ApiProviderException(message: energyRequired.error);
    }
    return energyRequired.energyUsed!;
  }

  Future<(MaxDelegatedResourceAmount, MaxDelegatedResourceAmount)>
      getMaxDelegatedEnergyAndBandwidth(ITronAddress address) async {
    final bandwidth = await provider.request(
        TronRequestGetCanDelegatedMaxSizeV2(
            ownerAddress: address.networkAddress,
            type: ResourceCode.bandWidth.value));
    final energy = await provider.request(TronRequestGetCanDelegatedMaxSizeV2(
        ownerAddress: address.networkAddress, type: ResourceCode.energy.value));
    return (energy, bandwidth);
  }

  Future<List<String>> getDelegatedResourceAddresses(
      ITronAddress address) async {
    final delegatedAddresses = await provider.request(
        TronRequestGetAccountDelegatedResourceAddresses(
            value: address.networkAddress));
    return delegatedAddresses;
  }

  Future<DelegatedAccountResourceInfo> getDelegatedResourceInfo(
      TronAddress from, TronAddress to) async {
    final details = await provider.request(
        TronRequestGetDelegatedResourceV2Details(
            fromAddress: from, toAddress: to));
    return details;
  }
}
