import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';

import 'package:mrt_wallet/wallet/models/contact/core/contract_core.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:on_chain/on_chain.dart';

class AptosContact with Equatable implements ContactCore<AptosAddress> {
  AptosContact._(
      {required this.addressObject, required this.created, required this.name});
  factory AptosContact.newContact(
      {required AptosAddress address, required String name}) {
    return AptosContact._(
        addressObject: address, created: DateTime.now(), name: name);
  }
  factory AptosContact.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.cborTagValue(
          cborBytes: bytes, object: obj, tags: CborTagsConst.aptosContact);
      final String address = cbor.elementAs(0);
      final DateTime created = cbor.elementAs(1);
      final String name = cbor.elementAs(2);
      final AptosAddress networkAddress = AptosAddress(address);

      return AptosContact._(
          addressObject: networkAddress, created: created, name: name);
    } catch (e) {
      throw WalletExceptionConst.invalidContactDetails;
    }
  }

  @override
  final AptosAddress addressObject;
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
        CborTagsConst.aptosContact);
  }

  @override
  List get variabels => [address, name];

  @override
  final String? type = null;
}
