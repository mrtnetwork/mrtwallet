import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:cosmos_sdk/cosmos_sdk.dart';
import 'package:mrt_wallet/app/error/exception/wallet_ex.dart';
import 'package:mrt_wallet/app/utils/method/utiils.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:mrt_wallet/crypto/models/networks.dart';
import 'package:on_chain/on_chain.dart';
import 'package:polkadot_dart/polkadot_dart.dart';
import 'package:stellar_dart/stellar_dart.dart';
import 'package:ton_dart/ton_dart.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

class BlockchainAddressUtils {
  static XRPAddress toRippleAddress(String address, WalletXRPNetwork network) {
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

  static BitcoinBaseAddress toBitcoinAddress(
      String address, BasedUtxoNetwork network,
      {BitcoinAddressType? p2shAddressType}) {
    BitcoinBaseAddress addr;
    try {
      if (network is BitcoinCashNetwork) {
        addr = BitcoinCashAddress(address, network: network).baseAddress;
      } else if (network is BitcoinNetwork) {
        addr = BitcoinAddress(address, network: network).baseAddress;
      } else if (network is DogecoinNetwork) {
        addr = DogeAddress(address, network: network).baseAddress;
      } else if (network is DashNetwork) {
        addr = DashAddress(address, network: network).baseAddress;
      } else if (network is LitecoinNetwork) {
        addr = LitecoinAddress(address, network: network).baseAddress;
      } else if (network is PepeNetwork) {
        addr = PepeAddress(address, network: network).baseAddress;
      } else {
        throw UnimplementedError();
      }
      if (addr.type.isP2sh && p2shAddressType != null) {
        if (addr.type != p2shAddressType) {
          addr = P2shAddress.fromHash160(
              addrHash: addr.addressProgram,
              type: p2shAddressType.isP2sh
                  ? p2shAddressType as P2shAddressType
                  : P2shAddressType.p2pkInP2sh);
        }
      }
      return addr;
    } catch (e) {
      throw ArgumentError("invalid ${network.conf.coinName} address");
    }
  }

  static BitcoinBaseAddress publicKeyToBitcoinAddress(
      List<int> publicKey, CryptoCoins coin, BitcoinAddressType addressType) {
    final bitcoinPublicKey = ECPublic.fromBytes(publicKey);
    BitcoinBaseAddress address;
    switch (coin.proposal) {
      case BipProposal.bip44:
        address = bitcoinPublicKey.toAddress();
        if (addressType == P2pkhAddressType.p2pkhwt) {
          address = P2pkhAddress.fromHash160(
              addrHash: address.addressProgram, type: P2pkhAddressType.p2pkhwt);
        }
        break;
      case BipProposal.bip49:
        switch (addressType) {
          case P2shAddressType.p2wshInP2sh:
            address = bitcoinPublicKey.toP2wshInP2sh();
            break;
          case P2shAddressType.p2wpkhInP2sh:
            address = bitcoinPublicKey.toP2wpkhInP2sh();
            break;
          case P2shAddressType.p2pkhInP2sh:
          case P2shAddressType.p2pkhInP2sh32:
          case P2shAddressType.p2pkhInP2shwt:
          case P2shAddressType.p2pkhInP2sh32wt:
            address = bitcoinPublicKey.toP2pkhInP2sh(
                useBCHP2sh32: addressType == P2shAddressType.p2pkhInP2sh32 ||
                    addressType == P2shAddressType.p2pkhInP2sh32wt);
            if (addressType == P2shAddressType.p2pkhInP2shwt ||
                addressType == P2shAddressType.p2pkhInP2sh32wt) {
              address = P2shAddress.fromHash160(
                  addrHash: address.addressProgram,
                  type: addressType as P2shAddressType);
            }
            break;
          case P2shAddressType.p2pkInP2sh:
          case P2shAddressType.p2pkInP2sh32:
          case P2shAddressType.p2pkInP2shwt:
          case P2shAddressType.p2pkInP2sh32wt:
            address = bitcoinPublicKey.toP2pkInP2sh(
                useBCHP2sh32: addressType == P2shAddressType.p2pkInP2sh32 ||
                    addressType == P2shAddressType.p2pkInP2sh32wt);
            if (addressType == P2shAddressType.p2pkInP2shwt ||
                addressType == P2shAddressType.p2pkInP2sh32wt) {
              address = P2shAddress.fromHash160(
                  addrHash: address.addressProgram,
                  type: addressType as P2shAddressType);
            }
            break;
          default:
            throw WalletExceptionConst.invalidBitcoinAddressType;
        }
        break;
      case BipProposal.bip84:
        if (addressType == SegwitAddresType.p2wsh) {
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

  static BitcoinBaseAddress toBitcoinAddressFromType(
      {required String bitcoinAddress,
      required BitcoinAddressType addressType,
      required WalletBitcoinNetwork network}) {
    BitcoinBaseAddress address;
    final bitcoinNetwork = network.coinParam.transacationNetwork;
    if (addressType.isP2sh) {
      return P2shAddress.fromAddress(
          address: bitcoinAddress,
          network: bitcoinNetwork,
          type: addressType as P2shAddressType);
    }
    switch (addressType) {
      case P2pkhAddressType.p2pkh:
      case P2pkhAddressType.p2pkhwt:
        address = P2pkhAddress.fromAddress(
            address: bitcoinAddress, network: bitcoinNetwork);
        break;
      case PubKeyAddressType.p2pk:
        final bitcoinPublicKey = ECPublic.fromHex(bitcoinAddress);
        address = P2pkAddress(publicKey: bitcoinPublicKey.toHex());
      case SegwitAddresType.p2wpkh:
        address = P2wpkhAddress.fromAddress(
            address: bitcoinAddress, network: bitcoinNetwork);
        break;
      case SegwitAddresType.p2tr:
        address = P2trAddress.fromAddress(
            address: bitcoinAddress, network: bitcoinNetwork);
        break;
      case SegwitAddresType.p2wsh:
        address = P2wshAddress.fromAddress(
            address: bitcoinAddress, network: bitcoinNetwork);
        break;
      default:
        throw UnimplementedError("invalid address types");
    }
    return address;
  }

  static ETHAddress? validatorEthereumAccount(String address) {
    return MethodUtils.nullOnException(() {
      return ETHAddress(address);
    });
  }

  static TronAddress? validatorTronAccount(String address) {
    return MethodUtils.nullOnException(() {
      return TronAddress(address);
    });
  }

  static SolAddress? validatorSolAccount(String address) {
    return MethodUtils.nullOnException(() {
      return SolAddress(address);
    });
  }

  static ADAAddress? validatorCardanoAddress(
      String address, WalletCardanoNetwork network) {
    return MethodUtils.nullOnException(() {
      return ADAAddress.fromAddress(address, network: network.toCardanoNetwork);
    });
  }

  static CosmosBaseAddress? validateCosmosAddress(
      String address, WalletCosmosNetwork network) {
    return MethodUtils.nullOnException(() {
      return CosmosBaseAddress(address, forceHrp: network.coinParam.hrp);
    });
  }

  static TonAddress? validateTonAddress(
      String address, WalletTonNetwork network) {
    return MethodUtils.nullOnException(() {
      return TonAddress(address, forceWorkchain: network.coinParam.workchain);
    });
  }

  static StellarAddress? validateStallerAddress(
      String address, WalletStellarNetwork network) {
    return MethodUtils.nullOnException(() {
      return StellarAddress.fromBase32Addr(address);
    });
  }

  static BitcoinBaseAddress? validateBitcoinNetwork(
      String address, WalletBitcoinNetwork network) {
    return MethodUtils.nullOnException(() {
      return toBitcoinAddress(address, network.coinParam.transacationNetwork);
    });
  }

  static SubstrateAddress? validateSubstrateAddress(
      String address, WalletPolkadotNetwork network) {
    return MethodUtils.nullOnException(() {
      return SubstrateAddress(address,
          ss58Format: network.coinParam.ss58Format);
    });
  }

  static XRPAddress? validateXRPAddress(
      String address, WalletXRPNetwork network,
      {int? tag}) {
    return MethodUtils.nullOnException(() {
      return BlockchainAddressUtils.toRippleAddress(address, network);
    });
  }

  static XRPAddress? validateXAddressTag(
      {required String? addr,
      required WalletXRPNetwork network,
      required int? tag}) {
    if (addr == null) return null;
    return MethodUtils.nullOnException(() {
      final address = BlockchainAddressUtils.toRippleAddress(addr, network);
      if (tag != null) {
        if (address.tag == tag) return address;
        if (address.tag != null && address.tag != tag) return null;
        return XRPAddress(address.toXAddress(
            tag: tag, isTestnet: !network.coinParam.mainnet));
      }
      return address;
    });
  }

  static Object? validateNetworkAddress(
      String? address, WalletNetwork network) {
    if (address == null) return null;
    switch (network.type) {
      case NetworkType.xrpl:
        return validateXRPAddress(address, network.toNetwork());
      case NetworkType.ethereum:
        return validatorEthereumAccount(address);
      case NetworkType.tron:
        return validatorTronAccount(address);
      case NetworkType.solana:
        return validatorSolAccount(address);
      case NetworkType.cardano:
        return validatorCardanoAddress(address, network.toNetwork());
      case NetworkType.cosmos:
        return validateCosmosAddress(address, network.toNetwork());
      case NetworkType.ton:
        return validateTonAddress(address, network.toNetwork());
      case NetworkType.stellar:
        return validateStallerAddress(address, network.toNetwork());
      case NetworkType.polkadot:
      case NetworkType.kusama:
        return validateSubstrateAddress(address, network.toNetwork());
      default:
        return validateBitcoinNetwork(address, network.toNetwork());
    }
  }

  static List<Bip32KeyIndex> praseBip32Path(String path) {
    return Bip32PathParser.parse(path).elems;
  }

  static List<SubstratePathElem> praseSubstratePath(String path) {
    return SubstratePathParser.parse(path).elems;
  }
}
