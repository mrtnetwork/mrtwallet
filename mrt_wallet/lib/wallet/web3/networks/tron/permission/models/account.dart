import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:mrt_wallet/wallet/api/provider/core/provider.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/network/core/network/network.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/account.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:on_chain/tron/tron.dart';

class Web3TronChainAccount extends Web3ChainAccount<TronAddress> {
  @override
  final int id;
  Web3TronChainAccount({
    required super.keyIndex,
    required super.address,
    required super.defaultAddress,
    required this.id,
  });
  factory Web3TronChainAccount.fromChainAccount(
      {required ITronAddress address,
      required int id,
      required bool isDefault}) {
    return Web3TronChainAccount(
        keyIndex: address.keyIndex,
        address: address.networkAddress,
        id: id,
        defaultAddress: isDefault);
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
        defaultAddress: values.elementAt(3));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [keyIndex.toCbor(), address.toAddress(), id, defaultAddress]),
        CborTagsConst.web3TronAccount);
  }

  @override
  String get addressStr => address.toAddress();

  @override
  List get variabels => [keyIndex, addressStr, id];
}

class Web3TronChainAuthenticated extends Web3ChainAuthenticated {
  final List<Web3TronChainAccount> accounts;
  final WalletTronNetwork network;
  final ProviderIdentifier? serviceIdentifier;
  final List<BigInt> chainIds;
  Web3TronChainAuthenticated(
      {required this.accounts,
      required this.network,
      required this.serviceIdentifier,
      required this.chainIds});

  factory Web3TronChainAuthenticated.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        object: object, cborBytes: bytes, hex: hex, tags: NetworkType.tron.tag);
    return Web3TronChainAuthenticated(
        accounts: values
            .elementAsListOf<CborTagValue>(0)
            .map((e) => Web3TronChainAccount.deserialize(object: e))
            .toList(),
        network:
            WalletTronNetwork.fromCborBytesOrObject(obj: values.getCborTag(1)),
        serviceIdentifier:
            values.elemetMybeAs<ProviderIdentifier, CborTagValue>(
                2, (p0) => ProviderIdentifier.deserialize(cbor: p0)),
        chainIds: values
            .elementAsListOf<CborBigIntValue>(3)
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
          CborListValue.fixedLength(chainIds.map((e) => e).toList()),
        ]),
        networkType.tag);
  }

  @override
  NetworkType get networkType => NetworkType.tron;
}
