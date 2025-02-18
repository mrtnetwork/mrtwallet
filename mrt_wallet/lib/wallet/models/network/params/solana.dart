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
  final int chainId;
  final SolanaNetworkType type;

  factory SolanaNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.decodeCborTags(
        bytes, obj, CborTagsConst.solNetworkParam);

    return SolanaNetworkParams(
        token: Token.fromCborBytesOrObject(obj: values.getCborTag(2)),
        providers: values
            .elementAsListOf<CborTagValue>(3)
            .map((e) => SolanaAPIProvider.fromCborBytesOrObject(obj: e))
            .toList(),
        chainType: ChainType.fromValue(values.elementAs(4)),
        chainId: values.elementAs(6),
        type: SolanaNetworkType.fromValue(values.elementAs(7)),
        addressExplorer: values.elementAs(8),
        transactionExplorer: values.elementAs(9));
  }
  SolanaNetworkParams(
      {required super.token,
      required super.providers,
      required super.chainType,
      required this.chainId,
      required this.type,
      super.addressExplorer,
      super.transactionExplorer});

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
          chainId,
          type.value,
          addressExplorer,
          transactionExplorer
        ]),
        CborTagsConst.solNetworkParam);
  }

  @override
  NetworkCoinParams<SolanaAPIProvider> updateParams(
      {List<APIProvider>? updateProviders,
      Token? token,
      String? transactionExplorer,
      String? addressExplorer,
      int? bip32CoinType}) {
    return SolanaNetworkParams(
        token: NetworkCoinParams.validateUpdateParams(
            token: this.token, updateToken: token),
        providers: updateProviders?.cast<SolanaAPIProvider>() ?? providers,
        chainType: chainType,
        chainId: chainId,
        type: type,
        addressExplorer: addressExplorer,
        transactionExplorer: transactionExplorer);
  }
}
