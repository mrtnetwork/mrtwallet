import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/compare/compare.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/address/network_address/cardano/cardano.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

abstract class CryptoAccountAddress<N, T, X> with CborSerializable {
  abstract final CryptoCoins coin;
  abstract final NetworkAddressDetailsCore<N> address;
  abstract final AddressDerivationIndex keyIndex;
  abstract final List<TokenCore<T>> tokens;
  abstract final List<NFTCore> nfts;
  abstract final int network;
  abstract final String? type;
  abstract final X networkAddress;
  abstract final String? accountName;
  abstract final String orginalAddress;
  void setAccountName(String? name);
  List<String> get signers;
  bool get multiSigAccount;
  String accountToString();
  void addNFT(NFTCore newNft);
  void removeNFT(NFTCore nft);
  void addToken(TokenCore<T> newToken);
  void removeToken(TokenCore<T> token);
  void updateToken(TokenCore<T> token, Token updatedToken);

  static CryptoAccountAddress fromCbor(
      AppNetworkImpl network, CborObject cbor) {
    if (cbor is! CborTagValue) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    if (bytesEqual(
        cbor.tags, WalletModelCborTagsConst.bitcoinMultiSigAccount)) {
      return IBitcoinMultiSigAddress.fromCborBytesOrObject(network, obj: cbor);
    } else if (bytesEqual(cbor.tags, WalletModelCborTagsConst.bitcoinAccount)) {
      return IBitcoinAddress.fromCborBytesOrObject(network, obj: cbor);
    } else if (bytesEqual(
        cbor.tags, WalletModelCborTagsConst.bitcoinCashAccount)) {
      return IBitcoinCashAddress.fromCborBytesOrObject(network, obj: cbor);
    } else if (bytesEqual(
        cbor.tags, WalletModelCborTagsConst.bitcoinCashMultiSigAccount)) {
      return IBitcoinCashMultiSigAddress.fromCborBytesOrObject(network,
          obj: cbor);
    } else if (bytesEqual(cbor.tags, WalletModelCborTagsConst.rippleAccount)) {
      return IXRPAddress.fromCborBytesOrObject(network, obj: cbor);
    } else if (bytesEqual(
        cbor.tags, WalletModelCborTagsConst.rippleMultisigAccount)) {
      return IXRPMultisigAddress.fromCborBytesOrObject(network, obj: cbor);
    } else if (bytesEqual(cbor.tags, WalletModelCborTagsConst.ethAccount)) {
      return IEthAddress.fromCborBytesOrObject(network, obj: cbor);
    } else if (bytesEqual(cbor.tags, WalletModelCborTagsConst.tronAccount)) {
      return ITronAddress.fromCborBytesOrObject(network, obj: cbor);
    } else if (bytesEqual(
        cbor.tags, WalletModelCborTagsConst.tronMultisigAccount)) {
      return ITronMultisigAddress.fromCborBytesOrObject(network, obj: cbor);
    } else if (bytesEqual(cbor.tags, WalletModelCborTagsConst.solAccount)) {
      return ISolanaAddress.fromCborBytesOrObject(network, obj: cbor);
    } else if (bytesEqual(cbor.tags, WalletModelCborTagsConst.cardanoAccount)) {
      return ICardanoAddress.fromCborBytesOrObject(network, obj: cbor);
    } else if (bytesEqual(cbor.tags, WalletModelCborTagsConst.cosmosAccount)) {
      return ICosmosAddress.fromCborBytesOrObject(network, obj: cbor);
    }
    throw WalletExceptionConst.invalidAccountDetails;
  }
}

abstract class MultiSigCryptoAccountAddress {
  abstract final List<(String, AddressDerivationIndex)> keyDetails;
}
