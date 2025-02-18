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
import 'package:on_chain/ethereum/ethereum.dart';

class Web3EthereumChainAccount extends Web3ChainAccount<ETHAddress> {
  @override
  final int id;
  Web3EthereumChainAccount(
      {required super.keyIndex,
      required super.address,
      required super.defaultAddress,
      required this.id});

  factory Web3EthereumChainAccount.fromChainAccount(
      {required IEthAddress address,
      required int id,
      required bool defaultAddress}) {
    return Web3EthereumChainAccount(
        keyIndex: address.keyIndex,
        address: address.networkAddress,
        id: id,
        defaultAddress: defaultAddress);
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
        defaultAddress: values.elementAt(3));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [keyIndex.toCbor(), address.address, id, defaultAddress]),
        CborTagsConst.web3EthereumAccount);
  }

  @override
  String get addressStr => address.address;

  @override
  List get variabels => [keyIndex, addressStr, id];
}

class Web3EthereumChainAuthenticated extends Web3ChainAuthenticated {
  final List<BigInt> existsChain;
  final List<Web3EthereumChainAccount> accounts;
  final WalletEthereumNetwork network;
  final ProviderIdentifier? serviceIdentifier;
  @override
  NetworkType get networkType => NetworkType.ethereum;
  Web3EthereumChainAuthenticated({
    required this.accounts,
    required this.network,
    required this.serviceIdentifier,
    required List<BigInt> existsChain,
  }) : existsChain = existsChain.immutable;

  factory Web3EthereumChainAuthenticated.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        object: object,
        cborBytes: bytes,
        hex: hex,
        tags: NetworkType.ethereum.tag);
    return Web3EthereumChainAuthenticated(
      accounts: values
          .elementAsListOf<CborTagValue>(0)
          .map((e) => Web3EthereumChainAccount.deserialize(object: e))
          .toList(),
      network: WalletEthereumNetwork.fromCborBytesOrObject(
          obj: values.getCborTag(1)),
      serviceIdentifier: values.elemetMybeAs<ProviderIdentifier, CborTagValue>(
          2, (p0) => ProviderIdentifier.deserialize(cbor: p0)),
      existsChain: values
          .elementAsListOf<CborBigIntValue>(3)
          .map((e) => e.value)
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
              existsChain.map((e) => CborBigIntValue(e)).toList()),
        ]),
        networkType.tag);
  }
}
