import 'package:mrt_wallet/wallet/api/client/networks/substrate/methods/metadata.dart';
import 'package:mrt_wallet/wallet/api/client/networks/substrate/models/models/fee_info.dart';
import 'package:mrt_wallet/wallet/api/client/networks/substrate/repository/substrate_repository.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/substrate.dart';
import 'package:mrt_wallet/wallet/constant/networks/substrate.dart';
import 'package:mrt_wallet/wallet/models/account/address/networks/substrate/substrate.dart';
import 'package:mrt_wallet/wallet/api/client/core/client.dart';
import 'package:mrt_wallet/wallet/api/services/core/base_service.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class SubstrateClient
    extends NetworkClient<ISubstrateAddress, SubstrateAPIProvider>
    with SubstrateRepository {
  SubstrateClient({required this.provider, required this.network});
  final SubstrateRPC provider;
  @override
  final WalletPolkadotNetwork network;

  MetadataApi? _api;
  MetadataApi get api => _api!;

  SubstrateBlockHash? _genesis;
  SubstrateBlockHash get genesisBlock => _genesis!;

  @override
  BaseServiceProtocol<SubstrateAPIProvider> get service =>
      provider.rpc as BaseServiceProtocol<SubstrateAPIProvider>;

  @override
  Future<void> updateBalance(ISubstrateAddress account) async {
    final storage = await api.getAccountInfo(
        address: account.networkAddress, rpc: provider);
    account.address.updateBalance(storage.data.free);
  }

  Future<int> getNonce(SubstrateAddress address) async {
    final storage = await api.getAccountInfo(address: address, rpc: provider);
    return storage.nonce;
  }

  Future<SubstrateBlockHash> getBlockHash({int? atNumber}) async {
    final blockHash =
        await provider.request(SubstrateRPCChainGetBlockHash(number: atNumber));
    return SubstrateBlockHash.hash(blockHash);
  }

  Future<SubstrateBlockHash> getFinalizBlock({int? atNumber}) async {
    final blockHash =
        await provider.request(const SubstrateRPCChainChainGetFinalizedHead());
    return SubstrateBlockHash.hash(blockHash);
  }

  Future<SubstrateHeaderResponse> getBlockHeader({String? atBlockHash}) async {
    final header = await provider
        .request(SubstrateRPCChainChainGetHeader(atBlockHash: atBlockHash));
    return header;
  }

  Future<String> broadcastTransaction(Extrinsic extrinsic) async {
    return await provider.request(
        SubstrateRPCAuthorSubmitExtrinsic(extrinsic.toHex(prefix: "0x")));
  }

  Future<MortalEra> getBlockEra(String blockHash) async {
    final header = await getBlockHeader(atBlockHash: blockHash);
    return header.toMortalEra();
  }

  Future<SubstrateFeeInfos> estimateFee(Extrinsic extrinsic) async {
    final fee = await provider.request(
        SubstrateRPCRuntimeTransactionPaymentApiQueryFeeDetails.fromExtrinsic(
            exirce: extrinsic));
    return SubstrateFeeInfos.fromFeeDetails(fee: fee, network: network);
  }

  Future<MetadataApi?> _loadApi() async {
    // final localApi = await super.loadApi();
    // if (localApi != null) {
    //   return localApi;
    // }
    final versions =
        await provider.request(const SubstrateRPCRuntimeMetadataGetVersions());
    final versionIds = versions..sort((a, b) => b.compareTo(a));
    (MetadataApi, String)? api;
    for (final i in versionIds) {
      if (SubstrateConst.supportedVersion.contains(i)) {
        api = await provider.request(SubstrateGetApiAt(i));
        if (api != null) break;
      }
    }
    api ??= await provider.request(const SubstrateGetStateApi());
    if (api != null) {
      await writeMetadata(api.$2);
    }
    return api?.$1;
  }

  Future<SubstrateBlockHash> _loadGenesis() async {
    // final localGenesis = await super.loadGenesis();
    // if (localGenesis != null) {
    //   return SubstrateBlockHash.hash(localGenesis);
    // }
    final genesis =
        await provider.request(const SubstrateRPCChainGetBlockHash(number: 0));
    await writeGenesis(genesis);
    return SubstrateBlockHash.hash(genesis);
  }

  @override
  Future<bool> onInit() async {
    final metadata = await _loadApi();
    final genesis = await _loadGenesis();
    if (metadata != null) {
      _api = metadata;
      _genesis = genesis;
    }
    return _api != null;
  }
}
