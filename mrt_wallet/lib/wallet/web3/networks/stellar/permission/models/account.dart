import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/account.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:stellar_dart/stellar_dart.dart';

class Web3StellarChainAccount extends Web3ChainAccount<StellarAddress> {
  @override
  final int id;
  Web3StellarChainAccount(
      {required super.keyIndex,
      required super.address,
      required super.defaultAddress,
      required this.id});
  factory Web3StellarChainAccount.fromChainAccount(
      {required IStellarAddress address,
      required int id,
      required bool isDefault}) {
    return Web3StellarChainAccount(
        keyIndex: address.keyIndex,
        address: address.networkAddress,
        id: id,
        defaultAddress: isDefault);
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
        defaultAddress: values.elementAt(3));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [keyIndex.toCbor(), address.toString(), id, defaultAddress]),
        CborTagsConst.web3StellarAccount);
  }

  @override
  String get addressStr => address.toString();

  @override
  List get variabels => [keyIndex, addressStr, id];
}

class Web3StellarChainAuthenticated extends Web3ChainAuthenticated {
  final List<Web3StellarChainAccount> accounts;
  final WalletStellarNetwork network;
  final ProviderIdentifier? serviceIdentifier;
  Web3StellarChainAuthenticated(
      {required this.accounts,
      required this.network,
      required this.serviceIdentifier});

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
      network:
          WalletStellarNetwork.fromCborBytesOrObject(obj: values.getCborTag(1)),
      serviceIdentifier: values.elemetMybeAs<ProviderIdentifier, CborTagValue>(
          2, (p0) => ProviderIdentifier.deserialize(cbor: p0)),
    );
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          CborListValue.fixedLength(accounts.map((e) => e.toCbor()).toList()),
          network.toCbor(),
          serviceIdentifier?.toCbor()
        ]),
        networkType.tag);
  }

  @override
  NetworkType get networkType => NetworkType.stellar;
}
