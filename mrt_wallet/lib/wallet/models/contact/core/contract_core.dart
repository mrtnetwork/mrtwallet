import 'package:blockchain_utils/cbor/core/cbor.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/models/contact/networks/bitcoin.dart';
import 'package:mrt_wallet/wallet/models/contact/networks/cardano.dart';
import 'package:mrt_wallet/wallet/models/contact/networks/cosmos.dart';
import 'package:mrt_wallet/wallet/models/contact/networks/ethereum.dart';
import 'package:mrt_wallet/wallet/models/contact/networks/stellar.dart';
import 'package:mrt_wallet/wallet/models/contact/networks/substrate.dart';
import 'package:mrt_wallet/wallet/models/contact/networks/xrp.dart';
import 'package:mrt_wallet/wallet/models/contact/networks/solana.dart';
import 'package:mrt_wallet/wallet/models/contact/networks/ton.dart';
import 'package:mrt_wallet/wallet/models/contact/networks/tron.dart';
import 'package:mrt_wallet/wallet/models/network/core/network.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';

abstract class ContactCore<T> with CborSerializable {
  abstract final T addressObject;
  abstract final String address;
  abstract final String name;
  abstract final DateTime created;
  abstract final String? type;
  static ContactCore<T> fromCborBytesOrObject<T>(WalletNetwork network,
      {List<int>? bytes, CborObject? obj}) {
    ContactCore contact;
    switch (network.type) {
      case NetworkType.bitcoinAndForked:
      case NetworkType.bitcoinCash:
        contact = BitcoinContact.fromCborBytesOrObject(
            network as WalletBitcoinNetwork,
            bytes: bytes,
            obj: obj);
        break;
      case NetworkType.ethereum:
        contact =
            EthereumContract.fromCborBytesOrObject(bytes: bytes, obj: obj);
        break;
      case NetworkType.tron:
        contact = TronContact.fromCborBytesOrObject(bytes: bytes, obj: obj);
        break;
      case NetworkType.solana:
        contact = SolanaContact.fromCborBytesOrObject(bytes: bytes, obj: obj);
        break;
      case NetworkType.cardano:
        contact = CardanoContact.fromCborBytesOrObject(bytes: bytes, obj: obj);
        break;
      case NetworkType.cosmos:
        contact = CosmosContact.fromCborBytesOrObject(bytes: bytes, obj: obj);
        break;
      case NetworkType.ton:
        contact = TonContact.fromCborBytesOrObject(bytes: bytes, obj: obj);
        break;
      case NetworkType.xrpl:
        contact = RippleContact.fromCborBytesOrObject(bytes: bytes, obj: obj);
        break;
      case NetworkType.stellar:
        contact = StellarContact.fromCborBytesOrObject(bytes: bytes, obj: obj);
        break;
      case NetworkType.polkadot:
      case NetworkType.kusama:
        contact =
            SubstrateContact.fromCborBytesOrObject(bytes: bytes, obj: obj);
        break;
      default:
        throw WalletExceptionConst.networkDoesNotExist;
    }
    if (contact is! ContactCore<T>) {
      throw WalletExceptionConst.invalidArgruments(
          "${ContactCore<T>}", contact.runtimeType.toString());
    }
    return contact;
  }

  static ContactCore<T> newContact<T>(
      {required WalletNetwork network,
      required dynamic address,
      required String name}) {
    ContactCore contact;
    switch (network.type) {
      case NetworkType.bitcoinAndForked:
      case NetworkType.bitcoinCash:
        contact = BitcoinContact.newContact(
            address: address, network: network.toNetwork(), name: name);
      case NetworkType.ethereum:
        contact = EthereumContract.newContact(address: address, name: name);
      case NetworkType.tron:
        contact = TronContact.newContact(address: address, name: name);
      case NetworkType.cardano:
        contact = CardanoContact.newContact(address: address, name: name);
      case NetworkType.cosmos:
        contact = CosmosContact.newContact(address: address, name: name);
      case NetworkType.solana:
        contact = SolanaContact.newContact(address: address, name: name);
      case NetworkType.ton:
        contact = TonContact.newContact(address: address, name: name);
      case NetworkType.polkadot:
      case NetworkType.kusama:
        contact = SubstrateContact.newContact(address: address, name: name);
      case NetworkType.xrpl:
        contact = RippleContact.newContact(address: address, name: name);
      case NetworkType.stellar:
        contact = StellarContact.newContact(address: address, name: name);
      default:
        throw WalletExceptionConst.networkDoesNotExist;
    }
    if (contact is! ContactCore<T>) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    return contact;
  }
}
