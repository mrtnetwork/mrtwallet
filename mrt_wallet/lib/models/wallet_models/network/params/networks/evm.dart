import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/network/params/core/network_params.dart';
import 'package:mrt_wallet/models/wallet_models/network/params/core/token.dart';
import 'package:mrt_wallet/provider/api/core/api_provider.dart';
import 'package:mrt_wallet/provider/api/networks/ethereum/api_provider/ethereum_api_provider_service.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class EVMNetworkParams extends NetworkCoinParams<EVMApiProviderService> {
  final BigInt chainId;
  final bool supportEIP1559;

  final bool defaultNetwork;

  EVMNetworkParams(
      {required super.transactionExplorer,
      required super.addressExplorer,
      required super.token,
      required super.providers,
      required this.chainId,
      required this.supportEIP1559,
      required super.mainnet,
      this.defaultNetwork = true});
  EVMNetworkParams copyWith(
      {String? transactionExplorer,
      String? addressExplorer,
      Token? token,
      List<EVMApiProviderService>? providers,
      BigInt? chainId,
      bool? supportEIP1559,
      bool? mainnet,
      bool? defaultNetwork}) {
    return EVMNetworkParams(
        transactionExplorer: transactionExplorer ?? this.transactionExplorer,
        addressExplorer: addressExplorer ?? this.addressExplorer,
        token: token ?? this.token,
        providers: providers ?? List.from(this.providers),
        chainId: chainId ?? this.chainId,
        supportEIP1559: supportEIP1559 ?? this.supportEIP1559,
        mainnet: mainnet ?? this.mainnet,
        defaultNetwork: defaultNetwork ?? this.defaultNetwork);
  }

  factory EVMNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.evmNetworkParam);
    final bool? defaultNetwork = cbor.elementAt(7);
    return EVMNetworkParams(
        chainId: cbor.elementAt(0),
        supportEIP1559: cbor.elementAt(1),
        mainnet: cbor.elementAt(2),
        transactionExplorer: cbor.elementAt(3),
        addressExplorer: cbor.elementAt(4),
        token: Token.fromCborBytesOrObject(obj: cbor.getCborTag(5)),
        providers: (cbor.elementAt(6) as List)
            .map((e) => EVMApiProviderService.fromCborBytesOrObject(obj: e))
            .toList(),
        defaultNetwork: defaultNetwork ?? true);
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          chainId,
          supportEIP1559,
          mainnet,
          transactionExplorer,
          addressExplorer,
          token.toCbor(),
          CborListValue.fixedLength(providers.map((e) => e.toCbor()).toList()),
          defaultNetwork
        ]),
        WalletModelCborTagsConst.evmNetworkParam);
  }

  @override
  NetworkCoinParams<ApiProviderService> updateProviders(
      List<EVMApiProviderService> updateProviders) {
    return EVMNetworkParams(
        transactionExplorer: transactionExplorer,
        addressExplorer: addressExplorer,
        token: token,
        providers: updateProviders,
        chainId: chainId,
        supportEIP1559: supportEIP1559,
        mainnet: mainnet,
        defaultNetwork: defaultNetwork);
  }
}
