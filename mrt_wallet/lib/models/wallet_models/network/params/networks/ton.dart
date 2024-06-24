import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/app/app_image.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/network/params/core/network_params.dart';
import 'package:mrt_wallet/models/wallet_models/network/params/core/token.dart';
import 'package:mrt_wallet/provider/api/networks/ethereum/api_provider/ethereum_api_provider_service.dart';
import 'package:mrt_wallet/provider/api/networks/ton/api_provider/service.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class TonNetworkParams implements NetworkCoinParams {
  static const String _txIdArgs = "#txid";
  static const String _addrArgs = "#address";
  TonNetworkParams(
      {required this.transactionExplorer,
      required this.addressExplorer,
      required this.token,
      required List<EVMApiProviderService> providers,
      required this.workchain,
      required this.mainnet})
      : providers = List.unmodifiable(providers);
  TonNetworkParams copyWith(
      {String? transactionExplorer,
      String? addressExplorer,
      Token? token,
      List<EVMApiProviderService>? providers,
      int? workchain,
      bool? supportEIP1559,
      bool? mainnet,
      bool? defaultNetwork}) {
    return TonNetworkParams(
        transactionExplorer: transactionExplorer ?? this.transactionExplorer,
        addressExplorer: addressExplorer ?? this.addressExplorer,
        token: token ?? this.token,
        providers: providers ?? List.from(this.providers),
        workchain: workchain ?? this.workchain,
        mainnet: mainnet ?? this.mainnet);
  }

  final int workchain;
  @override
  final bool mainnet;

  @override
  final String? transactionExplorer;

  @override
  final String? addressExplorer;

  @override
  int get decimal => token.decimal!;

  @override
  AppImage get logo => token.assetLogo!;

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
  final List<TonAPIProviderService> providers;
  factory TonNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.tonNetworkParam);
    return TonNetworkParams(
        workchain: cbor.elementAt(0),
        mainnet: cbor.elementAt(1),
        transactionExplorer: cbor.elementAt(2),
        addressExplorer: cbor.elementAt(3),
        token: Token.fromCborBytesOrObject(obj: cbor.getCborTag(4)),
        providers: (cbor.elementAt(5) as List)
            .map((e) => EVMApiProviderService.fromCborBytesOrObject(obj: e))
            .toList());
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          workchain,
          mainnet,
          transactionExplorer,
          addressExplorer,
          token.toCbor(),
          CborListValue.fixedLength(providers.map((e) => e.toCbor()).toList()),
        ]),
        WalletModelCborTagsConst.tonNetworkParam);
  }
}
