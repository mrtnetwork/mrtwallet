import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:blockchain_utils/cbor/types/cbor_tag.dart';
import 'package:blockchain_utils/cbor/types/list.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/network/params/core/network_params.dart';
import 'package:mrt_wallet/models/wallet_models/network/params/core/token.dart';
import 'package:mrt_wallet/provider/api/core/api_provider.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class RippleNetworkParams implements NetworkCoinParams {
  static const String _txIdArgs = "#txid";
  static const String _addrArgs = "#address";
  factory RippleNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.xrpNetworkParam);

    return RippleNetworkParams(
        transactionExplorer: cbor.getIndex(0),
        addressExplorer: cbor.getIndex(1),
        token: Token.fromCborBytesOrObject(obj: cbor.getCborTag(2)),
        providers: (cbor.getIndex(3) as List)
            .map((e) => ApiProviderService.fromCborBytesOrObject(obj: e))
            .toList());
  }
  const RippleNetworkParams(
      {required this.transactionExplorer,
      required this.addressExplorer,
      required this.token,
      required this.providers});
  @override
  final String transactionExplorer;

  @override
  final String addressExplorer;

  @override
  int get decimal => token.decimal!;

  @override
  String? get logo => token.assetLogo;

  @override
  final Token token;

  @override
  String getAccountExplorer(String address) {
    return addressExplorer.replaceAll(_addrArgs, address);
  }

  @override
  String getTransactionExplorer(String txId) {
    return transactionExplorer.replaceAll(_txIdArgs, txId);
  }

  @override
  final List<ApiProviderService> providers;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          transactionExplorer,
          addressExplorer,
          token.toCbor(),
          CborListValue.fixedLength(providers.map((e) => e.toCbor()).toList())
        ]),
        WalletModelCborTagsConst.xrpNetworkParam);
  }
}
