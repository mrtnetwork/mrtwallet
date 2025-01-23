import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/substrate.dart';
import 'package:mrt_wallet/wallet/models/network/core/params/params.dart';
import 'package:mrt_wallet/wallet/models/networks/substrate/substrate.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:blockchain_utils/bip/bip.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class SubstrateNetworkParams extends NetworkCoinParams<SubstrateAPIProvider> {
  final int ss58Format;
  final int specVersion;
  final String? gnesisBlock;
  final SubstrateChainType substrateChainType;

  final List<SubstrateKeyAlgorithm> keyAlgorithms;

  factory SubstrateNetworkParams.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: obj,
        tags: CborTagsConst.substrateNetworkParams);

    return SubstrateNetworkParams(
        token: Token.fromCborBytesOrObject(obj: values.getCborTag(2)),
        providers: values
            .elementAsListOf<CborTagValue>(3)
            .map((e) => SubstrateAPIProvider.fromCborBytesOrObject(obj: e))
            .toList(),
        chainType: ChainType.fromValue(values.elementAs(4)),
        ss58Format: values.elementAs(5),
        substrateChainType: SubstrateChainType.fromValue(values.elementAs(8)),
        gnesisBlock: values.elementAs(9),
        bip32CoinType: values.elementAs(10),
        addressExplorer: values.elementAs(11),
        transactionExplorer: values.elementAs(12),
        keyAlgorithms: values
            .elementAsListOf<CborIntValue>(13)
            .map((e) => SubstrateKeyAlgorithm.fromValue(e.value))
            .toList(),
        specVersion: values.elementAs(14));
  }
  SubstrateNetworkParams(
      {required super.token,
      required super.providers,
      required super.chainType,
      required this.ss58Format,
      required this.specVersion,
      this.gnesisBlock,
      required this.substrateChainType,
      super.bip32CoinType,
      super.addressExplorer,
      super.transactionExplorer,
      this.keyAlgorithms = const [
        SubstrateKeyAlgorithm.ecdsa,
        SubstrateKeyAlgorithm.sr25519,
        SubstrateKeyAlgorithm.ed25519
      ]});

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          const CborNullValue(),
          const CborNullValue(),
          token.toCbor(),
          CborListValue.fixedLength(providers.map((e) => e.toCbor()).toList()),
          chainType.name,
          ss58Format,
          const CborNullValue(),
          const CborNullValue(),
          substrateChainType.value,
          gnesisBlock,
          bip32CoinType,
          addressExplorer,
          transactionExplorer,
          CborListValue.fixedLength(keyAlgorithms.map((e) => e.value).toList()),
          specVersion
        ]),
        CborTagsConst.substrateNetworkParams);
  }

  @override
  NetworkCoinParams<SubstrateAPIProvider> updateParams(
      {List<APIProvider>? updateProviders,
      Token? token,
      String? transactionExplorer,
      String? addressExplorer}) {
    return SubstrateNetworkParams(
        token: NetworkCoinParams.validateUpdateParams(
            token: this.token, updateToken: token),
        addressExplorer: addressExplorer,
        transactionExplorer: transactionExplorer,
        providers: updateProviders?.cast<SubstrateAPIProvider>() ?? providers,
        chainType: chainType,
        ss58Format: ss58Format,
        gnesisBlock: gnesisBlock,
        substrateChainType: substrateChainType,
        bip32CoinType: bip32CoinType,
        keyAlgorithms: keyAlgorithms,
        specVersion: specVersion);
  }

  SubstrateNetworkParams updateSpecVersion(int specVersion) {
    // if (specVersion.isNegative || specVersion < this.specVersion) {
    //   throw WalletException("invalid_spec_version");
    // }
    return SubstrateNetworkParams(
        token: token,
        providers: providers,
        chainType: chainType,
        ss58Format: ss58Format,
        specVersion: specVersion,
        substrateChainType: substrateChainType,
        addressExplorer: addressExplorer,
        bip32CoinType: bip32CoinType,
        gnesisBlock: gnesisBlock,
        keyAlgorithms: keyAlgorithms,
        transactionExplorer: transactionExplorer);
  }
}
