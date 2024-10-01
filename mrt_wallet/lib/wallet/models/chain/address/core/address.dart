import 'package:blockchain_utils/bip/bip/bip.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/live_listener/live.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/balance/integer/integer.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/networks.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/core/core.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/nfts/nfts.dart';
import 'package:mrt_wallet/wallet/models/token/core/core.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:mrt_wallet/crypto/worker.dart';

typedef NETWORKCHAINACCOUNT<NETWORKADDRESS>
    = ChainAccount<NETWORKADDRESS, TokenCore, NFTCore>;
typedef NFTCHAINACCOUNT<NFT extends NFTCore>
    = ChainAccount<dynamic, TokenCore, NFT>;

abstract class ChainAccount<X, T extends TokenCore, N extends NFTCore>
    extends CryptoAddress<X> implements CryptoAddressToken<T, N> {}

abstract class CryptoAddressToken<T extends TokenCore, N extends NFTCore> {
  abstract final List<T> tokens;
  abstract final List<N> nfts;
  void addToken(T newToken);
  void removeToken(T token);
  void updateToken(T token, Token updatedToken);
  void addNFT(N newNft);
  void removeNFT(N nft);
  void setAccountName(String? name);
}

abstract class CryptoAddress<X> with CborSerializable {
  abstract final CryptoCoins coin;
  abstract final AccountBalance address;
  abstract final AddressDerivationIndex keyIndex;
  abstract final int network;
  abstract final String? type;
  abstract final X networkAddress;
  abstract final String? accountName;

  /// its only for checking duplicate account
  abstract final String orginalAddress;

  NewAccountParams toAccountParams();
  List<AddressDerivationIndex> accessKeysIndexes() {
    if (multiSigAccount) {
      throw WalletExceptionConst.featureUnavailableForMultiSignature;
    }
    return signerKeyIndexes();
  }

  List<AddressDerivationIndex> signerKeyIndexes() {
    if (multiSigAccount) {
      throw WalletExceptionConst.featureUnavailableForMultiSignature;
    }
    return [keyIndex];
  }

  bool isEqual(ChainAccount other);

  bool get multiSigAccount;
  String accountToString();

  static ChainAccount fromCbor(WalletNetwork network, CborObject cbor) {
    if (cbor is! CborTagValue) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    ChainAccount address;
    switch (network.type) {
      case NetworkType.bitcoinAndForked:
        address = IBitcoinAddress.fromCborBytesOrObject(network, obj: cbor);
        break;
      case NetworkType.bitcoinCash:
        address = IBitcoinCashAddress.fromCborBytesOrObject(network, obj: cbor);
        break;
      case NetworkType.xrpl:
        address = IXRPAddress.fromCborBytesOrObject(network, obj: cbor);
        break;
      case NetworkType.ethereum:
        address = IEthAddress.fromCborBytesOrObject(network, obj: cbor);
        break;
      case NetworkType.tron:
        address = ITronAddress.fromCborBytesOrObject(network, obj: cbor);
        break;
      case NetworkType.solana:
        address = ISolanaAddress.fromCborBytesOrObject(network, obj: cbor);
        break;
      case NetworkType.cardano:
        address = ICardanoAddress.fromCborBytesOrObject(network, obj: cbor);
        break;
      case NetworkType.cosmos:
        address = ICosmosAddress.fromCborBytesOrObject(network, obj: cbor);
        break;
      case NetworkType.ton:
        address = ITonAddress.fromCborBytesOrObject(network, obj: cbor);
        break;
      case NetworkType.stellar:
        address = IStellarAddress.fromCborBytesOrObject(network, obj: cbor);
        break;
      case NetworkType.polkadot:
      case NetworkType.kusama:
        address = ISubstrateAddress.fromCborBytesOrObject(network, obj: cbor);
        break;
      default:
        throw WalletExceptionConst.networkDoesNotExist;
    }
    return address;
  }

  T cast<T extends ChainAccount>() {
    if (this is T) return this as T;
    throw WalletExceptionConst.invalidArgruments("$runtimeType", "$T");
  }
}

abstract class MultiSigCryptoAccountAddress {
  abstract final List<(String, Bip32AddressIndex)> keyDetails;
}

class AccountBalance {
  AccountBalance(
      {required this.address,
      required IntegerBalance balance,
      DateTime? updated})
      : _updated = updated ?? DateTime.now(),
        balance = Live<IntegerBalance>(balance);

  factory AccountBalance.fromCborBytesOrObject(int currencyDecimal,
      {List<int>? bytes, CborObject? obj}) {
    final CborListValue cbor =
        CborSerializable.decodeCborTags(bytes, obj, CborTagsConst.address);
    final String address = cbor.elementAt(0);
    final BigInt balance = cbor.elementAt(1);
    final DateTime updated = cbor.elementAt(2);
    return AccountBalance(
        address: address,
        balance: IntegerBalance(balance, currencyDecimal),
        updated: updated);
  }

  final String address;
  String get toAddress {
    return address;
  }

  final Live<IntegerBalance> balance;

  String get viewBalance => balance.toString();
  BigInt get currencyBalance => balance.value.balance;

  DateTime _updated;

  DateTime get updated => _updated;

  void updateBalance([BigInt? updateBalance]) {
    balance.value.updateBalance(updateBalance);
    if (updateBalance != null) {
      balance.notify();
    }
  }

  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength(
            [address, balance.value.balance, CborEpochIntValue(updated)]),
        CborTagsConst.address);
  }
}
