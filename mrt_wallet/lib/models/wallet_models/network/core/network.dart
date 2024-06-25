import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_native_support/platform_interface.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/api/core/api_provider.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

class NetworkType {
  final String name;
  const NetworkType._(this.name);
  static const NetworkType bitcoinAndForked = NetworkType._("Bitcoin");
  static const NetworkType xrpl = NetworkType._("XRPL");
  static const NetworkType ethereum = NetworkType._("Ethereum");
  static const NetworkType tron = NetworkType._("Tron");
  static const NetworkType solana = NetworkType._("Solana");
  static const NetworkType cardano = NetworkType._("Cardano");
  static const NetworkType cosmos = NetworkType._("Cosmos");
  static const NetworkType ton = NetworkType._("TON");
}

abstract class AppNetworkImpl<PARAMS extends NetworkCoinParams>
    with Equatable, CborSerializable {
  const AppNetworkImpl();
  abstract final int value;
  abstract final PARAMS coinParam;
  abstract final NetworkType type;
  bool get supportCustomNode;
  List<CryptoCoins> get coins;
  List<EllipticCurveTypes> get keyTypes => [EllipticCurveTypes.secp256k1];

  T? getProvider<T extends ApiProviderService>(
      [ApiProviderService? selectProvider]) {
    final supportedProviders = coinParam.providers.whereType<T>().where(
        (element) =>
            element.protocol.platforms.contains(PlatformInterface.appPlatform));
    if (supportedProviders.isEmpty) return null;
    if (selectProvider == null) return supportedProviders.first;
    return MethodCaller.nullOnException(() {
      return coinParam.providers.whereType<T>().firstWhere((element) =>
          element.serviceName == selectProvider.serviceName &&
          element.protocol == selectProvider.protocol);
    });
  }

  T toNetwork<T extends AppNetworkImpl>() {
    if (this is! T) throw WalletExceptionConst.incorrectNetwork;
    return this as T;
  }

  static AppNetworkImpl fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final toCborTag = (obj ?? CborObject.fromCbor(bytes!)) as CborTagValue;

    if (BytesUtils.bytesEqual(
        toCborTag.tags, WalletModelCborTagsConst.bitconNetwork)) {
      return AppBitcoinNetwork.fromCborBytesOrObject(obj: toCborTag);
    }
    if (BytesUtils.bytesEqual(
        toCborTag.tags, WalletModelCborTagsConst.bitcoinCashNetwork)) {
      return AppBitcoinCashNetwork.fromCborBytesOrObject(obj: toCborTag);
    } else if (BytesUtils.bytesEqual(
        toCborTag.tags, WalletModelCborTagsConst.xrpNetwork)) {
      return AppXRPNetwork.fromCborBytesOrObject(obj: toCborTag);
    } else if (BytesUtils.bytesEqual(
        toCborTag.tags, WalletModelCborTagsConst.evmNetwork)) {
      return APPEVMNetwork.fromCborBytesOrObject(obj: toCborTag);
    } else if (BytesUtils.bytesEqual(
        toCborTag.tags, WalletModelCborTagsConst.solanaNetwork)) {
      return APPSolanaNetwork.fromCborBytesOrObject(obj: toCborTag);
    } else if (BytesUtils.bytesEqual(
        toCborTag.tags, WalletModelCborTagsConst.cardanoNetwork)) {
      return APPCardanoNetwork.fromCborBytesOrObject(obj: toCborTag);
    } else if (BytesUtils.bytesEqual(
        WalletModelCborTagsConst.cosmosNetwork, toCborTag.tags)) {
      return APPCosmosNetwork.fromCborBytesOrObject(obj: toCborTag);
    } else if (BytesUtils.bytesEqual(
        WalletModelCborTagsConst.tonNetwork, toCborTag.tags)) {
      return APPTonNetwork.fromCborBytesOrObject(obj: toCborTag);
    } else {
      return APPTVMNetwork.fromCborBytesOrObject(obj: toCborTag);
    }
  }

  Token get token => coinParam.token;

  int get coinDecimal => token.decimal!;

  AppNetworkImpl copyWith({int? value, PARAMS? coinParam});
}

class AppBitcoinNetwork extends AppNetworkImpl<BitcoinParams> {
  @override
  final int value;
  @override
  final BitcoinParams coinParam;

  factory AppBitcoinNetwork.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.bitconNetwork);
    return AppBitcoinNetwork(
      cbor.elementAt(0),
      BitcoinParams.fromCborBytesOrObject(obj: cbor.getCborTag(1)),
    );
  }

  const AppBitcoinNetwork(this.value, this.coinParam);

  bool get isBitcoin => true;

  @override
  NetworkType get type => NetworkType.bitcoinAndForked;

  @override
  List<CryptoCoins> get coins => coinParam.transacationNetwork.coins;

  CryptoCoins findCOinFromBitcoinAddressType(BitcoinAddressType type) {
    if (type.isP2sh) {
      return coins
          .firstWhere((element) => element.proposal == BipProposal.bip49);
    }
    switch (type) {
      case P2pkhAddressType.p2pkh:
      case P2pkhAddressType.p2pkhwt:
      case PubKeyAddressType.p2pk:
        return coins
            .firstWhere((element) => element.proposal == BipProposal.bip44);
      case SegwitAddresType.p2wsh:
      case SegwitAddresType.p2wpkh:
        return coins
            .firstWhere((element) => element.proposal == BipProposal.bip84);
      default:
        return coins
            .firstWhere((element) => element.proposal == BipProposal.bip86);
    }
  }

  @override
  List get variabels => [value];

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([value, coinParam.toCbor()]),
        WalletModelCborTagsConst.bitconNetwork);
  }

  @override
  bool get supportCustomNode => true;

  @override
  AppBitcoinNetwork copyWith({int? value, BitcoinParams? coinParam}) {
    return AppBitcoinNetwork(value ?? this.value, coinParam ?? this.coinParam);
  }
}

class AppBitcoinCashNetwork extends AppBitcoinNetwork {
  @override
  AppBitcoinCashNetwork copyWith({int? value, BitcoinParams? coinParam}) {
    return AppBitcoinCashNetwork(
        value ?? this.value, coinParam ?? this.coinParam);
  }

  const AppBitcoinCashNetwork(super.value, super.coinParam);
  @override
  bool get isBitcoin => false;

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([value, coinParam.toCbor()]),
        WalletModelCborTagsConst.bitcoinCashNetwork);
  }

  factory AppBitcoinCashNetwork.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.bitcoinCashNetwork);
    return AppBitcoinCashNetwork(
      cbor.elementAt(0),
      BitcoinParams.fromCborBytesOrObject(obj: cbor.getCborTag(1)),
    );
  }
}

class AppXRPNetwork extends AppNetworkImpl<RippleNetworkParams> {
  @override
  final int value;
  @override
  final RippleNetworkParams coinParam;

  const AppXRPNetwork(this.value, this.coinParam);
  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([value, coinParam.toCbor()]),
        WalletModelCborTagsConst.xrpNetwork);
  }

  factory AppXRPNetwork.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.xrpNetwork);
    return AppXRPNetwork(
      cbor.elementAt(0),
      RippleNetworkParams.fromCborBytesOrObject(obj: cbor.getCborTag(1)),
    );
  }

  @override
  List<CryptoCoins> get coins {
    if (coinParam.mainnet) {
      return [Bip44Coins.ripple, Bip44Coins.rippleEd25519];
    }
    return [Bip44Coins.rippleTestnet, Bip44Coins.rippleTestnetED25519];
  }

  @override
  List<EllipticCurveTypes> get keyTypes =>
      [EllipticCurveTypes.secp256k1, EllipticCurveTypes.ed25519];

  @override
  List get variabels => [value];

  @override
  bool get supportCustomNode => false;

  @override
  NetworkType get type => NetworkType.xrpl;

  @override
  AppXRPNetwork copyWith({int? value, RippleNetworkParams? coinParam}) {
    return AppXRPNetwork(value ?? this.value, coinParam ?? this.coinParam);
  }
}
//

class APPEVMNetwork extends AppNetworkImpl<EVMNetworkParams> {
  @override
  final int value;
  @override
  final EVMNetworkParams coinParam;
  final int? slip44;

  const APPEVMNetwork(this.value, this.coinParam, {this.slip44});
  factory APPEVMNetwork.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.evmNetwork);
    return APPEVMNetwork(cbor.elementAt(0),
        EVMNetworkParams.fromCborBytesOrObject(obj: cbor.getCborTag(1)),
        slip44: cbor.elementAt(2));
  }
  @override
  APPEVMNetwork copyWith(
      {int? value, EVMNetworkParams? coinParam, int? slip44}) {
    return APPEVMNetwork(value ?? this.value, coinParam ?? this.coinParam,
        slip44: slip44 ?? this.slip44);
  }

  @override
  List<CryptoCoins> get coins {
    if (coinParam.mainnet) {
      return [Bip44Coins.ethereum];
    }
    return [Bip44Coins.ethereumTestnet];
  }

  @override
  List get variabels => [value];

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([value, coinParam.toCbor(), slip44]),
        WalletModelCborTagsConst.evmNetwork);
  }

  @override
  bool get supportCustomNode => true;
  @override
  NetworkType get type => NetworkType.ethereum;
}

class APPTVMNetwork extends AppNetworkImpl<TVMNetworkParams> {
  @override
  final int value;
  @override
  final TVMNetworkParams coinParam;
  const APPTVMNetwork(this.value, this.coinParam);

  factory APPTVMNetwork.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.tvmNetwork);
    return APPTVMNetwork(
      cbor.elementAt(0),
      TVMNetworkParams.fromCborBytesOrObject(obj: cbor.getCborTag(1)),
    );
  }
  @override
  List<CryptoCoins> get coins {
    if (coinParam.mainnet) {
      return [Bip44Coins.tron];
    }
    return [Bip44Coins.tronTestnet];
  }

  @override
  List get variabels => [value];
  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([value, coinParam.toCbor()]),
        WalletModelCborTagsConst.tvmNetwork);
  }

  @override
  bool get supportCustomNode => false;

  @override
  NetworkType get type => NetworkType.tron;

  @override
  APPTVMNetwork copyWith({int? value, TVMNetworkParams? coinParam}) {
    return APPTVMNetwork(value ?? this.value, coinParam ?? this.coinParam);
  }
}

class APPSolanaNetwork extends AppNetworkImpl<SolanaNetworkParams> {
  @override
  final int value;
  @override
  final SolanaNetworkParams coinParam;
  const APPSolanaNetwork(this.value, this.coinParam);
  factory APPSolanaNetwork.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.solanaNetwork);
    return APPSolanaNetwork(
      cbor.elementAt(0),
      SolanaNetworkParams.fromCborBytesOrObject(obj: cbor.getCborTag(1)),
    );
  }
  @override
  APPSolanaNetwork copyWith({int? value, SolanaNetworkParams? coinParam}) {
    return APPSolanaNetwork(value ?? this.value, coinParam ?? this.coinParam);
  }

  @override
  List<CryptoCoins> get coins {
    if (coinParam.mainnet) {
      return [Bip44Coins.solana];
    }
    return [Bip44Coins.solanaTestnet];
  }

  @override
  List get variabels => [value];
  @override
  List<EllipticCurveTypes> get keyTypes => [EllipticCurveTypes.ed25519];

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([value, coinParam.toCbor()]),
        WalletModelCborTagsConst.solanaNetwork);
  }

  @override
  bool get supportCustomNode => true;

  @override
  NetworkType get type => NetworkType.solana;
}

class APPCardanoNetwork extends AppNetworkImpl<CardanoNetworkParams> {
  @override
  final int value;
  @override
  final CardanoNetworkParams coinParam;
  const APPCardanoNetwork(this.value, this.coinParam);
  factory APPCardanoNetwork.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.cardanoNetwork);
    return APPCardanoNetwork(
      cbor.elementAt(0),
      CardanoNetworkParams.fromCborBytesOrObject(obj: cbor.getCborTag(1)),
    );
  }

  ADANetwork get toCardanoNetwork =>
      coinParam.mainnet ? ADANetwork.mainnet : ADANetwork.testnetPreprod;

  @override
  List<CryptoCoins> get coins {
    return [
      if (coinParam.mainnet) ...[
        Bip44Coins.cardanoByronLedger,
        Bip44Coins.cardanoByronIcarus,
        Cip1852Coins.cardanoIcarus,
        Cip1852Coins.cardanoLedger,
        CustomCoins.byronLegacy
      ] else ...[
        Bip44Coins.cardanoByronIcarusTestnet,
        Bip44Coins.cardanoByronLedgerTestnet,
        Cip1852Coins.cardanoIcarusTestnet,
        Cip1852Coins.cardanoLedgerTestnet,
        CustomCoins.byronLegacyTestnet
      ]
    ];
  }

  @override
  List get variabels => [value];
  @override
  List<EllipticCurveTypes> get keyTypes => [EllipticCurveTypes.ed25519Kholaw];

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([value, coinParam.toCbor()]),
        WalletModelCborTagsConst.cardanoNetwork);
  }

  @override
  bool get supportCustomNode => false;

  @override
  NetworkType get type => NetworkType.cardano;

  @override
  APPCardanoNetwork copyWith({int? value, CardanoNetworkParams? coinParam}) {
    return APPCardanoNetwork(value ?? this.value, coinParam ?? this.coinParam);
  }
}

class APPCosmosNetwork extends AppNetworkImpl<CosmosNetworkParams> {
  @override
  final int value;
  @override
  final CosmosNetworkParams coinParam;
  const APPCosmosNetwork(this.value, this.coinParam);
  factory APPCosmosNetwork.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.cosmosNetwork);
    return APPCosmosNetwork(
      cbor.elementAt(0),
      CosmosNetworkParams.fromCborBytesOrObject(obj: cbor.getCborTag(1)),
    );
  }

  @override
  List<CryptoCoins> get coins {
    if (coinParam.mainnet) {
      return [Bip44Coins.cosmos];
    }
    return [Bip44Coins.cosmosTestnet];
  }

  @override
  List get variabels => [value];
  @override
  List<EllipticCurveTypes> get keyTypes => [EllipticCurveTypes.secp256k1];

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([value, coinParam.toCbor()]),
        WalletModelCborTagsConst.cosmosNetwork);
  }

  @override
  bool get supportCustomNode => false;

  @override
  NetworkType get type => NetworkType.cosmos;

  @override
  APPCosmosNetwork copyWith({int? value, CosmosNetworkParams? coinParam}) {
    return APPCosmosNetwork(value ?? this.value, coinParam ?? this.coinParam);
  }
}

class APPTonNetwork extends AppNetworkImpl<TonNetworkParams> {
  @override
  final int value;
  @override
  final TonNetworkParams coinParam;

  const APPTonNetwork(this.value, this.coinParam);
  factory APPTonNetwork.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.tonNetwork);
    return APPTonNetwork(
      cbor.elementAt(0),
      TonNetworkParams.fromCborBytesOrObject(obj: cbor.getCborTag(1)),
    );
  }

  @override
  List<CryptoCoins> get coins {
    if (coinParam.mainnet) {
      return [Bip44Coins.tonMainnet];
    }
    return [Bip44Coins.tonTestnet];
  }

  @override
  List get variabels => [value];
  @override
  List<EllipticCurveTypes> get keyTypes => [EllipticCurveTypes.ed25519];

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([value, coinParam.toCbor()]),
        WalletModelCborTagsConst.tonNetwork);
  }

  @override
  bool get supportCustomNode => false;
  @override
  NetworkType get type => NetworkType.ton;

  @override
  APPTonNetwork copyWith({int? value, TonNetworkParams? coinParam}) {
    return APPTonNetwork(value ?? this.value, coinParam ?? this.coinParam);
  }
}
