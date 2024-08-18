import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/serialization/cbor/cbor.dart';
import 'package:mrt_wallet/crypto/coins/coins.dart';
import 'package:mrt_wallet/crypto/derivation/derivation.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/xrp/addresses/multisig.dart';
import 'package:mrt_wallet/wallet/models/chain/address/networks/xrp/addresses/xrp.dart';
import 'package:mrt_wallet/wallet/models/chain/address/creation_params/core/core.dart';
import 'package:mrt_wallet/wallet/models/network/network.dart';
import 'package:xrpl_dart/xrpl_dart.dart';

class RippleNewAddressParams implements NewAccountParams<XRPAddress> {
  @override
  bool get isMultiSig => false;

  EllipticCurveTypes get curve => coin.conf.type;
  @override
  final AddressDerivationIndex deriveIndex;

  final int? tag;
  @override
  final CryptoCoins coin;
  const RippleNewAddressParams(
      {required this.deriveIndex, required this.coin, this.tag});

  factory RippleNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.rippleNewAddressParams.tag);
    return RippleNewAddressParams(
      deriveIndex: AddressDerivationIndex.fromCborBytesOrObject(
          obj: values.getCborTag(0)),
      tag: values.elementAt(1),
      coin: CustomCoins.getSerializationCoin(values.elementAt(2)),
    );
  }
  @override
  IXRPAddress toAccount(WalletNetwork network, List<int> publicKey) {
    return IXRPAddress.newAccount(
        accountParams: this,
        publicKey: publicKey,
        network: network as WalletXRPNetwork);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([deriveIndex.toCbor(), tag, coin.toCbor()]),
        type.tag);
  }

  @override
  NewAccountParamsType get type => NewAccountParamsType.rippleNewAddressParams;
}

class RippleMultiSigNewAddressParams implements RippleNewAddressParams {
  @override
  bool get isMultiSig => true;

  final XRPAddress masterAddress;

  @override
  final AddressDerivationIndex deriveIndex = const MultiSigAddressIndex();

  final RippleMultiSignatureAddress multiSigAccount;

  @override
  final int? tag;
  @override
  EllipticCurveTypes get curve => throw UnimplementedError();

  @override
  final CryptoCoins coin;

  const RippleMultiSigNewAddressParams(
      {required this.multiSigAccount,
      required this.masterAddress,
      required this.coin,
      this.tag});
  factory RippleMultiSigNewAddressParams.deserialize(
      {List<int>? bytes, CborObject? object, String? hex}) {
    final CborListValue values = CborSerializable.cborTagValue(
        cborBytes: bytes,
        object: object,
        hex: hex,
        tags: NewAccountParamsType.rippleMultiSigNewAddressParams.tag);
    return RippleMultiSigNewAddressParams(
      masterAddress: XRPAddress(values.elementAt(0)),
      multiSigAccount: RippleMultiSignatureAddress.fromCborBytesOrObject(
          obj: values.getCborTag(1)),
      tag: values.elementAt(1),
      coin: CustomCoins.getSerializationCoin(values.elementAt(2)),
    );
  }

  @override
  IXRPMultisigAddress toAccount(WalletNetwork network, List<int> publicKey) {
    return IXRPMultisigAddress.newAccount(
        accountParams: this, network: network as WalletXRPNetwork);
  }

  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          masterAddress.address,
          multiSigAccount.toCbor(),
          tag,
          coin.toCbor()
        ]),
        type.tag);
  }

  @override
  NewAccountParamsType get type =>
      NewAccountParamsType.rippleMultiSigNewAddressParams;
}
