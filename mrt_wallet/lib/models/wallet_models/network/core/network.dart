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

abstract class AppNetworkImpl with Equatable, CborSerializable {
  const AppNetworkImpl();
  abstract final int value;
  abstract final NetworkCoinParams coinParam;
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

  T toNetwork<T extends AppNetworkImpl>() => this as T;

  factory AppNetworkImpl.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final toCborTag = (obj ?? CborObject.fromCbor(bytes!)) as CborTagValue;

    if (bytesEqual(toCborTag.tags, WalletModelCborTagsConst.bitconNetwork)) {
      return AppBitcoinNetwork.fromCborBytesOrObject(obj: toCborTag);
    }
    if (bytesEqual(
        toCborTag.tags, WalletModelCborTagsConst.bitcoinCashNetwork)) {
      return AppBitcoinCashNetwork.fromCborBytesOrObject(obj: toCborTag);
    } else if (bytesEqual(
        toCborTag.tags, WalletModelCborTagsConst.xrpNetwork)) {
      return AppXRPNetwork.fromCborBytesOrObject(obj: toCborTag);
    } else if (bytesEqual(
        toCborTag.tags, WalletModelCborTagsConst.evmNetwork)) {
      return APPEVMNetwork.fromCborBytesOrObject(obj: toCborTag);
    } else if (bytesEqual(
        toCborTag.tags, WalletModelCborTagsConst.solanaNetwork)) {
      return APPSolanaNetwork.fromCborBytesOrObject(obj: toCborTag);
    } else if (bytesEqual(
        toCborTag.tags, WalletModelCborTagsConst.cardanoNetwork)) {
      return APPCardanoNetwork.fromCborBytesOrObject(obj: toCborTag);
    } else if (bytesEqual(
        WalletModelCborTagsConst.cosmosNetwork, toCborTag.tags)) {
      return APPCosmosNetwork.fromCborBytesOrObject(obj: toCborTag);
    } else {
      return APPTVMNetwork.fromCborBytesOrObject(obj: toCborTag);
    }
  }
}

class AppBitcoinNetwork extends AppNetworkImpl {
  @override
  final int value;
  @override
  final BitcoinParams coinParam;
  AppBitcoinNetwork copyWith({int? value, BitcoinParams? coinParam}) {
    return AppBitcoinNetwork(value ?? this.value, coinParam ?? this.coinParam);
  }

  const AppBitcoinNetwork(this.value, this.coinParam);
  bool get isBitcoin => true;

  @override
  List<CryptoCoins> get coins {
    switch (value) {
      case 0:
        return [
          Bip44Coins.bitcoin,
          Bip49Coins.bitcoin,
          Bip84Coins.bitcoin,
          Bip86Coins.bitcoin,
        ];
      case 1:
        return [
          Bip44Coins.bitcoinTestnet,
          Bip49Coins.bitcoinTestnet,
          Bip84Coins.bitcoinTestnet,
          Bip86Coins.bitcoinTestnet,
        ];
      case 10:
        return [
          Bip44Coins.bitcoinCash,
          Bip49Coins.bitcoinCash,
        ];
      case 11:
        return [
          Bip44Coins.bitcoinCashTestnet,
          Bip49Coins.bitcoinCashTestnet,
        ];
      case 2:
        return [Bip44Coins.litecoin, Bip49Coins.litecoin, Bip84Coins.litecoin];
      case 7:
        return [
          Bip44Coins.litecoinTestnet,
          Bip49Coins.litecoinTestnet,
          Bip84Coins.litecoinTestnet
        ];
      case 3:
        return [Bip44Coins.dogecoin, Bip49Coins.dogecoin];
      case 8:
        return [Bip44Coins.dogecoinTestnet, Bip49Coins.dogecoinTestnet];
      case 9:
        return [Bip44Coins.bitcoinSv];
      case 4:
        return [Bip44Coins.dash, Bip49Coins.dash];
      default:
        throw UnimplementedError();
    }
  }

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

  factory AppBitcoinNetwork.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.bitconNetwork);
    return AppBitcoinNetwork(
      cbor.elementAt(0),
      BitcoinParams.fromCborBytesOrObject(obj: cbor.getCborTag(1)),
    );
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

class AppXRPNetwork extends AppNetworkImpl {
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
  final int value;
  @override
  final RippleNetworkParams coinParam;

  bool get isMainnet => value == 30;

  @override
  List<CryptoCoins> get coins {
    if (isMainnet) {
      return [Bip44Coins.ripple, Bip44Coins.rippleEd25519];
    }
    return [Bip44Coins.rippleTestnet, Bip44Coins.rippleEd25519];
  }

  @override
  List<EllipticCurveTypes> get keyTypes =>
      [EllipticCurveTypes.secp256k1, EllipticCurveTypes.ed25519];

  @override
  List get variabels => [value];
}
//

class APPEVMNetwork extends AppNetworkImpl {
  APPEVMNetwork copyWith(
      {int? value, EVMNetworkParams? coinParam, int? slip44}) {
    return APPEVMNetwork(value ?? this.value, coinParam ?? this.coinParam,
        slip44: slip44 ?? this.slip44);
  }

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
  final int value;
  @override
  final EVMNetworkParams coinParam;
  final int? slip44;

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
}

class APPTVMNetwork extends AppNetworkImpl {
  const APPTVMNetwork(this.value, this.coinParam);
  @override
  final int value;
  @override
  final TVMNetworkParams coinParam;

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
    return CborTagValue(CborListValue.fixedLength([value, coinParam.toCbor()]),
        WalletModelCborTagsConst.tvmNetwork);
  }

  factory APPTVMNetwork.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.tvmNetwork);
    return APPTVMNetwork(
      cbor.elementAt(0),
      TVMNetworkParams.fromCborBytesOrObject(obj: cbor.getCborTag(1)),
    );
  }
}

class APPSolanaNetwork extends AppNetworkImpl {
  const APPSolanaNetwork(this.value, this.coinParam);
  @override
  final int value;
  @override
  final SolanaNetworkParams coinParam;

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

  factory APPSolanaNetwork.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.solanaNetwork);
    return APPSolanaNetwork(
      cbor.elementAt(0),
      SolanaNetworkParams.fromCborBytesOrObject(obj: cbor.getCborTag(1)),
    );
  }
}

class APPCardanoNetwork extends AppNetworkImpl {
  const APPCardanoNetwork(this.value, this.coinParam);
  @override
  final int value;
  @override
  final CardanoNetworkParams coinParam;

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
      ] else ...[
        Bip44Coins.cardanoByronIcarusTestnet,
        Bip44Coins.cardanoByronLedgerTestnet,
        Cip1852Coins.cardanoIcarusTestnet,
        Cip1852Coins.cardanoLedgerTestnet,
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

  factory APPCardanoNetwork.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.cardanoNetwork);
    return APPCardanoNetwork(
      cbor.elementAt(0),
      CardanoNetworkParams.fromCborBytesOrObject(obj: cbor.getCborTag(1)),
    );
  }
}

class APPCosmosNetwork extends AppNetworkImpl {
  const APPCosmosNetwork(this.value, this.coinParam);
  @override
  final int value;
  @override
  final CosmosNetworkParams coinParam;

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

  factory APPCosmosNetwork.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.cosmosNetwork);
    return APPCosmosNetwork(
      cbor.elementAt(0),
      CosmosNetworkParams.fromCborBytesOrObject(obj: cbor.getCborTag(1)),
    );
  }
}
