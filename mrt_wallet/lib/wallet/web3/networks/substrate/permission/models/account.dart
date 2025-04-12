import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/helper/helper.dart';
import 'package:blockchain_utils/utils/string/string.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/account.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class Web3SubstrateChainAccount extends Web3ChainAccount<BaseSubstrateAddress> {
  @override
  final int id;
  final List<int> publicKey;
  Web3SubstrateChainAccount(
      {required super.keyIndex,
      required super.address,
      required super.defaultAddress,
      required this.id,
      required List<int> publicKey})
      : publicKey = publicKey.asImmutableBytes;
  @override
  Web3SubstrateChainAccount clone({
    AddressDerivationIndex? keyIndex,
    BaseSubstrateAddress? address,
    bool? defaultAddress,
    int? id,
    List<int>? publicKey,
  }) {
    return Web3SubstrateChainAccount(
        keyIndex: keyIndex ?? this.keyIndex,
        address: address ?? this.address,
        defaultAddress: defaultAddress ?? this.defaultAddress,
        id: id ?? this.id,
        publicKey: publicKey ?? this.publicKey);
  }

  factory Web3SubstrateChainAccount.fromChainAccount(
      {required ISubstrateAddress address,
      required int id,
      required bool isDefault}) {
    return Web3SubstrateChainAccount(
        keyIndex: address.keyIndex,
        address: address.networkAddress,
        id: id,
        defaultAddress: isDefault,
        publicKey: address.publicKey);
  }

  factory Web3SubstrateChainAccount.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        object: object,
        cborBytes: bytes,
        hex: hex,
        tags: CborTagsConst.web3SubstrateAccount);
    return Web3SubstrateChainAccount(
        keyIndex: AddressDerivationIndex.fromCborBytesOrObject(
            obj: values.getCborTag(0)),
        address: BaseSubstrateAddress(values.elementAt(1)),
        id: values.elementAt(2),
        defaultAddress: values.elementAt(3),
        publicKey: values.elementAs(4));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          keyIndex.toCbor(),
          address.address,
          id,
          defaultAddress,
          publicKey
        ]),
        CborTagsConst.web3SubstrateAccount);
  }

  @override
  String get addressStr => address.toString();
}

class Web3SubstrateChainIdnetifier extends Web3ChainIdnetifier {
  final String genesisHash;
  final int specVersion;
  @override
  String get identifier => "substrate:$genesisHash";
  Web3SubstrateChainIdnetifier(
      {required String genesisHash,
      required this.specVersion,
      required super.id})
      : genesisHash = StringUtils.add0x(genesisHash);
  factory Web3SubstrateChainIdnetifier.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        object: object,
        cborBytes: bytes,
        hex: hex,
        tags: CborTagsConst.web3SubstrateChainIdentifier);
    return Web3SubstrateChainIdnetifier(
        genesisHash: values.elementAs(0),
        specVersion: values.elementAs(1),
        id: values.elementAs(2));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([genesisHash, specVersion, id]),
        CborTagsConst.web3SubstrateChainIdentifier);
  }
}

class Web3SubstrateChainAuthenticated
    extends Web3ChainAuthenticated<Web3SubstrateChainAccount> {
  @override
  final List<Web3SubstrateChainIdnetifier> networks;
  @override
  final Web3SubstrateChainIdnetifier currentNetwork;
  Web3SubstrateChainAuthenticated({
    required super.accounts,
    required this.currentNetwork,
    required List<Web3SubstrateChainIdnetifier> networks,
  })  : networks = networks.immutable,
        super(networkType: NetworkType.substrate);

  factory Web3SubstrateChainAuthenticated.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        object: object,
        cborBytes: bytes,
        hex: hex,
        tags: NetworkType.substrate.tag);
    return Web3SubstrateChainAuthenticated(
      accounts: values
          .elementAsListOf<CborTagValue>(0)
          .map((e) => Web3SubstrateChainAccount.deserialize(object: e))
          .toList(),
      networks: values
          .elementAsListOf<CborTagValue>(1)
          .map((e) => Web3SubstrateChainIdnetifier.deserialize(object: e))
          .toList(),
      currentNetwork: Web3SubstrateChainIdnetifier.deserialize(
          object: values.elementAs<CborTagValue>(2)),
    );
  }
}
