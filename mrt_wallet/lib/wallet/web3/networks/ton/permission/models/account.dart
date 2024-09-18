import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/account.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:ton_dart/ton_dart.dart';

class Web3TonChainAccount extends Web3ChainAccount<TonAddress> {
  final int workChain;
  Web3TonChainAccount(
      {required super.keyIndex,
      required super.address,
      required super.defaultAddress,
      required this.workChain});
  factory Web3TonChainAccount.fromChainAccount(
      {required ITonAddress address,
      required int workChain,
      required bool isDefault}) {
    return Web3TonChainAccount(
        keyIndex: address.keyIndex,
        address: address.networkAddress,
        workChain: workChain,
        defaultAddress: isDefault);
  }

  factory Web3TonChainAccount.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        object: object,
        cborBytes: bytes,
        hex: hex,
        tags: CborTagsConst.web3TonAccount);
    return Web3TonChainAccount(
        keyIndex: AddressDerivationIndex.fromCborBytesOrObject(
            obj: values.getCborTag(0)),
        address: TonAddress(values.elementAt(1)),
        workChain: values.elementAt(2),
        defaultAddress: values.elementAt(3));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          keyIndex.toCbor(),
          address.toFriendlyAddress(),
          workChain,
          defaultAddress
        ]),
        CborTagsConst.web3TonAccount);
  }

  @override
  String get addressStr => address.toFriendlyAddress();

  @override
  List get variabels => [keyIndex, addressStr, workChain];
}
