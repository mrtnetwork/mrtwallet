import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/network/params/core/network_params.dart';
import 'package:mrt_wallet/models/wallet_models/network/params/core/token.dart';
import 'package:mrt_wallet/provider/api/networks/cardano/api_provider/cardano_api_provider_service.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class CardanoNetworkParams with CborSerializable implements NetworkCoinParams {
  static const String _txIdArgs = "#txid";
  static const String _addrArgs = "#address";
  factory CardanoNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.cardanoNetworkParams);

    return CardanoNetworkParams(
        transactionExplorer: cbor.elementAt(0),
        addressExplorer: cbor.elementAt(1),
        token: Token.fromCborBytesOrObject(obj: cbor.getCborTag(2)),
        providers: (cbor.elementAt(3) as List)
            .map((e) => CardanoAPIProviderService.fromCborBytesOrObject(obj: e))
            .toList(),
        mainnet: cbor.elementAt(4));
  }
  const CardanoNetworkParams(
      {required this.transactionExplorer,
      required this.addressExplorer,
      required this.token,
      required this.providers,
      required this.mainnet});

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
  final List<CardanoAPIProviderService> providers;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          transactionExplorer,
          addressExplorer,
          token.toCbor(),
          CborListValue.fixedLength(providers.map((e) => e.toCbor()).toList()),
          mainnet
        ]),
        WalletModelCborTagsConst.cardanoNetworkParams);
  }
}
