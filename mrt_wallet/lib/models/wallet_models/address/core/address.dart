import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/compare/compare.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/models/serializable/serializable.dart';
import 'package:mrt_wallet/models/wallet_models/nfts/core/nft_core.dart';
import 'package:mrt_wallet/models/wallet_models/token/core/core.dart';
import 'package:mrt_wallet/models/wallet_models/wallet_models.dart';
import 'package:mrt_wallet/provider/wallet/constant/constant.dart';

abstract class CryptoAccountAddress<N, T, X> with CborSerializable {
  abstract final CryptoCoins coin;
  abstract final NetworkAddressDetailsCore<N> address;
  abstract final AddressDerivationIndex keyIndex;
  abstract final List<TokenCore<T>> tokens;
  abstract final List<NFTCore> nfts;
  abstract final AppNetworkImpl network;
  abstract final String type;
  abstract final X networkAddress;
  abstract final String? accountName;
  void setAccountName(String? name);
  List<String> get signers;
  bool get multiSigAccount;
  String accountToString();
  void addNFT(NFTCore newNft);
  void removeNFT(NFTCore nft);
  void addToken(TokenCore<T> newToken);
  void removeToken(TokenCore<T> token);

  static CryptoAccountAddress fromCbor(CborObject cbor) {
    if (cbor is! CborTagValue) {
      throw WalletExceptionConst.invalidAccountDetails;
    }
    if (bytesEqual(
        cbor.tags, WalletModelCborTagsConst.bitcoinMultiSigAccount)) {
      return IBitcoinMultiSigAddress.fromCborBytesOrObject(obj: cbor);
    } else if (bytesEqual(cbor.tags, WalletModelCborTagsConst.bitcoinAccoint)) {
      return IBitcoinAddress.fromCborBytesOrObject(obj: cbor);
    } else if (bytesEqual(cbor.tags, WalletModelCborTagsConst.rippleAccount)) {
      return IXRPAddress.fromCborBytesOrObject(obj: cbor);
    } else if (bytesEqual(
        cbor.tags, WalletModelCborTagsConst.rippleMultisigAccount)) {
      return IXRPMultisigAddress.fromCborBytesOrObject(obj: cbor);
    }
    throw WalletExceptionConst.invalidAccountDetails;
  }
}

abstract class MultiSigCryptoAccountAddress {
  abstract final List<(String, AddressDerivationIndex)> keyDetails;
}
