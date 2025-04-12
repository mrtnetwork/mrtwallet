import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/params/sui.dart'
    show SuiChainType;
import 'package:mrt_wallet/wallet/web3/core/permission/types/account.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:on_chain/sui/src/address/address/address.dart';

class Web3SuiChainAccount extends Web3ChainAccount<SuiAddress> {
  @override
  final int id;
  final List<int> publicKey;
  final int signingScheme;
  final SuiChainType network;
  @override
  Web3SuiChainAccount clone(
      {AddressDerivationIndex? keyIndex,
      SuiAddress? address,
      bool? defaultAddress,
      int? id,
      List<int>? publicKey,
      SuiChainType? network,
      int? signingScheme}) {
    return Web3SuiChainAccount(
        keyIndex: keyIndex ?? this.keyIndex,
        address: address ?? this.address,
        defaultAddress: defaultAddress ?? this.defaultAddress,
        id: id ?? this.id,
        publicKey: publicKey ?? this.publicKey,
        network: network ?? this.network,
        signingScheme: signingScheme ?? this.signingScheme);
  }

  Web3SuiChainAccount(
      {required super.keyIndex,
      required super.address,
      required super.defaultAddress,
      required this.id,
      required this.signingScheme,
      required List<int> publicKey,
      required this.network})
      : publicKey = publicKey.asImmutableBytes;
  factory Web3SuiChainAccount.fromChainAccount(
      {required ISuiAddress address,
      required int id,
      required bool isDefault,
      required SuiChainType network}) {
    return Web3SuiChainAccount(
        keyIndex: address.keyIndex,
        address: address.networkAddress,
        id: id,
        defaultAddress: isDefault,
        publicKey: address.toSuiPublicKey().toVariantBcs(),
        signingScheme: address.keyScheme.value,
        network: network);
  }

  factory Web3SuiChainAccount.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        object: object,
        cborBytes: bytes,
        hex: hex,
        tags: CborTagsConst.web3SuiAccount);
    return Web3SuiChainAccount(
        keyIndex: AddressDerivationIndex.fromCborBytesOrObject(
            obj: values.getCborTag(0)),
        address: SuiAddress(values.elementAt(1)),
        id: values.elementAt(2),
        defaultAddress: values.elementAt(3),
        publicKey: values.elementAs(4),
        signingScheme: values.elementAs(5),
        network: SuiChainType.fromValue(values.elementAs(6)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          keyIndex.toCbor(),
          address.address,
          id,
          defaultAddress,
          CborBytesValue(publicKey),
          signingScheme,
          network.value
        ]),
        CborTagsConst.web3SuiAccount);
  }

  @override
  String get addressStr => address.address;
}

class Web3SuiChainAuthenticated
    extends Web3ChainAuthenticated<Web3SuiChainAccount> {
  @override
  final List<Web3ChainDefaultIdnetifier> networks;
  @override
  final Web3ChainDefaultIdnetifier currentNetwork;
  Web3SuiChainAuthenticated({
    required super.accounts,
    required this.currentNetwork,
    required List<Web3ChainDefaultIdnetifier> networks,
  })  : networks = networks.immutable,
        super(networkType: NetworkType.sui);

  factory Web3SuiChainAuthenticated.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        object: object, cborBytes: bytes, hex: hex, tags: NetworkType.sui.tag);
    return Web3SuiChainAuthenticated(
      accounts: values
          .elementAsListOf<CborTagValue>(0)
          .map((e) => Web3SuiChainAccount.deserialize(object: e))
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
