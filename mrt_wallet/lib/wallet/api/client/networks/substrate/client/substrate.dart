import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/error/exception.dart';
import 'package:mrt_wallet/crypto/impl/worker_impl.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/crypto/requets/messages/non_encrypted/requests/substrate_read_api.dart';
import 'package:mrt_wallet/wallet/api/client/networks/substrate/methods/metadata.dart';
import 'package:mrt_wallet/wallet/api/client/networks/substrate/models/models/block_info.dart';
import 'package:mrt_wallet/wallet/api/client/networks/substrate/models/models/fee_info.dart';
import 'package:mrt_wallet/wallet/api/client/networks/substrate/repository/substrate_repository.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/substrate.dart';
import 'package:mrt_wallet/wallet/constant/networks/substrate.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/substrate/substrate.dart';
import 'package:mrt_wallet/wallet/api/client/core/client.dart';
import 'package:mrt_wallet/wallet/api/services/core/base_service.dart';
import 'package:mrt_wallet/wallet/models/chain/chain/chain.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/networks/substrate/substrate.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class SubstrateClient
    extends NetworkClient<ISubstrateAddress, SubstrateAPIProvider>
    with SubstrateRepository, CryptoWokerImpl {
  SubstrateClient({required this.provider, required this.network});
  final SubstrateProvider provider;
  @override
  final WalletSubstrateNetwork? network;
  SubstrateChainMetadata? _metadata;
  SubstrateChainMetadata? get metadataNullable => _metadata;
  SubstrateChainMetadata get metadata => _metadata!;
  MetadataApi get api => metadata.metadata;
  String get genesisBlock => metadata.genesis;

  @override
  BaseServiceProtocol<SubstrateAPIProvider> get service =>
      provider.rpc as BaseServiceProtocol<SubstrateAPIProvider>;

  @override
  Future<void> updateBalance(
    ISubstrateAddress address,
    APPCHAINACCOUNT<ISubstrateAddress> chain,
  ) async {
    final storage = await api.getDefaultAccountInfo(
        address: address.networkAddress, rpc: provider);
    chain.updateAddressBalance(
        address: address, updateBalance: storage.data.free);
  }

  Future<int> getAccountNonce(ISubstrateAddress address) async {
    final storage =
        await api.getAccount(address: address.networkAddress, rpc: provider);
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

  Future<String> broadcastTransaction(List<int> extrinsic) async {
    return await provider.request(SubstrateRequestAuthorSubmitExtrinsic(
        BytesUtils.toHexString(extrinsic, prefix: "0x")));
  }

  Future<SubstrateBlockWithEra> finalizeBlockWithEra() async {
    final finalizeBlock = (await getFinalizBlock());
    final blockHash = finalizeBlock.toHex();
    final header = await getBlockHeader(atBlockHash: blockHash);
    return SubstrateBlockWithEra(
        block: blockHash,
        era: header.toMortalEra(period: APPSubstrateConst.defaultEraPeriod),
        blockHashBytes: finalizeBlock.bytes);
  }

  Future<SubstrateFeeInfos> estimateFee(
      {required List<int> extrinsic,
      required WalletSubstrateNetwork network}) async {
    final fee = await provider.request(
        SubstrateRequestRuntimeTransactionPaymentApiQueryFeeDetails
            .fromExtrinsic(exirceBytes: extrinsic));
    return SubstrateFeeInfos.fromFeeDetails(fee: fee, network: network);
  }

  Future<String?> getLastestVersionedMetadata() async {
    List<int> versionIds = [];
    try {
      versionIds = await provider
          .request(const SubstrateRequestRuntimeMetadataGetVersions());
    } on RPCError {}
    versionIds.sort((a, b) => b.compareTo(a));
    for (final i in versionIds) {
      if (APPSubstrateConst.supportedVersion.contains(i)) {
        try {
          final request = SubstrateGetApiAt(i);
          final metadata = await provider.requestDynamic(request);
          final supported = request.onResonse(metadata);
          if (supported != null) return supported.$2;
        } on ApiProviderException {
          rethrow;
        } catch (_) {}
      }
    }
    final request = const SubstrateGetStateApi();
    final metadata = await provider.requestDynamic(request);
    if (request.onResonse(metadata) != null) return metadata;
    return null;
  }

  Future<SubstrateChainMetadata?> loadApi() async {
    final r = await crypto.nonEncryptedRequest(
        NoneEncryptedRequestSubstrateGetAPI(service.provider));
    if (r == null) return null;
    final api = VersionedMetadata.fromBytes(r).toApi();
    final genesis = await _loadGenesis();
    return SubstrateChainMetadata(genesis: genesis.toHex(), metadata: api);
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
    final genesis = await _loadGenesis();
    return StringUtils.strip0x(genesis.toHex()) == network?.genesisBlock;
  }

  Future<List<String>> queryStorage(
      List<SubstrateStorageQueryParams> requests) async {
    final r = await api.queryStorageAt(
        requestes: List.generate(requests.length, (i) {
          final request = requests[i];
          return QueryStorageRequest(
              palletNameOrIndex: request.pallet,
              methodName: request.storage.name,
              identifier: i,
              input: request.input);
        }),
        rpc: provider,
        fromTemplate: false);
    return List.generate(requests.length, (i) {
      final result = r.getResult(i);
      if (result is Map) {
        return StringUtils.fromJson(result,
            indent: '', toStringEncodable: true);
      }
      return result.toString();
    });
  }

  Future<String> runtimeCall(
      {required String methodName,
      required String apiName,
      List<Object?> inputs = const []}) async {
    final result = await api.runtimeCall(
        rpc: provider,
        fromTemplate: false,
        methodName: methodName,
        apiName: apiName,
        params: inputs);
    if (result is Map) {
      return StringUtils.fromJson(result, indent: '', toStringEncodable: true);
    }
    return result.toString();
  }

  @override
  Future<bool> onInit() async {
    if (_metadata != null) return true;
    final metadata = await loadApi();
    if (metadata?.genesis != network?.genesisBlock) {
      return false;
    }
    _metadata = metadata;
    return true;
  }

  @override
  NetworkType get networkType => NetworkType.substrate;
}
