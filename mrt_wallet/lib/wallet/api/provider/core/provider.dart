import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/bitcoin/providers/provider.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/cardano.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/cosmos.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/ethereum.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/ripple.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/solana.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/ton.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/tron.dart';
import 'package:mrt_wallet/wallet/api/services/models/models.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';

abstract class APIProvider with Equatable, CborSerializable {
  const APIProvider(
      this.serviceName, this.websiteUri, this.protocol, this.auth);
  final ServiceProtocol protocol;
  final String serviceName;
  final String websiteUri;
  final ProviderAuth? auth;

  T toProvider<T extends APIProvider>() {
    if (this is! T) throw WalletExceptionConst.invalidProviderInformation;
    return this as T;
  }

  @override
  List get variabels => [serviceName, websiteUri, protocol];

  String get callUrl => websiteUri;

  factory APIProvider.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final cborObj = (obj ?? CborObject.fromCbor(bytes!)) as CborTagValue;
    if (BytesUtils.bytesEqual(
        cborObj.tags, CborTagsConst.evmApiServiceProvider)) {
      return EthereumAPIProvider.fromCborBytesOrObject(obj: cborObj);
    } else if (BytesUtils.bytesEqual(
        cborObj.tags, CborTagsConst.tronApiServiceProvider)) {
      return TronAPIProvider.fromCborBytesOrObject(obj: cborObj);
    } else if (BytesUtils.bytesEqual(
            cborObj.tags, CborTagsConst.electrumApiServiceProvider) ||
        BytesUtils.bytesEqual(
            cborObj.tags, CborTagsConst.bitcoinExplorerApiProvider)) {
      return BaseBitcoinAPIProvider.fromCborBytesOrObject(obj: cborObj);
    } else if (BytesUtils.bytesEqual(
        cborObj.tags, CborTagsConst.solApiServiceProvider)) {
      return SolanaAPIProvider.fromCborBytesOrObject(obj: cborObj);
    } else if (BytesUtils.bytesEqual(
        cborObj.tags, CborTagsConst.cardanoApiServiceProvider)) {
      return CardanoAPIProvider.fromCborBytesOrObject(obj: cborObj);
    } else if (BytesUtils.bytesEqual(
        cborObj.tags, CborTagsConst.cosmosApiServiceProvider)) {
      return CosmosAPIProvider.fromCborBytesOrObject(obj: cborObj);
    } else if (BytesUtils.bytesEqual(
        cborObj.tags, CborTagsConst.rippleApiServiceProvider)) {
      return RippleAPIProvider.fromCborBytesOrObject(obj: cborObj);
    } else {
      return TonAPIProvider.fromCborBytesOrObject(obj: cborObj);
    }
  }
}
