import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/account.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:on_chain/aptos/src/address/address/address.dart';

class Web3AptosChainAccount extends Web3ChainAccount<AptosAddress> {
  @override
  final int id;
  final List<int> publicKey;
  final int signingScheme;
  Web3AptosChainAccount(
      {required super.keyIndex,
      required super.address,
      required super.defaultAddress,
      required this.id,
      required this.signingScheme,
      required List<int> publicKey})
      : publicKey = publicKey.asImmutableBytes;
  factory Web3AptosChainAccount.fromChainAccount(
      {required IAptosAddress address,
      required int id,
      required bool isDefault}) {
    return Web3AptosChainAccount(
        keyIndex: address.keyIndex,
        address: address.networkAddress,
        id: id,
        defaultAddress: isDefault,
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
        signingScheme: values.elementAs(5));
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
          signingScheme
        ]),
        CborTagsConst.web3AptosAccount);
  }

  @override
  String get addressStr => address.address;

  @override
  List get variabels => [keyIndex, addressStr, id];
}

class Web3AptosChainAuthenticated extends Web3ChainAuthenticated {
  final List<Web3AptosChainAccount> accounts;
  final WalletAptosNetwork network;
  final ProviderIdentifier? serviceIdentifier;
  final List<int> chainIds;
  Web3AptosChainAuthenticated(
      {required List<Web3AptosChainAccount> accounts,
      required this.network,
      required this.serviceIdentifier,
      required List<int> chainIds})
      : accounts = accounts.immutable,
        chainIds = chainIds.immutable;

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
        network:
            WalletAptosNetwork.fromCborBytesOrObject(obj: values.getCborTag(1)),
        serviceIdentifier:
            values.elemetMybeAs<ProviderIdentifier, CborTagValue>(
                2, (p0) => ProviderIdentifier.deserialize(cbor: p0)),
        chainIds: values
            .elementAsListOf<CborIntValue>(3)
            .map((e) => e.value)
            .toList());
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(accounts.map((e) => e.toCbor()).toList()),
          network.toCbor(),
          serviceIdentifier?.toCbor(),
          CborListValue.fixedLength(
              chainIds.map((e) => CborIntValue(e)).toList()),
        ]),
        networkType.tag);
  }

  @override
  NetworkType get networkType => NetworkType.aptos;
}
