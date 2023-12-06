import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';

class BlockchainAddressUtils {
  static BitcoinAddress toBitcoinAddress(
      String address, BasedUtxoNetwork network) {
    final length = address.length;
    try {
      switch (length) {
        case 34:
          try {
            return P2pkhAddress.fromAddress(address: address, network: network);
          } catch (e) {
            return P2shAddress.fromAddress(address: address, network: network);
          }
        case 35:
          return P2shAddress.fromAddress(address: address, network: network);
        case 42:
        case 43:
          return P2wpkhAddress.fromAddress(address: address, network: network);
        case 64:
        case 63:
        case 62:
          try {
            return P2wshAddress.fromAddress(address: address, network: network);
          } catch (e) {
            return P2trAddress.fromAddress(address: address, network: network);
          }

        default:
          throw ArgumentError("invalid bitcoin address length");
      }
    } on ArgumentError {
      rethrow;
    } catch (e) {
      throw ArgumentError("invalid bitcoin address");
    }
  }

  static BitcoinAddress publicKeyToBitcoinAddress(
      List<int> publicKey, CryptoCoins coin, BitcoinAddressType addressType) {
    final bitcoinPublicKey = ECPublic.fromBytes(publicKey);
    BitcoinAddress address;

    switch (coin.proposal) {
      case BipProposal.bip44:
        address = bitcoinPublicKey.toAddress();
        break;
      case BipProposal.bip49:
        switch (addressType) {
          case BitcoinAddressType.p2wshInP2sh:
            address = bitcoinPublicKey.toP2wshInP2sh();
            break;
          case BitcoinAddressType.p2wpkhInP2sh:
            address = bitcoinPublicKey.toP2wpkhInP2sh();
            break;
          case BitcoinAddressType.p2pkhInP2sh:
            address = bitcoinPublicKey.toP2pkhInP2sh();
            break;
          default:
            address = bitcoinPublicKey.toP2pkInP2sh();
            break;
        }
        break;
      case BipProposal.bip84:
        if (addressType == BitcoinAddressType.p2wsh) {
          address = bitcoinPublicKey.toP2wshAddress();
        } else {
          address = bitcoinPublicKey.toSegwitAddress();
        }

        break;
      default:
        address = bitcoinPublicKey.toTaprootAddress();
        break;
    }
    if (address.type != addressType) {
      throw WalletExceptionConst.invalidBitcoinAddressType;
    }

    return address;
  }
}
