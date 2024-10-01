import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/api/provider/provider.dart';

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
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.stellarNetworkParam);

    return StellarNetworkParams(
        transactionExplorer: cbor.elementAt(0),
        addressExplorer: cbor.elementAt(1),
        token: Token.fromCborBytesOrObject(obj: cbor.getCborTag(2)),
        providers: (cbor.elementAt(3) as List)
            .map((e) => StellarAPIProvider.fromCborBytesOrObject(obj: e))
            .toList(),
        mainnet: cbor.elementAt(4),
        passphrase: cbor.elementAt(5));
  }
  StellarNetworkParams(
      {required super.transactionExplorer,
      required super.addressExplorer,
      required super.token,
      required super.providers,
      required super.mainnet,
      required this.passphrase});

  StellarNetworkParams copyWith(
      {bool? mainnet,
      String? transactionExplorer,
      String? addressExplorer,
      Token? token,
      List<StellarAPIProvider>? providers,
      String? passphrase}) {
    return StellarNetworkParams(
        mainnet: mainnet ?? this.mainnet,
        transactionExplorer: transactionExplorer ?? this.transactionExplorer,
        addressExplorer: addressExplorer ?? this.addressExplorer,
        token: token ?? this.token,
        providers: providers ?? this.providers,
        passphrase: passphrase ?? this.passphrase);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          transactionExplorer,
          addressExplorer,
          token.toCbor(),
          CborListValue.fixedLength(providers.map((e) => e.toCbor()).toList()),
          mainnet,
          passphrase
        ]),
        CborTagsConst.stellarNetworkParam);
  }

  @override
  NetworkCoinParams<StellarAPIProvider> updateProviders(
      List<APIProvider> updateProviders) {
    return StellarNetworkParams(
        transactionExplorer: transactionExplorer,
        addressExplorer: addressExplorer,
        token: token,
        providers: updateProviders.cast<StellarAPIProvider>(),
        mainnet: mainnet,
        passphrase: passphrase);
  }
}
