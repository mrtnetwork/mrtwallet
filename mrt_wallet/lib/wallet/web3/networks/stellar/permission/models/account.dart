import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/chain/account.dart';
import 'package:mrt_wallet/wallet/web3/core/permission/types/account.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:stellar_dart/stellar_dart.dart';

class Web3StellarChainAccount extends Web3ChainAccount<StellarAddress> {
  final String passphrase;
  Web3StellarChainAccount(
      {required super.keyIndex,
      required super.address,
      required super.defaultAddress,
      required this.passphrase});
  factory Web3StellarChainAccount.fromChainAccount(
      {required IStellarAddress address,
      required String passphrase,
      required bool isDefault}) {
    return Web3StellarChainAccount(
        keyIndex: address.keyIndex,
        address: address.networkAddress,
        passphrase: passphrase,
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
        passphrase: values.elementAt(2),
        defaultAddress: values.elementAt(3));
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          keyIndex.toCbor(),
          address.toString(),
          passphrase,
          defaultAddress
        ]),
        CborTagsConst.web3StellarAccount);
  }

  @override
  String get addressStr => address.toString();

  @override
  List get variabels => [keyIndex, addressStr, passphrase];
}
