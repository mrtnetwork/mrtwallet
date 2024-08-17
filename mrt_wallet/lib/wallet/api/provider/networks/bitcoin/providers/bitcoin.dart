import 'package:bitcoin_base/bitcoin_base.dart'
    show APIConfig, APIType, BasedUtxoNetwork;
import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:blockchain_utils/cbor/types/cbor_tag.dart';
import 'package:blockchain_utils/cbor/types/list.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/app/utils/string/utils.dart';
import 'package:mrt_wallet/wallet/api/provider/models/bitcoin_explorer_provider_type.dart';
import 'package:mrt_wallet/wallet/api/services/service.dart';
import 'package:mrt_wallet/wallet/api/utils/utils.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'provider.dart';

class _BitcoinExplorerAPIProviderUtils {
  static APIConfig getDefaultConfing(BasedUtxoNetwork network, APIType type) {
    if (type == APIType.mempool) return APIConfig.mempool(network);
    return APIConfig.fromBlockCypher(network);
  }

  static APIConfig createConfig(
      {required BasedUtxoNetwork network, required APIType type, String? url}) {
    if (url == null) {
      return getDefaultConfing(network, type);
    }
    final String baseUrl = StrUtils.removeLastSlash(url);
    if (type == APIType.mempool) {
      return APIConfig(
          url: "$baseUrl/address/###/utxo",
          feeRate: "$baseUrl/v1/fees/recommended",
          transaction: "$baseUrl/tx/###",
          sendTransaction: "$baseUrl/tx",
          apiType: APIType.mempool,
          transactions: "$baseUrl/address/###/txs",
          network: network,
          blockHeight: "$baseUrl/block-height/###");
    }
    return APIConfig(
        url:
            "$baseUrl/addrs/###/?unspentOnly=true&includeScript=true&limit=2000",
        feeRate: baseUrl,
        transaction: "$baseUrl/txs/###",
        sendTransaction: "$baseUrl/txs/push",
        apiType: APIType.blockCypher,
        transactions: "$baseUrl/addrs/###/full?limit=200",
        network: network,
        blockHeight: "$baseUrl/blocks/###");
  }
}

class BitcoinExplorerAPIProviderConst {
  static const mempool = BitcoinExplorerAPIProvider._(
      serviceName: "Mempool",
      websiteUri: "https://mempool.space/",
      explorerType: BitcoinExplorerProviderType.mempool,
      identifier: "mempool");
  static const blockCypher = BitcoinExplorerAPIProvider._(
      serviceName: "BlockCypher",
      websiteUri: "https://www.blockcypher.com/",
      explorerType: BitcoinExplorerProviderType.blockcypher,
      identifier: "blockCypher");
}

class BitcoinExplorerAPIProvider extends BaseBitcoinAPIProvider {
  const BitcoinExplorerAPIProvider._({
    required super.serviceName,
    required super.websiteUri,
    super.protocol = ServiceProtocol.http,
    super.auth,
    required super.identifier,
    this.uri,
    required this.explorerType,
  });
  factory BitcoinExplorerAPIProvider(
      {required String serviceName,
      required String websiteUri,
      required String uri,
      required BitcoinExplorerProviderType type,
      ProviderAuth? auth,
      required String identifier}) {
    return BitcoinExplorerAPIProvider._(
        serviceName: serviceName,
        websiteUri: websiteUri,
        uri: uri,
        auth: auth,
        explorerType: type,
        identifier: identifier);
  }
  final String? uri;
  final BitcoinExplorerProviderType explorerType;

  APIConfig config(BasedUtxoNetwork network) =>
      _BitcoinExplorerAPIProviderUtils.createConfig(
          network: network, type: explorerType.type, url: uri);

  @override
  String get callUrl => throw UnimplementedError();

  factory BitcoinExplorerAPIProvider.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.bitcoinExplorerApiProvider);
    return BitcoinExplorerAPIProvider._(
        serviceName: cbor.elementAt(0),
        websiteUri: cbor.elementAt(1),
        uri: cbor.elementAt(2),
        auth: cbor.getCborTag(3)?.to<ProviderAuth, CborTagValue>(
            (e) => ProviderAuth.fromCborBytesOrObject(obj: e)),
        explorerType: BitcoinExplorerProviderType.fromName(cbor.elementAt(4)),
        identifier: APIUtils.getProviderIdentifier(cbor.elementAt(5)),
        protocol: ServiceProtocol.http);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [serviceName, websiteUri, uri, auth?.toCbor(), explorerType.name]),
        CborTagsConst.bitcoinExplorerApiProvider);
  }

  @override
  List get variabels => [serviceName, websiteUri, uri, protocol];

  @override
  BitcoinAPIProviderType get type => BitcoinAPIProviderType.explorer;
}
