import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/api/provider/provider.dart';
import 'package:blockchain_utils/bip/bip.dart';
import 'package:mrt_wallet/wallet/models/network/core/params/params.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:stellar_dart/stellar_dart.dart';

class StellarNetworkParams extends NetworkCoinParams<StellarAPIProvider> {
  final String passphrase;

  List<int> passphraseHash() {
    final network = StellarNetwork.fromPassphrase(passphrase);
    return network.passphraseHash;
  }

  factory StellarNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes, object: obj, tags: CborTagsConst.stellarNetworkParam);

    return StellarNetworkParams(
        token: Token.fromCborBytesOrObject(obj: values.getCborTag(2)),
        providers: values
            .elementAsListOf<CborTagValue>(3)
            .map((e) => StellarAPIProvider.fromCborBytesOrObject(obj: e))
            .toList(),
        chainType: ChainType.fromValue(values.elementAs(4)),
        passphrase: values.elementAs(5),
        addressExplorer: values.elementAs(6),
        transactionExplorer: values.elementAs(7));
  }
  StellarNetworkParams(
      {required super.token,
      required super.providers,
      required super.chainType,
      required this.passphrase,
      super.addressExplorer,
      super.transactionExplorer});

  StellarNetworkParams copyWith(
      {ChainType? chainType,
      String? transactionExplorer,
      String? addressExplorer,
      Token? token,
      List<StellarAPIProvider>? providers,
      String? passphrase}) {
    return StellarNetworkParams(
        chainType: chainType ?? this.chainType,
        token: token ?? this.token,
        providers: providers ?? this.providers,
        passphrase: passphrase ?? this.passphrase);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          const CborNullValue(),
          const CborNullValue(),
          token.toCbor(),
          CborListValue.fixedLength(providers.map((e) => e.toCbor()).toList()),
          chainType.name,
          passphrase,
          addressExplorer,
          transactionExplorer
        ]),
        CborTagsConst.stellarNetworkParam);
  }

  String get identifier => passphrase;

  @override
  NetworkCoinParams<StellarAPIProvider> updateParams(
      {List<APIProvider>? updateProviders,
      Token? token,
      String? transactionExplorer,
      String? addressExplorer}) {
    return StellarNetworkParams(
        token: NetworkCoinParams.validateUpdateParams(
            token: this.token, updateToken: token),
        providers: updateProviders?.cast<StellarAPIProvider>() ?? providers,
        chainType: chainType,
        passphrase: passphrase,
        addressExplorer: addressExplorer,
        transactionExplorer: transactionExplorer);
  }
}
