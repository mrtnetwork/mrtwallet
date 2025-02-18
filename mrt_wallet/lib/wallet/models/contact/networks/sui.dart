import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';

import 'package:mrt_wallet/wallet/models/contact/core/contract_core.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:on_chain/on_chain.dart';

class SuiContact with Equatable implements ContactCore<SuiAddress> {
  SuiContact._(
      {required this.addressObject, required this.created, required this.name});
  factory SuiContact.newContact(
      {required SuiAddress address, required String name}) {
    return SuiContact._(
        addressObject: address, created: DateTime.now(), name: name);
  }
  factory SuiContact.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.cborTagValue(
          cborBytes: bytes, object: obj, tags: CborTagsConst.suiContact);
      final String address = cbor.elementAs(0);
      final DateTime created = cbor.elementAs(1);
      final String name = cbor.elementAs(2);
      final SuiAddress networkAddress = SuiAddress(address);

      return SuiContact._(
          addressObject: networkAddress, created: created, name: name);
    } catch (e) {
      throw WalletExceptionConst.invalidContactDetails;
    }
  }

  @override
  final SuiAddress addressObject;
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
        CborTagsConst.suiContact);
  }

  @override
  List get variabels => [address, name];

  @override
  final String? type = null;
}
