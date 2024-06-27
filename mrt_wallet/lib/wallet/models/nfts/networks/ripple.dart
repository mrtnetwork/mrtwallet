import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:mrt_wallet/app/core.dart';

import 'package:mrt_wallet/wallet/models/nfts/core/core.dart';
import 'package:mrt_wallet/wallet/constant/tags/constant.dart';

class RippleNFToken with Equatable implements NFTCore {
  factory RippleNFToken.fromCborBytesOrObject(
      {List<int>? bytes, CborObject? obj}) {
    try {
      final CborListValue cbor =
          CborSerializable.decodeCborTags(bytes, obj, CborTagsConst.rippleNfts);
      final flags = cbor.getInt(0)!;
      final nftokenId = cbor.getString(1)!;
      final nftokenTaxon = cbor.getInt(2)!;
      final issuer = cbor.getString(3)!;
      final serial = cbor.getInt(4)!;
      final uri = cbor.getString(5);

      return RippleNFToken(
          flags: flags,
          issuer: issuer,
          nftokenId: nftokenId,
          nftokenTaxon: nftokenTaxon,
          serial: serial,
          uri: uri);
    } on WalletException {
      rethrow;
    } catch (e) {
      throw WalletExceptionConst.invalidNftInfromaation;
    }
  }
  const RippleNFToken({
    required this.flags,
    required this.nftokenId,
    required this.issuer,
    required this.nftokenTaxon,
    required this.serial,
    required this.uri,
  });
  @override
  CborTagValue toCbor() {
    return CborTagValue(
        CborListValue.fixedLength([
          flags,
          nftokenId,
          nftokenTaxon,
          issuer,
          serial,
          uri ?? const CborNullValue()
        ]),
        CborTagsConst.rippleNfts);
  }

  @override
  final String? uri;
  final String nftokenId;
  final int flags;
  final String issuer;
  final int serial;
  final int nftokenTaxon;

  @override
  List get variabels => [uri, nftokenId, flags, issuer, serial, nftokenTaxon];
}
