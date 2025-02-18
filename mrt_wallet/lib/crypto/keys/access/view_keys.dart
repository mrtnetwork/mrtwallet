import 'package:blockchain_utils/bip/ecc/curve/elliptic_curve_types.dart';
import 'package:blockchain_utils/utils/utils.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';

import 'key_data.dart';

class PublicKeysView {
  final String? extendKey;
  final String comprossed;
  final String? uncomprossed;
  final String? chainCode;
  final String keyName;
  final CryptoPublicKeyDataType keyType;
  const PublicKeysView(
      {required this.extendKey,
      required this.comprossed,
      required this.uncomprossed,
      required this.chainCode,
      required this.keyName,
      required this.keyType});

  PublicKeysView copyWith(
      {String? extendKey,
      String? comprossed,
      String? uncomprossed,
      String? chainCode,
      String? keyName}) {
    return PublicKeysView(
        extendKey: extendKey ?? this.extendKey,
        comprossed: comprossed ?? this.comprossed,
        uncomprossed: uncomprossed ?? this.uncomprossed,
        chainCode: chainCode ?? this.chainCode,
        keyName: keyName ?? this.keyName,
        keyType: keyType);
  }

  T cast<T extends PublicKeysView>() {
    if (this is! T) {
      throw WalletException.invalidArgruments(["$T", runtimeType.toString()]);
    }
    return this as T;
  }
}

class MoneroPublicKeysView extends PublicKeysView {
  final String spendPublicKey;
  final String viewPublicKey;
  MoneroPublicKeysView(
      {required super.extendKey,
      required super.comprossed,
      required super.uncomprossed,
      required this.spendPublicKey,
      required this.viewPublicKey,
      required super.chainCode,
      required super.keyName,
      required super.keyType});
  @override
  MoneroPublicKeysView copyWith({
    String? extendKey,
    String? comprossed,
    String? uncomprossed,
    String? chainCode,
    String? spendPublicKey,
    String? viewPublicKey,
    String? keyName,
  }) {
    return MoneroPublicKeysView(
        extendKey: extendKey ?? this.extendKey,
        comprossed: comprossed ?? this.comprossed,
        uncomprossed: uncomprossed ?? this.uncomprossed,
        chainCode: chainCode ?? this.chainCode,
        spendPublicKey: spendPublicKey ?? this.spendPublicKey,
        viewPublicKey: viewPublicKey ?? this.viewPublicKey,
        keyName: keyName ?? this.keyName,
        keyType: keyType);
  }
}

class PrivateKeysView {
  final String? extendKey;
  final String privateKey;
  final String? wif;
  final String keyName;
  final String? inNetworkStyle;
  final CryptoPrivateKeyDataType keyType;
  final EllipticCurveTypes curve;
  List<int> privateKeyBytes() {
    return BytesUtils.fromHexString(privateKey);
  }

  const PrivateKeysView(
      {required this.extendKey,
      required this.privateKey,
      required this.wif,
      required this.keyName,
      required this.keyType,
      required this.curve,
      required this.inNetworkStyle});

  PrivateKeysView copyWith(
      {String? extendKey,
      String? privateKey,
      String? wif,
      String? chainCode,
      String? keyName,
      String? inNetworkStyle}) {
    return PrivateKeysView(
        extendKey: extendKey ?? this.extendKey,
        privateKey: privateKey ?? this.privateKey,
        wif: wif ?? this.wif,
        keyName: keyName ?? this.keyName,
        keyType: keyType,
        curve: curve,
        inNetworkStyle: inNetworkStyle);
  }

  T cast<T extends PrivateKeysView>() {
    if (this is! T) {
      throw WalletException.invalidArgruments(["$T", runtimeType.toString()]);
    }
    return this as T;
  }
}

class MoneroPrivateKeysView extends PrivateKeysView {
  final String spendPrivateKey;
  final String viewPrivateKey;
  MoneroPrivateKeysView(
      {required super.extendKey,
      required super.privateKey,
      required super.wif,
      required this.spendPrivateKey,
      required this.viewPrivateKey,
      required super.keyName,
      required super.keyType,
      required super.curve})
      : super(inNetworkStyle: null);
  @override
  MoneroPrivateKeysView copyWith({
    String? extendKey,
    String? privateKey,
    String? wif,
    String? chainCode,
    String? spendPrivateKey,
    String? viewPrivateKey,
    String? keyName,
    String? inNetworkStyle,
  }) {
    return MoneroPrivateKeysView(
        extendKey: extendKey ?? this.extendKey,
        privateKey: privateKey ?? this.privateKey,
        wif: wif ?? this.wif,
        spendPrivateKey: spendPrivateKey ?? this.spendPrivateKey,
        viewPrivateKey: viewPrivateKey ?? this.viewPrivateKey,
        keyName: keyName ?? this.keyName,
        keyType: keyType,
        curve: curve);
  }
}
