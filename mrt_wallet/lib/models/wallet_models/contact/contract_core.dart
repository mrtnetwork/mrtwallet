import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'bitcoin/bitcoin_contact.dart';
import 'cardano/cardano.dart';
import 'cosmos/cosmos.dart';
import 'ethereum/ethereum.dart';
import 'ripple/ripple_contact.dart';
import 'solana/solana.dart';
import 'ton/ton.dart';
import 'tron/tron.dart';

abstract class ContactCore<T> with CborSerializable {
  abstract final T addressObject;
  abstract final String address;
  abstract final String name;
  abstract final DateTime created;
  abstract final String? type;
  static ContactCore fromCborBytesOrObject(AppNetworkImpl network,
      {List<int>? bytes, CborObject? obj}) {
    if (network is AppBitcoinNetwork) {
      return BitcoinContact.fromCborBytesOrObject(network,
          bytes: bytes, obj: obj);
    } else if (network is APPEVMNetwork) {
      return EthereumContract.fromCborBytesOrObject(bytes: bytes, obj: obj);
    } else if (network is APPTVMNetwork) {
      return TronContact.fromCborBytesOrObject(bytes: bytes, obj: obj);
    } else if (network is APPSolanaNetwork) {
      return SolanaContact.fromCborBytesOrObject(bytes: bytes, obj: obj);
    } else if (network is APPCardanoNetwork) {
      return CardanoContact.fromCborBytesOrObject(bytes: bytes, obj: obj);
    } else if (network is APPCosmosNetwork) {
      return CosmosContact.fromCborBytesOrObject(bytes: bytes, obj: obj);
    } else if (network is APPTonNetwork) {
      return TonContact.fromCborBytesOrObject(bytes: bytes, obj: obj);
    }
    return RippleContact.fromCborBytesOrObject(network as AppXRPNetwork,
        bytes: bytes, obj: obj);
  }

  static ContactCore newContact<T>(
      {required AppNetworkImpl network,
      required dynamic address,
      required String name}) {
    switch (network.type) {
      case NetworkType.bitcoinAndForked:
        return BitcoinContact.newContact(
            address: address, network: network.toNetwork(), name: name);
      case NetworkType.ethereum:
        return EthereumContract.newContact(address: address, name: name);
      case NetworkType.tron:
        return TronContact.newContact(address: address, name: name);
      case NetworkType.cardano:
        return CardanoContact.newContact(address: address, name: name);
      case NetworkType.cosmos:
        return CosmosContact.newContact(address: address, name: name);
      case NetworkType.solana:
        return SolanaContact.newContact(address: address, name: name);
      case NetworkType.ton:
        return TonContact.newContact(address: address, name: name);
      default:
        return RippleContact.newContact(
            address: address, network: network.toNetwork(), name: name);
    }
  }
}
