import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/network/params/core/network_params.dart';
import 'package:mrt_wallet/models/wallet_models/network/params/core/token.dart';
import 'package:mrt_wallet/provider/api/networks/ethereum/api_provider/ethereum_api_provider_service.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class EVMNetworkParams implements NetworkCoinParams {
  static const String _txIdArgs = "#txid";
  static const String _addrArgs = "#address";
  EVMNetworkParams(
      {required this.transactionExplorer,
      required this.addressExplorer,
      required this.token,
      required List<EVMApiProviderService> providers,
      required this.chainId,
      required this.supportEIP1559,
      required this.mainnet})
      : providers = List.unmodifiable(providers);
  EVMNetworkParams copyWith({
    String? transactionExplorer,
    String? addressExplorer,
    Token? token,
    List<EVMApiProviderService>? providers,
    BigInt? chainId,
    bool? supportEIP1559,
    bool? mainnet,
  }) {
    return EVMNetworkParams(
      transactionExplorer: transactionExplorer ?? this.transactionExplorer,
      addressExplorer: addressExplorer ?? this.addressExplorer,
      token: token ?? this.token,
      providers: providers ?? List.from(this.providers),
      chainId: chainId ?? this.chainId,
      supportEIP1559: supportEIP1559 ?? this.supportEIP1559,
      mainnet: mainnet ?? this.mainnet,
    );
  }

  final BigInt chainId;
  final bool supportEIP1559;
  final bool mainnet;

  @override
  final String? transactionExplorer;

  @override
  final String? addressExplorer;

  @override
  int get decimal => token.decimal!;

  @override
  String get logo => token.assetLogo!;

  @override
  final Token token;

  @override
  String? getAccountExplorer(String address) {
    return addressExplorer?.replaceAll(_addrArgs, address);
  }

  @override
  String? getTransactionExplorer(String txId) {
    return transactionExplorer?.replaceAll(_txIdArgs, txId);
  }

  @override
  final List<EVMApiProviderService> providers;
  factory EVMNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.evmNetworkParam);

    return EVMNetworkParams(
        chainId: cbor.getIndex(0),
        supportEIP1559: cbor.getIndex(1),
        mainnet: cbor.getIndex(2),
        transactionExplorer: cbor.getIndex(3),
        addressExplorer: cbor.getIndex(4),
        token: Token.fromCborBytesOrObject(obj: cbor.getCborTag(5)),
        providers: (cbor.getIndex(6) as List)
            .map((e) => EVMApiProviderService.fromCborBytesOrObject(obj: e))
            .toList());
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
          CborListValue.fixedLength(providers.map((e) => e.toCbor()).toList())
        ]),
        WalletModelCborTagsConst.evmNetworkParam);
  }
}
