import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/account.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:on_chain/solana/solana.dart';

class Web3SolanaChainAccount extends Web3ChainAccount<SolAddress> {
  final String genesis;
  Web3SolanaChainAccount({
    required super.keyIndex,
    required super.address,
    required super.defaultAddress,
    required this.genesis,
  });
  factory Web3SolanaChainAccount.fromChainAccount(
      {required ISolanaAddress address,
      required String genesis,
      required bool isDefault}) {
    return Web3SolanaChainAccount(
        keyIndex: address.keyIndex,
        address: address.networkAddress,
        genesis: genesis,
        defaultAddress: isDefault);
  }

  factory Web3SolanaChainAccount.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        object: object,
        cborBytes: bytes,
        hex: hex,
        tags: CborTagsConst.web3SolanaAccount);
    return Web3SolanaChainAccount(
        keyIndex: AddressDerivationIndex.fromCborBytesOrObject(
            obj: values.getCborTag(0)),
        address: SolAddress(values.elementAt(1)),
        genesis: values.elementAt(2),
        defaultAddress: values.elementAt(3));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [keyIndex.toCbor(), address.address, genesis, defaultAddress]),
        CborTagsConst.web3SolanaAccount);
  }

  @override
  String get addressStr => address.address;

  @override
  List get variabels => [keyIndex, addressStr, genesis];
}
