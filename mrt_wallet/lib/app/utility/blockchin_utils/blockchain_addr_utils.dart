import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/bip/bip/conf/bip_coins.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/models/wallet_models/network/network_models.dart';
import 'package:xrp_dart/xrp_dart.dart';

class BlockchainAddressUtils {
  static XRPAddress toRippleAddress(String address, AppXRPNetwork network) {
    try {
      if (XRPAddressUtils.isXAddress(address)) {
        return XRPAddress.fromXAddress(address,
            isTestnet: network.coins.first.conf.isTestnet);
      }
      return XRPAddress(address);
    } catch (e) {
      throw ArgumentError("invalid ${network.coinParam.token.name} address");
    }
  }

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
          throw ArgumentError();
      }
    } catch (e) {
      throw ArgumentError("invalid ${network.conf.coinName} address");
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

  static BitcoinAddress toBitcoinAddressFromType(
      {required String bitcoinAddress,
      required BitcoinAddressType addressType,
      required AppBitcoinNetwork network}) {
    BitcoinAddress address;
    final bitcoinNetwork = network.coinParam.transacationNetwork;
    switch (addressType) {
      case BitcoinAddressType.p2pkh:
        address = P2pkhAddress.fromAddress(
            address: bitcoinAddress, network: bitcoinNetwork);
        break;
      case BitcoinAddressType.p2pk:
        final bitcoinPublicKey = ECPublic.fromHex(bitcoinAddress);
        address = P2pkAddress(publicKey: bitcoinPublicKey.toHex());
      case BitcoinAddressType.p2wshInP2sh:
      case BitcoinAddressType.p2wpkhInP2sh:
      case BitcoinAddressType.p2pkhInP2sh:
      case BitcoinAddressType.p2pkInP2sh:
        address = P2shAddress.fromAddress(
            address: bitcoinAddress,
            network: bitcoinNetwork,
            type: addressType);
        break;
      case BitcoinAddressType.p2wpkh:
        address = P2wpkhAddress.fromAddress(
            address: bitcoinAddress, network: bitcoinNetwork);
        break;
      case BitcoinAddressType.p2tr:
        address = P2trAddress.fromAddress(
            address: bitcoinAddress, network: bitcoinNetwork);
        break;
      case BitcoinAddressType.p2wsh:
        address = P2wshAddress.fromAddress(
            address: bitcoinAddress, network: bitcoinNetwork);
        break;
      default:
        throw UnimplementedError("invalid address types");
    }
    return address;
  }
}
