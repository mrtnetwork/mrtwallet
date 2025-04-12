import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/helper/helper.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/api/provider/networks/ethereum.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/account.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:on_chain/ethereum/ethereum.dart';

class Web3EthereumChainAccount extends Web3ChainAccount<ETHAddress> {
  @override
  final int id;
  final List<int>? publicKey;
  Web3EthereumChainAccount(
      {required super.keyIndex,
      required super.address,
      required super.defaultAddress,
      required this.id,
      required List<int>? publicKey})
      : publicKey = publicKey?.asImmutableBytes;
  @override
  Web3EthereumChainAccount clone(
      {AddressDerivationIndex? keyIndex,
      ETHAddress? address,
      bool? defaultAddress,
      int? id,
      List<int>? publicKey}) {
    return Web3EthereumChainAccount(
        keyIndex: keyIndex ?? this.keyIndex,
        address: address ?? this.address,
        defaultAddress: defaultAddress ?? this.defaultAddress,
        id: id ?? this.id,
        publicKey: publicKey ?? this.publicKey);
  }

  factory Web3EthereumChainAccount.fromChainAccount(
      {required IEthAddress address,
      required int id,
      required bool defaultAddress}) {
    return Web3EthereumChainAccount(
        keyIndex: address.keyIndex,
        address: address.networkAddress,
        id: id,
        defaultAddress: defaultAddress,
        publicKey: address.publicKey);
  }
  factory Web3EthereumChainAccount.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        object: object,
        cborBytes: bytes,
        hex: hex,
        tags: CborTagsConst.web3EthereumAccount);
    return Web3EthereumChainAccount(
        keyIndex: AddressDerivationIndex.fromCborBytesOrObject(
            obj: values.getCborTag(0)),
        address: ETHAddress(values.elementAt(1)),
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
          publicKey == null ? null : CborBytesValue(publicKey!)
        ]),
        CborTagsConst.web3EthereumAccount);
  }

  @override
  String get addressStr => address.address;
}

class Web3EthereumChainIdnetifier extends Web3ChainIdnetifier {
  final BigInt chainId;
  final bool supportEIP1559;
  @override
  String get identifier => "ethereum:$chainId";
  const Web3EthereumChainIdnetifier(
      {required this.chainId, required this.supportEIP1559, required super.id});
  factory Web3EthereumChainIdnetifier.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        object: object,
        cborBytes: bytes,
        hex: hex,
        tags: CborTagsConst.web3EthereumChainIdentifier);
    return Web3EthereumChainIdnetifier(
        chainId: values.elementAs(0),
        supportEIP1559: values.elementAs(1),
        id: values.elementAs(2));
  }
  @override
  CborTagValue toCbor() {
    return CborTagValue(
      CborListValue.fixedLength([chainId, supportEIP1559, id]),
      CborTagsConst.web3EthereumChainIdentifier,
    );
  }
}

class Web3EthereumChainAuthenticated
    extends Web3ChainAuthenticated<Web3EthereumChainAccount> {
  final EthereumAPIProvider? serviceIdentifier;
  @override
  final List<Web3EthereumChainIdnetifier> networks;
  @override
  final Web3EthereumChainIdnetifier currentNetwork;
  Web3EthereumChainAuthenticated({
    required super.accounts,
    required this.currentNetwork,
    required this.serviceIdentifier,
    required List<Web3EthereumChainIdnetifier> networks,
  })  : networks = networks.immutable,
        super(networkType: NetworkType.ethereum);

  factory Web3EthereumChainAuthenticated.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        object: object,
        cborBytes: bytes,
        hex: hex,
        tags: NetworkType.ethereum.tag);
    try {
      return Web3EthereumChainAuthenticated(
        accounts: values
            .elementAsListOf<CborTagValue>(0)
            .map((e) => Web3EthereumChainAccount.deserialize(object: e))
            .toList(),
        serviceIdentifier:
            values.elemetMybeAs<EthereumAPIProvider, CborTagValue>(
                1, (p0) => EthereumAPIProvider.fromCborBytesOrObject(obj: p0)),
        networks: values
            .elementAsListOf<CborTagValue>(2)
            .map((e) => Web3EthereumChainIdnetifier.deserialize(object: e))
            .toList(),
        currentNetwork: Web3EthereumChainIdnetifier.deserialize(
            object: values.elementAs<CborTagValue>(3)),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(accounts.map((e) => e.toCbor()).toList()),
          serviceIdentifier?.toCbor(),
          CborListValue.fixedLength(networks.map((e) => e.toCbor()).toList()),
          currentNetwork.toCbor()
        ]),
        networkType.tag);
  }
}
