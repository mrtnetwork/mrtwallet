import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/wallet/api/client/networks/substrate/methods/metadata.dart';
import 'package:mrt_wallet/wallet/api/client/networks/substrate/models/models/fee_info.dart';
import 'package:mrt_wallet/wallet/api/client/networks/substrate/repository/substrate_repository.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/substrate.dart';
import 'package:mrt_wallet/wallet/constant/networks/substrate.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/substrate/substrate.dart';
import 'package:mrt_wallet/wallet/api/client/core/client.dart';
import 'package:mrt_wallet/wallet/api/services/core/base_service.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class SubstrateClient
    extends NetworkClient<ISubstrateAddress, SubstrateAPIProvider>
    with SubstrateRepository {
  SubstrateClient({required this.provider, required this.network});
  final SubstrateProvider provider;
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
  Future<void> updateBalance(
    ISubstrateAddress address,
    APPCHAINACCOUNT<ISubstrateAddress> chain,
  ) async {
    final storage = await api.getAccountInfo(
        address: address.networkAddress, rpc: provider);
    chain.updateAddressBalance(
        address: address, updateBalance: storage.data.free);
  }

  Future<int> getNonce(SubstrateAddress address) async {
    final storage = await api.getAccountInfo(address: address, rpc: provider);
    return storage.nonce;
  }

  Future<SubstrateBlockHash> getBlockHash({int? atNumber}) async {
    final blockHash = await provider
        .request(SubstrateRequestChainGetBlockHash(number: atNumber));
    if (blockHash == null) {
      throw UnimplementedError();
    }
    return SubstrateBlockHash.hash(blockHash);
  }

  Future<SubstrateBlockHash> getFinalizBlock({int? atNumber}) async {
    final blockHash = await provider
        .request(const SubstrateRequestChainChainGetFinalizedHead());
    return SubstrateBlockHash.hash(blockHash);
  }

  Future<SubstrateHeaderResponse> getBlockHeader({String? atBlockHash}) async {
    final header = await provider
        .request(SubstrateRequestChainChainGetHeader(atBlockHash: atBlockHash));
    return header;
  }

  Future<String> broadcastTransaction(Extrinsic extrinsic) async {
    return await provider.request(
        SubstrateRequestAuthorSubmitExtrinsic(extrinsic.toHex(prefix: "0x")));
  }

  Future<MortalEra> getBlockEra(String blockHash) async {
    final header = await getBlockHeader(atBlockHash: blockHash);
    return header.toMortalEra();
  }

  Future<SubstrateFeeInfos> estimateFee(Extrinsic extrinsic) async {
    final fee = await provider.request(
        SubstrateRequestRuntimeTransactionPaymentApiQueryFeeDetails
            .fromExtrinsic(exirce: extrinsic));
    return SubstrateFeeInfos.fromFeeDetails(fee: fee, network: network);
  }

  Future<MetadataApi?> _loadApi() async {
    final versions = await provider
        .request(const SubstrateRequestRuntimeMetadataGetVersions());
    final versionIds = versions..sort((a, b) => b.compareTo(a));
    (MetadataApi, String)? api;
    for (final i in versionIds) {
      if (SubstrateConst.supportedVersion.contains(i)) {
        api = await provider.request(SubstrateGetApiAt(i));
        if (api != null) break;
      }
    }
    api ??= await provider.request(const SubstrateGetStateApi());
    return api?.$1;
  }

  Future<SubstrateBlockHash> _loadGenesis() async {
    final genesis = await provider
        .request(const SubstrateRequestChainGetBlockHash(number: 0));
    if (genesis == null) {
      throw UnimplementedError();
    }
    return SubstrateBlockHash.hash(genesis);
  }

  Future<bool> validateNetworkGenesis() async {
    _genesis ??= await _loadGenesis();
    return StringUtils.strip0x(_genesis!.toHex()) == network.coinParam.gnesis;
  }

  @override
  Future<bool> onInit() async {
    final genesis = await validateNetworkGenesis();
    if (!genesis) {
      return false;
    }
    _api ??= await _loadApi();
    return _api != null;
  }
}
