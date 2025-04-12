import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart'
    show WalletExceptionConst;
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/api/provider/provider.dart';
import 'package:blockchain_utils/bip/bip.dart';
import 'package:mrt_wallet/wallet/models/network/core/params/params.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:stellar_dart/stellar_dart.dart';

enum StellarChainType {
  testnet(1),
  mainnet(2);

  const StellarChainType(this.value);
  final int value;
  String get identifier => "stellar:$name";
  static StellarChainType fromValue(int? value) {
    return values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw WalletExceptionConst.invalidData(
          messsage: "StellarChainType not found."),
    );
  }

  List<int> get passphraseHash {
    return switch (this) {
      testnet => StellarNetwork.testnet.passphraseHash,
      mainnet => StellarNetwork.mainnet.passphraseHash
    };
  }

  String get passphrase {
    return switch (this) {
      testnet => StellarNetwork.testnet.passphrase,
      mainnet => StellarNetwork.mainnet.passphrase
    };
  }
}

class StellarNetworkParams extends NetworkCoinParams<StellarAPIProvider> {
  final StellarChainType stellarChainType;

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
        stellarChainType: StellarChainType.fromValue(values.elementAs(8)),
        addressExplorer: values.elementAs(6),
        transactionExplorer: values.elementAs(7));
  }
  StellarNetworkParams(
      {required super.token,
      required super.providers,
      required super.chainType,
      required this.stellarChainType,
      super.addressExplorer,
      super.transactionExplorer});

  StellarNetworkParams copyWith(
      {ChainType? chainType,
      String? transactionExplorer,
      String? addressExplorer,
      Token? token,
      List<StellarAPIProvider>? providers,
      StellarChainType? stellarChainType}) {
    return StellarNetworkParams(
        chainType: chainType ?? this.chainType,
        token: token ?? this.token,
        providers: providers ?? this.providers,
        stellarChainType: stellarChainType ?? this.stellarChainType);
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
          const CborNullValue(),
          addressExplorer,
          transactionExplorer,
          stellarChainType.value
        ]),
        CborTagsConst.stellarNetworkParam);
  }

  StellarChainType get identifier => stellarChainType;

  @override
  NetworkCoinParams<StellarAPIProvider> updateParams(
      {List<APIProvider>? updateProviders,
      Token? token,
      String? transactionExplorer,
      String? addressExplorer,
      int? bip32CoinType}) {
    return StellarNetworkParams(
        token: NetworkCoinParams.validateUpdateParams(
            token: this.token, updateToken: token),
        providers: updateProviders?.cast<StellarAPIProvider>() ?? providers,
        chainType: chainType,
        stellarChainType: stellarChainType,
        addressExplorer: addressExplorer,
        transactionExplorer: transactionExplorer);
  }
}
