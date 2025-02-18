import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/helper/helper.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/account.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:polkadot_dart/polkadot_dart.dart';

class Web3SubstrateChainAccount extends Web3ChainAccount<BaseSubstrateAddress> {
  @override
  final int id;
  Web3SubstrateChainAccount(
      {required super.keyIndex,
      required super.address,
      required super.defaultAddress,
      required this.id});
  factory Web3SubstrateChainAccount.fromChainAccount(
      {required ISubstrateAddress address,
      required int id,
      required bool isDefault}) {
    return Web3SubstrateChainAccount(
        keyIndex: address.keyIndex,
        address: address.networkAddress,
        id: id,
        defaultAddress: isDefault);
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
        defaultAddress: values.elementAt(3));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [keyIndex.toCbor(), address.address, id, defaultAddress]),
        CborTagsConst.web3SubstrateAccount);
  }

  @override
  String get addressStr => address.toString();

  @override
  List get variabels => [keyIndex, addressStr, id];
}

class Web3SubstrateChainMetadata with CborSerializable {
  final String genesisHash;
  final int specVersion;
  const Web3SubstrateChainMetadata(
      {required this.genesisHash, required this.specVersion});
  factory Web3SubstrateChainMetadata.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        object: object,
        cborBytes: bytes,
        hex: hex,
        tags: CborTagsConst.web3SubstrateChainMetadata);
    return Web3SubstrateChainMetadata(
        genesisHash: values.elementAs(0), specVersion: values.elementAs(1));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(CborListValue.fixedLength([genesisHash, specVersion]),
        CborTagsConst.web3SubstrateChainMetadata);
  }
}

class Web3SubstrateChainAuthenticated extends Web3ChainAuthenticated {
  final List<Web3SubstrateChainAccount> accounts;
  final List<Web3SubstrateChainMetadata> knownMetadata;
  final WalletSubstrateNetwork network;
  final ProviderIdentifier? serviceIdentifier;
  Web3SubstrateChainAuthenticated(
      {required List<Web3SubstrateChainAccount> accounts,
      required this.network,
      required this.serviceIdentifier,
      required List<Web3SubstrateChainMetadata> knownMetadata})
      : accounts = accounts.immutable,
        knownMetadata = knownMetadata.immutable;

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
      network: WalletSubstrateNetwork.fromCborBytesOrObject(
          obj: values.getCborTag(1)),
      serviceIdentifier: values.elemetMybeAs<ProviderIdentifier, CborTagValue>(
          2, (p0) => ProviderIdentifier.deserialize(cbor: p0)),
      knownMetadata: values
          .elementAsListOf<CborTagValue>(3)
          .map((e) => Web3SubstrateChainMetadata.deserialize(object: e))
          .toList(),
    );
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(accounts.map((e) => e.toCbor()).toList()),
          network.toCbor(),
          serviceIdentifier?.toCbor(),
          CborListValue.fixedLength(
              knownMetadata.map((e) => e.toCbor()).toList()),
        ]),
        networkType.tag);
  }

  @override
  NetworkType get networkType => NetworkType.substrate;
}
