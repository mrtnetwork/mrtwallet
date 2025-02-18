import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/account.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:on_chain/sui/src/address/address/address.dart';

class Web3SuiChainAccount extends Web3ChainAccount<SuiAddress> {
  @override
  final int id;
  final List<int> publicKey;
  final int signingScheme;
  Web3SuiChainAccount(
      {required super.keyIndex,
      required super.address,
      required super.defaultAddress,
      required this.id,
      required this.signingScheme,
      required List<int> publicKey})
      : publicKey = publicKey.asImmutableBytes;
  factory Web3SuiChainAccount.fromChainAccount(
      {required ISuiAddress address,
      required int id,
      required bool isDefault}) {
    return Web3SuiChainAccount(
        keyIndex: address.keyIndex,
        address: address.networkAddress,
        id: id,
        defaultAddress: isDefault,
        publicKey: address.toSuiPublicKey().toVariantBcs(),
        signingScheme: address.keyScheme.value);
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
        CborTagsConst.web3SuiAccount);
  }

  @override
  String get addressStr => address.address;

  @override
  List get variabels => [keyIndex, addressStr, id];
}

class Web3SuiChainAuthenticated extends Web3ChainAuthenticated {
  final List<Web3SuiChainAccount> accounts;
  final WalletSuiNetwork network;
  final ProviderIdentifier? serviceIdentifier;
  Web3SuiChainAuthenticated(
      {required List<Web3SuiChainAccount> accounts,
      required this.network,
      required this.serviceIdentifier})
      : accounts = accounts.immutable;

  factory Web3SuiChainAuthenticated.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        object: object, cborBytes: bytes, hex: hex, tags: NetworkType.sui.tag);
    return Web3SuiChainAuthenticated(
        accounts: values
            .elementAsListOf<CborTagValue>(0)
            .map((e) => Web3SuiChainAccount.deserialize(object: e))
            .toList(),
        network:
            WalletSuiNetwork.fromCborBytesOrObject(obj: values.getCborTag(1)),
        serviceIdentifier:
            values.elemetMybeAs<ProviderIdentifier, CborTagValue>(
                2, (p0) => ProviderIdentifier.deserialize(cbor: p0)));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(accounts.map((e) => e.toCbor()).toList()),
          network.toCbor(),
          serviceIdentifier?.toCbor(),
        ]),
        networkType.tag);
  }

  @override
  NetworkType get networkType => NetworkType.sui;
}
