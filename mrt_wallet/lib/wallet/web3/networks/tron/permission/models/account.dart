import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/models/networks/tron/tron.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/account.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:on_chain/tron/tron.dart';

class Web3TronChainAccount extends Web3ChainAccount<TronAddress> {
  final TronChainType chain;
  Web3TronChainAccount({
    required super.keyIndex,
    required super.address,
    required super.defaultAddress,
    required this.chain,
  });
  factory Web3TronChainAccount.fromChainAccount(
      {required ITronAddress address,
      required TronChainType chain,
      required bool isDefault}) {
    return Web3TronChainAccount(
        keyIndex: address.keyIndex,
        address: address.networkAddress,
        chain: chain,
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
        chain: TronChainType.fromName(values.elementAt(2)),
        defaultAddress: values.elementAt(3));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          keyIndex.toCbor(),
          address.toAddress(),
          chain.name,
          defaultAddress
        ]),
        CborTagsConst.web3TronAccount);
  }

  @override
  String get addressStr => address.toAddress();

  @override
  List get variabels => [keyIndex, addressStr, chain];
}
