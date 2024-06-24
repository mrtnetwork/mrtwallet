import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/app/app_image.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/network/params/core/network_params.dart';
import 'package:mrt_wallet/models/wallet_models/network/params/core/token.dart';
import 'package:mrt_wallet/provider/api/api_provider.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class SolanaNetworkParams with CborSerializable implements NetworkCoinParams {
  static const String _txIdArgs = "#txid";
  static const String _addrArgs = "#address";
  factory SolanaNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.solNetworkParam);

    return SolanaNetworkParams(
        transactionExplorer: cbor.elementAt(0),
        addressExplorer: cbor.elementAt(1),
        token: Token.fromCborBytesOrObject(obj: cbor.getCborTag(2)),
        providers: (cbor.elementAt(3) as List)
            .map((e) => SolanaApiProviderService.fromCborBytesOrObject(obj: e))
            .toList(),
        mainnet: cbor.elementAt(4));
  }
  const SolanaNetworkParams(
      {required this.transactionExplorer,
      required this.addressExplorer,
      required this.token,
      required this.providers,
      required this.mainnet});

  SolanaNetworkParams copyWith({
    bool? mainnet,
    String? transactionExplorer,
    String? addressExplorer,
    Token? token,
    List<SolanaApiProviderService>? providers,
  }) {
    return SolanaNetworkParams(
      mainnet: mainnet ?? this.mainnet,
      transactionExplorer: transactionExplorer ?? this.transactionExplorer,
      addressExplorer: addressExplorer ?? this.addressExplorer,
      token: token ?? this.token,
      providers: providers ?? this.providers,
    );
  }

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
  final List<SolanaApiProviderService> providers;

  @override
  String? getAccountExplorer(String address) {
    return addressExplorer?.replaceAll(_addrArgs, address);
  }

  @override
  String? getTransactionExplorer(String txId) {
    return transactionExplorer?.replaceAll(_txIdArgs, txId);
  }

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
        WalletModelCborTagsConst.solNetworkParam);
  }
}
