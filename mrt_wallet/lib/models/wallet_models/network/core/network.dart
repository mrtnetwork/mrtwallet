import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/provider/api/core/api_provider.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

abstract class AppNetworkImpl with Equatable, CborSerializable {
  abstract final int value;
  abstract final NetworkCoinParams coinParam;
  List<CryptoCoins> get coins;
  List<EllipticCurveTypes> get keyTypes;

  ApiProviderService getProvider([String? selectProvider]);

  T toNetwork<T extends AppNetworkImpl>() => this as T;

  factory AppNetworkImpl.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final toCborTag = (obj ?? CborObject.fromCbor(bytes!)) as CborTagValue;
    if (bytesEqual(toCborTag.tags, WalletModelCborTagsConst.bitconNetwork)) {
      return AppBitcoinNetwork.fromCborBytesOrObject(obj: toCborTag);
    } else if (bytesEqual(
        toCborTag.tags, WalletModelCborTagsConst.xrpNetwork)) {
      return AppXRPNetwork.fromCborBytesOrObject(obj: toCborTag);
    } else if (bytesEqual(
        toCborTag.tags, WalletModelCborTagsConst.evmNetwork)) {
      return APPEVMNetwork.fromCborBytesOrObject(obj: toCborTag);
    } else {
      return APPTVMNetwork.fromCborBytesOrObject(obj: toCborTag);
    }
  }
}

class AppBitcoinNetwork implements AppNetworkImpl {
  @override
  T toNetwork<T extends AppNetworkImpl>() => this as T;
  @override
  final int value;
  @override
  final BitcoinParams coinParam;

  @override
  ApiProviderService getProvider([String? selectProvider]) {
    return coinParam.providers.firstWhere(
      (element) => element.serviceName == selectProvider,
      orElse: () => coinParam.providers[0],
    );
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
      case 2:
        return [Bip44Coins.litecoin, Bip49Coins.litecoin, Bip84Coins.litecoin];
      case 3:
        return [Bip44Coins.dogecoin, Bip49Coins.dogecoin];
      case 4:
        return [Bip44Coins.dash, Bip49Coins.dash];
      default:
        throw UnimplementedError();
    }
  }

  CryptoCoins findCOinFromBitcoinAddressType(BitcoinAddressType type) {
    switch (type) {
      case BitcoinAddressType.p2pkh:
      case BitcoinAddressType.p2pk:
        return coins
            .firstWhere((element) => element.proposal == BipProposal.bip44);
      case BitcoinAddressType.p2wsh:
      case BitcoinAddressType.p2wpkh:
        return coins
            .firstWhere((element) => element.proposal == BipProposal.bip84);
      case BitcoinAddressType.p2pkInP2sh:
      case BitcoinAddressType.p2pkhInP2sh:
      case BitcoinAddressType.p2wpkhInP2sh:
      case BitcoinAddressType.p2wshInP2sh:
        return coins
            .firstWhere((element) => element.proposal == BipProposal.bip49);
      default:
        return coins
            .firstWhere((element) => element.proposal == BipProposal.bip86);
    }
  }

  @override
  List<EllipticCurveTypes> get keyTypes => [EllipticCurveTypes.secp256k1];

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
      cbor.getIndex(0),
      BitcoinParams.fromCborBytesOrObject(obj: cbor.getCborTag(1)),
    );
  }
}

class AppXRPNetwork implements AppNetworkImpl {
  @override
  T toNetwork<T extends AppNetworkImpl>() => this as T;
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
      cbor.getIndex(0),
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
  ApiProviderService getProvider([String? selectProvider]) {
    return coinParam.providers.firstWhere(
      (element) => element.serviceName == selectProvider,
      orElse: () => coinParam.providers[0],
    );
  }

  @override
  List<EllipticCurveTypes> get keyTypes =>
      [EllipticCurveTypes.secp256k1, EllipticCurveTypes.ed25519];

  @override
  List get variabels => [value];
}
//

class APPEVMNetwork with CborSerializable implements AppNetworkImpl {
  APPEVMNetwork copyWith(
      {int? value, EVMNetworkParams? coinParam, int? slip44}) {
    return APPEVMNetwork(value ?? this.value, coinParam ?? this.coinParam,
        slip44: slip44 ?? this.slip44);
  }

  @override
  T toNetwork<T extends AppNetworkImpl>() => this as T;
  const APPEVMNetwork(this.value, this.coinParam, {this.slip44});
  factory APPEVMNetwork.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor = CborSerializable.decodeCborTags(
        bytes, obj, WalletModelCborTagsConst.evmNetwork);
    return APPEVMNetwork(cbor.getIndex(0),
        EVMNetworkParams.fromCborBytesOrObject(obj: cbor.getCborTag(1)),
        slip44: cbor.getIndex(2));
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
  ApiProviderService getProvider([String? selectProvider]) {
    return coinParam.providers.firstWhere(
      (element) => element.serviceName == selectProvider,
      orElse: () => coinParam.providers[0],
    );
  }

  @override
  List<EllipticCurveTypes> get keyTypes => [EllipticCurveTypes.secp256k1];

  @override
  List get variabels => [value];

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([value, coinParam.toCbor(), slip44]),
        WalletModelCborTagsConst.evmNetwork);
  }
}

class APPTVMNetwork implements AppNetworkImpl {
  @override
  T toNetwork<T extends AppNetworkImpl>() => this as T;
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
  ApiProviderService getProvider([String? selectProvider]) {
    return coinParam.providers.firstWhere(
      (element) => element.serviceName == selectProvider,
      orElse: () => coinParam.providers[0],
    );
  }

  @override
  List<EllipticCurveTypes> get keyTypes => [EllipticCurveTypes.secp256k1];

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
      cbor.getIndex(0),
      TVMNetworkParams.fromCborBytesOrObject(obj: cbor.getCborTag(1)),
    );
  }
}
