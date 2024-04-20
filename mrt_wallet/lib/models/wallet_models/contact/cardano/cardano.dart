import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/contact/contract_core.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';
import 'package:on_chain/ada/ada.dart';

class CardanoContact with Equatable implements ContactCore<ADAAddress> {
  CardanoContact._(
      {required this.addressObject, required this.created, required this.name});
  factory CardanoContact.newContact(
      {required ADAAddress address, required String name}) {
    return CardanoContact._(
        addressObject: address, created: DateTime.now(), name: name);
  }
  factory CardanoContact.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor = CborSerializable.decodeCborTags(
          bytes, obj, WalletModelCborTagsConst.cardanoContct);
      final String address = cbor.elementAt(0);
      final DateTime created = cbor.elementAt(1);
      final String name = cbor.elementAt(2);
      final ADAAddress cardanoAddr = ADAAddress.fromAddress(address);

      return CardanoContact._(
          addressObject: cardanoAddr, created: created, name: name);
    } catch (e) {
      throw WalletExceptionConst.invalidContactDetails;
    }
  }

  @override
  final ADAAddress addressObject;
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
        WalletModelCborTagsConst.cardanoContct);
  }

  @override
  List get variabels => [address, name];

  @override
  String? get type => addressObject.addressType.name;
}
