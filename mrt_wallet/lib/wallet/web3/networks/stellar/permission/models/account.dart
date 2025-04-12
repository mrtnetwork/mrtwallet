import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/account.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:stellar_dart/stellar_dart.dart';

class Web3StellarChainAccount extends Web3ChainAccount<StellarAddress> {
  @override
  final int id;
  final List<int> publicKey;
  final StellarChainType network;
  Web3StellarChainAccount(
      {required super.keyIndex,
      required super.address,
      required super.defaultAddress,
      required this.id,
      required this.network,
      required List<int> publicKey})
      : publicKey = publicKey.asImmutableBytes;
  @override
  Web3StellarChainAccount clone({
    AddressDerivationIndex? keyIndex,
    StellarAddress? address,
    bool? defaultAddress,
    int? id,
    List<int>? publicKey,
    StellarChainType? network,
  }) {
    return Web3StellarChainAccount(
        keyIndex: keyIndex ?? this.keyIndex,
        address: address ?? this.address,
        defaultAddress: defaultAddress ?? this.defaultAddress,
        id: id ?? this.id,
        network: network ?? this.network,
        publicKey: publicKey ?? this.publicKey);
  }

  factory Web3StellarChainAccount.fromChainAccount(
      {required IStellarAddress address,
      required int id,
      required bool isDefault,
      required StellarChainType network}) {
    return Web3StellarChainAccount(
        keyIndex: address.keyIndex,
        address: address.networkAddress,
        id: id,
        defaultAddress: isDefault,
        network: network,
        publicKey: address.publicKey);
  }

  factory Web3StellarChainAccount.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        object: object,
        cborBytes: bytes,
        hex: hex,
        tags: CborTagsConst.web3StellarAccount);
    return Web3StellarChainAccount(
        keyIndex: AddressDerivationIndex.fromCborBytesOrObject(
            obj: values.getCborTag(0)),
        address: StellarAddress.fromBase32Addr(values.elementAt(1)),
        id: values.elementAt(2),
        defaultAddress: values.elementAt(3),
        publicKey: values.elementAs(4),
        network: StellarChainType.fromValue(values.elementAs(5)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          keyIndex.toCbor(),
          address.toString(),
          id,
          defaultAddress,
          CborBytesValue(publicKey),
          network.value
        ]),
        CborTagsConst.web3StellarAccount);
  }

  @override
  String get addressStr => address.toString();
}

class Web3StellarChainAuthenticated
    extends Web3ChainAuthenticated<Web3StellarChainAccount> {
  @override
  final List<Web3ChainDefaultIdnetifier> networks;
  @override
  final Web3ChainDefaultIdnetifier currentNetwork;
  Web3StellarChainAuthenticated({
    required super.accounts,
    required this.currentNetwork,
    required List<Web3ChainDefaultIdnetifier> networks,
  })  : networks = networks.immutable,
        super(networkType: NetworkType.stellar);

  factory Web3StellarChainAuthenticated.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        object: object,
        cborBytes: bytes,
        hex: hex,
        tags: NetworkType.stellar.tag);
    return Web3StellarChainAuthenticated(
      accounts: values
          .elementAsListOf<CborTagValue>(0)
          .map((e) => Web3StellarChainAccount.deserialize(object: e))
          .toList(),
      networks: values
          .elementAsListOf<CborTagValue>(1)
          .map((e) => Web3ChainDefaultIdnetifier.deserialize(object: e))
          .toList(),
      currentNetwork: Web3ChainDefaultIdnetifier.deserialize(
          object: values.elementAs<CborTagValue>(2)),
    );
  }
}
