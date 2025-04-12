import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/params/aptos.dart'
    show AptosChainType;
import 'package:mrt_wallet/wallet/web3/core/permission/types/account.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:on_chain/aptos/src/address/address/address.dart';

class Web3AptosChainAccount extends Web3ChainAccount<AptosAddress> {
  @override
  final int id;
  final List<int> publicKey;
  final int signingScheme;
  final AptosChainType network;

  String get publicKeyHex {
    return BytesUtils.toHexString(publicKey, prefix: '0x');
  }

  Web3AptosChainAccount(
      {required super.keyIndex,
      required super.address,
      required super.defaultAddress,
      required this.id,
      required this.signingScheme,
      required this.network,
      required List<int> publicKey})
      : publicKey = publicKey.asImmutableBytes;
  factory Web3AptosChainAccount.fromChainAccount({
    required IAptosAddress address,
    required int id,
    required bool isDefault,
    required AptosChainType network,
  }) {
    return Web3AptosChainAccount(
        keyIndex: address.keyIndex,
        address: address.networkAddress,
        id: id,
        defaultAddress: isDefault,
        network: network,
        publicKey: address.aptosPublicKey().toBytes(),
        signingScheme: address.keyScheme.toSigningScheme.value);
  }

  factory Web3AptosChainAccount.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        object: object,
        cborBytes: bytes,
        hex: hex,
        tags: CborTagsConst.web3AptosAccount);
    return Web3AptosChainAccount(
        keyIndex: AddressDerivationIndex.fromCborBytesOrObject(
            obj: values.getCborTag(0)),
        address: AptosAddress(values.elementAt(1)),
        id: values.elementAt(2),
        defaultAddress: values.elementAt(3),
        publicKey: values.elementAs(4),
        signingScheme: values.elementAs(5),
        network: AptosChainType.fromValue(values.elementAs(6)));
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
          network.id
        ]),
        CborTagsConst.web3AptosAccount);
  }

  @override
  String get addressStr => address.address;

  @override
  Web3AptosChainAccount clone(
      {AddressDerivationIndex? keyIndex,
      AptosAddress? address,
      bool? defaultAddress,
      int? id,
      int? signingScheme,
      AptosChainType? network,
      List<int>? publicKey}) {
    return Web3AptosChainAccount(
        keyIndex: keyIndex ?? this.keyIndex,
        address: address ?? this.address,
        defaultAddress: defaultAddress ?? this.defaultAddress,
        id: id ?? this.id,
        signingScheme: signingScheme ?? this.signingScheme,
        network: network ?? this.network,
        publicKey: publicKey ?? this.publicKey);
  }
}

class Web3AptosChainIdnetifier extends Web3ChainIdnetifier {
  final int? chainId;
  @override
  final String identifier;
  late final AptosChainType aptosChain = AptosChainType.fromValue(chainId);

  Web3AptosChainIdnetifier(
      {required this.chainId, required this.identifier, required super.id});
  factory Web3AptosChainIdnetifier.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        object: object,
        cborBytes: bytes,
        hex: hex,
        tags: CborTagsConst.web3AptosChainIdentifier);
    return Web3AptosChainIdnetifier(
        chainId: values.elementAs(0),
        id: values.elementAs(1),
        identifier: values.elementAs(2));
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
      CborListValue.fixedLength([chainId, id, identifier]),
      CborTagsConst.web3AptosChainIdentifier,
    );
  }
}

class Web3AptosChainAuthenticated
    extends Web3ChainAuthenticated<Web3AptosChainAccount> {
  @override
  final List<Web3AptosChainIdnetifier> networks;
  @override
  final Web3AptosChainIdnetifier currentNetwork;
  Web3AptosChainAuthenticated({
    required super.accounts,
    required this.currentNetwork,
    required List<Web3AptosChainIdnetifier> networks,
  })  : networks = networks.immutable,
        super(networkType: NetworkType.aptos);

  factory Web3AptosChainAuthenticated.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        object: object,
        cborBytes: bytes,
        hex: hex,
        tags: NetworkType.aptos.tag);
    return Web3AptosChainAuthenticated(
      accounts: values
          .elementAsListOf<CborTagValue>(0)
          .map((e) => Web3AptosChainAccount.deserialize(object: e))
          .toList(),
      networks: values
          .elementAsListOf<CborTagValue>(1)
          .map((e) => Web3AptosChainIdnetifier.deserialize(object: e))
          .toList(),
      currentNetwork: Web3AptosChainIdnetifier.deserialize(
          object: values.elementAs<CborTagValue>(2)),
    );
  }

  @override
  NetworkType get networkType => NetworkType.aptos;
}
