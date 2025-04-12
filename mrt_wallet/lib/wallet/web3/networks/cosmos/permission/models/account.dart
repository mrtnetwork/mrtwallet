import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/account.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';

class Web3CosmosChainAccount extends Web3ChainAccount<CosmosBaseAddress> {
  @override
  final int id;
  final List<int> publicKey;
  final CosmosKeysAlgs algo;
  Web3CosmosChainAccount(
      {required super.keyIndex,
      required super.address,
      required super.defaultAddress,
      required this.id,
      required this.algo,
      required List<int> publicKey})
      : publicKey = publicKey.asImmutableBytes;

  @override
  Web3CosmosChainAccount clone({
    AddressDerivationIndex? keyIndex,
    CosmosBaseAddress? address,
    bool? defaultAddress,
    int? id,
    CosmosKeysAlgs? algo,
    List<int>? publicKey,
  }) {
    return Web3CosmosChainAccount(
        keyIndex: keyIndex ?? this.keyIndex,
        address: address ?? this.address,
        defaultAddress: defaultAddress ?? this.defaultAddress,
        id: id ?? this.id,
        algo: algo ?? this.algo,
        publicKey: publicKey ?? this.publicKey);
  }

  factory Web3CosmosChainAccount.fromChainAccount(
      {required ICosmosAddress address,
      required int id,
      required bool isDefault}) {
    return Web3CosmosChainAccount(
        keyIndex: address.keyIndex,
        address: address.networkAddress,
        id: id,
        defaultAddress: isDefault,
        publicKey: address.publicKey,
        algo: address.algorithm);
  }

  factory Web3CosmosChainAccount.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        object: object,
        cborBytes: bytes,
        hex: hex,
        tags: CborTagsConst.web3CosmosAccount);
    return Web3CosmosChainAccount(
        keyIndex: AddressDerivationIndex.fromCborBytesOrObject(
            obj: values.getCborTag(0)),
        address: CosmosBaseAddress(values.elementAt(1)),
        id: values.elementAt(2),
        defaultAddress: values.elementAt(3),
        publicKey: values.elementAs(4),
        algo: CosmosKeysAlgs.fromName(values.elementAs(5)));
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
          algo.name
        ]),
        CborTagsConst.web3CosmosAccount);
  }

  @override
  String get addressStr => address.address;
}

class Web3CosmoshainIdnetifier extends Web3ChainIdnetifier {
  final String chainId;
  @override
  String get identifier => "cosmos:$chainId";
  const Web3CosmoshainIdnetifier({required this.chainId, required super.id});
  factory Web3CosmoshainIdnetifier.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        object: object,
        cborBytes: bytes,
        hex: hex,
        tags: CborTagsConst.web3CosmosChainIdentifier);
    return Web3CosmoshainIdnetifier(
        chainId: values.elementAs(0), id: values.elementAs(1));
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([chainId, id]),
        CborTagsConst.web3CosmosChainIdentifier);
  }
}

class Web3CosmosChainAuthenticated
    extends Web3ChainAuthenticated<Web3CosmosChainAccount> {
  @override
  final List<Web3CosmoshainIdnetifier> networks;
  @override
  final Web3CosmoshainIdnetifier currentNetwork;
  Web3CosmosChainAuthenticated({
    required super.accounts,
    required this.currentNetwork,
    required List<Web3CosmoshainIdnetifier> networks,
  })  : networks = networks.immutable,
        super(networkType: NetworkType.cosmos);

  factory Web3CosmosChainAuthenticated.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        object: object,
        cborBytes: bytes,
        hex: hex,
        tags: NetworkType.cosmos.tag);
    return Web3CosmosChainAuthenticated(
      accounts: values
          .elementAsListOf<CborTagValue>(0)
          .map((e) => Web3CosmosChainAccount.deserialize(object: e))
          .toList(),
      networks: values
          .elementAsListOf<CborTagValue>(1)
          .map((e) => Web3CosmoshainIdnetifier.deserialize(object: e))
          .toList(),
      currentNetwork: Web3CosmoshainIdnetifier.deserialize(
          object: values.elementAs<CborTagValue>(2)),
    );
  }
}
