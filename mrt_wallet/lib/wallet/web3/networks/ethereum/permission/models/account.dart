import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/account.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:on_chain/ethereum/ethereum.dart';

class Web3EthereumChainAccount extends Web3ChainAccount<ETHAddress> {
  final BigInt chainId;
  Web3EthereumChainAccount({
    required super.keyIndex,
    required super.address,
    required super.defaultAddress,
    required this.chainId,
  });

  factory Web3EthereumChainAccount.fromChainAccount(
      {required IEthAddress address,
      required BigInt chainId,
      required bool defaultAddress}) {
    return Web3EthereumChainAccount(
        keyIndex: address.keyIndex,
        address: address.networkAddress,
        chainId: chainId,
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
        chainId: values.elementAt(2),
        defaultAddress: values.elementAt(3));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [keyIndex.toCbor(), address.address, chainId, defaultAddress]),
        CborTagsConst.web3EthereumAccount);
  }

  @override
  String get addressStr => address.address;

  @override
  List get variabels => [keyIndex, addressStr, chainId];
}
