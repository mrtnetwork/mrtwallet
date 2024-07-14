import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';

import 'package:mrt_wallet/wallet/models/contact/core/contract_core.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

class RippleContact with Equatable implements ContactCore<XRPAddress> {
  RippleContact._(
      {required this.addressObject,
      required this.address,
      required this.created,
      required this.name});
  factory RippleContact.newContact(
      {required XRPAddress address, required String name}) {
    return RippleContact._(
        addressObject: address,
        address: address.tag == null ? address.toString() : address.toAddress(),
        created: DateTime.now(),
        name: name);
  }
  factory RippleContact.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, CborTagsConst.rippleContact);
      final String address = cbor.elementAt(0);
      final int? tag = cbor.elementAt(1);
      final DateTime created = cbor.elementAt(2);
      final String name = cbor.elementAt(3);
      final rippleAddress = XRPAddress(address);
      if (rippleAddress.tag != tag) {
        throw WalletExceptionConst.invalidContactDetails;
      }
      return RippleContact._(
          addressObject: rippleAddress,
          address: address,
          created: created,
          name: name);
    } catch (e) {
      throw WalletExceptionConst.invalidContactDetails;
    }
  }

  @override
  final XRPAddress addressObject;
  @override
  final String address;
  @override
  final DateTime created;
  @override
  final String name;

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          address,
          addressObject.tag == null
              ? const CborNullValue()
              : CborIntValue(addressObject.tag!),
          CborEpochIntValue(created),
          name
        ]),
        CborTagsConst.rippleContact);
  }

  @override
  List get variabels => [address, name];

  @override
  late final String type =
      addressObject.tag != null ? "x_address" : "classic_address";
}
