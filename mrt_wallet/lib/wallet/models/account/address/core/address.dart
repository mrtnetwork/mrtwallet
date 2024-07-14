import 'package:blockchain_utils/bip/bip/bip.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/serialization/serialization.dart';
import 'package:mrt_wallet/wallet/models/account/address/balance/balance.dart';
import 'package:mrt_wallet/wallet/models/account/address/networks/networks.dart';
import 'package:mrt_wallet/wallet/models/account/address/new/core/core.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/wallet/models/nfts/nfts.dart';
import 'package:mrt_wallet/wallet/models/token/core/core.dart';
import 'package:mrt_wallet/wallet/models/token/token/token.dart';
import 'package:mrt_wallet/wroker/worker.dart';

abstract class CryptoAddress<T, X> with CborSerializable {
  abstract final CryptoCoins coin;
  abstract final AddressBalanceCore<BigInt> address;
  abstract final AddressDerivationIndex keyIndex;
  abstract final List<TokenCore<T>> tokens;
  abstract final List<NFTCore> nfts;
  abstract final int network;
  abstract final String? type;
  abstract final X networkAddress;
  abstract final String? accountName;
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

  /// its only for checking duplicate account
  abstract final String orginalAddress;

  ///
  bool isEqual(CryptoAddress<T, X> other);

  void setAccountName(String? name);
  bool get multiSigAccount;
  String accountToString();
  void addNFT(NFTCore newNft);
  void removeNFT(NFTCore nft);
  void addToken(TokenCore<T> newToken);
  void removeToken(TokenCore<T> token);
  void updateToken(TokenCore<T> token, Token updatedToken);

  static CryptoAddress<T, X> fromCbor<T, X>(
      WalletNetwork network, CborObject cbor) {
    if (cbor is! CborTagValue) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    CryptoAddress address;
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
      case NetworkType.polkadot:
      case NetworkType.kusama:
        address = ISubstrateAddress.fromCborBytesOrObject(network, obj: cbor);
        break;
      default:
        throw UnimplementedError("Network does not exists. ");
    }
    if (address is! CryptoAddress<T, X>) {
      throw WalletExceptionConst.invalidArgruments(
          "${CryptoAddress<T, X>}", "${address.runtimeType}");
    }
    return address;
  }
}

abstract class MultiSigCryptoAccountAddress {
  abstract final List<(String, Bip32AddressIndex)> keyDetails;
}
