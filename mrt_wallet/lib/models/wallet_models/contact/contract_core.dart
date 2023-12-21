import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/contact/bitcoin/bitcoin_contact.dart';
import 'package:mrt_wallet/models/wallet_models/contact/ripple/ripple_contact.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';

abstract class ContactCore<T> with CborSerializable {
  abstract final T addressObject;
  abstract final String address;
  abstract final String name;
  abstract final DateTime created;
  abstract final String type;
  static ContactCore fromCborBytesOrObject(AppNetworkImpl network,
      {List<int>? bytes, CborObject? obj}) {
    if (network is AppBitcoinNetwork) {
      return BitcoinContact.fromCborBytesOrObject(network,
          bytes: bytes, obj: obj);
    }
    return RippleContact.fromCborBytesOrObject(network as AppXRPNetwork,
        bytes: bytes, obj: obj);
  }

  static ContactCore newContact(
      {required AppNetworkImpl network,
      required dynamic address,
      required String name}) {
    if (network is AppBitcoinNetwork) {
      return BitcoinContact.newContact(
          address: address, network: network, name: name);
    }
    return RippleContact.newContact(
        address: address, network: network.toNetwork(), name: name);
  }
}
