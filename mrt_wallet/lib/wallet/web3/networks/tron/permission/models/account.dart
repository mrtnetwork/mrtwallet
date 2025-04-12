import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/helper/extensions/extensions.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/account.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:on_chain/tron/tron.dart';

class Web3TronChainAccount extends Web3ChainAccount<TronAddress> {
  @override
  final int id;
  final List<int>? publicKey;
  Web3TronChainAccount(
      {required super.keyIndex,
      required super.address,
      required super.defaultAddress,
      required this.id,
      required List<int>? publicKey})
      : publicKey = publicKey?.asImmutableBytes;
  @override
  Web3TronChainAccount clone({
    AddressDerivationIndex? keyIndex,
    TronAddress? address,
    bool? defaultAddress,
    int? id,
    List<int>? publicKey,
  }) {
    return Web3TronChainAccount(
        keyIndex: keyIndex ?? this.keyIndex,
        address: address ?? this.address,
        defaultAddress: defaultAddress ?? this.defaultAddress,
        id: id ?? this.id,
        publicKey: publicKey ?? this.publicKey);
  }

  factory Web3TronChainAccount.fromChainAccount(
      {required ITronAddress address,
      required int id,
      required bool isDefault}) {
    return Web3TronChainAccount(
        keyIndex: address.keyIndex,
        address: address.networkAddress,
        id: id,
        defaultAddress: isDefault,
        publicKey: address.multiSigAccount ? null : address.publicKey);
  }

  factory Web3TronChainAccount.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        object: object,
        cborBytes: bytes,
        hex: hex,
        tags: CborTagsConst.web3TronAccount);
    return Web3TronChainAccount(
        keyIndex: AddressDerivationIndex.fromCborBytesOrObject(
            obj: values.getCborTag(0)),
        address: TronAddress(values.elementAt(1)),
        id: values.elementAt(2),
        defaultAddress: values.elementAt(3),
        publicKey: values.elementAs(4));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          keyIndex.toCbor(),
          address.toAddress(),
          id,
          defaultAddress,
          publicKey == null ? null : CborBytesValue(publicKey!)
        ]),
        CborTagsConst.web3TronAccount);
  }

  @override
  String get addressStr => address.toAddress();
}

class Web3TronChainIdnetifier extends Web3ChainIdnetifier {
  final int chainId;
  final String solidityNode;
  final String fullNode;
  @override
  String get identifier => "tron:$chainId";
  const Web3TronChainIdnetifier({
    required this.chainId,
    required super.id,
    required this.solidityNode,
    required this.fullNode,
  });
  factory Web3TronChainIdnetifier.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        object: object,
        cborBytes: bytes,
        hex: hex,
        tags: CborTagsConst.web3TronChainIdentifier);
    return Web3TronChainIdnetifier(
        chainId: values.elementAs(0),
        id: values.elementAs(1),
        fullNode: values.elementAs(2),
        solidityNode: values.elementAs(3));
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
      CborListValue.fixedLength([chainId, id, fullNode, solidityNode]),
      CborTagsConst.web3TronChainIdentifier,
    );
  }
}

class Web3TronChainAuthenticated
    extends Web3ChainAuthenticated<Web3TronChainAccount> {
  @override
  final List<Web3TronChainIdnetifier> networks;
  @override
  final Web3TronChainIdnetifier currentNetwork;
  Web3TronChainAuthenticated({
    required super.accounts,
    required this.currentNetwork,
    required List<Web3TronChainIdnetifier> networks,
  })  : networks = networks.immutable,
        super(networkType: NetworkType.tron);

  factory Web3TronChainAuthenticated.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        object: object, cborBytes: bytes, hex: hex, tags: NetworkType.tron.tag);
    return Web3TronChainAuthenticated(
      accounts: values
          .elementAsListOf<CborTagValue>(0)
          .map((e) => Web3TronChainAccount.deserialize(object: e))
          .toList(),
      networks: values
          .elementAsListOf<CborTagValue>(1)
          .map((e) => Web3TronChainIdnetifier.deserialize(object: e))
          .toList(),
      currentNetwork: Web3TronChainIdnetifier.deserialize(
          object: values.elementAs<CborTagValue>(2)),
    );
  }
}
