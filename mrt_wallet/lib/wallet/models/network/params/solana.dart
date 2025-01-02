import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/error/exception.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/api/provider/provider.dart';

import 'package:mrt_wallet/wallet/models/network/core/params/params.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:blockchain_utils/bip/bip.dart';

enum SolanaNetworkType {
  mainnet('solana:mainnet', 0),
  testnet('solana:testnet', 1),
  devnet('solana:devnet', 2);

  final String walletStandardChainName;
  final int value;
  const SolanaNetworkType(this.walletStandardChainName, this.value);
  static SolanaNetworkType fromValue(int? value) {
    return values.firstWhere((e) => e.value == value,
        orElse: () => throw WalletExceptionConst.invalidData(
            messsage: 'Solana network type not found.'));
  }
}

class SolanaNetworkParams extends NetworkCoinParams<SolanaAPIProvider> {
  final String genesis;
  final int chainId;
  final SolanaNetworkType type;

  factory SolanaNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.solNetworkParam);

    return SolanaNetworkParams(
        transactionExplorer: values.elementAs(0),
        addressExplorer: values.elementAs(1),
        token: Token.fromCborBytesOrObject(obj: values.getCborTag(2)),
        providers: values
            .elementAsListOf<CborTagValue>(3)
            .map((e) => SolanaAPIProvider.fromCborBytesOrObject(obj: e))
            .toList(),
        chainType: ChainType.fromValue(values.elementAs(4)),
        genesis: values.elementAs(5),
        chainId: values.elementAs(6),
        type: SolanaNetworkType.fromValue(values.elementAs(7)));
  }
  SolanaNetworkParams(
      {required super.transactionExplorer,
      required super.addressExplorer,
      required super.token,
      required super.providers,
      required super.chainType,
      required this.genesis,
      required this.chainId,
      required this.type});

  SolanaNetworkParams copyWith({
    ChainType? chainType,
    String? transactionExplorer,
    String? addressExplorer,
    Token? token,
    List<SolanaAPIProvider>? providers,
    String? genesis,
    int? chainId,
    SolanaNetworkType? type,
  }) {
    return SolanaNetworkParams(
        chainType: chainType ?? this.chainType,
        transactionExplorer: transactionExplorer ?? this.transactionExplorer,
        addressExplorer: addressExplorer ?? this.addressExplorer,
        token: token ?? this.token,
        providers: providers ?? this.providers,
        genesis: genesis ?? this.genesis,
        chainId: chainId ?? this.chainId,
        type: type ?? this.type);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          transactionExplorer,
          addressExplorer,
          token.toCbor(),
          CborListValue.fixedLength(providers.map((e) => e.toCbor()).toList()),
          chainType.name,
          genesis,
          chainId,
          type.value
        ]),
        CborTagsConst.solNetworkParam);
  }

  @override
  NetworkCoinParams<SolanaAPIProvider> updateProviders(
      List<APIProvider> updateProviders) {
    return SolanaNetworkParams(
        transactionExplorer: transactionExplorer,
        addressExplorer: addressExplorer,
        token: token,
        providers: updateProviders.cast<SolanaAPIProvider>(),
        chainType: chainType,
        genesis: genesis,
        chainId: chainId,
        type: type);
  }

  @override
  String get identifier => genesis;
}
