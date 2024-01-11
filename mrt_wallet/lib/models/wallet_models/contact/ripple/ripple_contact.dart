import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/contact/contract_core.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';
import 'package:xrp_dart/xrp_dart.dart';

class RippleContact with Equatable implements ContactCore<XRPAddress> {
  RippleContact._(
      {required this.addressObject,
      required this.address,
      required this.created,
      required this.name});
  factory RippleContact.newContact(
      {required XRPAddress address,
      required AppXRPNetwork network,
      required String name}) {
    return RippleContact._(
        addressObject: address,
        address: address.tag == null
            ? address.toString()
            : address.toXAddress(
                tag: address.tag, forTestnet: !network.isMainnet),
        created: DateTime.now(),
        name: name);
  }
  factory RippleContact.fromCborBytesOrObject(AppXRPNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, WalletModelCborTagsConst.rippleContact);
      final String address = cbor.getIndex(0);
      final int? tag = cbor.getIndex(1);
      final DateTime created = cbor.getIndex(2);
      final String name = cbor.getIndex(3);
      final rippleAddress =
          BlockchainAddressUtils.toRippleAddress(address, network);
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
        WalletModelCborTagsConst.rippleContact);
  }

  @override
  List get variabels => [address, name];

  @override
  late final String type =
      addressObject.tag != null ? "x_address" : "classic_address";
}
