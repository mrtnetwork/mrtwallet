import 'package:blockchain_utils/bip/bip/bip.dart';
import 'package:blockchain_utils/cbor/cbor.dart';
import 'package:blockchain_utils/utils/binary/utils.dart';
import 'package:mrt_wallet/app/core.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';
import 'package:mrt_wallet/wallet/models/chain/address/core/address.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/networks/bch.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/networks/bitcoin.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/networks/cardano.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/networks/cosmos.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/networks/ethereum.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/networks/ripple.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/networks/solana.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/networks/stellar.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/networks/substrate.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/networks/ton.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/networks/tron.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';

enum NewAccountParamsType {
  bitcoinCashNewAddressParams(CborTagsConst.bitcoinCashNewAddressParams),
  bitcoinCashMultiSigNewAddressParams(
      CborTagsConst.bitcoinCashMultiSigNewAddressParams),
  bitcoinNewAddressParams(CborTagsConst.bitcoinNewAddressParams),
  bitcoinMultiSigNewAddressParams(
      CborTagsConst.bitcoinMultiSigNewAddressParams),
  cardanoNewAddressParams(CborTagsConst.cardanoNewAddressParams),
  cosmosNewAddressParams(CborTagsConst.cosmosNewAddressParams),
  ethereumNewAddressParamss(CborTagsConst.ethereumNewAddressParamss),
  solanaNewAddressParams(CborTagsConst.solanaNewAddressParams),
  substrateNewAddressParams(CborTagsConst.substrateNewAddressParams),
  tronNewAddressParams(CborTagsConst.tronNewAddressParams),
  tronMultisigNewAddressParams(CborTagsConst.tronMultisigNewAddressParams),
  tonNewAddressParams(CborTagsConst.tonNewAddressParams),
  rippleNewAddressParams(CborTagsConst.rippleNewAddressParams),
  rippleMultiSigNewAddressParams(CborTagsConst.rippleMultiSigNewAddressParams),
  stellarNewAddressParams(CborTagsConst.stellarNewAddressParams),
  stellarMultiSigNewAddressParams(
      CborTagsConst.stellarMultiSigNewAddressParams);

  final List<int> tag;
  const NewAccountParamsType(this.tag);
  static NewAccountParamsType fromTag(List<int>? tag) {
    return values.firstWhere((e) => BytesUtils.bytesEqual(e.tag, tag),
        orElse: () => throw WalletExceptionConst.dataVerificationFailed);
  }
}

abstract class NewAccountParams<NETWORKADDRESS> with CborSerializable {
  const NewAccountParams();
  abstract final CryptoCoins coin;
  abstract final AddressDerivationIndex deriveIndex;
  abstract final NewAccountParamsType type;
  bool get isMultiSig;
  NETWORKCHAINACCOUNT<NETWORKADDRESS> toAccount(
      WalletNetwork network, List<int> publicKey);

  factory NewAccountParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborTagValue decode =
        CborSerializable.decode(cborBytes: bytes, object: object, hex: hex);
    final type = NewAccountParamsType.fromTag(decode.tags);
    final NewAccountParams params;
    switch (type) {
      case NewAccountParamsType.bitcoinCashNewAddressParams:
        params = BitcoinCashNewAddressParams.deserialize(object: decode);
        break;
      case NewAccountParamsType.bitcoinCashMultiSigNewAddressParams:
        params =
            BitcoinCashMultiSigNewAddressParams.deserialize(object: decode);
        break;
      case NewAccountParamsType.bitcoinNewAddressParams:
        params = BitcoinNewAddressParams.deserialize(object: decode);
        break;
      case NewAccountParamsType.bitcoinMultiSigNewAddressParams:
        params = BitcoinMultiSigNewAddressParams.deserialize(object: decode);
        break;
      case NewAccountParamsType.cardanoNewAddressParams:
        params = CardanoNewAddressParams.deserialize(object: decode);
        break;
      case NewAccountParamsType.cosmosNewAddressParams:
        params = CosmosNewAddressParams.deserialize(object: decode);
        break;
      case NewAccountParamsType.ethereumNewAddressParamss:
        params = EthereumNewAddressParams.deserialize(object: decode);
        break;
      case NewAccountParamsType.solanaNewAddressParams:
        params = SolanaNewAddressParams.deserialize(object: decode);
        break;
      case NewAccountParamsType.substrateNewAddressParams:
        params = SubstrateNewAddressParams.deserialize(object: decode);
        break;
      case NewAccountParamsType.tronNewAddressParams:
        params = TronNewAddressParams.deserialize(object: decode);
        break;
      case NewAccountParamsType.tronMultisigNewAddressParams:
        params = TronMultisigNewAddressParams.deserialize(object: decode);
        break;
      case NewAccountParamsType.tonNewAddressParams:
        params = TonNewAddressParams.deserialize(object: decode);
        break;
      case NewAccountParamsType.rippleNewAddressParams:
        params = RippleNewAddressParams.deserialize(object: decode);
        break;
      case NewAccountParamsType.rippleMultiSigNewAddressParams:
        params = RippleMultiSigNewAddressParams.deserialize(object: decode);
        break;
      case NewAccountParamsType.stellarNewAddressParams:
        params = StellarNewAddressParams.deserialize(object: decode);
        break;
      case NewAccountParamsType.stellarMultiSigNewAddressParams:
        params = StellarMultiSigNewAddressParams.deserialize(object: decode);
        break;
      default:
        throw UnimplementedError("Network does not exists.");
    }
    if (params is! NewAccountParams<NETWORKADDRESS>) {
      throw WalletExceptionConst.dataVerificationFailed;
    }
    return params;
  }
}
