import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';

import 'package:mrt_wallet/wallet/models/contact/core/contract_core.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:on_chain/ethereum/src/address/evm_address.dart';

class EthereumContract with Equatable implements ContactCore<ETHAddress> {
  EthereumContract._(
      {required this.addressObject, required this.created, required this.name});
  factory EthereumContract.newContact(
      {required ETHAddress address, required String name}) {
    return EthereumContract._(
        addressObject: address, created: DateTime.now(), name: name);
  }
  factory EthereumContract.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, CborTagsConst.ethereumContact);
      final String address = cbor.elementAt(0);
      final DateTime created = cbor.elementAt(1);
      final String name = cbor.elementAt(2);
      final ETHAddress ethAddress = ETHAddress(address);

      return EthereumContract._(
          addressObject: ethAddress, created: created, name: name);
    } catch (e) {
      throw WalletExceptionConst.invalidContactDetails;
    }
  }

  @override
  final ETHAddress addressObject;
  @override
  String get address => addressObject.address;
  @override
  final DateTime created;
  @override
  final String name;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([address, CborEpochIntValue(created), name]),
        CborTagsConst.ethereumContact);
  }

  @override
  List get variabels => [address, name];

  @override
  final String? type = null;
}
